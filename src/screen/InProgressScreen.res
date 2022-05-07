open Types
open Utils

module Parts = {
  @react.component
  let table = (~game: inProgress, ~player: player) => {
    let isDefender = GameUtils.isDefender(game, player)

    switch (isDefender, game.table) {
    | (true, table) => <TableUI className="my-1" table={table} />
    | (false, _) =>
      <ReactDnd.Droppable
        isDropDisabled={GameUtils.isValidMove(game, player)->Result.isError} droppableId={"table"}>
        {(droppableProvided, droppableSnapshot) => {
          <div
            ref={droppableProvided.innerRef}
            className={cx([
              droppableSnapshot.isDraggingOver
                ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
                : "",
            ])}>
            {switch game.table {
            | list{} =>
              <div className={cx(["w-12 h-16 border rounded-md border-solid border-slate-500"])} />
            | table => <TableUI className="my-1" table={table} />
            }}
            droppableProvided.placeholder
          </div>
        }}
      </ReactDnd.Droppable>
    }
  }
}

type destionation =
  | ToUnknown
  | ToTable
  | ToCard(card)

@react.component
let make = (~game, ~player, ~onMessage) => {
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
  }

  <ReactDnd.DragDropContext onDragEnd={handleDragEnd}>
    <GameUI.InProgressUI game />
    <div className="m-1"> <Parts.table game player /> </div>
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
