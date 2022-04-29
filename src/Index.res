open Types
open Utils

type props = {game: int}

module Client = {
  @react.component
  let make = (~game, ~player, ~onAction) => {
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

let default = (_: props) => {
  let handleAction = (game, player, action) => {
    Socket.SClient.send(game.gameId, player.id, action)
    ()
  }

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
      | Ok(game) => <Client onAction={handleAction(game, author)} game={game} player={author} />
      | Error(e) => uiStr(e)
      }}
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch game {
      | Ok(game) => <Client onAction={handleAction(game, client)} game={game} player={client} />
      | Error(e) => uiStr(e)
      }}
    </div>
  </div>
}

let getServerSideProps = _ctx => {
  Js.Promise.resolve({
    "props": {
      game: 123,
    },
  })
}
