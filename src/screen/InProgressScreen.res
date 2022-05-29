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

@val @scope("document")
external body: Dom.element = "body"

module PlayerTableUI = {
  @react.component
  let make = (~game, ~draggedCard, ~player) => {
    let isDefender = GameUtils.isDefender(game, player)
    let draggedCard = Utils.toResult(draggedCard, "No card")

    <div className="relative">
      <ReactDnd.Droppable
        droppableId="table"
        direction="horizontal"
        isDropDisabled={isDefender ||
        draggedCard->Result.flatMap(card => Game.isValidMove(game, player, card))->Result.isError}>
        {(provided, snapshot) => {
          let container =
            <div
              ref={provided.innerRef}
              className={cx([
                "w-full flex flex-row bg-pink-200",
                snapshot.isDraggingOver
                  ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
                  : "opacity-100",
              ])}>
              <TableUI
                isDefender
                isDropDisabled={toCard =>
                  !isDefender ||
                  draggedCard
                  ->Result.flatMap(byCard => Game.isValidBeat(game, player, toCard, byCard))
                  ->Result.isError}
                className="my-1 h-16"
                table={game.table}
                placeholder={provided.placeholder}
              />
            </div>

          React.cloneElement(container, provided.droppableProps)
        }}
      </ReactDnd.Droppable>
    </div>
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
      | Won => uiStr("Won")
      | Lose => uiStr("Lose")
      | Draw => uiStr("Draw")
      | Playing => uiStr("Playing")
      }}
      <div>
        <DeckUI disabled={!isDeckEnabled} isDraggable={true} deck={player.cards} />
        <PlayerActionsUI
          className="py-2" game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)}
        />
      </div>
    </div>
  }
}

module OpponentUI = {
  @react.component
  let make = (~player, ~className, ~isDefender, ~isAttacker) => {
    <div className={cx(["flex flex-col gap-2", className])}>
      <DeckUI.hidden deck={player.cards} />
      <div className="vertial-align">
        <PlayerUI.Short player className="inline-block" />
        {uiStr(isDefender ? ` 🛡️` : "")}
        {uiStr(isAttacker ? ` 🔪` : "")}
      </div>
    </div>
  }
}

type destination =
  | ToUnknown
  | ToTable
  | ToCard(card)

let useOptimisticGame = (~game, ~player, ~onMessage) => {
  let (optimisticGame, setOptimisticGame) = React.useState(_ => game)
  React.useEffect1(() => {
    setOptimisticGame(_ => game)
    None
  }, [game])

  let handleOptimisticMessage = msg => {
    switch msg {
    | Progress(move, _, _) =>
      setOptimisticGame(prevGame =>
        Game.dispatch(prevGame, player, move)->Result.getWithDefault(prevGame)
      )
    | _ => ()
    }->ignore

    onMessage(msg)
  }

  (optimisticGame, handleOptimisticMessage)
}

@react.component
let make = (~game as realGame, ~player, ~onMessage) => {
  let (game, handleOptimisticMessage) = useOptimisticGame(~game=realGame, ~player, ~onMessage)

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
    | (true, _, Some(card)) => handleOptimisticMessage(Progress(Move(card), player.id, game.gameId))
    | (false, Some(toCard), Some(byCard)) =>
      handleOptimisticMessage(Progress(Beat(toCard, byCard), player.id, game.gameId))
    | (false, None, _) => Js.log("No destination")
    | _ => Js.log("unknown move")
    }

    setDraggedCard(_ => None)
  }

  let reorderedPlayers =
    game.players
    ->listIndexOf(item => Player.equals(item, player))
    ->Option.flatMap(index => List.splitAt(game.players, index))
    ->Option.map(((before, after)) => List.concat(after, before))
    ->Option.map(players => List.keep(players, p => !Player.equals(p, player)))
    ->Option.getWithDefault(game.players)

  <div>
    <div className="flex">
      <div className="flex m-2 flex-row">
        {
          let trumpCard = lastListItem(game.deck)

          switch trumpCard {
          | Some(Visible(card)) =>
            <div className="relative flex h-min">
              <DeckUI.hidden className="z-10" deck={game.deck} />
              <div className="z-0 relative top-1 -left-2 rotate-90">
                <CardUI.VisibleCard card />
              </div>
            </div>
          | Some(Hidden) =>
            <div> <DeckUI.hidden deck={game.deck} /> <CardUI.trump suit={game.trump} /> </div>
          | None => <CardUI.EmptyCard> <CardUI.trump suit={game.trump} /> </CardUI.EmptyCard>
          }
        }
      </div>
      <div className="flex m-2 w-full justify-evenly">
        {uiList(reorderedPlayers, player =>
          <OpponentUI
            key={player.id}
            isDefender={GameUtils.isDefender(game, player)}
            isAttacker={GameUtils.isAttacker(game, player)}
            className="m-1 flex flex-col"
            player
          />
        )}
      </div>
    </div>
    <ReactDnd.DragDropContext onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
      <div className="m-1"> <PlayerTableUI draggedCard game player /> </div>
      <ClientUI className="m-1 flex flex-col" player game onMessage={handleOptimisticMessage} />
    </ReactDnd.DragDropContext>
  </div>
}
