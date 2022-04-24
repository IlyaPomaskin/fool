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

let isFirstMove = (game: inProgress) => {
  List.length(game.table) === 0
}

let isPlayerCanMove = (game: inProgress, player: player) => {
  if isFirstMove(game) {
    isAttacker(game, player)
  } else {
    false
  }

  //   if isDefender(game, player) {
  //     true
  //   } else if isFirstMove(game) && !isAttacker(game, player) {
  //     true
  //   } else {
  //     false
  //   }
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
