open Types

let makeGameInLobby = (authorId: playerId) => InLobby({
  players: list{Player.make(authorId)},
  ready: list{},
})

let logoutPlayer = (game: inLobby, player: player) => InLobby({
  ...game,
  players: Belt.List.keep(game.players, item => item !== player),
})

let enterGame = (game: inLobby, player: player) => InLobby({
  ...game,
  players: List.add(game.players, player),
})

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

let startGame = (game: inLobby): result<state, string> => {
  let (players, deck) = Player.dealDeckToPlayers(Card.makeShuffledDeck(), game.players)

  let trump = Option.mapWithDefault(getTrump(deck, players), Error("No trump"), Utils.makeOk)
  let attacker = Result.flatMap(trump, r =>
    Option.mapWithDefault(Player.findFirstAttacker(r, players), Error("No attacker"), Utils.makeOk)
  )
  let defender = Result.flatMap(attacker, a =>
    Option.mapWithDefault(Player.getNextPlayer(a, players), Error("No deffender"), Utils.makeOk)
  )

  switch (trump, attacker, defender) {
  | (Ok(trump), Ok(attacker), Ok(defender)) =>
    Ok(
      InProgress({
        attacker: attacker,
        defender: defender,
        table: list{},
        trump: trump,
        pass: list{},
        players: players,
        deck: deck,
      }),
    )
  | (Error(a), _, _) => Error(a)
  | (_, Error(a), _) => Error(a)
  | (_, _, Error(a)) => Error(a)
  }
}

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

let isValidMove = (game: inProgress, player: player, card: card) => {
  if isDefender(game, player) {
    Error("Defender can't make move")
  } else if isFirstMove(game) && !isAttacker(game, player) {
    Error("First move made not by attacker")
  } else if !isPlayerHasCard(player, card) {
    Error("Player don't have card")
  } else if !isFirstMove(game) && !isCorrectAdditionalCard(game, card) {
    Error("Incorrect card")
  } else {
    Ok(InProgress(game))
  }
}

let move = (game: inProgress, player: player, card: card): result<state, string> => {
  let isValid = isValidMove(game, player, card)

  if Result.isError(isValid) {
    isValid
  } else {
    Ok(
      InProgress({
        ...game,
        players: List.map(game.players, p => {
          ...p,
          cards: Player.removeCard(p, card),
        }),
        table: game.table->List.add((card, None)),
      }),
    )
  }
}

let isValidPass = (game: inProgress, player: player) => {
  if isDefender(game, player) {
    Error("Defender can't pass")
  } else if !Player.isPlayerExists(game.players, player) {
    Error("Player doesn't exists ")
  } else {
    Ok(InProgress(game))
  }
}

let pass = (game: inProgress, player: player) => {
  let isValid = isValidPass(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(
      InProgress({
        ...game,
        pass: List.add(game.pass, player),
      }),
    )
  }
}

let isValidBeat = (game: inProgress, to: card, by: card, player: player) => {
  if !isDefender(game, player) {
    Error("Is not deffender")
  } else if isPlayerHasCard(player, by) {
    Error("Player dont have card")
  } else if Card.isValidTableBeat(to, by, game.trump) {
    Error("Wrong card to beat")
  } else {
    Ok(InProgress(game))
  }
}

let beat = (game: inProgress, to: card, by: card, player: player) => {
  let isValid = isValidBeat(game, to, by, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(
      InProgress({
        ...game,
        players: List.map(game.players, p => {
          ...p,
          cards: Player.removeCard(p, by),
        }),
        table: List.map(game.table, ((firstCard, secondCard)) => {
          if Card.isCardEquals(firstCard, to) {
            (firstCard, Some(by))
          } else {
            (firstCard, secondCard)
          }
        }),
      }),
    )
  }
}

let isValidTake = (game: inProgress, player: player) => {
  if isDefender(game, player) {
    Error("Player is not defender")
  } else {
    Ok(InProgress(game))
  }
}

let take = (game: inProgress, player: player) => {
  let isValid = isValidTake(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(
      InProgress({
        ...game,
        table: list{},
        players: List.map(game.players, p =>
          if isDefender(game, p) {
            {
              ...p,
              cards: List.concat(p.cards, Card.getFlatTableCards(game.table)),
            }
          } else {
            p
          }
        ),
      }),
    )
  }
}
