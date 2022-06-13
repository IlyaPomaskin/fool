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
        props.isDragging ? "hidden" : "inline-block",
      ])}>
      children
    </div>
  }
}

@react.component
let hidden = (~className="", ~deck, ~text: option<React.element>=?) => {
  let cardsAmount = deck->List.length
  let cardsList =
    deck->List.keepWithIndex((_, index) => index <= 2)->List.mapWithIndex((index, _) => index)
  let deckText = switch (text, cardsAmount) {
  | (Some(text), _) => text
  | (_, 0) => uiStr("0")
  | (_, amount) => uiStr(string_of_int(amount))
  }

  <div className={cx(["relative", className])}>
    {switch cardsAmount {
    | 0 => <CardUI.EmptyCard />
    | _ =>
      cardsList->uiList(index => {
        let offset = `${string_of_int(index * 2)}px`

        <div
          key={string_of_int(index)}
          className={index === 0 ? "relative" : "absolute"}
          style={ReactDOMStyle.make(~top=offset, ~left=offset, ())}>
          <CardUI.HiddenCard />
        </div>
      })
    }}
    <div className="absolute top-1/2 left-1/2 -translate-y-1/2 -translate-x-1/2 text-slate-200">
      {deckText}
    </div>
  </div>
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
    <div className={cx([className, "leading flex flex-row gap-1"])}>
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
