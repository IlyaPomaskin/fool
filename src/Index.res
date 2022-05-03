open Types
open Utils
open Webapi

module Client = {
  @react.component
  let make = (~playerId) => {
    let ws = React.useMemo(_ => WebSocket.make("ws://localhost:3001/ws"))

    let (player, setPlayer) = React.useState(_ => None)
    let (inLobby, setInLobby) = React.useState(_ => None)
    let (inProgress, setInProgress) = React.useState(_ => None)
    let (error, setError) = React.useState(_ => None)

    React.useEffect0(() => {
      ws->WebSocket.addOpenListener(_ => {
        Js.log2("open", playerId)
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Connect, playerId)))
      })

      ws->WebSocket.addMessageListener(event => {
        Js.log3("message", playerId, event)
        let msg = switch WebSocket.messageAsText(event) {
        | Some(msg) => Serializer.deserializeServerMessage(msg)
        | None => Error(#SyntaxError("Message can't be parsed as json"))
        }

        Js.log3("received msg:", playerId, msg)

        Js.log2(
          "msg:",
          switch msg {
          | Ok(Connected(player)) =>
            "Connected: " ++ player.id ++ " " ++ player.sessionId->Option.getWithDefault("no sesid")
          | Ok(LobbyCreated(g)) => "LobbyCreated: " ++ g.gameId
          | Ok(LobbyUpdated(g)) => "LobbyUpdated: " ++ g.gameId
          | Ok(ProgressCreated(g)) => "ProgressCreated: " ++ g.gameId
          | Ok(ProgressUpdated(g)) => "ProgressUpdated: " ++ g.gameId
          | _ => "unk"
          },
        )

        switch msg {
        | Ok(gMsg) =>
          switch gMsg {
          | Connected(player) => {
              setPlayer(_ => Some(player))
              if playerId === "alice" {
                ws->WebSocket.sendText(
                  Serializer.serializeClientMessage(Lobby(Create, playerId, "")),
                )
              } else {
                ws->WebSocket.sendText(
                  Serializer.serializeClientMessage(Lobby(Enter, playerId, "gameId")),
                )
              }
            }
          | LobbyCreated(inLobby) => {
              setInLobby(_ => Some(inLobby))
              ws->WebSocket.sendText(
                Serializer.serializeClientMessage(Lobby(Enter, playerId, inLobby.gameId)),
              )
            }
          | LobbyUpdated(inLobby) => {
              setInLobby(_ => Some(inLobby))
              ws->WebSocket.sendText(
                Serializer.serializeClientMessage(Lobby(Enter, playerId, inLobby.gameId)),
              )
            }
          | ProgressCreated(inProgress) => {
              setInProgress(_ => Some(inProgress))
              ws->WebSocket.sendText(
                Serializer.serializeClientMessage(Lobby(Enter, playerId, inProgress.gameId)),
              )
            }
          | ProgressUpdated(inProgress) => setInProgress(_ => Some(inProgress))
          | Err(msg) => setError(_ => Some(msg))
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

    let (error, setError) = React.useState(() => None)

    let handleMove = move => {
      let game = inProgress->Option.getExn
      let nextGame =
        player->Utils.toResult("No player")->Result.map(player => Game.dispatch(game, player, move))

      switch nextGame {
      | Ok(_) => {
          WebSocket.sendText(
            ws,
            Serializer.serializeClientMessage(Progress(move, playerId, game.gameId)),
          )
          setError(_ => None)
        }
      | Error(err) => setError(_ => Some(err))
      }
    }

    switch (inLobby, inProgress) {
    | (Some(_), _) => <div> {uiStr("inLobby")} </div>
    | (_, Some(game)) =>
      <div>
        <Base.Button> {uiStr("connect")} </Base.Button>
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
    | _ => <div> {uiStr("err")} </div>
    }
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
