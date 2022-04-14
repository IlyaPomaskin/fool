type gameInLobby = {
  players: list<Player.player>,
  ready: list<Player.player>,
}

type gameInProgress = {
  attacker: Player.player,
  defender: Player.player,
  players: list<Player.player>,
  trump: Card.suit,
  deck: Card.deck,
  table: Card.table,
  pass: list<Player.player>,
}

let makeGameInLobby = (authorId: Player.playerId) => {
  players: list{Player.make(authorId)},
  ready: list{},
}

let logoutPlayer = (game: gameInLobby, player: Player.player) => {
  ...game,
  players: Belt.List.keep(game.players, item => item !== player),
}

let enterGame = (game: gameInLobby, player: Player.player) => {
  ...game,
  players: List.add(game.players, player),
}

let toggleReady = (game: gameInLobby, player: Player.player) => {
  ...game,
  players: Utils.toggleArrayItem(game.players, player),
}

let lastListItem = (list: list<'a>) => List.get(list, List.size(list) - 1)

let getTrump = (deck: Card.deck, players: list<Player.player>) => {
  let lastCard = lastListItem(deck)
  let lastPlayer = lastListItem(players)

  switch (lastCard, lastPlayer) {
  | (Some(card), _) => Some(fst(card))
  | (None, Some(player)) => Option.map(lastListItem(player.cards), fst)
  | (None, None) => None
  }
}

let startGame = (game: gameInLobby): result<gameInProgress, string> => {
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
    Ok({
      attacker: attacker,
      defender: defender,
      table: list{},
      trump: trump,
      pass: list{},
      players: players,
      deck: deck,
    })
  | (Error(a), _, _) => Error(a)
  | (_, Error(a), _) => Error(a)
  | (_, _, Error(a)) => Error(a)
  }
}

let isDefender = (game: gameInProgress, player: Player.player) => {
  game.defender == player
}

let isPlayerHasCard = (player: Player.player, card: Card.card) => {
  List.has(player.cards, card, Utils.equals)
}

let isCorrectAdditionalCard = (game: gameInProgress, card: Card.card) => {
  game.table->Card.getFlatTableCards->Belt.List.has(card, Utils.equals)
}

let isValidMove = (game: gameInProgress, player: Player.player, card: Card.card) => {
  if !isDefender(game, player) {
    Error("Player is not a defender")
  } else if !isPlayerHasCard(player, card) {
    Error("Player don't have card")
  } else if !isCorrectAdditionalCard(game, card) {
    Error("Incorrect card")
  } else {
    Ok(game)
  }
}

let move = (game: gameInProgress, player: Player.player, card: Card.card): result<
  gameInProgress,
  string,
> => {
  let isValid = isValidMove(game, player, card)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok({
      ...game,
      players: List.map(game.players, p => {
        ...p,
        cards: Player.removeCard(p, card),
      }),
    })
  }
}

let isValidPass = (game: gameInProgress, player: Player.player) => {
  if isDefender(game, player) {
    Error("Defender can't pass")
  } else if !Player.isPlayerExists(game.players, player) {
    Error("Player doesn't exists ")
  } else {
    Ok(game)
  }
}

let pass = (game: gameInProgress, player: Player.player) => {
  let isValid = isValidPass(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok({
      ...game,
      pass: List.add(game.pass, player),
    })
  }
}

let isValidBeat = (game: gameInProgress, to: Card.card, by: Card.card, player: Player.player) => {
  if !isDefender(game, player) {
    Error("Is not deffender")
  } else if isPlayerHasCard(player, by) {
    Error("Player dont have card")
  } else if Card.isValidTableBeat(to, by, game.trump) {
    Error("Wrong card to beat")
  } else {
    Ok(game)
  }
}

let beat = (game: gameInProgress, to: Card.card, by: Card.card, player: Player.player) => {
  let isValid = isValidBeat(game, to, by, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok({
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
    })
  }
}

let isValidTake = (game: gameInProgress, player: Player.player) => {
  if isDefender(game, player) {
    Error("Player is not defender")
  } else {
    Ok(game)
  }
}

let take = (game: gameInProgress, player: Player.player) => {
  let isValid = isValidTake(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok({
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
    })
  }
}
