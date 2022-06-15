open Types
open Utils

module Actions = {
  @react.component
  let make = (
    ~className: string="",
    ~game: inProgress,
    ~player: player,
    ~onPass: _ => unit,
    ~onTake: _ => unit,
  ) => {
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player.id)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)
    let isDefender = GameUtils.isDefender(game, player)
    let isDuel =
      game.players->List.keep(player => !GameUtils.isPlayerDone(game, player))->List.length <= 2

    <div className={cx(["grid grid-flow-col gap-1", className])}>
      {switch (isDefender, isDuel) {
      | (true, _) =>
        <Base.Button disabled={isTakeDisabled} onClick={onTake}> {uiStr("take")} </Base.Button>
      | (false, true) =>
        <Base.Button disabled={isPassDisabled} onClick={onPass}> {uiStr("pass")} </Base.Button>
      | (false, false) =>
        <Base.Switch disabled={isPassDisabled} onClick={onPass} checked={isPassed} text="pass" />
      }}
    </div>
  }
}

@react.component
let make = (~className: string="", ~player, ~game: inProgress, ~onDrag, ~onMessage, ()) => {
  let isDefender = GameUtils.isDefender(game, player)
  let isThereCardsOnTable = Table.hasCards(game.table)
  let isPlayerCanMove = GameUtils.isPlayerCanMove(game, player)
  let isDeckEnabled = isDefender ? isThereCardsOnTable : isPlayerCanMove
  let onMove = move => onMessage(Progress(move, player.id, game.gameId))

  <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
    {switch GameUtils.getPlayerGameState(game, player) {
    | Won => uiStr("Won")
    | Lose => uiStr("Lose")
    | Draw => uiStr("Draw")
    | Playing => uiStr("Playing")
    }}
    <div>
      <DeckUI onDrag disabled={!isDeckEnabled} isDraggable={true} deck={player.cards} />
      <Actions className="py-2" game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)} />
    </div>
  </div>
}
