open Types

module Codecs = {
  type mBeatData = {to: card, by: card}
  type mMoveData = {card: card}

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

  let beat = Jzon.object2(
    ({to, by}) => (to, by),
    ((to, by)) => {to: to, by: by}->Ok,
    Jzon.field("to", card),
    Jzon.field("by", card),
  )

  let move = Jzon.object1(({card}) => card, card => {card: card}->Ok, Jzon.field("card", card))

  let msg = Jzon.object2(
    kind =>
      switch kind {
      | Take => ("take", None)
      | Beat(to, by) => ("beat", Some(Jzon.encodeWith({to: to, by: by}, beat)))
      | Pass => ("pass", None)
      | Move(card) => ("move", Some(Jzon.encodeWith({card: card}, move)))
      },
    ((kind, payload)) =>
      switch (kind, payload) {
      | ("take", _) => Ok(Take)
      | ("beat", Some(payload)) =>
        payload->Jzon.decodeWith(beat)->Result.map(({to, by}) => Beat(to, by))
      | ("pass", _) => Ok(Pass)
      | ("move", Some(payload)) =>
        payload->Jzon.decodeWith(move)->Result.map(({card}) => Move(card))
      | (x, _) => Error(#UnexpectedJsonValue([Field("kind")], x))
      },
    Jzon.field("kind", Jzon.string),
    Jzon.field("payload", Jzon.json)->Jzon.optional,
  )
}

// module Channel = {
//   let make = () => nan

//   let send = (gameId, playerId, msg) =>
//     Promise.make((resolve, reject) => {
//       let timeoutId = Js.Global.setTimeout(() => {
//         let response = GameServer.dispatch(gameId)

//         resolve(. 0)
//       }, 100)
//     })
// }

// let sendMove = (move, gameId, playerId) => {
//   Promise.make((resolve, reject) => {
//     let timeoutId = Js.Global.setTimeout(
//       () => resolve(. move->GameServer.dispatch(game, playerId)),
//       100,
//     )
//   })
// }
