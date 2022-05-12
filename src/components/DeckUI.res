open Types
open Utils

let spread3: ('a1, 'a2, 'a3) => 'b = %raw(`(x1,x2,x3) => ({ ...x1, ...x2, ...x3 })`)

let getDropAnimation = (
  style: ReactDnd.draggableStyles,
  snapshot: ReactDnd.draggableStateSnapshot,
): ReactDOMStyle.t => {
  let dropAnimation = snapshot.dropAnimation->Js.Nullable.toOption

  switch (snapshot.isDropAnimating, dropAnimation) {
  | (true, Some(drop)) =>
    let {moveTo} = drop

    let translate = `translate(${moveTo.x->string_of_int}px, ${moveTo.y->string_of_int}px)`

    ReactDOMStyle.combine(style->Obj.magic, ReactDOMStyle.make(~transform=translate, ()))
  | _ => style->Obj.magic
  }
}

module DndWrapper = {
  @react.component
  let make = (~card, ~index, ~children) => {
    let id = Card.cardToString(card)

    <ReactDnd.Droppable direction="horizontal" isDropDisabled={true} droppableId={id}>
      {(droppableProvided, _) => {
        <div ref={droppableProvided.innerRef}>
          <ReactDnd.Draggable draggableId={id} index>
            {(provided, snapshot, _) => {
              React.cloneElement(
                <div ref={provided.innerRef}>
                  <div
                    className="transition duration-150 ease-in-out"
                    style={ReactDOMStyle.make(
                      ~transform=snapshot.isDragging && !snapshot.isDropAnimating
                        ? "scale(1.2)"
                        : "scale(1)",
                      (),
                    )}>
                    children
                  </div>
                </div>,
                spread3(
                  provided.draggableProps,
                  provided.dragHandleProps,
                  {"style": getDropAnimation(provided.draggableProps["style"], snapshot)},
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
