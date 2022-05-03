open NodeJs

let wsServer = WsWebSocketServer.Make.make({
  backlog: 101,
  clientTracking: true,
  maxPayload: 104857600,
  path: "/ws",
  noServer: false,
  server: WsWebSocketServer.restartServer(),
  skipUTF8Validation: true,
})

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
        ws->WsWebSocket.send(Serializer.serializeServerMessage(Connected(player)))
      })
    | Ok(Lobby(Create, playerId, _)) =>
      playerId
      ->GameInstance.createLobby
      ->Result.map(lobby =>
        ws->WsWebSocket.send(Serializer.serializeServerMessage(LobbyUpdated(lobby)))
      )
    | Ok(Lobby(Enter, playerId, gameId)) =>
      playerId
      ->GameInstance.enterGame(gameId)
      ->Result.map(lobby =>
        ws->WsWebSocket.send(Serializer.serializeServerMessage(LobbyUpdated(lobby)))
      )
    | Ok(Lobby(Ready, playerId, gameId)) =>
      playerId
      ->GameInstance.toggleReady(gameId)
      ->Result.map(lobby => {
        ws->WsWebSocket.send(Serializer.serializeServerMessage(LobbyUpdated(lobby)))
      })
    | Ok(Lobby(Start, playerId, gameId)) =>
      playerId
      ->GameInstance.startGame(gameId)
      ->Result.map(progress =>
        ws->WsWebSocket.send(Serializer.serializeServerMessage(ProgressCreated(progress)))
      )
    | Ok(Progress(move, playerId, gameId)) =>
      playerId
      ->GameInstance.dispatch(gameId, move)
      ->Result.map(progress =>
        ws->WsWebSocket.send(Serializer.serializeServerMessage(ProgressUpdated(progress)))
      )
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
