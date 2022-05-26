open Types
open GameUtils

let makeGameInLobby = player => Ok({
  // FIXME remove debug code
  // gameId: "gameId:" ++ string_of_int(Js.Math.random_int(0, 10000000)),
  gameId: "g1",
  players: list{player},
  ready: list{player},
})

let logoutPlayer = (game: inLobby, player) => {
  ...game,
  players: Belt.List.keep(game.players, item => item !== player),
}

let enterGame = (game: inLobby, player) => {
  let isPlayerInGame = List.has(game.players, player, (p1, p2) => p1.id == p2.id)

  Ok({
    ...game,
    players: isPlayerInGame ? game.players : List.add(game.players, player),
  })
}

let isValidToggleReady = (game: inLobby, player) => {
  if !List.has(game.players, player, (p1, p2) => p1.id == p2.id) {
    Error("Player not in game")
  } else {
    Ok(game)
  }
}

let toggleReady = (game: inLobby, player) => {
  let isValid = isValidToggleReady(game, player)

  if Result.isError(isValid) {
    isValid
  } else {
    let inList = List.has(game.ready, player, (p1, p2) => p1.id == p2.id)

    Ok({
      ...game,
      ready: !inList
        ? List.add(game.ready, player)
        : game.ready->List.keep(p => p.id !== player.id),
    })
  }
}

let startGame = (game: inLobby) => {
  let (players, deck) = Deck.makeShuffled()->Player.dealDeckToPlayers(game.players)

  let trump = getTrump(deck, players)
  let attacker = trump->Option.flatMap(tr => Player.findFirstAttacker(tr, players))
  let defender = attacker->Option.flatMap(at => Player.getNextPlayer(at, players))

  switch (trump, attacker, defender) {
  | (Some(trump), Some(a), Some(d)) =>
    Ok({
      gameId: game.gameId,
      attacker: a,
      defender: d,
      table: list{},
      trump: trump,
      pass: list{},
      players: players,
      deck: deck,
    })
  | (None, _, _) => Error("Can't find trump")
  | _ => Error("Can't find next attacker/defender")
  }
}

let isValidMove = (game, player, card) => {
  let isDefenderHasEnoughCards = List.length(game.defender.cards) >= List.length(game.table) + 1

  if isDefender(game, player) {
    Error("Defender can't make move")
  } else if !Table.hasCards(game.table) && !isAttacker(game, player) {
    Error("First move made not by attacker")
  } else if Table.isMaximumCards(game.table) {
    Error("Maximum cards on table")
  } else if !isDefenderHasEnoughCards {
    Error("Defender don't have enough cards")
  } else if !isPlayerHasCard(player, card) {
    Error("Player don't have card")
  } else if Table.hasCards(game.table) && !isCorrectAdditionalCard(game, card) {
    Error("Incorrect card")
  } else {
    Ok(game)
  }
}

let move = (game, player, card) => {
  let isValid = isValidMove(game, player, card)

  if Result.isError(isValid) {
    isValid
  } else {
    Ok({
      ...game,
      players: List.map(game.players, p => {
        ...p,
        cards: Player.removeCard(p, card),
      }),
      table: game.table->List.add((card, None)),
    })
  }
}

let isValidPass = (game, player) => {
  if !GameUtils.isCanPass(game, player) {
    Error("Can't pass")
  } else {
    Ok(game)
  }
}

let finishRound = game => {
  let nextAttacker = Player.getNextPlayer(game.attacker, game.players)
  let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayer(p, game.players))
  let (nextPlayers, nextDeck) = Player.dealDeckToPlayers(game.deck, game.players)

  switch (nextAttacker, nextDefender) {
  | (Some(a), Some(d)) =>
    Ok({
      ...game,
      table: list{},
      pass: list{},
      attacker: a,
      defender: d,
      players: nextPlayers,
      deck: nextDeck,
    })
  | _ => Error("Can't find next attacker/defender")
  }
}

let pass = (game, player) => {
  let isValid = isValidPass(game, player)
  let nextGameWithPassed = {...game, pass: Utils.toggleArrayItem(game.pass, player)}

  if Result.isError(isValid) {
    isValid
  } else if isAllPassed(nextGameWithPassed) && Table.isAllBeaten(game.table) {
    finishRound(nextGameWithPassed)
  } else {
    Ok(nextGameWithPassed)
  }
}

let isValidBeat = (game, player, to, by) => {
  if !isDefender(game, player) {
    Error("Is not deffender")
  } else if !isPlayerHasCard(player, by) {
    Error("Player dont have card")
  } else if !Card.isValidBeat(to, by, game.trump) {
    Error("Invalid card beat")
  } else {
    Ok(game)
  }
}

let beat = (game, player, to, by) => {
  let isValid = isValidBeat(game, player, to, by)

  if Result.isError(isValid) {
    isValid
  } else {
    let playerWithoutCard = {
      ...player,
      cards: Player.removeCard(player, by),
    }

    Ok({
      {
        ...game,
        pass: list{},
        table: game.table->List.map(((firstCard, secondCard)) => {
          if Card.isEquals(firstCard, to) {
            (firstCard, Some(by))
          } else {
            (firstCard, secondCard)
          }
        }),
        players: List.map(game.players, p => {
          if Player.equals(p, player) {
            playerWithoutCard
          } else {
            p
          }
        }),
      }
    })
  }
}

let isValidTake = (game, player) => {
  if !isDefender(game, player) {
    Error("Player is not defender")
  } else if !Table.hasCards(game.table) {
    Error("Table is empty")
  } else {
    Ok(game)
  }
}

let take = (game, player) => {
  let isValid = isValidTake(game, player)

  if Result.isError(isValid) {
    isValid
  } else {
    let nextAttacker = Player.getNextPlayer(game.defender, game.players)
    let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayer(p, game.players))
    let nextPlayers = List.map(game.players, p =>
      if isDefender(game, p) {
        {...p, cards: List.concat(p.cards, Table.getFlatCards(game.table))}
      } else {
        p
      }
    )
    let (nextPlayers, nextDeck) = Player.dealDeckToPlayers(game.deck, nextPlayers)

    switch (nextAttacker, nextDefender) {
    | (Some(a), Some(d)) =>
      Ok({
        ...game,
        pass: list{},
        table: list{},
        attacker: a,
        defender: d,
        players: nextPlayers,
        deck: nextDeck,
      })
    | _ => Error("Can't find next attacker/defender")
    }
  }
}

let dispatch = (game, player, action: move) => {
  switch action {
  | Take => take(game, player)
  | Beat(to, by) => beat(game, player, to, by)
  | Pass => pass(game, player)
  | Move(card) => move(game, player, card)
  }
}

let maskGameDeck = deck => {
  let lastCardIndex = List.length(deck) - 1

  List.mapWithIndex(deck, (index, card) =>
    switch index == lastCardIndex {
    | true => card
    | false => Hidden
    }
  )
}

let maskForPlayer = (game, playerId) => {
  ...game,
  attacker: playerId->Player.mask(game.attacker),
  defender: playerId->Player.mask(game.defender),
  players: game.players->List.map(Player.mask(playerId)),
  deck: game.deck->maskGameDeck,
  pass: game.pass->List.map(Player.mask(playerId)),
}

let toObject = game =>
  {
    "gameId": game.gameId,
    "table": Table.toObject(game.table),
    "trump": Card.suitToString(game.trump),
    "attacker": Player.toStringShort(game.attacker),
    "defender": Player.toStringShort(game.defender),
    "players": game.players->List.map(Player.toObject)->List.toArray,
    "deck": Deck.toObject(game.deck),
    "pass": game.pass->List.map(Player.toStringShort)->List.toArray,
  }

let actionToObject = (action: move) =>
  switch action {
  | Take => "take"
  | Beat(to, by) => `beat to:${to->Card.cardToString} by:${by->Card.cardToString}`
  | Pass => "pass"
  | Move(card) => `move ${card->Card.cardToString}`
  }
