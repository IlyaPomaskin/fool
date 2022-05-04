open Types
open Utils

@react.component
let make = (~game: inLobby, ~onMessage, ~playerId) => {
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
}
