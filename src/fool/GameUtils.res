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
  game.table->Table.getFlatCards->List.has(card, Card.isCardEqualsByRank)
}

let isPlayerCanMove = (game: inProgress, player: player) => {
  if !Table.hasCards(game.table) {
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

let getTrump = (deck: deck, players: list<player>) => {
  let lastCard = Utils.lastListItem(deck)
  let lastPlayer = players->List.keep(p => List.length(p.cards) != 0)->Utils.lastListItem

  switch (lastCard, lastPlayer) {
  | (Some(card), _) => Some(fst(card))
  | (None, Some(player)) => player.cards->Utils.lastListItem->Option.map(fst)
  | (None, None) => None
  }
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
  isDefender(game, player) && Table.hasCards(game.table) && !Table.isAllBeaten(game.table)
}

let isCanPass = (game: inProgress, player: player) => {
  Table.hasCards(game.table) && !isDefender(game, player)
}

let isPassed = (game: inProgress, player: player) => {
  let inPassedList = game.pass->List.has(player, Utils.equals)
  let hasCards = !Card.isDeckEmpty(player.cards)

  hasCards ? inPassedList : true
}

let isAllPassed = (game: inProgress) => {
  game.players->List.keep(p => !isDefender(game, p))->List.every(isPassed(game))
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
