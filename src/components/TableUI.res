open Types
open Utils

module DndBeatableCard = {
  @react.component
  let make = (~card, ~isDropDisabled, ~beatByClassName) => {
    <ReactDnd.Droppable
      isDropDisabled={isDropDisabled(card)}
      direction="horizontal"
      droppableId={Card.cardToString(card)}>
      {(provided, snapshot) => {
        <div className={cx([beatByClassName, "w-12 h-16"])} ref={provided.innerRef}>
          <CardUI.Base className={cx([snapshot.isDraggingOver ? "bg-pink-200 opacity-50" : ""])}>
            provided.placeholder
          </CardUI.Base>
          <div />
        </div>
      }}
    </ReactDnd.Droppable>
  }
}

@react.component
let make = (~className: string="", ~isDropDisabled=_ => true, ~table: table) => {
  let beatByClassName = `${Utils.rightRotationClassName} absolute left-1 top-1`

  <div className={cx(["flex gap-1 flex-row", className])}>
    {table->uiReverseList(((to, by)) => {
      let key =
        Card.cardToString(to) ++ by->Option.map(Card.cardToString)->Option.getWithDefault("")

      <div key className="flex flex-col gap-1 relative">
        {switch by {
        | Some(byCard) =>
          <React.Fragment>
            <CardUI className={Utils.leftRotationClassName} card={to} />
            <div className=beatByClassName> <CardUI card={byCard} /> </div>
          </React.Fragment>
        | None =>
          <React.Fragment>
            <CardUI className={Utils.leftRotationClassName} card={to} />
            <DndBeatableCard isDropDisabled beatByClassName card={to} />
          </React.Fragment>
        }}
      </div>
    })}
  </div>
}
