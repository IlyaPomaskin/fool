open Types
open Utils

module Parts = {
  @react.component
  let table = (~game, ~draggedCard, ~player) => {
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

type destionation =
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
    Js.log2("result", result)
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

  <ReactDnd.DragDropContext onDragStart={handleDragStart} onDragEnd={handleDragEnd}>
    <GameUI.InProgressUI game />
    <div className="m-1"> <Parts.table draggedCard game player /> </div>
    <div className="flex flex-wrap">
      {game.players->uiList(p =>
        <ClientUI
          key={p.id}
          isOwner={p.id === player.id}
          className="m-1 flex flex-col"
          player={p}
          game
          onMove={move => onMessage(Progress(move, player.id, game.gameId))}
        />
      )}
    </div>
  </ReactDnd.DragDropContext>
}
