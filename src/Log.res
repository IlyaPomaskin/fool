open Types

let createLogger = (prefix: string, logFn, list: array<'a>) =>
  logFn(Array.concat([`[${prefix}]`], list))

type loggers =
  | Ws
  | User
  | LoginPlayer
  | PlayersMap

let enabledLoggers = [LoginPlayer]

let loggerToString = level =>
  switch level {
  | Ws => "Ws"
  | User => "User"
  | LoginPlayer => "LoginPlayer"
  | PlayersMap => "PlayersMap"
  }

let error = createLogger("error", Js.Console.errorMany)
let log = createLogger("log", Js.Console.logMany)
let info = createLogger("info", Js.Console.infoMany)
let debugLogger = createLogger("debug", Js.Console.infoMany)
let debug = (logger, msgs) => {
  let isShouldBeLogged = Array.some(enabledLoggers, item => item === logger)

  if isShouldBeLogged {
    debugLogger(Array.concat([`[${loggerToString(logger)}]`], msgs))
  }
}

let clientMsgToString = msg =>
  switch msg {
  | Player(event, pId) =>
    `player [${pId}] ` ++
    switch event {
    | Disconnect => "Disconnect"
    | Ping => "Ping"
    | Pong => "Pong"
    }
  | Lobby(game, pId, gId) =>
    `lobby [${gId}][${pId}] ` ++
    switch game {
    | Create => "Create"
    | Enter => "Enter"
    | Ready => "Ready"
    | Start => "Start"
    }
  | Progress(game, pId, gId) =>
    `progress [${gId}][${pId}] ` ++
    switch game {
    | Take => "Take"
    | Pass => "Pass"
    | Beat(to, by) => `Beat to: ${Card.cardToString(to)} by: ${Card.cardToString(by)}`
    | Move(card) => `Move ${Card.cardToString(card)}`
    }
  }

let logMessageFromClient = msg => info(["[client]", clientMsgToString(msg)])

let serverMsgToString = msg =>
  switch msg {
  | Connected(player) => `Connected ${player.id}`
  | LobbyCreated(g) => `[${g.gameId}] LobbyCreated`
  | LobbyUpdated(g) => `[${g.gameId}] LobbyUpdated`
  | ProgressCreated(g) => `[${g.gameId}] ProgressCreated`
  | ProgressUpdated(g) => `[${g.gameId}] ProgressUpdated`
  | LoginError(err) => `LoginError: ${err}`
  | RegisterError(err) => `RegisterError: ${err}`
  | ServerError(msg) => `ServerError: ${msg}`
  }

let logMessageFromServer = (msg, player) => {
  let playerId = player->Option.map(p => p.id)->Option.getWithDefault("No player")

  info([`[server] [${playerId}]`, serverMsgToString(msg)])
}
