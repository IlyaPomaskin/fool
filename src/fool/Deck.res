open Types

let suitsList = list{Spades, Hearts, Diamonds, Clubs}

let ranksList = list{Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace}

let makeShuffled = () => {
  let suits = suitsList->List.make(9, _)->List.flatten
  let ranks = ranksList->List.make(4, _)->List.flatten

  List.shuffle(
    List.reduce2(suits, ranks, list{}, (acc, suit, rank) => List.add(acc, Visible(suit, rank))),
  )
}

let dealCards = (amount, deck) => {
  let cardsToDeal = List.keepWithIndex(deck, (_, index) => index <= amount - 1)
  let nextDeck = List.keepWithIndex(deck, (_, index) => index > amount - 1)

  (cardsToDeal, nextDeck)
}

let removeCard = (removedCard, deck) => List.keep(deck, card => !Card.isEquals(card, removedCard))

let getSmallestValuableCard = (trump, deck) =>
  deck
  ->List.map(card => Some(card))
  ->List.reduce(None, (prev, next) => {
    let nextSmallestCard = Card.getSmallest(trump, prev, next)

    switch (prev, nextSmallestCard) {
    | (None, None) => None
    | (Some(_), None) => prev
    | (_, Some(_)) => nextSmallestCard
    }
  })

let isEmpty = deck => List.length(deck) == 0

let mask = deck => deck->List.map(_ => Hidden)

let toObject = deck => deck->List.map(Card.cardToString)->List.toArray
