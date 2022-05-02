open Types
open Utils
open Webapi

module Client = {
  @react.component
  let make = (~game: inProgress, ~playerId) => {
    let ws = React.useMemo(_ => WebSocket.make("ws://localhost:3001/ws"))

    let (player, setPlayer) = React.useState(_ => None)

    React.useEffect(() => {
      ws->WebSocket.addOpenListener(_ => {
        Js.log("open")
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Connect, playerId)))
      })

      ws->WebSocket.addMessageListener(event => {
        Js.log2("message", event)
        let msg = switch WebSocket.messageAsText(event) {
        | Some(msg) => Serializer.deserializeServerMessage(msg)
        | None => Error(#SyntaxError("Message can't be parsed as json"))
        }

        Js.log2("received msg:", msg)

        switch msg {
        | Ok(gMsg) =>
          switch gMsg {
          | Connected(playerId) => ""
          | _ => "unhandled gMsg"
          }
        | Error(err) => "received msg error: " ++ Jzon.DecodingError.toString(err)
        } |> Js.log2("received msg dispatch:")
      })

      ws->WebSocket.addCloseListener(_ => {
        Js.log("close")
        ws->WebSocket.sendText(Serializer.serializeClientMessage(Player(Disconnect, playerId)))
      })

      ws->WebSocket.addErrorListener(event => {
        Js.log2("error", event)
      })

      Some(
        () => {
          WebSocket.close(ws)
        },
      )
    })

    let (error, setError) = React.useState(() => None)

    let handleMove = move => {
      let nextGame =
        player->Utils.toResult("No player")->Result.map(player => Game.dispatch(game, player, move))

      switch nextGame {
      | Ok(_) => {
          setError(_ => None)
          // WebSocket.sendText(
          //   ws,
          //   Serializer.serializeClientMessage(Progress(action, playerId, game.gameId)),
          // )
          setError(_ => None)
        }
      | Error(err) => setError(_ => Some(err))
      }
    }

    <div>
      <GameUI.InProgressUI game={game} />
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
  }
}

let default = () => {
  let state = React.useMemo(() => {
    let author = Player.make("owner")
    let client = Player.make("user2")
    let players = list{author, client}

    {
      "game": Game.startGame({gameId: "GAME_ID", players: players, ready: players}),
      "author": author,
      "client": client,
    }
  })

  let game = state["game"]
  let author = state["author"]
  let client = state["client"]

  <div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch game {
      | Ok(game) => <Client game={game} playerId="alice" />
      | Error(e) => uiStr(e)
      }}
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch game {
      | Ok(game) => <Client game={game} playerId="bob" />
      | Error(e) => uiStr(e)
      }}
    </div>
  </div>
}
