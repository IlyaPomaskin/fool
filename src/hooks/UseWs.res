open Types
open Webapi

type hookReturn = {
  player: option<player>,
  inLobby: option<inLobby>,
  inProgress: option<inProgress>,
  error: option<string>,
  handleMove: (inProgress, move) => unit,
  sendMessage: gameMessageFromClient => unit,
}

let hook = (playerId): hookReturn => {
  let (player, setPlayer) = React.useState(_ => None)
  let (inLobby, setInLobby) = React.useState(_ => None)
  let (inProgress, setInProgress) = React.useState(_ => None)
  let (error, setError) = React.useState(_ => None)

  let ws = React.useMemo0(_ => WebSocket.make("ws://localhost:3001/ws"))

  let sendMessage = React.useCallback1((message: gameMessageFromClient) => {
    ws->WebSocket.sendText(Serializer.serializeClientMessage(message))
  }, [ws])

  React.useEffect0(() => {
    ws->WebSocket.addOpenListener(_ => sendMessage(Player(Connect, playerId)))

    ws->WebSocket.addMessageListener(event => {
      event
      ->WebSocket.messageAsText
      ->Utils.toResult(#SyntaxError("Message from server cannot be parsed as text"))
      ->Result.flatMap(Serializer.deserializeServerMessage)
      ->Utils.tapResult(message => Log.logMessageFromServer(message, playerId))
      ->Result.map(message => {
        switch message {
        | ServerError(msg) => setError(_ => Some(msg))
        | _ => setError(_ => None)
        }

        switch message {
        | Connected(player) => setPlayer(_ => Some(player))
        | LobbyCreated(inLobby)
        | LobbyUpdated(inLobby) =>
          setInLobby(_ => Some(inLobby))
        | ProgressCreated(inProgress)
        | ProgressUpdated(inProgress) =>
          setInProgress(_ => Some(inProgress))
        | _ => ()
        }
      })
      ->ignore
    })

    ws->WebSocket.addCloseListener(_ => sendMessage(Player(Disconnect, playerId)))

    ws->WebSocket.addErrorListener(_ => {
      Log.error(["socket error for player", playerId])
    })

    Some(() => WebSocket.close(ws))
  })

  let handleMove = React.useCallback2((game, move) => {
    let nextGame =
      player
      ->Utils.toResult("No player")
      ->Result.flatMap(player => Game.dispatch(game, player, move))

    switch nextGame {
    | Ok(game) => sendMessage(Progress(move, playerId, game.gameId))
    | Error(error) => setError(_ => Some(error))
    }
  }, (player, ws))

  {
    player: player,
    inLobby: inLobby,
    inProgress: inProgress,
    error: error,
    handleMove: handleMove,
    sendMessage: sendMessage,
  }
}
