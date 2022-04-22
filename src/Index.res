open Types
open UiUtils

let players = list{Player.make("aaa"), Player.make("bbb"), Player.make("ccc")}

type props = {
  inProgress: state,
  inLobby: state,
}

let default = (p: props) => {
  let (game, nextGame) = React.useState(() => p.inProgress)
  let (error, setError) = React.useState(() => None)

  let handleGameChange = (a: result<state, string>) => {
    switch a {
    | Ok(nextG) => {
        nextGame(_ => nextG)
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
  | InProgress(g) => Js.log(g)
  | _ => ()
  }

  switch game {
  | InProgress(g) =>
    <div>
      <GameUI.InProgressUI game={g} onMove={handleMove} />
      <div>
        {switch error {
        | Some(err) => uiStr("Error: " ++ err)
        | None => uiStr("No errors")
        }}
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
