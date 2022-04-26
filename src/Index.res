open Types
open Utils

let players = list{Player.make("aaa"), Player.make("bbb"), Player.make("ccc")}

type props = {
  inProgress: state,
  inLobby: state,
}

let default = (p: props) => {
  let (game, nextGame) = React.useState(() => p.inProgress)
  let (error, setError) = React.useState(() => None)

  let handleGameChange = (game: result<state, string>) => {
    switch game {
    | Ok(game) => {
        nextGame(_ => game)
        setError(_ => None)
      }
    | Error(err) => setError(_ => Some(err))
    }
  }

  let handleMove = (m: move) => {
    switch game {
    | InLobby(_) => ()
    | InProgress(g) =>
      switch m {
      | Take(player) => handleGameChange(Game.take(g, player))
      | Beat(player, to, by) => handleGameChange(Game.beat(g, to, by, player))
      | Pass(player) => handleGameChange(Game.pass(g, player))
      | Move(player, card) => handleGameChange(Game.move(g, player, card))
      }
    }
  }

  switch game {
  | InProgress(game) =>
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
  | InLobby(_) => <div> {uiStr("In lobby")} </div>
  }
}

let getServerSideProps = _ctx => {
  Js.Promise.resolve({
    "props": {
      inProgress: Result.getExn(
        Game.startGame({
          players: players,
          ready: players,
        }),
      ),
      inLobby: Game.makeGameInLobby("owner"),
    },
  })
}
