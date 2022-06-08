open Types
open Utils
open GameUtils

let makeGameInLobby = player => Ok(
  InLobby({
    gameId: "g" ++ string_of_int(Js.Math.random_int(0, 100)),
    owner: player.id,
    players: list{player},
    ready: list{player.id},
  }),
)

let logoutPlayer = (game, player) => {
  ...game,
  players: Belt.List.keep(game.players, item => item !== player),
}

let enterLobby = (game: inLobby, player) =>
  game
  ->MResult.makeOk
  ->Result.map(game => {
    let isPlayerInGame = List.has(game.players, player, (p1, p2) => p1.id == p2.id)

    InLobby({
      ...game,
      players: isPlayerInGame ? game.players : List.add(game.players, player),
    })
  })

let isValidToggleReady = (game: inLobby, player) => {
  if !List.has(game.players, player, Player.equals) {
    Error("Player not in game")
  } else {
    Ok(game)
  }
}

let toggleReady = (game, player) =>
  game
  ->MResult.makeOk
  ->Result.flatMap(lobby => isValidToggleReady(lobby, player))
  ->Result.map(lobby => {
    let inList = List.has(lobby.ready, player.id, equals)

    InLobby({
      ...lobby,
      ready: !inList
        ? List.add(lobby.ready, player.id)
        : lobby.ready->List.keep(pId => pId !== player.id),
    })
  })

let startGame = (game: inLobby, playerId) => {
  game
  ->MResult.makeOk
  ->Result.flatMap(lobby => GameUtils.isCanStart(lobby, playerId))
  ->Result.flatMap(game => {
    let (players, deck) = Deck.makeShuffled()->Player.dealDeckToPlayers(game.players)

    let trump = getTrump(deck, players)
    let attacker = trump->Option.flatMap(tr => Player.findFirstAttackerId(tr, players))
    let defender = attacker->Option.flatMap(at => Player.getNextPlayerId(at, players))

    switch (trump, attacker, defender) {
    | (Some(trump), Some(atId), Some(defId)) =>
      Ok(
        InProgress({
          gameId: game.gameId,
          attacker: atId,
          defender: defId,
          table: list{},
          trump: trump,
          pass: list{},
          players: players,
          deck: deck,
          disconnected: list{},
        }),
      )
    | (None, _, _) => Error("Can't find trump")
    | _ => Error("Can't find next attacker/defender")
    }
  })
}

let isValidMove = (game, player, card) => {
  let isDefenderHasEnoughCards =
    Player.getById(game.players, game.defender)
    ->Option.map(defender => List.length(defender.cards) >= List.length(game.table) + 1)
    ->Option.getWithDefault(false)

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
  let nextAttacker = Player.getNextPlayerId(game.attacker, game.players)
  let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayerId(p, game.players))
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
  let nextGameWithPassed = {...game, pass: Utils.toggleArrayItem(game.pass, player.id)}

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
    let nextAttacker = Player.getNextPlayerId(game.defender, game.players)
    let nextDefender = nextAttacker->Option.flatMap(p => Player.getNextPlayerId(p, game.players))
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

let dispatch = (game, player, action: move) =>
  switch action {
  | Take => take(game, player)
  | Beat(to, by) => beat(game, player, to, by)
  | Pass => pass(game, player)
  | Move(card) => move(game, player, card)
  }->Result.map(game => InProgress(game))

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
  players: game.players->List.map(Player.mask(playerId)),
  deck: game.deck->maskGameDeck,
}

let toObject = game =>
  {
    "gameId": game.gameId,
    "table": Table.toObject(game.table),
    "trump": Card.suitToString(game.trump),
    "attacker": game.attacker,
    "defender": game.defender,
    "players": game.players->List.map(Player.toObject)->List.toArray,
    "deck": Deck.toObject(game.deck),
    "pass": game.pass->List.toArray,
  }

let actionToObject = (action: move) =>
  switch action {
  | Take => "take"
  | Beat(to, by) => `beat to:${to->Card.cardToString} by:${by->Card.cardToString}`
  | Pass => "pass"
  | Move(card) => `move ${card->Card.cardToString}`
  }
