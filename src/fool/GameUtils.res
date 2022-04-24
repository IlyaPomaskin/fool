open Types

let isDefender = (game: inProgress, player: player) => {
  game.defender == player
}

let isAttacker = (game: inProgress, player: player) => {
  game.attacker == player
}

let isPlayerHasCard = (player: player, card: card) => {
  List.has(player.cards, card, Utils.equals)
}

let isCorrectAdditionalCard = (game: inProgress, card: card) => {
  game.table->Card.getFlatTableCards->List.has(card, Card.isCardEqualsByRank)
}

let isTableHasCards = (game: inProgress) => {
  List.length(game.table) > 0
}

let isPlayerCanMove = (game: inProgress, player: player) => {
  if !isTableHasCards(game) {
    isAttacker(game, player)
  } else if isDefender(game, player) {
    false
  } else {
    true
  }
}

let toggleReady = (game: inLobby, player: player) => InLobby({
  ...game,
  players: Utils.toggleArrayItem(game.players, player),
})

let lastListItem = (list: list<'a>) => List.get(list, List.size(list) - 1)

let getTrump = (deck: deck, players: list<player>) => {
  let lastCard = lastListItem(deck)
  let lastPlayer = lastListItem(players->List.keep(p => List.length(p.cards) != 0))

  switch (lastCard, lastPlayer) {
  | (Some(card), _) => Some(fst(card))
  | (None, Some(player)) => Option.map(lastListItem(player.cards), fst)
  | (None, None) => None
  }
}

let isAllTableBeaten = (game: inProgress) => {
  let isBeaten = game.table->List.every(((_, by)) => Option.isSome(by))

  isTableHasCards(game) && isBeaten
}

let isPlayerDone = (game: inProgress, player: player) => {
  Card.isDeckEmpty(game.deck) && Card.isDeckEmpty(player.cards)
}

let isCanTake = (game: inProgress, player: player) => {
  isDefender(game, player) && isTableHasCards(game) && !isAllTableBeaten(game)
}

let isCanPass = (game: inProgress, player: player) => {
  isTableHasCards(game) && !isDefender(game, player)
}

let isPassed = (game: inProgress, player: player) => {
  let inPassedList = game.pass->List.has(player, Utils.equals)
  let hasCards = !Card.isDeckEmpty(player.cards)

  hasCards ? inPassedList : true
}

let isAllPassed = (game: inProgress) => {
  game.players->List.every(isPassed(game))
}
