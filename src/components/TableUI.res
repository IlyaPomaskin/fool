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
let make = (~className: string="", ~isCardDisabled: card => bool=_ => false, ~table: table) =>
  <div className={cx(["flex gap-1 flex-row", className])}>
    {table->uiList(((to, by)) => {
      let isDisabled = Option.isSome(by) || isCardDisabled(to)

      switch by {
      | Some(byCard) =>
        <div
          key={Card.cardToString(to) ++
          by->Option.map(Card.cardToString)->Option.getWithDefault("")}
          className="flex flex-col gap-1">
          <CardUI card={to} disabled={true} />
          <CardUI card={byCard} className="absolute opacity-0.5" disabled={true} />
        </div>
      | None =>
        <ReactDnd.Droppable
          key={Card.cardToString(to) ++
          by->Option.map(Card.cardToString)->Option.getWithDefault("")}
          direction="horizontal"
          droppableId={Card.cardToString(to)}>
          {(provided, _) => {
            <div ref={provided.innerRef} className="flex flex-col gap-1">
              <CardUI card={to} disabled={isDisabled} />
              <CardUI.Base> provided.placeholder </CardUI.Base>
            </div>
          }}
        </ReactDnd.Droppable>
      }
    })}
  </div>
