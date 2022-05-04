open Types
open Utils

@react.component
let make = (~playerId, ~onMessage) => {
  let (gameId, setGameId) = React.useState(_ => "")

  <div>
    {uiStr("lobby setup " ++ playerId)}
    <Base.Button onClick={_ => onMessage(Lobby(Create, playerId, ""))}>
      {uiStr("create lobby")}
    </Base.Button>
    <div>
      <input value={gameId} onChange={e => setGameId(_ => ReactEvent.Form.target(e)["value"])} />
      <Base.Button onClick={_ => onMessage(Lobby(Enter, playerId, gameId))}>
        {uiStr("lobby connect")}
      </Base.Button>
    </div>
  </div>
}
