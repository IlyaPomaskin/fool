open Types
open Utils

type props = {
  game: result<state, string>,
  player: player,
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

let default = ({game, player}: props) => {
  switch game {
  | Ok(InProgress(game)) => <Client game={game} player />
  | Ok(_) => uiStr("lobby?")
  | Error(e) => uiStr(e)
  }
}

let getServerSideProps = _ctx => {
  let player = Server.author

  Js.Promise.resolve({
    "props": {
      game: Server.getGame("GAME_ID")->Result.map(game =>
        switch game {
        | InProgress(game) => InProgress(Game.maskForPlayer(player, game))
        | InLobby(g) => InLobby(g)
        }
      ),
      player: player,
    },
  })
}
