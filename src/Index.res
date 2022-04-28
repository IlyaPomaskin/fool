open Types
open Utils

type props = {
  authorGame: result<inProgress, string>,
  clientGame: result<inProgress, string>,
}

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

let default = ({authorGame, clientGame}: props) => {
  let handleAction = (game, player, action) => {
    Socket.SClient.send(game.gameId, player.id, action)
    ()
  }

  <div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch authorGame {
      | Ok(game) =>
        <Client onAction={handleAction(game, Server.author)} game={game} player={Server.author} />
      | Error(e) => uiStr(e)
      }}
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch clientGame {
      | Ok(game) =>
        <Client onAction={handleAction(game, Server.client)} game={game} player={Server.client} />
      | Error(e) => uiStr(e)
      }}
    </div>
  </div>
}

let getServerSideProps = _ctx => {
  Js.Promise.resolve({
    "props": {
      authorGame: Server.gamesInProgress
      ->Server.ProgressGameMap.get("GAME_ID")
      ->Result.map(Game.maskForPlayer(Server.author)),
      clientGame: Server.gamesInProgress
      ->Server.ProgressGameMap.get("GAME_ID")
      ->Result.map(Game.maskForPlayer(Server.client)),
    },
  })
}
