open Types
open Utils
open GameUtils

let makeGameInLobby = player =>
  InLobby({
    gameId: "g" ++ string_of_int(Js.Math.random_int(0, 100)),
    owner: player.id,
    players: list{player},
    ready: list{player.id},
  })->MResult.makeOk

let enterLobby = (game: inLobby, player) => {
  let isPlayerInGame = List.has(game.players, player, Player.equals)

  InLobby({
    ...game,
    players: isPlayerInGame ? game.players : List.add(game.players, player),
  })->MResult.makeOk
}

let leaveLobby = (game: inLobby, player) => Ok(
  InLobby({
    ...game,
    players: Belt.List.keep(game.players, item => item !== player),
  }),
)

let disconnectProgress = (game: inProgress, player) =>
  game
  ->MResult.makeOk
  ->MResult.validate("Player not in game", g => !List.has(g.players, player, Player.equals))
  ->Result.map(game => {
    let isDisconnected = List.has(game.disconnected, player.id, Utils.equals)

    InProgress({
      ...game,
      disconnected: isDisconnected ? game.disconnected : List.add(game.disconnected, player.id),
    })
  })

let enterProgress = (game: inProgress, player) =>
  game
  ->MResult.makeOk
  ->MResult.validate("Player not in game", g => !List.has(g.players, player, Player.equals))
  ->Result.map(game => {
    let isDisconnected = List.has(game.disconnected, player.id, Utils.equals)

    InProgress({
      ...game,
      disconnected: isDisconnected
        ? List.keep(game.disconnected, pId => pId !== player.id)
        : game.disconnected,
    })
  })

let isValidToggleReady = (game: inLobby, player) =>
  Ok(game)->MResult.validate("Player not in game", g => !List.has(g.players, player, Player.equals))

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

let startGame = (game: inLobby, playerId) =>
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

let isValidMove = (game, player, card) =>
  Ok(game)
  ->MResult.validate("Defender can't make move", g => isDefender(g, player))
  ->MResult.validate("First move made not by attacker", g =>
    !Table.hasCards(g.table) && !isAttacker(g, player)
  )
  ->MResult.validate("Maximum cards on table", g => Table.isMaximumCards(g.table))
  ->MResult.validate("Defender don't have enough cards", g => {
    let isDefenderHasEnoughCards =
      Player.getById(g.players, g.defender)
      ->Option.map(defender => List.length(defender.cards) >= List.length(g.table) + 1)
      ->Option.getWithDefault(false)

    !isDefenderHasEnoughCards
  })
  ->MResult.validate("Player don't have card", _ => !isPlayerHasCard(player, card))
  ->MResult.validate("Incorrect card", g =>
    Table.hasCards(g.table) && !isCorrectAdditionalCard(g, card)
  )

let move = (game, player, card) =>
  Ok(game)
  ->Result.flatMap(game => isValidMove(game, player, card))
  ->Result.map(game => {
    ...game,
    players: List.map(game.players, p => Player.removeCard(p, card)),
    table: game.table->List.add((card, None)),
  })

let isValidPass = (game, player) =>
  Ok(game)->MResult.validate("Can't pass", g => !GameUtils.isCanPass(g, player))

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

let pass = (game, player) =>
  Ok(game)
  ->Result.flatMap(game => isValidPass(game, player))
  ->Result.flatMap(game => {
    let nextGameWithPassed = {...game, pass: Utils.toggleListItem(game.pass, player.id)}

    if isAllPassed(nextGameWithPassed) && Table.isAllBeaten(game.table) {
      finishRound(nextGameWithPassed)
    } else {
      Ok(nextGameWithPassed)
    }
  })

let isValidBeat = (game, player, to, by) =>
  Ok(game)
  ->MResult.validate("Is not deffender", g => !isDefender(g, player))
  ->MResult.validate("Player dont have card", _ => !isPlayerHasCard(player, by))
  ->MResult.validate("Invalid card beat", g => !Card.isValidBeat(to, by, g.trump))

let beat = (game, player, to, by) =>
  Ok(game)
  ->Result.flatMap(game => isValidBeat(game, player, to, by))
  ->Result.map(game => {
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
        Player.removeCard(player, by)
      } else {
        p
      }
    }),
  })

let isValidTake = (game, player) =>
  Ok(game)
  ->MResult.validate("Player is not defender", g => !isDefender(g, player))
  ->MResult.validate("Table is empty", g => !Table.hasCards(g.table))

let take = (game, player) =>
  Ok(game)
  ->Result.flatMap(game => isValidTake(game, player))
  ->Result.flatMap(game => {
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
  })

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
