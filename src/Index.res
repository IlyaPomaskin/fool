open Types
open Utils

module PlayerScreen = {
  @react.component
  let make = () => {
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

    // let {player, screen, onMessage} = useMessageHandler()
    let {error, sendMessage} = UseWs.hook(~onMessage, ~player)

    // UseDebug.autologin(
    //   ~sendMessage,
    //   ~playerId="p1",
    //   ~gameId="g1",
    //   ~sessionId="s:p1",
    //   ~isOwner=true,
    //   (),
    // )
    // useDebugActions(~sendMessage, ~playerId="p2", ~gameId="g1", ~sessionId="s:p2", ())
    // useDebugActions(~sendMessage, ~playerId="p3", ~gameId="g1", ~sessionId="s:p3", ())
    // useDebugActions(~sendMessage, ~playerId="p4", ~gameId="g1", ~sessionId="s:p4", ())

    let handleLogin = player => {
      setPlayer(_ => Some(player))
      setScreen(_ => LobbySetupScreen)
    }

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
}

let default = () => {
  // FIXME remove debug code
  let isStarted = UseDebug.startServer()

  if !isStarted {
    <div> {React.string("Loading...")} </div>
  } else {
    <div className="flex flex-row flex-wrap w-full">
      <PlayerScreen />
      // <PlayerScreen />
      // <PlayerScreen playerId="p1" sessionId="session:p1" />
      // <PlayerScreen playerId="p2" sessionId="session:p2" />
      // <PlayerScreen playerId="p3" sessionId="session:p3" />
      // <PlayerScreen playerId="p4" sessionId="session:p4" />
    </div>
  }
}
