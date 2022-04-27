open Types
open Utils

let players = list{Player.make("aaa"), Player.make("bbb"), Player.make("ccc")}

type props = {inProgress: inProgress}

module GameServer = {
  let make = () => {
    Result.getExn(
      Game.startGame({
        players: players,
        ready: players,
      }),
    )
  }

  let maskForPlayer = (player, game) => {
    trump: game.trump,
    table: game.table,
    attacker: player->Player.mask(game.attacker),
    defender: player->Player.mask(game.defender),
    players: game.players->List.map(Player.mask(player)),
    deck: game.deck->Deck.mask,
    pass: game.pass->List.map(Player.mask(player)),
  }

  let dispatch = (game: inProgress, action) => {
    switch action {
    | Take(player) => Game.take(game, player)->Result.map(maskForPlayer(player))
    | Beat(player, to, by) => Game.beat(game, to, by, player)
    | Pass(player) => Game.pass(game, player)
    | Move(player, card) => Game.move(game, player, card)
    }
  }
}

let game = GameServer.make()

let default = _ => {
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
    handleGameChange(GameServer.dispatch(game, move))
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
      {error->Option.map(err => uiStr("Error: " ++ err))->Option.getWithDefault(uiStr("No errors"))}
    </div>
  </div>
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
    },
  })
}
