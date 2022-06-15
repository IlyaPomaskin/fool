open Types
open Utils

module DndWrapper = {
  module DragObject = {
    type t = Types.card
  }
  module EmptyDropResult = {
    type t
  }

  module CollectedProps = {
    type t = {draggedCard: card, isDragging: bool}
  }

  include ReactDnd.MakeUseDrag(DragObject, EmptyDropResult, CollectedProps)

  @react.component
  let make = (~card, ~children, ~onDrag) => {
    let (props, ref, _) = UseDrag.makeInstance(
      UseDrag.makeConfig(
        ~\"type"="card",
        ~item=card,
        ~collect=monitor => {
          draggedCard: DragSourceMonitor.getItem(monitor),
          isDragging: DragSourceMonitor.isDragging(monitor),
        },
        (),
      ),
      [],
    )

    React.useEffect1(() => {
      onDrag(props.draggedCard)
      None
    }, [props.draggedCard])

    <div
      ref
      className={cx([
        "transition duration-150 ease-in-out",
        props.isDragging ? "invisible" : "visible",
      ])}>
      children
    </div>
  }
}

@react.component
let make = (
  ~deck: deck,
  ~className: string="",
  ~disabled: bool=false,
  ~isDraggable: bool=false,
  ~isCardDisabled: card => bool=_ => false,
  ~onDrag=noop,
  (),
) =>
  switch deck {
  | list{} => <div className> {uiStr("No cards in deck")} </div>
  | _ =>
    <div className={cx([className, "leading flex flex-row gap-1 flex-wrap"])}>
      {deck->uiListWithIndex((index, card) => {
        let key = Card.cardToString(card) ++ index->string_of_int
        let disabled = disabled || isCardDisabled(card)

        switch isDraggable {
        | true => <DndWrapper key card onDrag> <CardUI card disabled /> </DndWrapper>
        | false => <CardUI key card disabled />
        }
      })}
    </div>
  }
