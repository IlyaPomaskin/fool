open Utils
open Types

module Parts = {
  @react.component
  let actions = (
    ~className: string="",
    ~game: inProgress,
    ~player: player,
    ~onPass: _ => unit,
    ~onTake: _ => unit,
  ) => {
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)

    <div className={cx(["grid grid-flow-col gap-1", className])}>
      <Base.Switch disabled={isPassDisabled} onClick={onPass} checked={isPassed} text="pass" />
      <Base.Button disabled={isTakeDisabled} onClick={onTake}> {uiStr("take")} </Base.Button>
    </div>
  }

  @react.component
  let deck = (~game: inProgress, ~player: player, ~isDraggable: bool=false) => {
    let isDefender = GameUtils.isDefender(game, player)
    let disabled = isDefender
      ? !Table.hasCards(game.table)
      : !GameUtils.isPlayerCanMove(game, player)

    <DeckUI disabled isDraggable deck={player.cards} />
  }
}

@react.component
let make = (
  ~className: string="",
  ~player: player,
  ~isOwner: bool=false,
  ~game: inProgress,
  ~onMove: move => unit,
) => {
  let isDefender = GameUtils.isDefender(game, player)

  <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
    <div className="mb-1">
      {uiStr("Player: ")}
      <PlayerUI.Short className="inline-block" player />
      {uiStr(isDefender ? ` 🛡️` : "")}
      {uiStr(GameUtils.isAttacker(game, player) ? ` 🔪` : "")}
    </div>
    {switch GameUtils.getPlayerGameState(game, player) {
    | Done => uiStr("Done")
    | Lose => uiStr("Lose")
    | Draw => uiStr("Draw")
    | Playing =>
      <div>
        {isOwner
          ? <Parts.actions
              className="py-2" game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)}
            />
          : React.null}
        <Parts.deck isDraggable={isOwner} game player />
      </div>
    }}
  </div>
}
