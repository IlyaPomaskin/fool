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

let broadcastToPlayers = (players: list<Types.player>, event) => {
  players->List.forEach(player => {
    playersSocket
    ->PlayersSocketMap.get(player.id)
    ->Result.map(socket => {
      socket->WsWebSocket.send(
        Serializer.serializeServerMessage(
          switch event {
          | ProgressCreated(game) => ProgressCreated(Game.maskForPlayer(game, player.id))
          | ProgressUpdated(game) => ProgressUpdated(Game.maskForPlayer(game, player.id))
          | _ => event
          },
        ),
      )
    })
  })
}

wsServer
->WsWebSocketServer.on(WsWebSocketServer.ServerEvents.connection, @this (_, ws, _) => {
  ws
  ->WsWebSocket.on(WsWebSocket.ClientEvents.message, @this (ws, msg, _) => {
    let msg =
      WsWebSocket.RawData.toString(msg)
      ->Option.getWithDefault("")
      ->Serializer.deserializeClientMessage

    Js.log2(
      "msg:",
      switch msg {
      | Ok(Player(p, pId)) =>
        "player: " ++
        switch p {
        | Connect => "connect " ++ pId
        | Disconnect => "disconnect " ++ pId
        | Ping => "ping " ++ pId
        | Pong => "pong " ++ pId
        }
      | Ok(Lobby(g, pId, gId)) =>
        "game: " ++
        switch g {
        | Create => "Create " ++ pId ++ " " ++ gId
        | Enter => "Enter " ++ pId ++ " " ++ gId
        | Ready => "Ready " ++ pId ++ " " ++ gId
        | Start => "Start " ++ pId ++ " " ++ gId
        }
      | _ => "unk"
      },
    )

    switch msg {
    | Ok(Player(Connect, playerId)) =>
      playerId
      ->GameInstance.connectPlayer
      ->Result.map(player => {
        playersSocket->PlayersSocketMap.set(player.id, ws)
        ws->WsWebSocket.send(Serializer.serializeServerMessage(Connected(player)))
      })
    | Ok(Lobby(Create, playerId, _)) =>
      playerId
      ->GameInstance.createLobby
      ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyCreated(lobby)))
    | Ok(Lobby(Enter, playerId, gameId)) =>
      playerId
      ->GameInstance.enterGame(gameId)
      ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyUpdated(lobby)))
    | Ok(Lobby(Ready, playerId, gameId)) =>
      playerId
      ->GameInstance.toggleReady(gameId)
      ->Result.map(lobby => broadcastToPlayers(lobby.players, LobbyUpdated(lobby)))

    | Ok(Lobby(Start, playerId, gameId)) =>
      playerId
      ->GameInstance.startGame(gameId)
      ->Result.map(progress => broadcastToPlayers(progress.players, ProgressCreated(progress)))
    | Ok(Progress(move, playerId, gameId)) =>
      playerId
      ->GameInstance.dispatchMove(gameId, move)
      ->Result.map(progress => broadcastToPlayers(progress.players, ProgressUpdated(progress)))
    | _ => Error("error?")
    }->{
      result => {
        switch result {
        | Ok(_) => ()
        | Error(msg) => ws->WsWebSocket.send(Serializer.serializeServerMessage(Err(msg)))
        }
      }
    }
  })
  ->ignore
})
->ignore

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
