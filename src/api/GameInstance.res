open Types

module LobbyGameMap = GameMap.MakeGameMap({
  type t = inLobby
})

module ProgressGameMap = GameMap.MakeGameMap({
  type t = inProgress
})

let gamesInLobby = LobbyGameMap.empty()
let gamesInProgress = ProgressGameMap.empty()

let author = Player.make("owner")
let client = Player.make("user2")
let players = list{author, client}

gamesInLobby->LobbyGameMap.set("GAME_ID", {gameId: "GAME_ID", players: players, ready: players})

let startGame = (gameId: gameId): unit => {
  let nextGame = gamesInLobby->LobbyGameMap.get(gameId)->Result.flatMap(Game.startGame)

  switch nextGame {
  | Ok(game) => {
      ProgressGameMap.set(gamesInProgress, gameId, game)

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
  Js.log4(
    "[predispatch]",
    game->Result.map(Game.toObject),
    player->Result.map(Player.toObject),
    action->Game.actionToObject,
  )

  let nextGame =
    player->Result.flatMap(player =>
      Result.flatMap(game, game => Game.dispatch(game, player, action))
    )

  let result = switch (nextGame, player) {
  | (Ok(game), Ok(player)) => {
      ProgressGameMap.set(gamesInProgress, game.gameId, game)
      Ok(Game.maskForPlayer(player, game))
    }
  | (Error(err), _) => Error(err)
  | (_, Error(err)) => Error(err)
  }

  switch result {
  | Ok(game) => Js.log2("[dispatch] ok ", Game.toObject(game))
  | Error(err) => Js.log2("[dispatch] error ", err)
  }
}

startGame("GAME_ID")
