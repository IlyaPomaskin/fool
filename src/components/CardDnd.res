open Types

module CardId = {
  module Id = {
    type t = card
  }

  type t = Id.t
  external make: card => t = "%identity"
  external toString: t => card = "%identity"

  let eq = (c1, c2) => Card.cardToString(c1) == Card.cardToString(c2)
  let cmp = (c1, c2) => compare(Card.cardToString(c1), Card.cardToString(c2))

  module Comparable = Belt.Id.MakeComparable({
    type t = Id.t
    let cmp = cmp
  })

  module Map = {
    type t<'t> = Map.t<Id.t, 't, Comparable.identity>
    let make = () => Map.make(~id=module(Comparable))
  }
}

module DeckId = {
  module Id = {
    type t = card
  }

  type t = Id.t
  external make: card => t = "%identity"
  external toString: t => card = "%identity"

  let eq = (c1, c2) => Card.cardToString(c1) == Card.cardToString(c2)
  let cmp = (c1, c2) => compare(Card.cardToString(c1), Card.cardToString(c2))

  module Comparable = Belt.Id.MakeComparable({
    type t = Id.t
    let cmp = cmp
  })

  module Map = {
    type t<'t> = Map.t<Id.t, 't, Comparable.identity>
    let make = () => Map.make(~id=module(Comparable))
  }
}

module DraggableItem = {
  type t = CardId.t
  let eq = CardId.eq
  let cmp = CardId.cmp
}

module DroppableContainer = {
  type t = DeckId.t
  let eq = DeckId.eq
  let cmp = DeckId.cmp
}

module Cards = Dnd.Make(DraggableItem, DroppableContainer)
