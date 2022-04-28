open Types

module Server = {
  let broadcast = (gameId, payload) => {
    // Promise.make((resolve, _) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log3("[server] broadcast: ", gameId, payload)
    }, 100)
    // })
  }

  let send = (player: player, payload) => {
    // Promise.make((resolve, _) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log3("[server] send: ", Player.toObject(player), payload)
    }, 100)
    // })
  }
}

module Client = {
  let send = (gameId: gameId, playerId: playerId, payload) => {
    // Promise.make((resolve, _) => {
    let _timeoutId = Js.Global.setTimeout(() => {
      Js.log4("[client] send: ", gameId, playerId, payload)
      // resolve(. (gameId, playerId, payload))
    }, 100)
    // })
  }
}
