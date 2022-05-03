open Types
open Utils

@react.component
let make = (~game, ~onLobbyMessage, ~playerId) => {
  <div>
    <Base.Button onClick={_ => onLobbyMessage(Player(Connect, playerId))}>
      {uiStr("create player")}
    </Base.Button>
    <Base.Button onClick={_ => onLobbyMessage(Lobby(Create, playerId, ""))}>
      {uiStr("create lobby")}
    </Base.Button>
    <Base.Button onClick={_ => onLobbyMessage(Lobby(Enter, playerId, "gameId"))}>
      {uiStr("lobby connect")}
    </Base.Button>
    {switch game {
    | Some(game) =>
      <div>
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
