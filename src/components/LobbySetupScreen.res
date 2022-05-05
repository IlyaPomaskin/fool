open Types
open Utils

@react.component
let make = (~player, ~onMessage) => {
  let (gameId, setGameId) = React.useState(_ => "")

  <div>
    {uiStr("lobby setup " ++ player.id)}
    <Base.Button onClick={_ => onMessage(Lobby(Create, player.id, ""))}>
      {uiStr("create lobby")}
    </Base.Button>
    <div>
      <input value={gameId} onChange={e => setGameId(_ => ReactEvent.Form.target(e)["value"])} />
      <Base.Button onClick={_ => onMessage(Lobby(Enter, player.id, gameId))}>
        {uiStr("lobby connect")}
      </Base.Button>
    </div>
  </div>
}
