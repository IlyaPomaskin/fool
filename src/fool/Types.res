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

type gameId = string

type inLobby = {
  gameId: gameId,
  players: list<player>,
  ready: list<player>,
}

type inProgress = {
  gameId: gameId,
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

type playerMessage =
  | Connect
  | Disconnect
  | Ping
  | Pong

type lobbyMessage =
  | Create
  | Enter
  | Ready
  | Start

type beatPayload = {
  to: card,
  by: card,
}

type movePayload = {card: card}

type progressMessage =
  | Pass
  | Take
  | Beat(beatPayload)
  | Move(movePayload)

type gameMessage =
  | Player(playerMessage, playerId)
  | Lobby(lobbyMessage, playerId, gameId)
  | Progress(progressMessage, playerId, gameId)
