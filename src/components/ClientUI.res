open Utils
open Types

module Parts = {
  @react.component
  let actions = (~game: inProgress, ~player: player, ~onPass: _ => unit, ~onTake: _ => unit) => {
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)

    <div className="grid grid-flow-col gap-1">
      <Base.Switch disabled={isPassDisabled} onClick={onPass} checked={isPassed} text="pass" />
      <Base.Button disabled={isTakeDisabled} onClick={onTake}> {uiStr("take")} </Base.Button>
    </div>
  }

  @react.component
  let table = (~game: inProgress, ~player: player) => {
    let isDefender = GameUtils.isDefender(game, player)

    <div className="mt-1">
      {switch isDefender {
      | true => <CardUI.table className="my-1" table={game.table} />
      | false => React.null
      }}
    </div>
  }

  @react.component
  let deck = (~game: inProgress, ~player: player, ~isDraggable: bool=false) => {
    let isDefender = GameUtils.isDefender(game, player)
    let disabled = isDefender
      ? !Table.hasCards(game.table)
      : !GameUtils.isPlayerCanMove(game, player)

    <CardUI.deck disabled isDraggable deck={player.cards} />
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
  let {handleBeat, handleTake, handlePass} = UseInProgressActions.hook(~onMove)

  let isDefender = GameUtils.isDefender(game, player)

  let handleReorder = result =>
    switch result {
    | Some(Dnd.ReorderResult.NewContainer(byCard, toCard, _)) => handleBeat(toCard, byCard)
    | x => Js.log2("unknown", x)
    }->ignore

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
        <CardDnd.Cards.DndManager onReorder={handleReorder}>
          {switch isOwner {
          | true =>
            <div className="my-2">
              <Parts.actions game player onPass={handlePass} onTake={handleTake} />
            </div>
          | false => React.null
          }}
          <Parts.deck isDraggable={true} game player />
          <Parts.table game player />
        </CardDnd.Cards.DndManager>
      </div>
    }}
  </div>
}
