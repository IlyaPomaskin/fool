open Types
open GameUtils

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

let startGame = (game: inLobby): result<state, string> => {
  let (players, deck) = Player.dealDeckToPlayers(Card.makeShuffledDeck(), game.players)

  let trump = getTrump(deck, players)
  let attacker = trump->Option.flatMap(tr => Player.findFirstAttacker(tr, players))
  let defender = attacker->Option.flatMap(at => Player.getNextPlayer(at, players))

  switch (trump, attacker, defender) {
  | (Some(trump), Some(a), Some(d)) =>
    Ok(
      InProgress({
        attacker: a,
        defender: d,
        table: list{},
        trump: trump,
        pass: list{},
        players: players,
        deck: deck,
      }),
    )
  | (None, _, _) => Error("Can't find trump")
  | _ => Error("Can't find next attacker/defender")
  }
}

let isValidMove = (game: inProgress, player: player, card: card) => {
  if isDefender(game, player) {
    Error("Defender can't make move")
  } else if !isTableHasCards(game) && !isAttacker(game, player) {
    Error("First move made not by attacker")
  } else if !isPlayerHasCard(player, card) {
    Error("Player don't have card")
  } else if isTableHasCards(game) && !isCorrectAdditionalCard(game, card) {
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
  if !GameUtils.isCanPass(game, player) {
    Error("Can't pass")
  } else {
    Ok(InProgress(game))
  }
}

let pass = (game: inProgress, player: player) => {
  let isValid = isValidPass(game, player)

  if Result.isError(isValid) {
    isValid
  } else if isAllPassed(game) && isAllTableBeaten(game) {
    let nextAttacker = Player.getNextPlayer(game.attacker, game.players)
    let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayer(p, game.players))

    switch (nextAttacker, nextDefender) {
    | (Some(a), Some(d)) =>
      Ok(
        InProgress({
          ...game,
          table: list{},
          pass: list{},
          attacker: a,
          defender: d,
        }),
      )
    | _ => Error("Can't find next attacker/defender")
    }
  } else {
    Ok(
      InProgress({
        ...game,
        pass: Utils.toggleArrayItem(game.pass, player),
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

  if Result.isError(isValid) {
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
  if !isDefender(game, player) {
    Error("Player is not defender")
  } else if !isTableHasCards(game) {
    Error("Table is empty")
  } else {
    Ok(InProgress(game))
  }
}

let take = (game: inProgress, player: player) => {
  let isValid = isValidTake(game, player)

  if Result.isError(isValid) {
    isValid
  } else {
    let nextAttacker = Player.getNextPlayer(game.defender, game.players)
    let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayer(p, game.players))

    switch (nextAttacker, nextDefender) {
    | (Some(a), Some(d)) =>
      Ok(
        InProgress({
          ...game,
          pass: list{},
          table: list{},
          attacker: a,
          defender: d,
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
    | _ => Error("Can't find next attacker/defender")
    }
  }
}
