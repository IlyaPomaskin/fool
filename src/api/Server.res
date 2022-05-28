open NodeJs
open Utils
open Types
open Storage
open ServerUtils

let playersSocket = PlayersSocketMap.empty()

let wsServer = WsWebSocketServer.Make.make({
  backlog: 101,
  clientTracking: true,
  maxPayload: 104857600,
  path: "/ws",
  noServer: false,
  server: WsWebSocketServer.restartServer(),
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
  let playerId =
    getUrl(req, "ws")
    ->ServerUtils.getSearchParams
    ->ServerUtils.getParam("sessionId")
    ->Utils.toResult("No sessionId")
    ->Result.flatMap(GameInstance.loginPlayer)
    ->Result.map(player => player.id)

  Js.log2("playerId", playerId)

  switch playerId {
  | Ok(playerId) => {
      playersSocket->PlayersSocketMap.set(playerId, ws)

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
  | _ => {
      WsWebSocket.close(ws)

      Log.error(["PlayerId not found"])
    }
  }
})
->ignore

Js.log("START")

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
