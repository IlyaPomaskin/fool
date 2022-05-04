open Types
open Utils

@react.component
let make = (~game: inLobby, ~onMessage, ~playerId) => {
  let (gameId, setGameId) = React.useState(_ => "")

  <div>
    // <Base.Button onClick={_ => onMessage(Player(Connect, playerId))}>
    //   {uiStr("create player")}
    // </Base.Button>
    <Base.Button onClick={_ => onMessage(Lobby(Create, playerId, ""))}>
      {uiStr("create lobby")}
    </Base.Button>
    <div>
      <input value={gameId} onChange={e => setGameId(_ => ReactEvent.Form.target(e)["value"])} />
      <Base.Button onClick={_ => onMessage(Lobby(Enter, playerId, gameId))}>
        {uiStr("lobby connect")}
      </Base.Button>
    </div>
    <div>
      <div> {uiStr("Lobby Id: " ++ game.gameId)} </div>
      <Base.Button
        pressed={game.ready->List.has(playerId, (player, id) => player.id === id)}
        onClick={_ => onMessage(Lobby(Ready, playerId, game.gameId))}>
        {uiStr("lobby ready")}
      </Base.Button>
      <Base.Button onClick={_ => onMessage(Lobby(Start, playerId, game.gameId))}>
        {uiStr("lobby start")}
      </Base.Button>
    </div>
  </div>
}
