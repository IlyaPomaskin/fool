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
      {switch (isDefender, game.table) {
      | (false, _) =>
        <CardDnd.Cards.DroppableContainer
          className={(~draggingOver: bool) =>
            cx([
              "top-0",
              "left-0",
              "w-12 h-16",
              draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : "",
            ])}
          accept={_ => true}
          id={CardDnd.ContainerId.make(CardDnd.ToTable)}
          axis=Y
          lockAxis={true}>
          <div
            className={cx([
              // "absolute",
              "w-12 h-16",
              "inline-block",
              "transform-x-[-100%]",
              "border rounded-md border-solid border-slate-500",
            ])}
          />
        </CardDnd.Cards.DroppableContainer>
      | (true, list{}) => uiStr("Table empty")
      | (true, table) => <TableUI className="my-1" table={table} />
      | _ => React.null
      }}
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

  let handleReorder = result =>
    switch result {
    | Some(Dnd.ReorderResult.NewContainer(byCard, CardDnd.ToCard(toCard), _)) =>
      onMove(Beat(toCard, byCard))
    | Some(Dnd.ReorderResult.NewContainer(card, CardDnd.ToTable, _)) => onMove(Move(card))
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
              <Parts.actions game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)} />
            </div>
          | false => React.null
          }}
          <Parts.deck isDraggable={isOwner} game player />
          <Parts.table game player />
        </CardDnd.Cards.DndManager>
      </div>
    }}
  </div>
}
