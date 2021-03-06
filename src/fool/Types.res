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

type sessionId = string

type player = {
  id: playerId,
  sessionId: sessionId,
  cards: deck,
}

type gameId = string

type inLobby = {
  owner: playerId,
  gameId: gameId,
  players: list<player>,
  ready: list<playerId>,
}

type inProgress = {
  gameId: gameId,
  attacker: playerId,
  defender: playerId,
  players: list<player>,
  disconnected: list<playerId>,
  trump: suit,
  deck: deck,
  table: table,
  pass: list<playerId>,
}

type gameState =
  | InLobby(inLobby)
  | InProgress(inProgress)

type move =
  | Take
  | Beat(card, card)
  | Pass
  | Move(card)

type playerWinState =
  | Playing
  | Won
  | Lose
  | Draw

type clientPlayerMessage =
  | Connect(gameId)
  | Disconnect
  | Ping
  | Pong

type clientLobbyMessage =
  | Create
  | Enter
  | Ready
  | Start

type beatPayload = {
  to: card,
  by: card,
}

type movePayload = {card: card}

type gameMessageFromClient =
  | Player(clientPlayerMessage, playerId)
  | Lobby(clientLobbyMessage, playerId, gameId)
  | Progress(move, playerId, gameId)

type gameMessageFromServer =
  | Connected(player)
  | LobbyCreated(inLobby)
  | LobbyUpdated(inLobby)
  | ProgressCreated(inProgress)
  | ProgressUpdated(inProgress)

  | ServerError(string)
  | LoginError(string)
  | RegisterError(string)

type clientScreen =
  | AuthorizationScreen
  | LobbySetupScreen
  | InLobbyScreen(inLobby)
  | InProgressScreen(inProgress)

type userApiResponse =
  | Registered(player)
  | LoggedIn(player)
  | UserError(string)
