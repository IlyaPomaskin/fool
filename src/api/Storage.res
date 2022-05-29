open Types

module type GameType = {
  type t
  type createGameArg

  let createGame: createGameArg => result<t, string>
  let getId: t => gameId
}

module PlayerId = Id.MakeHashable({
  type t = playerId
  let hash = Hashtbl.hash
  let eq = (a, b) => a === b
})

module GameId = Id.MakeHashable({
  type t = gameId
  let hash = Hashtbl.hash
  let eq = (a, b) => a === b
})

module MakeGameMap = (Item: GameType) => {
  type t = Belt.HashMap.t<GameId.t, Item.t, GameId.identity>

  let empty = (): t => Belt.HashMap.make(~id=module(GameId), ~hintSize=10)

  let get = (map, gameId): result<Item.t, string> =>
    map->HashMap.get(gameId)->Utils.toResult(`Game "${gameId}" not found`)

  let set = (map, gameId, game) => {
    HashMap.set(map, gameId, game)
    Ok(game)
  }

  let create = (map, arg) => {
    let game = Item.createGame(arg)
    let gameWithSameIdFound = game->Result.map(Item.getId)->Result.flatMap(id => get(map, id))

    switch (game, gameWithSameIdFound) {
    | (Error(_), _) => game
    | (_, Ok(game)) => Error(`Game ${Item.getId(game)} already exists`)
    | (Ok(game), _) => set(map, Item.getId(game), game)
    }
  }

  let remove = (map, gameId) => map->HashMap.remove(gameId)

  let update = (map, gameId, fn: Item.t => Item.t) =>
    map->get(gameId)->Result.flatMap(game => set(map, gameId, fn(game)))
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
  type t = Belt.HashMap.t<PlayerId.t, player, PlayerId.identity>

  let empty = (): t => Belt.HashMap.make(~id=module(PlayerId), ~hintSize=10)

  let get = (map, playerId): result<player, string> =>
    map->HashMap.get(playerId)->Utils.toResult(`Player "${playerId}" not found`)

  let findBySessionId = (map, sessionId: sessionId): result<player, string> => {
    Js.log2("playersMap", map->HashMap.toArray)
    map
    ->HashMap.reduce(None, (acc, _, value) => {
      switch acc {
      | Some(_) => acc
      | None => value.sessionId === sessionId ? Some(value) : None
      }
    })
    ->Utils.toResult(`Player ${sessionId} not found`)
  }

  let set = (map, game) => map->HashMap.set(game)

  let create = (map, playerId): result<player, string> =>
    switch HashMap.get(map, playerId) {
    | Some(_) => Error(`Player ${playerId} already exists`)
    | None => {
        let player = Player.make(playerId)
        HashMap.set(map, playerId, player)
        Ok(player)
      }
    }
}

module PlayersSocketMap = {
  type t = Belt.HashMap.t<PlayerId.t, WsWebSocket.t, PlayerId.identity>

  let empty = (): t => Belt.HashMap.make(~id=module(PlayerId), ~hintSize=10)

  let get = (map, playerId) =>
    map->HashMap.get(playerId)->Utils.toResult(`Player "${playerId}" socket not found`)

  let set = (map, playerId, socket) => map->HashMap.set(playerId, socket)

  let remove = (map, playerId) => map->HashMap.remove(playerId)
}

let gamesInLobby = LobbyGameMap.empty()
let gamesInProgress = ProgressGameMap.empty()
let players = PlayersMap.empty()
