open Types

let isDefender = (game, player) => {
  game.defender.id === player.id
}

let isAttacker = (game, player) => {
  game.attacker.id === player.id
}

let isPlayerHasCard = (player, card) => {
  List.has(player.cards, card, Utils.equals)
}

let isCorrectAdditionalCard = (game, card) => {
  game.table->Table.getFlatCards->List.has(card, Card.isEqualsByRank)
}

let isPlayerCanMove = (game, player) => {
  if !Table.hasCards(game.table) {
    isAttacker(game, player)
  } else if isDefender(game, player) {
    false
  } else {
    true
  }
}

let getTrump = (deck, players) => {
  let lastCard = Utils.lastListItem(deck)
  let lastPlayer = players->List.keep(p => List.length(p.cards) != 0)->Utils.lastListItem

  switch (lastCard, lastPlayer) {
  | (Some(Visible(card)), _) => Some(fst(card))
  | (None, Some(player)) =>
    player.cards
    ->Utils.lastListItem
    ->Option.flatMap(card =>
      switch card {
      | Visible((suit, _)) => Some(suit)
      | Hidden => None
      }
    )
  | _ => None
  }
}

let isPlayerDone = (game, player) => {
  Utils.isEmpty(game.deck) && Utils.isEmpty(player.cards)
}

let isPlayerLose = (game, player) => {
  let playersWithCards = game.players->List.keep(p => p.cards->List.length > 0)
  let isOnlyOnePlayerLeft = playersWithCards->List.length === 1
  let isCurrentPlayerLeft = game.players->List.has(player, Utils.equals)

  isOnlyOnePlayerLeft && isCurrentPlayerLeft
}

let isCanTake = (game, player) => {
  isDefender(game, player) && Table.hasCards(game.table) && !Table.isAllBeaten(game.table)
}

let isCanPass = (game, player) => {
  Table.hasCards(game.table) && !isDefender(game, player)
}

let isPassed = (game, player) => {
  let inPassedList = game.pass->List.has(player, Utils.equals)
  let hasCards = !Utils.isEmpty(player.cards)

  hasCards ? inPassedList : true
}

let isAllPassed = game => {
  game.players->List.keep(p => !isDefender(game, p))->List.every(isPassed(game))
}

let isPlayerCanBeat = (game, player) => {
  let isThereCardsOnTable = !Utils.isEmpty(game.table)
  let unbeatedCards = Table.getUnbeatedCards(game.table)
  let isSameAmountOfCards = List.length(unbeatedCards) === List.length(player.cards)
  let canBeatEveryCard = List.every(unbeatedCards, toCard =>
    List.some(player.cards, byCard => Card.isValidBeat(toCard, byCard, game.trump))
  )

  isThereCardsOnTable && isSameAmountOfCards && canBeatEveryCard
}

let getPlayerGameState = (game, player) => {
  let isPlayerHasCards = !Utils.isEmpty(player.cards)
  let isThereCardsInDeck = !Utils.isEmpty(game.deck)
  let hasCardsForRound = isPlayerHasCards || isThereCardsInDeck
  let otherPlayersWithCardsAmount =
    game.players
    ->List.keep(p => !Utils.equals(p, player))
    ->List.keep(p => !Utils.isEmpty(p.cards))
    ->List.length
  let isThereArePlayersWithCards = otherPlayersWithCardsAmount > 0

  if hasCardsForRound {
    if isThereArePlayersWithCards || isPlayerCanBeat(game, player) {
      Playing
    } else {
      Lose
    }
  } else {
    switch isThereArePlayersWithCards {
    | true => Won
    | false => Draw
    }
  }
}

let findPlayerById = (game, playerId) => game.players->List.getBy(p => p.id === playerId)

let isFirstPlayerAddedToList = (players: list<player>, player) =>
  players
  ->List.get(List.length(players) - 1)
  ->Option.map(p => p.id === player.id)
  ->Option.getWithDefault(false)

let isCanStart = (game: inLobby, player) => {
  let isEnoughPlayers = List.length(game.players) > 1
  let isAllPlayersAreReady = List.cmpByLength(game.players, game.ready) === 0
  let isOwner = isFirstPlayerAddedToList(game.players, player)

  if !isOwner {
    Error("Only owner can start game")
  } else if !isEnoughPlayers {
    Error("Not enough players")
  } else if !isAllPlayersAreReady {
    Error("Not all players are ready")
  } else {
    Ok(game)
  }
}
