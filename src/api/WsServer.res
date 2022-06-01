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
    server: server,
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
      getUrl(req, "ws")
      ->ServerUtils.getSearchParams
      ->ServerUtils.getParam("sessionId")
      ->Option.flatMap(sessionId => {
        switch sessionId {
        | "" => None
        | _ => Some(sessionId)
        }
      })
      ->Utils.toResult("No sessionId")

    Log.debug(Ws, [`login ${sessionId->Result.getWithDefault("No sessionId")}`])

    let player = sessionId->Result.flatMap(p => GameInstance.loginPlayer(p))

    switch (sessionId, player) {
    | (Error(err), _) => {
        Log.error(["Can't get sessionId error:", err])
        WsWebSocket.close(ws)
      }
    | (_, Error(err)) => {
        Log.error(["Player not found error:", err])
        WsWebSocket.close(ws)
      }
    | (Ok(_), Ok(player)) => {
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
    }
  })
  ->ignore
}

let isWsServerSet = ref(false)
let isHandlerSet = ref(false)

let setWsServer = res => {
  if !isWsServerSet.contents {
    Js.log("Set handlers")

    createServer(res->Http.ServerResponse.socket->WsWebSocketServer.getServerFromSocket)

    // res
    // ->Http.ServerResponse.socket
    // ->WsWebSocketServer.getServerFromSocket
    // ->Http.Server.onListening(() =>
    //   wsServer->WsWebSocketServer.emit(WsWebSocketServer.ServerEvents.listening)->ignore
    // )
    // ->Http.Server.onError(() =>
    //   wsServer->WsWebSocketServer.emit(WsWebSocketServer.ServerEvents.error)->ignore
    // )
    // ->Http.Server.onUpgrade((req, socket, head) => {
    //   let isWs = Js.String.startsWith("/ws", Http.IncomingMessage.url(req))

    //   Js.log3("on upgrade ws", isWs, isHandlerSet.contents)

    //   if isWs && !isHandlerSet.contents {
    //     Js.log3("upgrade ws", isWs, isHandlerSet.contents)

    //     isHandlerSet := true

    //     WsWebSocketServer.handleUpgrade(wsServer, req, socket, head, (ws, req) =>
    //       wsServer
    //       ->WsWebSocketServer.emit2(WsWebSocketServer.ServerEvents.connection, ws, req)
    //       ->ignore
    //     )
    //   }
    // })
    // ->ignore

    isWsServerSet := true
  }
}
