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
        } else {
          delayM(Login(sessionId), ())
          ->then(() => delayM(~timeout=250, Lobby(Enter, playerId, "g1"), ()))
          ->then(() => delayM(~timeout=100, Lobby(Ready, playerId, "g1"), ()))
          ->ignore
        }

        setIsLoaded(_ => true)
      }

      None
    }, (sendMessage, isLoaded))

    <div className="w-96 h-128 border rounded-md border-solid border-slate-500">
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
    <div className="flex flex-row flex-wrap w-full">
      <PlayerScreen playerId="p1" sessionId="session:p1" />
      <PlayerScreen playerId="p2" sessionId="session:p2" />
      <PlayerScreen playerId="p3" sessionId="session:p3" />
      <PlayerScreen playerId="p4" sessionId="session:p4" />
    </div>
  }
}
