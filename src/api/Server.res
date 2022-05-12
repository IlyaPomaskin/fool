open Types
open NodeJs
open Storage

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

let sendToPlayer = (playerId, event) => {
  playersSocket
  ->PlayersSocketMap.get(playerId)
  ->Result.map(socket => {
    socket->WsWebSocket.send(
      Serializer.serializeServerMessage(
        switch event {
        | ProgressCreated(game) => ProgressCreated(Game.maskForPlayer(game, playerId))
        | ProgressUpdated(game) => ProgressUpdated(Game.maskForPlayer(game, playerId))
        | _ => event
        },
      ),
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
    Some(req)
    ->Option.map(Http.IncomingMessage.headers)
    ->Option.flatMap(headers => headers.host)
    ->Option.map(host =>
      Url.fromBaseString(~input=Http.IncomingMessage.url(req), ~base=`ws://${host}`)
    )
    ->Option.map(url => url.username)

  switch playerId {
  | None => Log.error(["Connection without playerId", "url.toString()"])
  | Some(playerId) =>
    ws
    // ->WsWebSocket.on(WsWebSocket.ClientEvents.open_, @this ws => {
    //   playerId
    //   ->GameInstance.connectPlayer
    //   ->Result.map(player => {
    //     playersSocket->PlayersSocketMap.set(player.id, ws)
    //     sendToPlayer(player.id, Connected(player))
    //   })
    //   ->ignore
    // })
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
        | Login(sessionId) =>
          sessionId
          ->GameInstance.loginPlayer
          ->Result.map(player => {
            playersSocket->PlayersSocketMap.set(player.id, ws)
            sendToPlayer(player.id, Connected(player))
          })
        | Register(playerId) =>
          playerId
          ->GameInstance.registerPlayer
          ->Result.map(player => {
            playersSocket->PlayersSocketMap.set(player.id, ws)
            sendToPlayer(player.id, Connected(player))
          })
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
          ->Result.map(progress => broadcastToPlayers(progress.players, ProgressCreated(progress)))
        | Progress(move, playerId, gameId) =>
          playerId
          ->GameInstance.move(gameId, move)
          ->Result.map(progress => broadcastToPlayers(progress.players, ProgressUpdated(progress)))
        | _ => Error("Message from server cannot be parsed as text")
        }->(
          result =>
            switch result {
            | Ok(_) => ()
            | Error(msg) =>
              ws->WsWebSocket.send(Serializer.serializeServerMessage(ServerError(msg)))
            }
        )
      })
      ->ignore
    })
    ->ignore
  }
})
->ignore

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
