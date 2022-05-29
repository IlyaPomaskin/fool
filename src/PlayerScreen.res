open Types
open Utils

@react.component
let make = (~gameId=None) => {
  let (player, setPlayer) = useStateValue(None)
  let (screen, setScreen) = useStateValue(AuthorizationScreen)
  let (error, setError) = useStateValue(None)
  let onMessage = React.useCallback1(message => {
    Log.logMessageFromServer(message, player)

    switch (message, player) {
    | (Connected(player), _) => {
        setPlayer(Some(player))
        setScreen(LobbySetupScreen)
      }
    | (LobbyCreated(game), Some(player))
    | (LobbyUpdated(game), Some(player)) => {
        setScreen(InLobbyScreen(game))
        setPlayer(game.players->List.getBy(Player.equals(player)))
      }
    | (ProgressCreated(game), Some(player))
    | (ProgressUpdated(game), Some(player)) =>
      setScreen(InProgressScreen(game))
      setPlayer(game.players->List.getBy(Player.equals(player)))
    | (ServerError(err), _) => {
        setError(Some(err))
        Log.info(["ServerError", err])
      }
    | _ => ignore()
    }
  }, [player])

  let handleLogin = player => setPlayer(Some(player))

  let (isConnected, setIsConnected) = useStateValue(false)

  let sendMessage = UseWs.hook(
    ~onMessage,
    ~player,
    ~onConnect=_ => setIsConnected(true),
    ~onDisconnect=_ => setIsConnected(false),
    ~onError=_ => setIsConnected(false),
  )

  <div className="w-96 h-128 border rounded-md border-solid border-slate-500 p-2">
    <div>
      {switch player {
      | Some(player) => <>
          {uiStr("Player: ")}
          <PlayerUI.Short className="inline" player />
          <span className="px-1"> {uiStr(isConnected ? `🟢` : `🔴`)} </span>
        </>
      | None => React.null
      }}
    </div>
    <div>
      {switch error {
      | Some(err) => <div> {uiStr("ServerError: " ++ err)} </div>
      | None => React.null
      }}
    </div>
    {switch (screen, player) {
    | (AuthorizationScreen, _) => <AuthorizationScreen onLogin={handleLogin} />
    | (LobbySetupScreen, Some(player)) => <LobbySetupScreen gameId player onMessage={sendMessage} />
    | (InLobbyScreen(game), Some(player)) => <InLobbyScreen player game onMessage={sendMessage} />
    | (InProgressScreen(game), Some(player)) =>
      <InProgressScreen player game onMessage={sendMessage} />
    | _ => <div> {uiStr("unhandled case")} </div>
    }}
  </div>
}
