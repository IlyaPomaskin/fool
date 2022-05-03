open Types
open Storage

let gamesInLobby = LobbyGameMap.empty()
let gamesInProgress = ProgressGameMap.empty()
let players = PlayersMap.empty()

let connectPlayer = playerId => {
  let player = PlayersMap.get(players, playerId)

  switch player {
  | Ok(player) => Ok(player)
  | Error(_) => players->PlayersMap.create(playerId)
  }
}

let createLobby = playerId => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => gamesInLobby->LobbyGameMap.create(player))
}

let enterGame = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player => {
    gamesInLobby->LobbyGameMap.get(gameId)->Result.flatMap(lobby => Game.enterGame(lobby, player))
  })
  ->Result.flatMap(game => gamesInLobby->LobbyGameMap.set(game.gameId, game))
}

let toggleReady = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(player =>
    gamesInLobby->LobbyGameMap.update(gameId, game =>
      Game.toggleReady(game, player)->Result.getWithDefault(game)
    )
  )
}

let startGame = (playerId, gameId) => {
  players
  ->PlayersMap.get(playerId)
  ->Result.flatMap(_ => gamesInLobby->LobbyGameMap.get(gameId))
  ->Result.flatMap(game => Game.startGame(game))
  ->Result.flatMap(game => {
    gamesInLobby->LobbyGameMap.remove(gameId)
    gamesInProgress->ProgressGameMap.set(gameId, game)
  })
}

let initiateGame = () =>
  {
    let alicePlayer = players->PlayersMap.create("alice")
    let bobPlayer = players->PlayersMap.create("bob")

    switch (alicePlayer, bobPlayer) {
    | (Ok(alice), Ok(bob)) =>
      gamesInLobby
      ->LobbyGameMap.create(alice)
      ->Result.flatMap(game => Game.enterGame(game, bob))
      ->Result.flatMap(game => Game.toggleReady(game, alice))
      ->Result.flatMap(game => Game.toggleReady(game, bob))
      ->Result.flatMap(game => LobbyGameMap.set(gamesInLobby, game.gameId, game))
      ->Result.flatMap(game => ProgressGameMap.create(gamesInProgress, game))
      ->Result.flatMap(game => {
        LobbyGameMap.remove(gamesInLobby, game.gameId)
        Ok(game)
      })
    | _ => Error("Can't create alice or bob")
    }
  }->Js.log2("game created")

let dispatch = (playerId, gameId, action): result<inProgress, string> => {
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

  let result = switch nextGame {
  | Ok(game) => gamesInProgress->ProgressGameMap.set(game.gameId, game)
  | Error(err) => Error(err)
  }

  switch result {
  | Ok(game) => Js.log2("[dispatch] ok ", Game.toObject(game))
  | Error(err) => Js.log2("[dispatch] error ", err)
  }

  result
}
