open Types
open Utils

type props = {
  authorGame: result<inProgress, string>,
  clientGame: result<inProgress, string>,
}

module Client = {
  @react.component
  let make = (~game, ~player) => {
    let (game, nextGame) = React.useState(() => game)
    let (error, setError) = React.useState(() => None)

    let handleGameChange = game => {
      switch game {
      | Ok(game) => {
          nextGame(_ => game)
          setError(_ => None)
        }
      | Error(err) => setError(_ => Some(err))
      }
    }

    let handleMove = move => {
      // Promise.make((resolve, reject) => {
      //   let timeoutId = Js.Global.setTimeout(
      //     () => resolve(. move->GameServer.dispatch(game, player)),
      //     100,
      //   )
      // })->Promise.thenResolve(handleGameChange)
      ()
    }

    Js.log2("render", Game.toObject(game))

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
        {error
        ->Option.map(err => uiStr("Error: " ++ err))
        ->Option.getWithDefault(uiStr("No errors"))}
      </div>
    </div>
  }
}

let default = ({authorGame, clientGame}: props) => {
  <div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch authorGame {
      | Ok(game) => <Client game={game} player={Server.author} />
      | Error(e) => uiStr(e)
      }}
    </div>
    <div className="my-2 border rounded-md border-solid border-slate-500">
      {switch clientGame {
      | Ok(game) => <Client game={game} player={Server.client} />
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
