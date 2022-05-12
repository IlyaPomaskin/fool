open Types
open Utils

module DndWrapper = {
  @react.component
  let make = (~card, ~children) => {
    <ReactDnd.Droppable direction="horizontal" droppableId={Card.cardToString(card)}>
      {(provided, snapshot) => {
        <div
          ref={provided.innerRef}
          className={cx([
            "relative top-0 left-0 w-12 h-16 flex",
            snapshot.isDraggingOver
              ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
              : "",
          ])}>
          children provided.placeholder
        </div>
      }}
    </ReactDnd.Droppable>
  }
}

@react.component
let make = (~className: string="", ~isDropDisabled=_ => false, ~isDefender, ~table: table) =>
  <div className={cx(["flex gap-1 flex-row", className])}>
    {table->uiReverseList(((to, by)) => {
      let key =
        Card.cardToString(to) ++ by->Option.map(Card.cardToString)->Option.getWithDefault("")

      switch (isDefender, by) {
      | (_, Some(byCard)) =>
        <div key className="flex flex-col gap-1">
          <CardUI card={to} disabled={true} />
          <CardUI card={byCard} className="absolute opacity-0.5" disabled={true} />
        </div>
      | (false, None) =>
        <div key className="flex flex-col gap-1">
          <CardUI card={to} disabled={true} /> <CardUI.Base />
        </div>
      | (true, None) =>
        <div key className="flex flex-col gap-1">
          <CardUI card={to} />
          <ReactDnd.Droppable
            isDropDisabled={isDropDisabled(to)}
            direction="horizontal"
            droppableId={Card.cardToString(to)}>
            {(provided, snapshot) => {
              <div ref={provided.innerRef}>
                <CardUI.Base className={cx([snapshot.isDraggingOver ? "bg-pink-200" : ""])}>
                  provided.placeholder
                </CardUI.Base>
                <div />
              </div>
            }}
          </ReactDnd.Droppable>
        </div>
      }
    })}
  </div>
