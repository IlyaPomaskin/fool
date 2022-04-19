type playerId = string

type sessionId = string

type player = {
  id: playerId,
  sessionId: sessionId,
  cards: Card.deck,
}

let make = (login: playerId) => {
  id: login,
  sessionId: "session:" ++ string_of_int(Js.Math.random_int(0, 10000000)),
  cards: list{},
}

let getNextPlayer = (p: player, players: list<player>) => {
  let playersCount = List.length(players)
  let nonExistingPlayerIndex = playersCount + 1
  let foundPlayerIndex = List.reduceWithIndex(players, nonExistingPlayerIndex, (
    prev,
    item,
    index,
  ) => item.id === p.id ? index : prev)

  let nextPlayer = List.get(players, foundPlayerIndex)

  switch nextPlayer {
  | None => List.get(players, 0)
  | Some(_) => nextPlayer
  }
}

let findFirstAttacker = (trump: Card.suit, players: list<player>) => {
  List.reduce(players, List.get(players, 0), (prev, next) => {
    let prevSmallestCard = Card.getSmallestValuableCard(
      trump,
      Belt.Option.getWithDefault(Belt.Option.map(prev, a => a.cards), list{}),
    )
    let nextSmallestCard = Card.getSmallestValuableCard(trump, next.cards)
    let smallestCard = Card.getSmallestCard(trump, prevSmallestCard, nextSmallestCard)

    smallestCard === nextSmallestCard ? Some(next) : prev
  })
}

let dealToPlayer = (deck: Card.deck, player: player) => {
  let requiredCardsAmount = max(0, 5 - List.length(player.cards))
  let (playerCards, nextDeck) = Card.dealCards(requiredCardsAmount, deck)

  ({...player, cards: playerCards}, nextDeck)
}

let dealDeckToPlayers = (deck: Card.deck, players: list<player>) => {
  let (nextPlayers, nextDeck) = List.reduce(players, ([], deck), (
    (accPlayers, accDeck),
    player,
  ) => {
    let (playerWithCards, nextDeck) = dealToPlayer(accDeck, player)

    (Array.concat(accPlayers, [playerWithCards]), nextDeck)
  })

  (List.fromArray(nextPlayers), nextDeck)
}

let removeCard = (player: player, card: Card.card) => {
  List.keep(player.cards, c => c !== card)
}

let isPlayerExists = (players: list<player>, player: player) => {
  List.has(players, player, Utils.equals)
}
