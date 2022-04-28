open Types

module GameMap = {
  module GameId = Belt.Id.MakeComparable({
    type t = gameId
    let cmp: (gameId, gameId) => int = Pervasives.compare
  })

  type t = Belt.MutableMap.t<GameId.t, state, GameId.identity>

  let empty = () => Belt.MutableMap.make(~id=module(GameId))
}

let games = GameMap.empty()

let startGame = (gameId: gameId): unit => {
  let nextGame =
    games
    ->MutableMap.get(gameId)
    ->Option.map(game => Ok(game))
    ->Option.getWithDefault(Error("game " ++ gameId ++ "not found"))
    ->Result.flatMap(game =>
      switch game {
      | InProgress(_) => Error("game already started")
      | InLobby(game) => Ok(game)
      }
    )
    ->Result.flatMap(Game.startGame)

  switch nextGame {
  | Ok(game) => {
      MutableMap.set(games, gameId, InProgress(game))

      game.players->List.forEach(player =>
        Socket.Server.send(player, Game.maskForPlayer(player, game)->Game.toObject)
      )
    }
  | Error(err) => Socket.Server.broadcast(gameId, {"error": err})
  }
}

let getGame = gameId =>
  games
  ->MutableMap.get(gameId)
  ->Option.map(game => Ok(game))
  ->Option.getWithDefault(Error(`Game ${gameId} not found`))

let author = Player.make("author")
let client = Player.make("client")
let players = list{author, client}

games->MutableMap.set("GAME_ID", InLobby({gameId: "GAME_ID", players: players, ready: players}))

startGame("GAME_ID")

// let dispatch = (action, gameId, playerId) => {
//   let game = games->MutableMap.String.get(gameId)
//   let player = game->Option.flatMap(game => GameUtils.findPlayerById(game, playerId))

//   switch (game, player) {
//   | (None, _) => Error("Game not found")
//   | (_, None) => Error("Player not found")
//   | (Some(game), Some(player)) =>
//     switch action {
//     | Take => Game.take(game, player)
//     | Beat(to, by) => Game.beat(game, to, by, player)
//     | Pass => Game.pass(game, player)
//     | Move(card) => Game.move(game, player, card)
//     }->Result.map(maskForPlayer(player))
//   }
// }
