open Types
open Utils

@react.component
let make = (~game: option<inLobby>, ~onLobbyMessage, ~playerId) => {
  let (gameId, setGameId) = React.useState(_ => "")

  <div>
    <Base.Button onClick={_ => onLobbyMessage(Player(Connect, playerId))}>
      {uiStr("create player")}
    </Base.Button>
    <Base.Button onClick={_ => onLobbyMessage(Lobby(Create, playerId, ""))}>
      {uiStr("create lobby")}
    </Base.Button>
    <div>
      <input value={gameId} onChange={e => setGameId(_ => ReactEvent.Form.target(e)["value"])} />
      <Base.Button onClick={_ => onLobbyMessage(Lobby(Enter, playerId, gameId))}>
        {uiStr("lobby connect")}
      </Base.Button>
    </div>
    {switch game {
    | Some(game) =>
      <div>
        <div> {uiStr("Lobby Id: " ++ game.gameId)} </div>
        <Base.Button
          pressed={game.ready->List.has(playerId, (player, id) => player.id === id)}
          onClick={_ => onLobbyMessage(Lobby(Ready, playerId, game.gameId))}>
          {uiStr("lobby ready")}
        </Base.Button>
        <Base.Button onClick={_ => onLobbyMessage(Lobby(Start, playerId, game.gameId))}>
          {uiStr("lobby start")}
        </Base.Button>
      </div>
    | None => React.null
    }}
  </div>
}
