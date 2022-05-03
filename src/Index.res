open Types
open Utils
open Webapi

module Client = {
  @react.component
  let make = (~playerId) => {
    let ws = React.useMemo0(_ => WebSocket.make("ws://localhost:3001/ws"))

    let (player, setPlayer) = React.useState(_ => None)
    let (inLobby, setInLobby) = React.useState(_ => None)
    let (inProgress, setInProgress) = React.useState(_ => None)
    let (error, setError) = React.useState(_ => None)

    React.useEffect0(() => {
      Js.log("CREATE SOCKET")

      ws->WebSocket.addOpenListener(_ => {
        Js.log2("open", playerId)
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Connect, playerId)))
      })

      ws->WebSocket.addMessageListener(event => {
        let msg = switch WebSocket.messageAsText(event) {
        | Some(msg) => Serializer.deserializeServerMessage(msg)
        | None => Error(#SyntaxError("Message can't be parsed as json"))
        }

        Js.log2("unbox", @unboxed @unboxed msg)

        Js.log2(
          "msg:",
          switch msg {
          | Ok(Connected(player)) =>
            "Connected: " ++ playerId ++ " " ++ player.sessionId->Option.getWithDefault("no sesid")
          | Ok(LobbyCreated(g)) => "LobbyCreated: " ++ playerId ++ " " ++ g.gameId
          | Ok(LobbyUpdated(g)) => "LobbyUpdated: " ++ playerId ++ " " ++ g.gameId
          | Ok(ProgressCreated(g)) => "ProgressCreated: " ++ playerId ++ " " ++ g.gameId
          | Ok(ProgressUpdated(g)) => "ProgressUpdated: " ++ playerId ++ " " ++ g.gameId
          | Ok(Err(msg)) => "Error: " ++ playerId ++ " " ++ msg
          | _ => "unk"
          },
        )

        switch msg {
        | Ok(gMsg) =>
          switch gMsg {
          | Connected(player) => setPlayer(_ => Some(player))
          | LobbyCreated(inLobby)
          | LobbyUpdated(inLobby) =>
            setInLobby(_ => Some(inLobby))
          | ProgressCreated(inProgress)
          | ProgressUpdated(inProgress) =>
            setInProgress(_ => Some(inProgress))
          | Err(msg) => {
              Js.log2("msg event", msg)
              setError(_ => Some(msg))
            }
          }
        | Error(err) => Js.log("received msg error: " ++ Jzon.DecodingError.toString(err))
        }
      })

      ws->WebSocket.addCloseListener(_ => {
        Js.log2("close", playerId)
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Disconnect, playerId)))
      })

      ws->WebSocket.addErrorListener(event => {
        Js.log3("error", playerId, event)
      })

      Some(
        () => {
          WebSocket.close(ws)
        },
      )
    })

    let handleMove = move => {
      // let nextGame = player->Utils.toResult("No player") // ->Result.map(player => Game.dispatch(game, player, move))

      switch inProgress {
      | Some(game) => {
          WebSocket.sendText(
            ws,
            Serializer.serializeClientMessage(Progress(move, playerId, game.gameId)),
          )
          setError(_ => None)
        }
      | None => ()
      // | Error(err) => setError(_ => Some(err))
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
                key={player.id} className="m-1 flex-initial w-96" player game onMove={handleMove}
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
    <div className="my-2 border rounded-md border-solid border-slate-500">
      <Client playerId="alice" />
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      <Client playerId="bob" />
    </div>
  </div>
}
