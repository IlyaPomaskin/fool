open Types
open Utils

module DndWrapper = {
  @react.component
  let make = (~card, ~children) => {
    <ReactDnd.Droppable droppableId={Card.cardToString(card)}>
      {(droppableProvided, droppableSnapshot) => {
        <div
          ref={droppableProvided.innerRef}
          className={cx([
            "relative top-0 left-0 w-12 h-16 flex",
            droppableSnapshot.isDraggingOver
              ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
              : "",
          ])}>
          children droppableProvided.placeholder
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

      <div
        key={Card.cardToString(to) ++ by->Option.map(Card.cardToString)->Option.getWithDefault("")}
        className="flex flex-col gap-1">
        {switch by {
        | Some(byCard) => <>
            <CardUI card={to} disabled={true} />
            <CardUI card={byCard} className="absolute opacity-0.5" disabled={true} />
          </>
        | None => <>
            <CardUI card={to} disabled={isDisabled} />
            <DndWrapper card={to}> <CardUI.EmptyCard /> </DndWrapper>
          </>
        }}
      </div>
    })}
  </div>
