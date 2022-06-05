open Types
open Utils

@react.component
let make = (~gameId=None) => {
  let (player, setPlayer) = useStateValue(None)
  let (screen, setScreen) = useStateValue(AuthorizationScreen)
  let (error, setError) = useStateValue(None)
  let (isConnected, setIsConnected) = useStateValue(false)
  let onMessage = React.useCallback1(message => {
    Log.logMessageFromServer(message, player)

    setError(None)

    switch (message, player) {
    | (Connected(player), _) => {
        setPlayer(Some(player))
        setScreen(LobbySetupScreen)
        setIsConnected(true)
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

  let sendMessage = UseWs.hook(
    ~onMessage,
    ~player,
    ~onConnect=_ => ignore(),
    ~onDisconnect=_ => setIsConnected(false),
    ~onError=_ => setIsConnected(false),
  )

  <div className="mx-auto max-w-sm w-full">
    {switch player {
    | Some(player) =>
      <div>
        {uiStr("Player: ")}
        <PlayerUI.Short className="inline break-all" player />
        <span className="px-1"> {uiStr(isConnected ? `🟢` : `🔴`)} </span>
      </div>
    | None => React.null
    }}
    {switch error {
    | Some(err) => <p className="break-all"> {uiStr("ServerError: " ++ err)} </p>
    | None => React.null
    }}
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
