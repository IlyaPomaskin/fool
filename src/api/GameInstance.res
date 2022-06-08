open Types
open Storage

// FIXME remove debug code
let p1 = {id: "p1", sessionId: "s:p1", cards: list{}}
let p2 = {id: "p2", sessionId: "s:p2", cards: list{}}
players->PlayersMap.set("p1", p1)->ignore
players->PlayersMap.set("p2", p2)->ignore
games
->GameMap.set(
  "g1",
  InLobby({gameId: "g1", owner: "p1", players: list{p1, p2}, ready: list{p1.id, p2.id}}),
)
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

let getPlayerWithGame = (playerId, gameId, unpackGame) =>
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player =>
    games->GameMap.get(gameId)->Result.flatMap(unpackGame)->Result.map(game => (game, player))
  )

let createLobby = playerId =>
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => Game.makeGameInLobby(player))
  ->Result.flatMap(game => GameMap.create(games, game))

let enterGame = (playerId, gameId) =>
  getPlayerWithGame(playerId, gameId, GameUtils.unpackLobby)
  ->Result.flatMap(((lobby, player)) => Game.enterLobby(lobby, player))
  ->Result.flatMap(lobby => GameMap.set(games, gameId, lobby))

let toggleReady = (playerId, gameId) =>
  getPlayerWithGame(playerId, gameId, GameUtils.unpackLobby)
  ->Result.flatMap(((game, player)) => Game.toggleReady(game, player))
  ->Result.flatMap(game => GameMap.set(games, gameId, game))

let startGame = (playerId, gameId) =>
  getPlayerWithGame(playerId, gameId, GameUtils.unpackLobby)
  ->Result.flatMap(((game, player)) => Game.startGame(game, player))
  ->Result.flatMap(game => GameMap.set(games, gameId, game))

let move = (playerId, gameId, action) =>
  getPlayerWithGame(playerId, gameId, GameUtils.unpackProgress)
  ->Result.flatMap(((game, player)) => Game.dispatch(game, player, action))
  ->Result.flatMap(game => GameMap.set(games, gameId, game))
