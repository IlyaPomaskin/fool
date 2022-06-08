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

module GameMap = {
  type t = Belt.HashMap.t<GameId.t, gameState, GameId.identity>

  let log = (map: t) => {
    Js.Json.stringifyWithSpace(
      Js.Json.array(
        map
        ->HashMap.toArray
        ->Array.map(((k, v)) => Js.Json.array([Js.Json.string(k), v->Obj.magic])),
      ),
      2,
    )
  }

  let empty = (): t => Belt.HashMap.make(~id=module(GameId), ~hintSize=10)

  let get = (map, gameId): result<gameState, string> =>
    map->HashMap.get(gameId)->MOption.toResult(`Game "${gameId}" not found`)

  let set = (map, gameId, game) => {
    HashMap.set(map, gameId, game)
    Ok(game)
  }

  let create = (map, game) => {
    let gameWithSameIdFound = get(map, GameUtils.getGameId(game))

    switch gameWithSameIdFound {
    | Ok(game) => Error(`Game ${GameUtils.getGameId(game)} already exists`)
    | Error(_) => set(map, GameUtils.getGameId(game), game)
    }
  }

  let remove = (map, gameId) => map->HashMap.remove(gameId)

  let update = (map, gameId, fn: gameState => gameState) =>
    map->get(gameId)->Result.flatMap(game => set(map, gameId, fn(game)))
}

module PlayersMap = {
  type t = Belt.HashMap.t<PlayerId.t, player, PlayerId.identity>

  let log = (map: t) => {
    Js.Json.stringifyWithSpace(
      Js.Json.array(
        map
        ->HashMap.toArray
        ->Array.map(((k, v)) => Js.Json.array([Js.Json.string(k), v->Obj.magic])),
      ),
      2,
    )
  }

  let empty = (): t => Belt.HashMap.make(~id=module(PlayerId), ~hintSize=10)

  let get = (map, playerId): result<player, string> =>
    map->HashMap.get(playerId)->MOption.toResult(`Player "${playerId}" not found`)

  let findBySessionId = (map: t, sessionId: sessionId): result<player, string> => {
    Log.debug(PlayersMap, ["findBySessionId", log(map)])
    map
    ->HashMap.reduce(None, (acc, _, value) => {
      switch acc {
      | Some(_) => acc
      | None => value.sessionId === sessionId ? Some(value) : None
      }
    })
    ->MOption.toResult(`Player ${sessionId} not found`)
  }

  let set = (map, key, nextValue) => {
    map->HashMap.set(key, nextValue)
    Log.debug(PlayersMap, ["set", key, log(map)])
  }

  let create = (map, playerId): result<player, string> =>
    switch HashMap.get(map, playerId) {
    | Some(_) => Error(`Player ${playerId} already exists`)
    | None => {
        let player = Player.make(playerId)
        set(map, playerId, player)
        Ok(player)
      }
    }
}

module PlayersSocketMap = {
  type t = Belt.HashMap.t<PlayerId.t, WsWebSocket.t, PlayerId.identity>

  let empty = (): t => Belt.HashMap.make(~id=module(PlayerId), ~hintSize=10)

  let get = (map, playerId) =>
    map->HashMap.get(playerId)->MOption.toResult(`Player "${playerId}" socket not found`)

  let set = (map, playerId, socket) => map->HashMap.set(playerId, socket)

  let remove = (map, playerId) => map->HashMap.remove(playerId)
}

let games = GameMap.empty()
let players = PlayersMap.empty()
let playersSocket = PlayersSocketMap.empty()
