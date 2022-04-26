open Types

let make = (login: playerId) => {
  id: login,
  sessionId: "session:" ++ string_of_int(Js.Math.random_int(0, 10000000)),
  cards: list{},
}

let getNextPlayer = (p: player, players: list<player>) => {
  let playersWithCards = players->List.keep(p => List.length(p.cards) != 0)
  let nonExistingPlayerIndex = -1
  let foundPlayerIndex = playersWithCards->List.reduceWithIndex(nonExistingPlayerIndex, (
    prev,
    item,
    index,
  ) => {
    item.id === p.id ? index : prev
  })

  let nextPlayer = List.get(playersWithCards, foundPlayerIndex + 1)

  switch nextPlayer {
  | Some(_) => nextPlayer
  | None => List.get(playersWithCards, 0)
  }
}

let findFirstAttacker = (trump: suit, players: list<player>) => {
  List.reduce(players, List.get(players, 0), (prev, next) => {
    let prevSmallestCard = Deck.getSmallestValuableCard(
      trump,
      Belt.Option.getWithDefault(Belt.Option.map(prev, a => a.cards), list{}),
    )
    let nextSmallestCard = Deck.getSmallestValuableCard(trump, next.cards)
    let smallestCard = Card.getSmallest(trump, prevSmallestCard, nextSmallestCard)

    smallestCard === nextSmallestCard ? Some(next) : prev
  })
}

let dealToPlayer = (deck: deck, player: player) => {
  let requiredCardsAmount = max(0, 6 - List.length(player.cards))
  let (playerCards, nextDeck) = Deck.dealCards(requiredCardsAmount, deck)

  ({...player, cards: List.concat(player.cards, playerCards)}, nextDeck)
}

let dealDeckToPlayers = (deck: deck, players: list<player>) => {
  let (nextPlayers, nextDeck) = players->List.reduce(([], deck), (
    (accPlayers, accDeck),
    player,
  ) => {
    let (playerWithCards, nextDeck) = dealToPlayer(accDeck, player)

    (Array.concat(accPlayers, [playerWithCards]), nextDeck)
  })

  (List.fromArray(nextPlayers), nextDeck)
}

let removeCard = (player: player, card: card) => {
  List.keep(player.cards, c => c !== card)
}

let isPlayerExists = (players: list<player>, player: player) => {
  List.has(players, player, Utils.equals)
}
