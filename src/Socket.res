open Types

module SServer = {
  let broadcast = (gameId, payload) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log3("[server] broadcast: ", gameId, payload)
    }, 100)
  }

  let send = (player: player, payload) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log3("[server] send: ", Player.toObject(player), payload)
    }, 100)
  }
}

module SClient = {
  let send = (gameId, playerId, payload) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log4("[client] send: ", gameId, playerId, payload)
      // Server.dispatch(gameId, playerId, payload)
    }, 100)
  }
}
