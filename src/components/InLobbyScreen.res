open Types
open Utils

@react.component
let make = (~game: inLobby, ~onMessage, ~player) => {
  <div>
    <div> {uiStr("Lobby Id: " ++ game.gameId)} </div>
    <Base.Switch
      text="Ready?"
      checked={game.ready->List.has(player.id, (player, id) => player.id === id)}
      onClick={_ => onMessage(Lobby(Ready, player.id, game.gameId))}
    />
    <Base.Button onClick={_ => onMessage(Lobby(Start, player.id, game.gameId))}>
      {uiStr("lobby start")}
    </Base.Button>
  </div>
}
