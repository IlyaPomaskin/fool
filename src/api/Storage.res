open Types

module type GameType = {
  type t
  type createGameArg

  let createGame: createGameArg => result<t, string>
  let getId: t => gameId
}

module MakeGameMap = (Item: GameType) => {
  module GameId = Id.MakeComparable({
    type t = gameId
    let cmp: (gameId, gameId) => int = Pervasives.compare
  })

  type t = Belt.MutableMap.t<GameId.t, Item.t, GameId.identity>

  let empty = (): t => Belt.MutableMap.make(~id=module(GameId))

  let get = (map, gameId): result<Item.t, string> =>
    map->MutableMap.get(gameId)->Utils.toResult(`Game "${gameId}" not found`)

  let set = (map, gameId, game) => MutableMap.set(map, gameId, game)

  let create = (map, arg) => {
    let game = Item.createGame(arg)
    let gameWithSameIdFound = game->Result.map(Item.getId)->Result.flatMap(id => get(map, id))

    switch (game, gameWithSameIdFound) {
    | (Error(_), _) => game
    | (_, Ok(game)) => Error(`Game ${Item.getId(game)} already exists`)
    | (Ok(game), _) => {
        set(map, Item.getId(game), game)
        Ok(game)
      }
    }
  }

  let remove = (map, gameId) => map->MutableMap.remove(gameId)
}

module LobbyGameMap = MakeGameMap({
  type t = inLobby
  type createGameArg = player

  let createGame = player => Game.makeGameInLobby(player)
  let getId = (game: t) => game.gameId
})

module ProgressGameMap = MakeGameMap({
  type t = inProgress
  type createGameArg = inLobby

  let createGame = lobby => Game.startGame(lobby)
  let getId = (game: t) => game.gameId
})

module PlayersMap = {
  module PlayerId = Id.MakeComparable({
    type t = playerId
    let cmp: (playerId, playerId) => int = Pervasives.compare
  })

  type t = Belt.MutableMap.t<PlayerId.t, player, PlayerId.identity>

  let empty = (): t => Belt.MutableMap.make(~id=module(PlayerId))

  let get = (map, playerId): result<player, string> =>
    map->MutableMap.get(playerId)->Utils.toResult(`Player "${playerId}" not found`)

  let set = (map, game) => map->MutableMap.set(game)

  let create = (map, playerId): result<player, string> =>
    switch MutableMap.get(map, playerId) {
    | Some(_) => Error(`Player ${playerId} already exists`)
    | None => Ok(Player.make(playerId))
    }
}