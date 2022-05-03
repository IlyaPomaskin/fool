open Types

let createLogger = (prefix: string, logFn, list: array<'a>) =>
  logFn(Array.concat([`[${prefix}]`], list))

let error = createLogger("error", Js.Console.errorMany)
let log = createLogger("log", Js.Console.logMany)
let info = createLogger("debug", Js.Console.infoMany)

let logMessageFromClient = msg => {
  info([
    "[client]",
    switch msg {
    | Player(event, pId) =>
      `player [$pid] ` ++
      switch event {
      | Connect => "Connect " ++ pId
      | Disconnect => "Disconnect " ++ pId
      | Ping => "Ping " ++ pId
      | Pong => "Pong " ++ pId
      }
    | Lobby(game, pId, gId) =>
      `lobby [${gId}][${pId}] ` ++
      switch game {
      | Create => "Create " ++ pId ++ " " ++ gId
      | Enter => "Enter " ++ pId ++ " " ++ gId
      | Ready => "Ready " ++ pId ++ " " ++ gId
      | Start => "Start " ++ pId ++ " " ++ gId
      }
    | Progress(game, pId, gId) =>
      `progress [${gId}][${pId}] ` ++
      switch game {
      | Take => "Take"
      | Pass => "Pass"
      | Beat(to, by) => `Beat to: ${Card.cardToString(to)} by: ${Card.cardToString(by)}`
      | Move(card) => `Move ${Card.cardToString(card)}`
      }
    },
  ])
}

let logMessageFromServer = (msg, playerId) =>
  Log.log([
    "[server]",
    switch msg {
    | Connected(player) =>
      "Connected: " ++ playerId ++ " " ++ player.sessionId->Option.getWithDefault("no sesid")
    | LobbyCreated(g) => "LobbyCreated: " ++ playerId ++ " " ++ g.gameId
    | LobbyUpdated(g) => "LobbyUpdated: " ++ playerId ++ " " ++ g.gameId
    | ProgressCreated(g) => "ProgressCreated: " ++ playerId ++ " " ++ g.gameId
    | ProgressUpdated(g) => "ProgressUpdated: " ++ playerId ++ " " ++ g.gameId
    | ServerError(msg) => "Error: " ++ playerId ++ " " ++ msg
    },
  ])
