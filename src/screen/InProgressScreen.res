open Types
open Utils

module PlayerActionsUI = {
  @react.component
  let make = (
    ~className: string="",
    ~game: inProgress,
    ~player: player,
    ~onPass: _ => unit,
    ~onTake: _ => unit,
  ) => {
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)
    let isDefender = GameUtils.isDefender(game, player)
    let isDuel =
      game.players->List.keep(player => !GameUtils.isPlayerDone(game, player))->List.length === 2

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

module PlayerTableUI = {
  @react.component
  let make = (~game, ~draggedCard, ~player) => {
    let isDefender = GameUtils.isDefender(game, player)

    switch isDefender {
    | true =>
      <TableUI
        isDropDisabled={toCard => {
          switch draggedCard {
          | Some(byCard) => !Card.isValidBeat(toCard, byCard, game.trump)
          | None => true
          }
        }}
        className="my-1"
        table={game.table}
      />
    | false =>
      <div className="flex flex-row gap-1">
        {switch game.table {
        | list{} => <div className="h-16" />
        | table => <TableUI isDefender className="my-1" table={table} />
        }}
        <ReactDnd.Droppable
          droppableId="table"
          isDropDisabled={draggedCard
          ->Utils.toResult("No card")
          ->Result.flatMap(card => Game.isValidMove(game, player, card))
          ->Result.isError}>
          {(provided, snapshot) => {
            <div
              ref={provided.innerRef}
              className={cx([
                "w-full flex flex-row",
                game.table->List.length === 0 ? "bg-pink-200" : "",
                snapshot.isDraggingOver
                  ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
                  : "",
              ])}>
              provided.placeholder
            </div>
          }}
        </ReactDnd.Droppable>
      </div>
    }
  }
}

module ClientUI = {
  @react.component
  let make = (~className: string="", ~player, ~game: inProgress, ~onMessage) => {
    let isDefender = GameUtils.isDefender(game, player)
    let isThereCardsOnTable = Table.hasCards(game.table)
    let isPlayerCanMove = GameUtils.isPlayerCanMove(game, player)
    let isDeckEnabled = isDefender ? isThereCardsOnTable : isPlayerCanMove
    let onMove = move => onMessage(Progress(move, player.id, game.gameId))

    <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
      {switch GameUtils.getPlayerGameState(game, player) {
      | Done => uiStr("Done")
      | Lose => uiStr("Lose")
      | Draw => uiStr("Draw")
      | Playing =>
        <div>
          <DeckUI disabled={!isDeckEnabled} isDraggable={true} deck={player.cards} />
          <PlayerActionsUI
            className="py-2" game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)}
          />
        </div>
      }}
    </div>
  }
}

module OpponentUI = {
  @react.component
  let make = (~player, ~className, ~isDefender, ~isAttacker) => {
    <div className={cx(["flex flex-col", className])}>
      <div className="vertial-align">
        <PlayerUI.Short player className="inline-block" />
        {uiStr(isDefender ? ` 🛡️` : "")}
        {uiStr(isAttacker ? ` 🔪` : "")}
      </div>
      <DeckUI.hidden deck={player.cards} />
    </div>
  }
}

type destination =
  | ToUnknown
  | ToTable
  | ToCard(card)

@react.component
let make = (~game, ~player, ~onMessage) => {
  let (draggedCard, setDraggedCard) = React.useState(_ => None)

  let handleDragStart = (beforeCapture: ReactDnd.dragStartBeforeCapture, _) => {
    setDraggedCard(_ => Card.stringToCard(beforeCapture.draggableId))
  }

  let handleDragEnd = (result: ReactDnd.dropResult, _) => {
    let byCard = Card.stringToCard(result.draggableId)
    let dst = result.destination->Js.Nullable.toOption->Option.map(d => d.droppableId)
    let isTable = dst->Option.map(dst => dst === "table")->Option.getWithDefault(false)
    let toCard = dst->Option.flatMap(Card.stringToCard)

    switch (isTable, toCard, byCard) {
    | (true, _, Some(card)) => onMessage(Progress(Move(card), player.id, game.gameId))
    | (false, Some(toCard), Some(byCard)) =>
      onMessage(Progress(Beat(toCard, byCard), player.id, game.gameId))
    | (false, None, _) => Js.log("No destination")
    | _ => Js.log("unknown move")
    }

    setDraggedCard(_ => None)
  }

  // FIXME remove getExn
  let currentPlayer = game.players->List.getBy(p => p.id === player.id)->Option.getExn

  <ReactDnd.DragDropContext onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
    <div className="m-1 inline-block">
      <DeckUI.hidden
        deck={game.deck}
        text={switch lastListItem(game.deck) {
        | Some(card) => <CardUI.Short card />
        | None => <CardUI.trump className="inline-block" suit={game.trump} />
        }}
      />
    </div>
    <div className="flex flex-wrap">
      {game.players->uiList(p =>
        <OpponentUI
          isDefender={GameUtils.isDefender(game, p)}
          isAttacker={GameUtils.isAttacker(game, p)}
          key={p.id}
          className="m-1 flex flex-col"
          player={p}
        />
      )}
    </div>
    <div className="m-1"> <PlayerTableUI draggedCard game player /> </div>
    <ClientUI className="m-1 flex flex-col" player={currentPlayer} game onMessage />
  </ReactDnd.DragDropContext>
}
