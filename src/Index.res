open Types
open Utils

let delay = (send, msg, ~timeout=100, ()) =>
  Promise.make((resolve, _) => Js.Global.setTimeout(() => resolve(. send(msg)), timeout)->ignore)

module PlayerScreen = {
  @react.component
  let make = (~pId) => {
    let (player, setPlayer) = React.useState(_ => None)
    let (screen, setScreen) = React.useState(_ => AuthorizationScreen)

    let onMessage = React.useCallback1(message => {
      Log.logMessageFromServer(
        message,
        player->Option.map(p => p.id)->Option.getWithDefault("no player"),
      )

      switch message {
      | Connected(player) => {
          setPlayer(_ => Some(player))
          setScreen(_ => LobbySetupScreen)
        }
      | LobbyCreated(game)
      | LobbyUpdated(game) =>
        setScreen(_ => InLobbyScreen(game))
      | ProgressCreated(game)
      | ProgressUpdated(game) =>
        setScreen(_ => InProgressScreen(game))
      | ServerError(msg) => Log.info(["ServerError", msg])
      }
    }, [player])

    let {error, sendMessage} = UseWs.hook(onMessage)

    // FIXME remove debug code
    React.useEffect1(() => {
      open Promise

      let delayM = delay(sendMessage)

      if pId === "session:p1" {
        delayM(Login(pId), ())
        ->then(() => delayM(~timeout=100, Lobby(Create, "p1", ""), ()))
        ->then(() => delayM(~timeout=100, Lobby(Enter, "p1", "g1"), ()))
        ->then(() => delayM(~timeout=100, Lobby(Ready, "p1", "g1"), ()))
        ->then(() => delayM(~timeout=300, Lobby(Start, "p1", "g1"), ()))
        ->ignore
      }

      if pId === "session:p2" {
        delayM(Login(pId), ())
        ->then(() => delayM(~timeout=250, Lobby(Enter, "p2", "g1"), ()))
        ->then(() => delayM(~timeout=100, Lobby(Ready, "p2", "g1"), ()))
        ->ignore
      }

      None
    }, [sendMessage])

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
  <div className="flex flex-col">
    <div className="border rounded-md border-solid border-slate-500">
      <PlayerScreen pId="session:p1" />
    </div>
    <div className="border rounded-md border-solid border-slate-500">
      <PlayerScreen pId="session:p2" />
    </div>
  </div>
}
