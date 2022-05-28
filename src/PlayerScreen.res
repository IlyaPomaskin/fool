open Types
open Utils

@react.component
let make = (~onConnect) => {
  let (player, setPlayer) = React.useState(_ => None)
  let (screen, setScreen) = React.useState(_ => AuthorizationScreen)
  let onMessage = React.useCallback1(message => {
    Log.logMessageFromServer(message, player)

    switch (message, player) {
    | (Connected(player), _) => {
        setPlayer(_ => Some(player))
        setScreen(_ => LobbySetupScreen)
      }
    | (LobbyCreated(game), Some(player))
    | (LobbyUpdated(game), Some(player)) => {
        setScreen(_ => InLobbyScreen(game))
        setPlayer(_ => game.players->List.getBy(Player.equals(player)))
      }
    | (ProgressCreated(game), Some(player))
    | (ProgressUpdated(game), Some(player)) =>
      setScreen(_ => InProgressScreen(game))
      setPlayer(_ => game.players->List.getBy(Player.equals(player)))
    | (ServerError(msg), _) => Log.info(["ServerError", msg])
    | _ => ignore()
    }
  }, [player])

  let handleLogin = player => setPlayer(_ => Some(player))

  let {error, sendMessage} = UseWs.hook(~onMessage, ~onConnect, ~player)

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
    | (AuthorizationScreen, _) => <AuthorizationScreen onLogin={handleLogin} />
    | (LobbySetupScreen, Some(player)) => <LobbySetupScreen player onMessage={sendMessage} />
    | (InLobbyScreen(game), Some(player)) => <InLobbyScreen player game onMessage={sendMessage} />
    | (InProgressScreen(game), Some(player)) =>
      <InProgressScreen player game onMessage={sendMessage} />
    | _ => <div> {uiStr("unhandled case")} </div>
    }}
  </div>
}
