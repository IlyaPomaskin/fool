open Types
open Utils
open Webapi

let logServerMessage = (msg, playerId) =>
  Log.log([
    "got msg",
    switch msg {
    | Connected(player) =>
      "Connected: " ++ playerId ++ " " ++ player.sessionId->Option.getWithDefault("no sesid")
    | LobbyCreated(g) => "LobbyCreated: " ++ playerId ++ " " ++ g.gameId
    | LobbyUpdated(g) => "LobbyUpdated: " ++ playerId ++ " " ++ g.gameId
    | ProgressCreated(g) => "ProgressCreated: " ++ playerId ++ " " ++ g.gameId
    | ProgressUpdated(g) => "ProgressUpdated: " ++ playerId ++ " " ++ g.gameId
    | Err(msg) => "Error: " ++ playerId ++ " " ++ msg
    },
  ])

module Client = {
  @react.component
  let make = (~playerId) => {
    let (player, setPlayer) = React.useState(_ => None)
    let (inLobby, setInLobby) = React.useState(_ => None)
    let (inProgress, setInProgress) = React.useState(_ => None)
    let (error, setError) = React.useState(_ => None)

    let ws = React.useMemo0(_ => WebSocket.make("ws://localhost:3001/ws"))
    React.useEffect0(() => {
      ws->WebSocket.addOpenListener(_ => {
        Log.info(["open", playerId])
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Connect, playerId)))
      })

      ws->WebSocket.addMessageListener(event => {
        event
        ->WebSocket.messageAsText
        ->toResult(#SyntaxError("Message from server cannot be parsed as text"))
        ->Result.flatMap(Serializer.deserializeServerMessage)
        ->Result.map(message => {
          logServerMessage(message, playerId)
          message
        })
        ->Result.map(message => {
          switch message {
          | Err(msg) => setError(_ => Some(msg))
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

      ws->WebSocket.addCloseListener(_ => {
        Log.info(["disconnect", playerId])
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Disconnect, playerId)))
      })

      ws->WebSocket.addErrorListener(_ => {
        Log.error(["socket error for player", playerId])
      })

      Some(() => WebSocket.close(ws))
    })

    let handleMove = (game, move) => {
      let nextGame =
        player
        ->Utils.toResult("No player")
        ->Result.flatMap(player => Game.dispatch(game, player, move))

      switch nextGame {
      | Ok(game) =>
        ws->WebSocket.sendText(
          Serializer.serializeClientMessage(Progress(move, playerId, game.gameId)),
        )
      | Error(error) => setError(_ => Some(error))
      }
    }

    <div>
      <div>
        <Base.Button
          onClick={_ => {
            ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Connect, playerId)))
          }}>
          {uiStr("create player")}
        </Base.Button>
        <Base.Button
          onClick={_ => {
            ws->WebSocket.sendText(Serializer.serializeClientMessage(Lobby(Create, playerId, "")))
          }}>
          {uiStr("create lobby")}
        </Base.Button>
        <Base.Button
          onClick={_ => {
            ws->WebSocket.sendText(
              Serializer.serializeClientMessage(Lobby(Enter, playerId, "gameId")),
            )
          }}>
          {uiStr("lobby connect")}
        </Base.Button>
        {switch inLobby {
        | Some(inLobby) =>
          <div>
            <Base.Button
              pressed={inLobby.ready->List.map(a => Some(a))->List.has(player, Utils.equals)}
              onClick={_ => {
                ws->WebSocket.sendText(
                  Serializer.serializeClientMessage(Lobby(Ready, playerId, inLobby.gameId)),
                )
              }}>
              {uiStr("lobby ready")}
            </Base.Button>
            <Base.Button
              onClick={_ => {
                ws->WebSocket.sendText(
                  Serializer.serializeClientMessage(Lobby(Start, playerId, inLobby.gameId)),
                )
              }}>
              {uiStr("lobby start")}
            </Base.Button>
          </div>
        | None => React.null
        }}
      </div>
      <div>
        {switch error {
        | Some(error) => <div> {uiStr("server error: " ++ error)} </div>
        | None => <div> {uiStr("no server error")} </div>
        }}
      </div>
      <div>
        {switch player {
        | Some(player) => <PlayerUI.Short player />
        | None => <div />
        }}
      </div>
      {switch inLobby {
      | Some(_) => <div> {uiStr("inLobby")} </div>
      | None => <div />
      }}
      {switch inProgress {
      | Some(game) =>
        <div>
          <GameUI.InProgressUI game />
          <div className="flex flex-wrap">
            {game.players->uiList(player =>
              <ClientUI
                key={player.id}
                isOwner={player.id === playerId}
                className="m-1 flex-initial w-96"
                player
                game
                onMove={handleMove(game)}
              />
            )}
          </div>
          <div>
            {error->Option.map(err => "Error: " ++ err)->Option.getWithDefault("No errors")->uiStr}
          </div>
        </div>
      | _ => <div />
      }}
    </div>
  }
}

let default = () => {
  <div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <Client playerId="alice" />
    </div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <Client playerId="bob" />
    </div>
  </div>
}
