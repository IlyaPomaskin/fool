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

type containerType =
  | ToCard(card)
  | ToTable

module ContainerId = {
  module Id = {
    type t = containerType
  }

  type t = Id.t
  external make: containerType => t = "%identity"
  external toString: t => containerType = "%identity"

  let eq = (c1, c2) =>
    switch (c1, c2) {
    | (ToCard(c1), ToCard(c2)) => Card.cardToString(c1) == Card.cardToString(c2)
    | (ToTable, ToTable) => true
    | _ => false
    }
  let cmp = (c1, c2) =>
    switch (c1, c2) {
    | (ToCard(c1), ToCard(c2)) => compare(Card.cardToString(c1), Card.cardToString(c2))
    | (ToTable, ToTable) => 0
    | (ToCard(_), ToTable) => -1
    | (ToTable, ToCard(_)) => 1
    }

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
  type t = ContainerId.t
  let eq = ContainerId.eq
  let cmp = ContainerId.cmp
}

module Cards = Dnd.Make(DraggableItem, DroppableContainer)
