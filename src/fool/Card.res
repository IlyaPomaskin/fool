type suit =
  | Spades
  | Hearts
  | Diamonds
  | Clubs

type rank =
  | Six
  | Seven
  | Eight
  | Nine
  | Ten
  | Jack
  | Queen
  | King
  | Ace

type card = (suit, rank)

type deck = list<card>

type tableCards = (card, option<card>)

type table = list<tableCards>

let suitsList = list{Spades, Hearts, Diamonds, Clubs}

let ranksList = list{Six, Seven, Eight, Nine, Ten, Jack, Queen, King, Ace}

let makeShuffledDeck = (): deck => {
  let suits = suitsList->List.make(9, _)->List.flatten
  let ranks = ranksList->List.make(4, _)->List.flatten

  List.shuffle(List.reduce2(suits, ranks, list{}, (acc, suit, rank) => List.add(acc, (suit, rank))))
}

let dealCards = (amount: int, deck: deck) => {
  let cardsToDeal = List.keepWithIndex(deck, (_, index) => index <= amount)
  let nextDeck = List.keepWithIndex(deck, (_, index) => index > amount)

  (cardsToDeal, nextDeck)
}

let isCardEqualsBySuit = ((s1, _): card, (s2, _): card) => s1 === s2

let isCardEqualsByRank = ((_, r1): card, (_, r2): card) => r1 === r2

let isCardEquals = (first: card, second: card) =>
  isCardEqualsBySuit(first, second) && isCardEqualsByRank(first, second)

let ltCardByRank = ((_, r1): card, (_, r2): card) => r1 < r2

let sortCardsByRank = (first: card, second: card) => ltCardByRank(first, second) ? -1 : 1

let removeCard = (removedCard: card, deck: deck) =>
  List.keep(deck, card => !isCardEquals(card, removedCard))

let isAllCardsAreBeat = (table: list<tableCards>) =>
  List.every(table, ((card, by)) =>
    switch (card, by) {
    | (_, None) => false
    | (card, Some(by)) => !ltCardByRank(card, by)
    }
  )

let isTrump = (trump: suit, (suit, _): card) => trump === suit

let getSmallestCard = (trump: suit, first: option<card>, second: option<card>) => {
  switch (first, second) {
  | (None, None) => None
  | (None, Some(_)) => second
  | (Some(_), None) => first
  | (Some(fst), Some(snd)) =>
    let isFstTrump = isTrump(trump, fst)
    let isSndTrump = isTrump(trump, snd)

    switch (isFstTrump, isSndTrump) {
    | (true, false) => first
    | (false, true) => second
    | _ => ltCardByRank(fst, snd) ? first : second
    }
  }
}

let getSmallestValuableCard = (trump: suit, deck: deck) =>
  deck
  ->List.map(card => Some(card))
  ->List.reduce(None, (prev, next) => {
    let nextSmallestCard = getSmallestCard(trump, prev, next)

    switch (prev, nextSmallestCard) {
    | (None, None) => None
    | (Some(_), None) => prev
    | (_, Some(_)) => nextSmallestCard
    }
  })

let isBeatByTrump = (to: card, by: card, trump: suit) => {
  fst(to) != trump && fst(by) == trump
}

let isValidTableBeat = (to: card, by: card, trump: suit) => {
  isCardEqualsBySuit(to, by) && ltCardByRank(to, by) && isBeatByTrump(to, by, trump)
}

let getFlatTableCards = (table: table) => {
  table
  ->List.map(((firstCard, secondCard)) => list{Some(firstCard), secondCard})
  ->List.flatten
  ->List.keepMap(c => c)
}
