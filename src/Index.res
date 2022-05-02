open Types
open Utils
open Webapi

module Client = {
  @react.component
  let make = (~game, ~player) => {
    let ws = React.useMemo(_ => WebSocket.make("ws://localhost:3001/ws"))

    React.useEffect(() => {
      ws->WebSocket.addOpenListener(_ => {
        Js.log("open")
        ws->WebSocket.sendText("Connection open")
      })

      ws->WebSocket.addMessageListener(event => {
        Js.log2("message", WebSocket.messageAsText(event))
      })

      ws->WebSocket.addCloseListener(_ => {
        Js.log("close")
      })

      Some(
        () => {
          WebSocket.close(ws)
        },
      )
    })

    let onAction = action => {
      Js.log2("action", @unbox action)
    }

    let (error, setError) = React.useState(() => None)

    let handleMove = move => {
      let nextGame = Game.dispatch(game, player, move)

      switch nextGame {
      | Ok(_) => {
          onAction(move)
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
      | Ok(game) => <Client game={game} player={author} />
      | Error(e) => uiStr(e)
      }}
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch game {
      | Ok(game) => <Client game={game} player={client} />
      | Error(e) => uiStr(e)
      }}
    </div>
  </div>
}
