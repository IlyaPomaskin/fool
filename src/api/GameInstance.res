open Types
open Storage

let gamesInLobby = LobbyGameMap.empty()
let gamesInProgress = ProgressGameMap.empty()
let players = PlayersMap.empty()

// FIXME remove debug code
PlayersMap.set(players, "p1", {id: "p1", sessionId: "session:p1", cards: list{}})
PlayersMap.set(players, "p2", {id: "p2", sessionId: "session:p2", cards: list{}})

let registerPlayer = (playerId: playerId): result<player, string> => {
  let player = players->PlayersMap.get(playerId)

  switch player {
  | Ok(_) => Error("Player with same name already exists")
  | Error(_) => players->PlayersMap.create(playerId)
  }
}

let loginPlayer = sessionId => PlayersMap.findBySessionId(players, sessionId)

let createLobby = playerId => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => gamesInLobby->LobbyGameMap.create(player))
}

let enterGame = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => {
    gamesInLobby->LobbyGameMap.get(gameId)->Result.flatMap(lobby => Game.enterGame(lobby, player))
  })
  ->Result.flatMap(game => gamesInLobby->LobbyGameMap.set(game.gameId, game))
}

let toggleReady = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player =>
    gamesInLobby->LobbyGameMap.update(gameId, game =>
      Game.toggleReady(game, player)->Result.getWithDefault(game)
    )
  )
}

let startGame = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player =>
    gamesInLobby
    ->LobbyGameMap.get(gameId)
    ->Result.flatMap(game => GameUtils.isCanStart(game, player))
  )
  ->Result.flatMap(game => Game.startGame(game))
  ->Result.flatMap(game => {
    gamesInLobby->LobbyGameMap.remove(gameId)
    gamesInProgress->ProgressGameMap.set(gameId, game)
  })
}

let move = (playerId, gameId, action): result<inProgress, string> => {
  gamesInProgress
  ->ProgressGameMap.get(gameId)
  ->Result.flatMap(game =>
    game
    ->GameUtils.findPlayerById(playerId)
    ->Utils.toResult(`Player ${playerId} not found`)
    ->Result.map(player => (player, game))
  )
  ->Result.flatMap(((player, game)) => Game.dispatch(game, player, action))
  ->Result.flatMap(game => gamesInProgress->ProgressGameMap.set(game.gameId, game))
}
