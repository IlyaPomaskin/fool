open Types

let players = list{
  Player.make("aaa"),
  Player.make("bbb"),
  Player.make("ccc"),
  Player.make("ddd"),
  Player.make("eee"),
  Player.make("fff"),
}

type props = {
  inProgress: state,
  inLobby: state,
}

let default = (p: props) =>
  <div> <GameUI game={p.inProgress} /> <br /> <GameUI game={p.inLobby} /> </div>

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
