open Types
open Utils

let author = Player.make("author")

let players = list{author, Player.make("bbb"), Player.make("ccc")}

type props = {
  inProgress: inProgress,
  player: player,
}

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

  let dispatch = (action, game: inProgress, player) => {
    switch action {
    | Take => Game.take(game, player)
    | Beat(to, by) => Game.beat(game, to, by, player)
    | Pass => Game.pass(game, player)
    | Move(card) => Game.move(game, player, card)
    }->Result.map(maskForPlayer(player))
  }
}

let game = GameServer.make()

let default = ({player}: props) => {
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

  let handleMove = move => move->GameServer.dispatch(game, player)->handleGameChange

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
      inProgress: Result.getExn(Game.startGame({players: players, ready: players})),
      player: author,
    },
  })
}
