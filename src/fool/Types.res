type suit =
  | Spades
  | Hearts
  | Diamonds
  | Clubs

type rank =
  | Six
  | Seven
  | Eight
  | Nine
  | Ten
  | Jack
  | Queen
  | King
  | Ace

type plainCard = (suit, rank)

type card =
  | Visible(plainCard)
  | Hidden

type deck = list<card>

type tableCards = (card, option<card>)

type table = list<tableCards>

type playerId = string

type sessionId = option<string>

type player = {
  id: playerId,
  sessionId: sessionId,
  cards: deck,
}

type inLobby = {
  players: list<player>,
  ready: list<player>,
}

type inProgress = {
  attacker: player,
  defender: player,
  players: list<player>,
  trump: suit,
  deck: deck,
  table: table,
  pass: list<player>,
}

type state =
  | InLobby(inLobby)
  | InProgress(inProgress)

type move =
  | Take
  | Beat(card, card)
  | Pass
  | Move(card)

type playerWinState =
  | Playing
  | Done
  | Lose
  | Draw
