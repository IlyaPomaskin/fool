open Types
open Utils

@react.component
let make = (~game: inLobby, ~onMessage, ~player) => {
  let isOwner = GameUtils.isOwner(game, player)
  let isCanStart = GameUtils.isCanStart(game, player)->Result.isOk

  <div className="flex flex-col gap-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Lobby Id: " ++ game.gameId)} </Base.Heading>
    <div>
      <Base.Heading size={H5}> {uiStr("Players:")} </Base.Heading>
      {game.players->uiReverseList(player => {
        let isReady = game.ready->List.some(p => p == player)
        let readyEmoji = switch isReady {
        | true => `✅`
        | false => `❌`
        }

        <div key={player.id}>
          <span className="pr-2"> {uiStr(readyEmoji)} </span>
          <PlayerUI.Short player className="inline-block" />
        </div>
      })}
    </div>
    {isOwner
      ? <Base.Button
          disabled={!isCanStart} onClick={_ => onMessage(Lobby(Start, player.id, game.gameId))}>
          {uiStr("Start")}
        </Base.Button>
      : <Base.Switch
          className="my-2"
          text="Ready?"
          checked={game.ready->List.has(player.id, (player, id) => player.id === id)}
          onClick={_ => onMessage(Lobby(Ready, player.id, game.gameId))}
        />}
  </div>
}
