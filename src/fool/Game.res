type inLobby = {
  players: list<Player.player>,
  ready: list<Player.player>,
}

type inProgress = {
  attacker: Player.player,
  defender: Player.player,
  players: list<Player.player>,
  trump: Card.suit,
  deck: Card.deck,
  table: Card.table,
  pass: list<Player.player>,
}

type state = 
  | InLobby(inLobby)
  | InProgress(inProgress)

let makeGameInLobby = (authorId: Player.playerId) => InLobby({
  players: list{Player.make(authorId)},
  ready: list{},
})

let logoutPlayer = (game: inLobby, player: Player.player) => InLobby({
  ...game,
  players: Belt.List.keep(game.players, item => item !== player),
})

let enterGame = (game: inLobby, player: Player.player) => InLobby({
  ...game,
  players: List.add(game.players, player),
})

let toggleReady = (game: inLobby, player: Player.player) => InLobby({
  ...game,
  players: Utils.toggleArrayItem(game.players, player),
})

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
    Ok(InProgress({
      attacker: attacker,
      defender: defender,
      table: list{},
      trump: trump,
      pass: list{},
      players: players,
      deck: deck,
    }))
  | (Error(a), _, _) => Error(a)
  | (_, Error(a), _) => Error(a)
  | (_, _, Error(a)) => Error(a)
  }
}

let isDefender = (game: inProgress, player: Player.player) => {
  game.defender == player
}

let isPlayerHasCard = (player: Player.player, card: Card.card) => {
  List.has(player.cards, card, Utils.equals)
}

let isCorrectAdditionalCard = (game: inProgress, card: Card.card) => {
  game.table->Card.getFlatTableCards->Belt.List.has(card, Utils.equals)
}

let isValidMove = (game: inProgress, player: Player.player, card: Card.card) => {
  if !isDefender(game, player) {
    Error("Player is not a defender")
  } else if !isPlayerHasCard(player, card) {
    Error("Player don't have card")
  } else if !isCorrectAdditionalCard(game, card) {
    Error("Incorrect card")
  } else {
    Ok(InProgress(game))
  }
}

let move = (game: inProgress, player: Player.player, card: Card.card): result<
  state,
  string,
> => {
  let isValid = isValidMove(game, player, card)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(InProgress({
      ...game,
      players: List.map(game.players, p => {
        ...p,
        cards: Player.removeCard(p, card),
      }),
    }))
  }
}

let isValidPass = (game: inProgress, player: Player.player) => {
  if isDefender(game, player) {
    Error("Defender can't pass")
  } else if !Player.isPlayerExists(game.players, player) {
    Error("Player doesn't exists ")
  } else {
    Ok(InProgress(game))
  }
}

let pass = (game: inProgress, player: Player.player) => {
  let isValid = isValidPass(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(InProgress({
      ...game,
      pass: List.add(game.pass, player),
    }))
  }
}

let isValidBeat = (game: inProgress, to: Card.card, by: Card.card, player: Player.player) => {
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

let beat = (game: inProgress, to: Card.card, by: Card.card, player: Player.player) => {
  let isValid = isValidBeat(game, to, by, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(InProgress({
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
    }))
  }
}

let isValidTake = (game: inProgress, player: Player.player) => {
  if isDefender(game, player) {
    Error("Player is not defender")
  } else {
    Ok(InProgress(game))
  }
}

let take = (game: inProgress, player: Player.player) => {
  let isValid = isValidTake(game, player)

  if !Result.isError(isValid) {
    isValid
  } else {
    Ok(InProgress({
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
    }))
  }
}
