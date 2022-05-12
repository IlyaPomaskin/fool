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

let toBeatClassName = "-rotate-12 -translate-x-1.5"
let beatByClassName = "rotate-12 translate-x-1.5 absolute left-1 top-1"

@react.component
let make = (~className: string="", ~isDropDisabled=_ => false, ~isDefender, ~table: table) =>
  <div className={cx(["flex gap-1 flex-row", className])}>
    {table->uiReverseList(((to, by)) => {
      let key =
        Card.cardToString(to) ++ by->Option.map(Card.cardToString)->Option.getWithDefault("")

      switch (isDefender, by) {
      | (_, Some(byCard)) =>
        <div key className="flex flex-col gap-1 relative">
          <CardUI className=toBeatClassName card={to} disabled={true} />
          <div className=beatByClassName> <CardUI card={byCard} disabled={true} /> </div>
        </div>
      | (false, None) =>
        <div key className="flex flex-col gap-1"> <CardUI card={to} disabled={true} /> </div>
      | (true, None) =>
        <div key className="flex flex-col gap-1 relative">
          <CardUI className=toBeatClassName card={to} />
          <ReactDnd.Droppable
            isDropDisabled={isDropDisabled(to)}
            direction="horizontal"
            droppableId={Card.cardToString(to)}>
            {(provided, snapshot) => {
              <div className={cx([beatByClassName, "w-12 h-16"])} ref={provided.innerRef}>
                <CardUI.Base
                  className={cx([snapshot.isDraggingOver ? "bg-pink-200 opacity-50" : ""])}>
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
