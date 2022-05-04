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

    let onMessage = React.useCallback0(message => {
      switch (message, player) {
      | (Connected(player), _) => {
          setPlayer(_ => Some(player))
          setScreen(_ => LobbySetupScreen(player.id))
          LocalStorage.setItem("sessionId", player.sessionId)
        }
      | (LobbyCreated(game), Some(player))
      | (LobbyUpdated(game), Some(player)) =>
        setScreen(_ => InLobbyScreen(game, player.id))
      | (ProgressCreated(game), Some(player))
      | (ProgressUpdated(game), Some(player)) =>
        setScreen(_ => InProgressScreen(game, player.id))
      | _ => ()
      }
    })

    let {error, sendMessage} = UseWs.hook(onMessage)

    <div>
      <div>
        {switch error {
        | Some(err) => <div> {uiStr("error: " ++ err)} </div>
        | None => <div> {uiStr("No error")} </div>
        }}
      </div>
      {switch screen {
      | AuthorizationScreen => <AuthorizationUI onMessage={sendMessage} />
      | LobbySetupScreen(playerId) =>
        <LobbySetupScreen playerId={playerId} onMessage={sendMessage} />
      | InLobbyScreen(game, playerId) => <InLobbyScreen playerId game onMessage={sendMessage} />
      | InProgressScreen(game, playerId) =>
        <InProgressScreen playerId game onMessage={sendMessage} />
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
