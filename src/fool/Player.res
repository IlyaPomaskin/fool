open Types

let make = login => {
  id: login,
  sessionId: "session:" ++ string_of_int(Js.Math.random_int(0, 10000000)),
  cards: list{},
}

let getNextPlayerId = (playerId, players) => {
  let playersWithCards = players->List.keep(p => List.length(p.cards) != 0)
  let nonExistingPlayerIndex = -1
  let foundPlayerIndex =
    playersWithCards->List.reduceWithIndex(nonExistingPlayerIndex, (prev, item, index) =>
      item.id === playerId ? index : prev
    )

  let nextPlayerId = List.get(playersWithCards, foundPlayerIndex + 1)->Option.map(p => p.id)

  switch nextPlayerId {
  | Some(_) => nextPlayerId
  | None => playersWithCards->List.get(0)->Option.map(p => p.id)
  }
}

let findFirstAttackerId = (trump, players) => {
  players
  ->List.reduce(List.get(players, 0), (prev, next) => {
    let prevSmallestCard = Deck.getSmallestValuableCard(
      trump,
      Belt.Option.getWithDefault(Belt.Option.map(prev, a => a.cards), list{}),
    )
    let nextSmallestCard = Deck.getSmallestValuableCard(trump, next.cards)
    let smallestCard = Card.getSmallest(trump, prevSmallestCard, nextSmallestCard)

    smallestCard === nextSmallestCard ? Some(next) : prev
  })
  ->Option.map(p => p.id)
}

let dealToPlayer = (deck, player) => {
  let requiredCardsAmount = max(0, 6 - List.length(player.cards))
  let (playerCards, nextDeck) = Deck.dealCards(requiredCardsAmount, deck)

  ({...player, cards: List.concat(player.cards, playerCards)}, nextDeck)
}

let dealDeckToPlayers = (deck, players) => {
  let (nextPlayers, nextDeck) = players->List.reduce(([], deck), (
    (accPlayers, accDeck),
    player,
  ) => {
    let (playerWithCards, nextDeck) = dealToPlayer(accDeck, player)

    (Array.concat(accPlayers, [playerWithCards]), nextDeck)
  })

  (List.fromArray(nextPlayers), nextDeck)
}

let removeCard = (player, card) => {
  List.keep(player.cards, c => !Card.isEquals(card, c))
}

let isPlayerExists = (players, player) => {
  List.has(players, player, Utils.equals)
}

let equals = (a, b) => a.id === b.id

let mask = (playerId, player) => {
  ...player,
  sessionId: playerId === player.id ? player.sessionId : "masked",
  cards: player.cards->List.map(card => player.id == playerId ? card : Hidden),
}

let toObject = player =>
  {
    "id": player.id,
    "sessionId": player.sessionId,
    "cards": player.cards->List.map(Card.cardToString)->List.toArray,
  }

let toStringShort = player =>
  {
    "id": player.id,
    "sessionId": player.sessionId,
  }

let getById = (list, id) => Utils.findInList(list, player => player.id === id)
