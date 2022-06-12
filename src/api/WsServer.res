open NodeJs
open Types
open Storage
open ServerUtils

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

  let broadcast = (players, event) =>
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
      ->MOption.toResult("No sessionId")

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
        PlayersSocketMap.set(playersSocket, playerId, ws)
        sendToPlayer(playerId, Connected(player))

        ws
        ->WsWebSocket.on(WsWebSocket.ClientEvents.close, @this (_, _, _) => {
          PlayersSocketMap.remove(playersSocket, playerId)

          let game = HashMap.reduce(games, Error("Game not found"), (acc, key, value) => {
            switch acc {
            | Ok(_) => acc
            | Error(_) =>
              if playerId === key {
                Ok(value)
              } else {
                acc
              }
            }
          })

          game
          ->Result.flatMap(game => GameInstance.leaveGame(playerId, GameUtils.getGameId(game)))
          ->Result.flatMap(game => GameMap.set(games, GameUtils.getGameId(game), game))
          ->Result.map(game =>
            switch game {
            | InLobby(g) => broadcast(g.players, LobbyUpdated(g))
            | InProgress(g) => broadcast(g.players, ProgressUpdated(g))
            }
          )
          ->ignore
        })
        ->WsWebSocket.on(WsWebSocket.ClientEvents.message, @this (ws, msg, _) => {
          msg
          ->WsWebSocket.RawData.toString
          ->Option.getWithDefault("")
          ->Serializer.deserializeClientMessage
          ->MResult.tap(Log.logMessageFromClient)
          ->MResult.mapError(Jzon.DecodingError.toString)
          ->Result.flatMap(msg => {
            switch msg {
            | Lobby(Create, playerId, _) =>
              GameInstance.createLobby(playerId)
              ->Result.flatMap(GameUtils.unpackLobby)
              ->Result.map(lobby => broadcast(lobby.players, LobbyCreated(lobby)))
            | Lobby(Enter, playerId, gameId) =>
              GameInstance.enterGame(playerId, gameId)->Result.map(game =>
                switch game {
                | InLobby(lobby) => broadcast(lobby.players, LobbyUpdated(lobby))
                | InProgress(progress) => broadcast(progress.players, ProgressUpdated(progress))
                }
              )
            | Lobby(Ready, playerId, gameId) =>
              GameInstance.toggleReady(playerId, gameId)
              ->Result.flatMap(GameUtils.unpackLobby)
              ->Result.map(lobby => broadcast(lobby.players, LobbyUpdated(lobby)))
            | Lobby(Start, playerId, gameId) =>
              GameInstance.startGame(playerId, gameId)
              ->Result.flatMap(GameUtils.unpackProgress)
              ->Result.map(progress => broadcast(progress.players, ProgressCreated(progress)))
            | Progress(move, playerId, gameId) =>
              GameInstance.move(playerId, gameId, move)
              ->Result.flatMap(GameUtils.unpackProgress)
              ->Result.map(progress => broadcast(progress.players, ProgressUpdated(progress)))
            | Player(_, _) => Error("'Player' message dont have handlers")
            }
          })
          ->MResult.tapError(err => Log.error(["Server error:", err]))
          ->MResult.tapError(msg => sendToWs(ws, ServerError(msg)))
          ->ignore
        })
        ->ignore
      }
    }
  })
  ->ignore
}

let isWsServerSet = ref(false)

let setWsServer = res => {
  if !isWsServerSet.contents {
    isWsServerSet := true

    createServer(res->Http.ServerResponse.socket->WsWebSocketServer.getServerFromSocket)
  }
}
