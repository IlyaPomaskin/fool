open NodeJs
open Utils
open Types
open Storage
open ServerUtils

let playersSocket = PlayersSocketMap.empty()

let createServer = server => {
  let wsServer = WsWebSocketServer.Make.make({
    backlog: 101,
    clientTracking: true,
    maxPayload: 104857600,
    path: "/ws",
    noServer: false,
    server: server, //: WsWebSocketServer.restartServer(),
    skipUTF8Validation: true,
  })

  let sendToWs = (ws, event): unit =>
    WsWebSocket.send(ws, Serializer.serializeServerMessage(event))->ignore

  let sendToPlayer = (playerId, event) => {
    playersSocket
    ->PlayersSocketMap.get(playerId)
    ->Result.map(socket => {
      sendToWs(
        socket,
        switch event {
        | ProgressCreated(game) => ProgressCreated(Game.maskForPlayer(game, playerId))
        | ProgressUpdated(game) => ProgressUpdated(Game.maskForPlayer(game, playerId))
        | _ => event
        },
      )
    })
    ->(result =>
      switch result {
      | Ok(_) => Log.info(["[server]", `sent to ${playerId}:`, Log.serverMsgToString(event)])
      | Error(err) => Log.error(["[server]", `Unable to send to player ${playerId}:`, err])
      })
    ->ignore
  }

  let broadcastToPlayers = (players, event) =>
    players->List.forEach(player => sendToPlayer(player.id, event))

  wsServer
  ->WsWebSocketServer.on(WsWebSocketServer.ServerEvents.connection, @this (_, ws, req) => {
    let sessionId =
      getUrl(req, "ws")->ServerUtils.getSearchParams->ServerUtils.getParam("sessionId")
    Js.log(`/ws login ${sessionId->Option.getWithDefault("No sessionId")}`)
    let player = sessionId->Utils.toResult("No sessionId")->Result.flatMap(GameInstance.loginPlayer)

    switch (sessionId, player) {
    | (Some(""), _) => {
        WsWebSocket.close(ws)
        Log.error(["No sessionId"])
      }
    | (Some(_), Ok(player)) => {
        let playerId = player.id
        playersSocket->PlayersSocketMap.set(playerId, ws)
        sendToPlayer(playerId, Connected(player))

        ws
        ->WsWebSocket.on(WsWebSocket.ClientEvents.close, @this (_, _, _) => {
          playersSocket->PlayersSocketMap.remove(playerId)
        })
        ->WsWebSocket.on(WsWebSocket.ClientEvents.message, @this (ws, msg, _) => {
          msg
          ->WsWebSocket.RawData.toString
          ->Option.getWithDefault("")
          ->Serializer.deserializeClientMessage
          ->Utils.tapResult(Log.logMessageFromClient)
          ->Result.map(msg => {
            switch msg {
            | Lobby(Create, playerId, _) =>
              playerId
              ->GameInstance.createLobby
              ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyCreated(lobby)))
            | Lobby(Enter, playerId, gameId) =>
              playerId
              ->GameInstance.enterGame(gameId)
              ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyUpdated(lobby)))
            | Lobby(Ready, playerId, gameId) =>
              playerId
              ->GameInstance.toggleReady(gameId)
              ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyUpdated(lobby)))
            | Lobby(Start, playerId, gameId) =>
              playerId
              ->GameInstance.startGame(gameId)
              ->Result.map(progress =>
                broadcastToPlayers(progress.players, ProgressCreated(progress))
              )
            | Progress(move, playerId, gameId) =>
              playerId
              ->GameInstance.move(gameId, move)
              ->Result.map(progress =>
                broadcastToPlayers(progress.players, ProgressUpdated(progress))
              )
            | _ => Error("Message from server cannot be parsed as text")
            }->tapErrorResult(msg => sendToWs(ws, ServerError(msg)))
          })
          ->ignore
        })
        ->ignore
      }
    | (_, Error(err)) => {
        WsWebSocket.close(ws)
        Log.error(["Error:", err])
      }
    | _ => {
        WsWebSocket.close(ws)
        Log.error(["Connection error"])
      }
    }
  })
  ->ignore
}

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
