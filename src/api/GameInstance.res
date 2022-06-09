open Types
open Storage

let registerPlayer = (playerId: playerId): result<player, string> => {
  let player = players->PlayersMap.get(playerId)

  switch player {
  | Ok(_) => Error("Player with same name already exists")
  | Error(_) => players->PlayersMap.create(playerId)
  }
}

let loginPlayer = sessionId => PlayersMap.findBySessionId(players, sessionId)

let getPlayerWithGame = (playerId, gameId, unpackGame) =>
  games
  ->GameMap.get(gameId)
  ->Result.flatMap(game => {
    let players = switch game {
    | InProgress(g) => g.players
    | InLobby(g) => g.players
    }

    players
    ->Utils.findInList(p => p.id == playerId)
    ->Option.map(player => (game, player))
    ->MOption.toResult(`Player not found in game ${gameId}`)
  })
  ->Result.flatMap(((game, player)) => unpackGame(game)->Result.map(game => (game, player)))

let createLobby = playerId =>
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => Game.makeGameInLobby(player))
  ->Result.flatMap(game => GameMap.create(games, game))

let enterGame = (playerId, gameId) =>
  getPlayerWithGame(playerId, gameId, g => Ok(g))
  ->Result.flatMap(((game, player)) =>
    switch game {
    | InLobby(x) => Game.enterLobby(x, player)
    | InProgress(x) => Game.enterProgress(x, player)
    }
  )
  ->Result.flatMap(lobby => GameMap.set(games, gameId, lobby))

let leaveGame = (playerId, gameId) =>
  getPlayerWithGame(playerId, gameId, g => Ok(g))
  ->Result.flatMap(((game, player)) =>
    switch game {
    | InLobby(game) => Game.leaveLobby(game, player)
    | InProgress(game) => Game.disconnectProgress(game, player)
    }
  )
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
->Result.map(game => {
  startGame("p2", "g1")->MResult.fold(r => Js.log2("ok", r), e => Js.log2("err", e))
  game
})
->ignore
