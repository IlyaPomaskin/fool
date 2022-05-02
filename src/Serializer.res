open Types

module Codecs = {
  let suitToString = suit =>
    switch suit {
    | Spades => "S"
    | Hearts => "H"
    | Diamonds => "D"
    | Clubs => "C"
    }

  let stringToSuit = str =>
    switch str {
    | "S" => Some(Spades)
    | "H" => Some(Hearts)
    | "D" => Some(Diamonds)
    | "C" => Some(Clubs)
    | _ => None
    }

  let rankToString = rank =>
    switch rank {
    | Six => "6"
    | Seven => "7"
    | Eight => "8"
    | Nine => "9"
    | Ten => "10"
    | Jack => "J"
    | Queen => "Q"
    | King => "K"
    | Ace => "A"
    }

  let stringToRank = str =>
    switch str {
    | "6" => Some(Six)
    | "7" => Some(Seven)
    | "8" => Some(Eight)
    | "9" => Some(Nine)
    | "10" => Some(Ten)
    | "J" => Some(Jack)
    | "Q" => Some(Queen)
    | "K" => Some(King)
    | "A" => Some(Ace)
    | _ => None
    }

  let cardToString = card =>
    switch card {
    | Hidden => "hidden"
    | Visible(suit, rank) => suitToString(suit) ++ rankToString(rank)
    }

  let stringToCard = str =>
    switch str {
    | "hidden" => Ok(Hidden)
    | str => {
        let suit = str->Js.String.slice(~from=0, ~to_=1)->stringToSuit
        let rank = str->Js.String.slice(~from=1, ~to_=3)->stringToRank

        switch (suit, rank) {
        | (Some(suit), Some(rank)) => Ok(Visible(suit, rank))
        | (None, _) => Error(#UnexpectedJsonValue([Jzon.DecodingError.Field("suit")], str))
        | (_, None) => Error(#UnexpectedJsonValue([Jzon.DecodingError.Field("rank")], str))
        }
      }
    }

  let card = Jzon.custom(
    card => card->cardToString->Js.Json.string,
    json => json->Js.Json.decodeString->Option.getWithDefault("")->stringToCard,
  )

  let playerMsg = Jzon.object1(
    kind =>
      switch kind {
      | Connect => "connect"
      | Disconnect => "disconnect"
      | Ping => "ping"
      | Pong => "pong"
      },
    kind =>
      switch kind {
      | "connect" => Ok(Connect)
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
      | Enter => "enter"
      | Ready => "ready"
      | Start => "start"
      },
    kind =>
      switch kind {
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

  let movePayload = Jzon.object1(
    ({card}) => card,
    card => {card: card}->Ok,
    Jzon.field("card", card),
  )

  let progressMsg = Jzon.object2(
    kind =>
      switch kind {
      | Pass => ("pass", None)
      | Take => ("take", None)
      | Beat(payload) => ("beat", Some(Jzon.encodeWith(payload, beatPayload)))
      | Move(payload) => ("move", Some(Jzon.encodeWith(payload, movePayload)))
      },
    ((kind, payload)) =>
      switch (kind, payload) {
      | ("pass", _) => Ok(Pass)
      | ("take", _) => Ok(Take)
      | ("beat", Some(payload)) =>
        payload->Jzon.decodeWith(beatPayload)->Result.map(({to, by}) => Beat({to: to, by: by}))
      | ("move", Some(payload)) =>
        payload->Jzon.decodeWith(movePayload)->Result.map(({card}) => Move({card: card}))
      | (x, _) => Error(#UnexpectedJsonValue([Field("kind")], x))
      },
    Jzon.field("kind", Jzon.string),
    Jzon.field("payload", Jzon.json)->Jzon.optional,
  )

  let gameMsg = Jzon.object4(
    kind =>
      switch kind {
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
      switch (kind, gameId) {
      | ("player", _) => Jzon.decodeWith(msg, playerMsg)->Result.map(msg => Player(msg, playerId))
      | ("lobby", Some(gameId)) =>
        Jzon.decodeWith(msg, lobbyMsg)->Result.map(msg => Lobby(msg, playerId, gameId))
      | ("progress", Some(gameId)) =>
        Jzon.decodeWith(msg, progressMsg)->Result.map(msg => Progress(msg, playerId, gameId))
      | (x, _) => Error(#UnexpectedJsonValue([Field("kind")], x))
      }
    },
    Jzon.field("kind", Jzon.string),
    Jzon.field("payload", Jzon.json),
    Jzon.field("playerId", Jzon.string),
    Jzon.field("gameId", Jzon.string)->Jzon.optional,
  )
}
