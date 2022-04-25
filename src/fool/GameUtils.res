open Types

let isDefender = (game: inProgress, player: player) => {
  game.defender.id === player.id
}

let isAttacker = (game: inProgress, player: player) => {
  game.attacker.id === player.id
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

let isPlayerLose = (game: inProgress, player: player) => {
  let playersWithCards = game.players->List.keep(p => p.cards->List.length > 0)
  let isOnlyOnePlayerLeft = playersWithCards->List.length === 1
  let isCurrentPlayerLeft = game.players->List.has(player, Utils.equals)

  isOnlyOnePlayerLeft && isCurrentPlayerLeft
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
  game.players->List.keep(p => !isDefender(game, p))->List.every(isPassed(game))
}

let isMaximumTableCards = (game: inProgress) => {
  game.table->List.length === 6
}

let getPlayerGameState = (game: inProgress, player: player) => {
  let isThereCardsInDeck = !Card.isDeckEmpty(game.deck)
  let isPlayerHasCards = !Card.isDeckEmpty(player.cards)
  let isOtherPlayersHasCards =
    game.players
    ->List.keep(p => !Utils.equals(p, player))
    ->List.keep(p => !Card.isDeckEmpty(p.cards))
    ->List.length > 0

  switch (isThereCardsInDeck, isOtherPlayersHasCards, isPlayerHasCards) {
  | (false, false, true) => Lose
  | (false, true, false) => Done
  | (false, false, false) => Draw
  | _ => Playing
  }
}
