open Types
open Utils

let spread3: ('a1, 'a2, 'a3) => 'b = %raw(`(x1,x2,x3) => ({ ...x1, ...x2, ...x3 })`)

let getDropAnimation = (
  style: ReactDnd.draggableStyles,
  snapshot: ReactDnd.draggableStateSnapshot,
): ReactDOMStyle.t => {
  let dropAnimation = snapshot.dropAnimation->Js.Nullable.toOption

  let transform = switch dropAnimation {
  | Some(drop) => `translate(${drop.moveTo.x->string_of_int}px, ${drop.moveTo.y->string_of_int}px)`
  | _ => style["transform"]->Js.Nullable.toOption->Option.getWithDefault("")
  }

  let transform = `${transform} rotate(var(--tw-rotate)) skewX(var(--tw-skew-x)) skewY(var(--tw-skew-y)) scaleX(var(--tw-scale-x)) scaleY(var(--tw-scale-y))`

  ReactDOMStyle.combine(style->Obj.magic, ReactDOMStyle.make(~transform, ()))
}

let getAnimationClassNames = (snapshot: ReactDnd.draggableStateSnapshot) => {
  let dropAnimation = snapshot.dropAnimation->Js.Nullable.toOption

  switch (snapshot.isDragging, snapshot.isDropAnimating, dropAnimation) {
  | (_, true, Some(_)) => "rotate-12 translate-x-1.5 scale-100"
  | (true, _, _) => "rotate-12 translate-x-1.5 scale-125"
  | (false, _, _) => "scale-100"
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
                <div ref={provided.innerRef}> children </div>,
                spread3(
                  provided.draggableProps,
                  provided.dragHandleProps,
                  {
                    "className": cx([
                      "transition duration-150 ease-in-out",
                      getAnimationClassNames(snapshot),
                    ]),
                    "style": getDropAnimation(provided.draggableProps["style"], snapshot),
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
let hidden = (~deck, ~text: option<React.element>=?) => {
  let cardsAmount = deck->List.length
  let cardsList =
    deck->List.keepWithIndex((_, index) => index <= 2)->List.mapWithIndex((index, _) => index)
  let deckText = switch (text, cardsAmount) {
  | (Some(text), _) => text
  | (_, 0) => uiStr("0")
  | (_, amount) => uiStr(string_of_int(amount))
  }

  <div className="relative">
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
