open Types
open Utils

@react.component
let make = (~game: inLobby, ~onMessage, ~player) => {
  let isCanStart = GameUtils.isCanStart(game, player)->Result.isOk

  <div className="m-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Lobby Id: " ++ game.gameId)} </Base.Heading>
    <Base.Switch
      className="my-2"
      text="Ready?"
      checked={game.ready->List.has(player.id, (player, id) => player.id === id)}
      onClick={_ => onMessage(Lobby(Ready, player.id, game.gameId))}
    />
    <Base.Button
      disabled={!isCanStart} onClick={_ => onMessage(Lobby(Start, player.id, game.gameId))}>
      {uiStr("Start")}
    </Base.Button>
  </div>
}
