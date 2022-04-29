open Types

module type GameType = {
  type t
}

module MakeGameMap = (Item: GameType) => {
  module GameId = Id.MakeComparable({
    type t = gameId
    let cmp: (gameId, gameId) => int = Pervasives.compare
  })

  type t = Belt.MutableMap.t<GameId.t, Item.t, GameId.identity>

  let empty = (): t => Belt.MutableMap.make(~id=module(GameId))

  let get = (map: t, gameId: gameId): result<Item.t, string> =>
    map->MutableMap.get(gameId)->Utils.toResult(`Game "${gameId}" not found`)

  let set = (map: t, game) => map->MutableMap.set(game)
}
