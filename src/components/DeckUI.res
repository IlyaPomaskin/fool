open Types
open Utils

let spread3: ('a1, 'a2, 'a3) => 'b = %raw(`(x1,x2,x3) => ({ ...x1, ...x2, ...x3 })`)

module DndWrapper = {
  @react.component
  let make = (~card, ~index, ~children) => {
    let id = Card.cardToString(card)

    <ReactDnd.Droppable isDropDisabled={true} droppableId={id}>
      {(droppableProvided, _) => {
        <div key={id} ref={droppableProvided.innerRef}>
          <ReactDnd.Draggable key={id} draggableId={id} index>
            {(draggableProvided, _, _) => {
              React.cloneElement(
                <div> children </div>,
                spread3(
                  draggableProvided.draggableProps,
                  draggableProvided.dragHandleProps,
                  {
                    "key": id,
                    "ref": draggableProvided.innerRef,
                    "style": draggableProvided.draggableProps["style"],
                  },
                ),
              )
            }}
          </ReactDnd.Draggable>
          droppableProvided.placeholder
        </div>
      }}
    </ReactDnd.Droppable>
  }
}

@react.component
let make = (
  ~deck: deck,
  ~className: string="",
  ~disabled: bool=false,
  ~isDraggable: bool=false,
  ~isCardDisabled: card => bool=_ => false,
  (),
) =>
  switch deck {
  | list{} => <div className> {uiStr("No cards in deck")} </div>
  | _ =>
    <div className={cx([className, "leading flex flex-row gap-1"])}>
      {deck->uiListWithIndex((index, card) => {
        let key = Card.cardToString(card) ++ index->string_of_int
        let disabled = disabled || isCardDisabled(card)

        switch isDraggable {
        | true => <DndWrapper key card index> <CardUI card disabled /> </DndWrapper>
        | false => <CardUI key card disabled />
        }
      })}
    </div>
  }
