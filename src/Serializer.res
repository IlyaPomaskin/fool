open Types

let card = Jzon.custom(
  card => card->Card.cardToString->Js.Json.string,
  json => {
    let parsedCard = json->Js.Json.decodeString->Option.getWithDefault("")->Card.stringToCard

    switch parsedCard {
    | Some(card) => Ok(card)
    | None =>
      Error(#UnexpectedJsonValue([Jzon.DecodingError.Field("card")], json->Js.Json.stringify))
    }
  },
)

let suit = Jzon.custom(
  suit => suit->Card.suitToString->Js.Json.string,
  json =>
    switch json->Js.Json.decodeString->Option.flatMap(Card.stringToSuit) {
    | Some(suit) => Ok(suit)
    | None => Error(#UnexpectedJsonValue([Jzon.DecodingError.Field("suit")], "s"))
    },
)

let tablePair = Jzon.object2(
  ((to, by)) => (to, by),
  ((to, by)) => (to, by)->Ok,
  Jzon.field("to", card),
  Jzon.field("by", card)->Jzon.optional,
)

/*
let tablePair = Jzon.custom(
  ((to, by): tableCards) =>
    Js.Json.array([
      to->cardToString->Js.Json.string,
      by->Option.map(cardToString)->Option.getWithDefault("none")->Js.Json.string,
    ]),
  json =>
    switch json->Js.Json.decodeArray {
    | Some(arr) => {
        let toCard =
          arr
          ->Array.get(0)
          ->Option.flatMap(Js.Json.decodeString)
          ->Option.getWithDefault("")
          ->stringToCard

        let byCardOptional = arr->Array.get(1)->Option.flatMap(Js.Json.decodeString)
        let byCardValue = byCardOptional->Option.getWithDefault("")
        let byCard = switch (byCardOptional, byCardValue) {
        | (Some(card), _) => Ok(Some(card))
        | (_, "none") => Ok(None)
        | _ => Error(#UnexpectedJsonValue([Field("second table pair card")], ""))
        }

        switch (toCard, byCard) {
        | (Ok(to), Ok(by)) => (to, by)
        | (Error(_), _) => toCard
        | (_, Error()) => byCard
        }
      }
    | None => Error(#UnexpectedJsonValue([Field("table pair")], json))
    },
) */

let playerMsg = Jzon.object1(
  kind =>
    switch kind {
    // | Connect => "connect"
    | Disconnect => "disconnect"
    | Ping => "ping"
    | Pong => "pong"
    },
  kind =>
    switch kind {
    // | "connect" => Ok(Connect)
    | "disconnect" => Ok(Disconnect)
    | "ping" => Ok(Ping)
    | "Pong" => Ok(Pong)
    | x => Error(#UnexpectedJsonValue([Field("kind")], x))
    },
  Jzon.field("kind", Jzon.string),
)

let lobbyMsg = Jzon.object1(
  kind =>
    switch kind {
    | Create => "create"
    | Enter => "enter"
    | Ready => "ready"
    | Start => "start"
    },
  kind =>
    switch kind {
    | "create" => Ok(Create)
    | "enter" => Ok(Enter)
    | "ready" => Ok(Ready)
    | "start" => Ok(Start)
    | x => Error(#UnexpectedJsonValue([Field("kind")], x))
    },
  Jzon.field("kind", Jzon.string),
)

let beatPayload = Jzon.object2(
  ({to, by}) => (to, by),
  ((to, by)) => {to: to, by: by}->Ok,
  Jzon.field("to", card),
  Jzon.field("by", card),
)

let movePayload = Jzon.object1(({card}) => card, card => {card: card}->Ok, Jzon.field("card", card))

let progressMsg = Jzon.object2(
  kind =>
    switch kind {
    | Pass => ("pass", None)
    | Take => ("take", None)
    | Beat(to, by) => ("beat", Some(Jzon.encodeWith({to: to, by: by}, beatPayload)))
    | Move(card) => ("move", Some(Jzon.encodeWith({card: card}, movePayload)))
    },
  ((kind, payload)) =>
    switch (kind, payload) {
    | ("pass", _) => Ok(Pass)
    | ("take", _) => Ok(Take)
    | ("beat", Some(payload)) =>
      payload->Jzon.decodeWith(beatPayload)->Result.map(({to, by}) => Beat(to, by))
    | ("move", Some(payload)) =>
      payload->Jzon.decodeWith(movePayload)->Result.map(({card}) => Move(card))
    | (x, _) => Error(#UnexpectedJsonValue([Field("kind")], x))
    },
  Jzon.field("kind", Jzon.string),
  Jzon.field("payload", Jzon.json)->Jzon.optional,
)

let gameMsg = Jzon.object4(
  kind =>
    switch kind {
    | Register(playerId) => ("register", Jzon.encodeWith(playerId, Jzon.string), "", None)
    | Login(sessionId) => ("login", Jzon.encodeWith(sessionId, Jzon.string), "", None)
    | Player(msg, playerId) => ("player", Jzon.encodeWith(msg, playerMsg), playerId, None)
    | Lobby(msg, playerId, gameId) => (
        "lobby",
        Jzon.encodeWith(msg, lobbyMsg),
        playerId,
        Some(gameId),
      )
    | Progress(msg, playerId, gameId) => (
        "progress",
        Jzon.encodeWith(msg, progressMsg),
        playerId,
        Some(gameId),
      )
    },
  ((kind, msg, playerId, gameId)) => {
    switch kind {
    | "register" => Jzon.decodeWith(msg, Jzon.string)->Result.map(playerId => Register(playerId))
    | "login" => Jzon.decodeWith(msg, Jzon.string)->Result.map(sessionId => Login(sessionId))
    | "player" => Jzon.decodeWith(msg, playerMsg)->Result.map(msg => Player(msg, playerId))
    | "lobby" =>
      gameId
      ->Utils.toResult(
        #UnexpectedJsonValue([Jzon.DecodingError.Field("gameId")], Js.Json.stringify(msg)),
      )
      ->Result.flatMap(gameId =>
        Jzon.decodeWith(msg, lobbyMsg)->Result.flatMap(lobbyMessage => {
          Ok(Lobby(lobbyMessage, playerId, gameId))
        })
      )
    | "progress" =>
      gameId
      ->Utils.toResult(
        #UnexpectedJsonValue([Jzon.DecodingError.Field("gameId")], Js.Json.stringify(msg)),
      )
      ->Result.flatMap(gameId =>
        Jzon.decodeWith(msg, progressMsg)->Result.flatMap(move => {
          Ok(Progress(move, playerId, gameId))
        })
      )
    | x => Error(#UnexpectedJsonValue([Field("kind")], x))
    }
  },
  Jzon.field("kind", Jzon.string),
  Jzon.field("payload", Jzon.json),
  Jzon.field("playerId", Jzon.string),
  Jzon.field("gameId", Jzon.string)->Jzon.optional,
)

let serializeClientMessage = (msg: gameMessageFromClient) => Jzon.encodeStringWith(msg, gameMsg)

let deserializeClientMessage = (msg: string) => Jzon.decodeStringWith(msg, gameMsg)

let listViaArray = elementCodec =>
  Jzon.custom(
    (list: list<'a>) => list->List.toArray->Jzon.encodeWith(Jzon.array(elementCodec)),
    json => json->Jzon.decodeWith(Jzon.array(elementCodec))->Result.map(List.fromArray),
  )

let playerMsg = Jzon.object3(
  ({id, sessionId, cards}) => (id, sessionId, cards),
  ((id, sessionId, cards)) => {id: id, sessionId: sessionId, cards: cards}->Ok,
  Jzon.field("id", Jzon.string),
  Jzon.field("sessionId", Jzon.string),
  Jzon.field("cards", listViaArray(card)),
)

let inLobbyMsg = Jzon.object3(
  ({gameId, players, ready}) => (gameId, players, ready),
  ((gameId, players, ready)) => {gameId: gameId, players: players, ready: ready}->Ok,
  Jzon.field("gameId", Jzon.string),
  Jzon.field("players", listViaArray(playerMsg)),
  Jzon.field("ready", listViaArray(playerMsg)),
)

let tableCards = listViaArray(tablePair)

let inProgressMsg = Jzon.object8(
  ({gameId, attacker, defender, players, trump, deck, table, pass}) => (
    gameId,
    attacker,
    defender,
    players,
    trump,
    deck,
    table,
    pass,
  ),
  ((gameId, attacker, defender, players, trump, deck, table, pass)) =>
    {
      gameId: gameId,
      attacker: attacker,
      defender: defender,
      players: players,
      trump: trump,
      deck: deck,
      table: table,
      pass: pass,
    }->Ok,
  Jzon.field("gameId", Jzon.string),
  Jzon.field("attacker", playerMsg),
  Jzon.field("defender", playerMsg),
  Jzon.field("players", listViaArray(playerMsg)),
  Jzon.field("trump", suit),
  Jzon.field("deck", listViaArray(card)),
  Jzon.field("table", tableCards),
  Jzon.field("pass", listViaArray(playerMsg)),
)

let serverGameMsg = Jzon.object2(
  kind =>
    switch kind {
    | Connected(player) => ("connected", Jzon.encodeWith(player, playerMsg))
    | LobbyCreated(game) => ("lobbyCreated", Jzon.encodeWith(game, inLobbyMsg))
    | LobbyUpdated(game) => ("lobbyUpdated", Jzon.encodeWith(game, inLobbyMsg))
    | ProgressCreated(game) => ("progressCreated", Jzon.encodeWith(game, inProgressMsg))
    | ProgressUpdated(game) => ("progressUpdated", Jzon.encodeWith(game, inProgressMsg))
    | ServerError(msg) => ("error", Jzon.encodeWith(msg, Jzon.string))
    },
  ((kind, payload)) => {
    switch (kind, payload) {
    | ("connected", player) =>
      Jzon.decodeWith(player, playerMsg)->Result.map(player => Connected(player))
    | ("lobbyCreated", game) =>
      Jzon.decodeWith(game, inLobbyMsg)->Result.map(game => LobbyCreated(game))
    | ("lobbyUpdated", game) =>
      Jzon.decodeWith(game, inLobbyMsg)->Result.map(game => LobbyUpdated(game))
    | ("progressCreated", game) =>
      Jzon.decodeWith(game, inProgressMsg)->Result.map(game => ProgressCreated(game))
    | ("progressUpdated", game) =>
      Jzon.decodeWith(game, inProgressMsg)->Result.map(game => ProgressUpdated(game))
    | ("error", err) => Jzon.decodeWith(err, Jzon.string)->Result.map(msg => ServerError(msg))
    | (x, _) => Error(#UnexpectedJsonValue([Field("kind")], x))
    }
  },
  Jzon.field("kind", Jzon.string),
  Jzon.field("payload", Jzon.json),
)

let serializeServerMessage = (msg: gameMessageFromServer) =>
  Jzon.encodeStringWith(msg, serverGameMsg)

let deserializeServerMessage = (msg: string) => Jzon.decodeStringWith(msg, serverGameMsg)
