open Types
open Utils

module AuthorizationUI = {
  @react.component
  let make = (~onMessage: gameMessageFromClient => unit) => {
    React.useEffect0(() => {
      let sessionId = LocalStorage.getItem("sessionId")->Js.Nullable.toOption

      switch sessionId {
      | Some(sessionId) => onMessage(Login(sessionId))
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

module LobbySetupScreen = {
  @react.component
  let make = (~playerId) => {
    <div> {uiStr("lobby setup " ++ playerId)} </div>
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

    switch screen {
    | AuthorizationScreen => <AuthorizationUI onMessage={sendMessage} />
    | LobbySetupScreen(playerId) => <LobbySetupScreen playerId={playerId} />
    | InLobbyScreen(game, playerId) => <LobbyUI playerId game onMessage={sendMessage} />
    | InProgressScreen(game, playerId) =>
      <div>
        <div>
          {switch error {
          | Some(err) => <div> {uiStr("error: " ++ err)} </div>
          | None => <div> {uiStr("No error")} </div>
          }}
        </div>
        <GameUI.InProgressUI game />
        <div className="flex flex-wrap">
          {game.players->uiList(player =>
            <ClientUI
              key={player.id}
              isOwner={player.id === playerId}
              className="m-1 flex-initial w-96"
              player
              game
              onMove={move => sendMessage(Progress(move, playerId, game.gameId))}
            />
          )}
        </div>
      </div>
    }
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
