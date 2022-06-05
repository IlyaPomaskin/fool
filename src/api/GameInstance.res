open Types
open Storage

// FIXME remove debug code
let p1 = {id: "p1", sessionId: "s:p1", cards: list{}}
let p2 = {id: "p2", sessionId: "s:p2", cards: list{}}
players->PlayersMap.set("p1", p1)->ignore
players->PlayersMap.set("p2", p2)->ignore
gamesInLobby
->LobbyGameMap.set("g1", {gameId: "g1", owner: "p1", players: list{p1, p2}, ready: list{p1, p2}})
->ignore

let registerPlayer = (playerId: playerId): result<player, string> => {
  let player = players->PlayersMap.get(playerId)

  switch player {
  | Ok(_) => Error("Player with same name already exists")
  | Error(_) => players->PlayersMap.create(playerId)
  }
}

let instanceId = ref(0.)

let loginPlayer = sessionId => {
  if instanceId.contents === 0. {
    instanceId := Js.Math.random()
  }

  Log.debug(LoginPlayer, ["GameInstance", string_of_float(instanceId.contents)])

  PlayersMap.findBySessionId(players, sessionId)
}

let createLobby = playerId => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => LobbyGameMap.create(gamesInLobby, player))
}

let enterGame = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => {
    gamesInLobby->LobbyGameMap.get(gameId)->Result.flatMap(lobby => Game.enterGame(lobby, player))
  })
  ->Result.flatMap(game => LobbyGameMap.set(gamesInLobby, game.gameId, game))
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
    LobbyGameMap.remove(gamesInLobby, gameId)
    ProgressGameMap.set(gamesInProgress, gameId, game)
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
