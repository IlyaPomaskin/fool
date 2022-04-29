open Types

module LobbyGameMap = GameMap.MakeGameMap({
  type t = inLobby
})

module ProgressGameMap = GameMap.MakeGameMap({
  type t = inProgress
})

let gamesInLobby = LobbyGameMap.empty()
let gamesInProgress = ProgressGameMap.empty()

let author = Player.make("author")
let client = Player.make("client")
let players = list{author, client}

gamesInLobby->MutableMap.set("GAME_ID", {gameId: "GAME_ID", players: players, ready: players})

let startGame = (gameId: gameId): unit => {
  let nextGame = gamesInLobby->LobbyGameMap.get(gameId)->Result.flatMap(Game.startGame)

  switch nextGame {
  | Ok(game) => {
      MutableMap.set(gamesInProgress, gameId, game)

      game.players->List.forEach(player =>
        Socket.SServer.send(player, Game.maskForPlayer(player, game)->Game.toObject)
      )
    }
  | Error(err) => Socket.SServer.broadcast(gameId, {"error": err})
  }
}

let dispatch = (gameId, playerId, action) => {
  let game = gamesInProgress->ProgressGameMap.get(gameId)
  let player =
    game->Result.flatMap(game =>
      game->GameUtils.findPlayerById(playerId)->Utils.toResult(`Player ${playerId} not found`)
    )

  switch (game, player) {
  | (Ok(game), Ok(player)) =>
    Game.dispatch(game, player, action)->Result.map(Game.maskForPlayer(player))
  | (Error(err), _) => Error(err)
  | (_, Error(err)) => Error(err)
  }
}

startGame("GAME_ID")
