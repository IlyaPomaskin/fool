open Types
open Utils

let delay = (send, msg, ~timeout=100, ()) =>
  Promise.make((resolve, _) => Js.Global.setTimeout(() => resolve(. send(msg)), timeout)->ignore)

module PlayerScreen = {
  @react.component
  let make = (~playerId, ~sessionId) => {
    let (player, setPlayer) = React.useState(_ => None)
    let (screen, setScreen) = React.useState(_ => AuthorizationScreen)
    let (isLoaded, setIsLoaded) = React.useState(_ => false)

    let onMessage = React.useCallback1(message => {
      Log.logMessageFromServer(message, playerId)

      switch message {
      | Connected(player) => {
          setPlayer(_ => Some(player))
          setScreen(_ => LobbySetupScreen)
        }
      | LobbyCreated(game)
      | LobbyUpdated(game) => {
          setScreen(_ => InLobbyScreen(game))
          setPlayer(_ => game.players->List.getBy(player => player.id == playerId))
        }
      | ProgressCreated(game)
      | ProgressUpdated(game) =>
        setScreen(_ => InProgressScreen(game))
        setPlayer(_ => game.players->List.getBy(player => player.id == playerId))
      | ServerError(msg) => Log.info(["ServerError", msg])
      }
    }, [playerId])

    let {error, sendMessage} = UseWs.hook(onMessage)

    // FIXME remove debug code
    React.useEffect2(() => {
      if !isLoaded {
        open Promise

        let delayM = delay(sendMessage)

        if playerId === "p1" {
          delayM(Login(sessionId), ())
          ->then(() => delayM(~timeout=100, Lobby(Create, "p1", ""), ()))
          ->then(() => delayM(~timeout=100, Lobby(Enter, "p1", "g1"), ()))
          ->then(() => delayM(~timeout=100, Lobby(Ready, "p1", "g1"), ()))
          ->then(() => delayM(~timeout=300, Lobby(Start, "p1", "g1"), ()))
          ->ignore
        }

        if playerId === "p2" {
          delayM(Login(sessionId), ())
          ->then(() => delayM(~timeout=250, Lobby(Enter, "p2", "g1"), ()))
          ->then(() => delayM(~timeout=100, Lobby(Ready, "p2", "g1"), ()))
          ->ignore
        }

        setIsLoaded(_ => true)
      }

      None
    }, (sendMessage, isLoaded))

    <div>
      <div>
        {switch player {
        | Some(player) =>
          <div> {uiStr("Player: ")} <PlayerUI.Short className="inline-block" player /> </div>
        | None => uiStr("No player")
        }}
      </div>
      <div>
        {switch error {
        | Some(err) => <div> {uiStr("error: " ++ err)} </div>
        | None => <div> {uiStr("No error")} </div>
        }}
      </div>
      {switch (screen, player) {
      | (AuthorizationScreen, _) => <AuthorizationScreen onMessage={sendMessage} />
      | (LobbySetupScreen, Some(player)) => <LobbySetupScreen player onMessage={sendMessage} />
      | (InLobbyScreen(game), Some(player)) => <InLobbyScreen player game onMessage={sendMessage} />
      | (InProgressScreen(game), Some(player)) =>
        <InProgressScreen player game onMessage={sendMessage} />
      | _ => <div> {uiStr("unhandled case")} </div>
      }}
    </div>
  }
}

let default = () => {
  // FIXME remove debug code
  let (isLoaded, setIsLoaded) = React.useState(_ => false)
  React.useEffect1(() => {
    if !isLoaded {
      Fetch.fetch("/api/server")
      |> Js.Promise.then_(_ => {
        setIsLoaded(_ => true)
        Js.Promise.resolve(1)
      })
      |> ignore
    }

    None
  }, [isLoaded])

  if !isLoaded {
    <div> {React.string("Loading...")} </div>
  } else {
    <div className="flex flex-col">
      <div className="border rounded-md border-solid border-slate-500">
        <PlayerScreen playerId="p1" sessionId="session:p1" />
      </div>
      <div className="border rounded-md border-solid border-slate-500">
        <PlayerScreen playerId="p2" sessionId="session:p2" />
      </div>
    </div>
  }
}
