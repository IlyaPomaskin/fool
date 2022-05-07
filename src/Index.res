open Types
open Utils

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
    <div className="border rounded-md border-solid border-slate-500"> <PlayerScreen /> </div>
    <div className="border rounded-md border-solid border-slate-500"> <PlayerScreen /> </div>
  </div>
}
