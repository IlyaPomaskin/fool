open Types
open Utils

module AuthorizationUI = {
  @react.component
  let make = (~onMessage) => {
    React.useEffect0(() => {
      let sessionId = LocalStorage.getItem("sessionId")->Js.Nullable.toOption

      switch sessionId {
      | Some(sessionId) => Js.log2("sessionId", sessionId)
      | None => ()
      }

      None
    })

    let (login, setLogin) = React.useState(_ => "")

    <div>
      <input value={login} onChange={e => setLogin(_ => ReactEvent.Form.target(e)["value"])} />
      <Base.Button onClick={_ => onMessage(Register(login))}> {uiStr("Create user")} </Base.Button>
    </div>
  }
}

module PlayerScreen = {
  @react.component
  let make = () => {
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
          LocalStorage.setItem("sessionId", player.sessionId)
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
      | (AuthorizationScreen, _) => <AuthorizationUI onMessage={sendMessage} />
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
  <div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <PlayerScreen />
    </div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <PlayerScreen />
    </div>
  </div>
}
