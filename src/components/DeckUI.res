open Types
open Utils

module DndWrapper = {
  @react.component
  let make = (~card, ~index, ~children) => {
    <CardDnd.Cards.DroppableContainer
      accept={_ => false} id={CardDnd.ContainerId.make(CardDnd.ToCard(card))} axis=X>
      <CardDnd.Cards.DraggableItem
        className={(~dragging: bool) => cx(["", dragging ? "" : ""])}
        id=card
        containerId={CardDnd.ContainerId.make(CardDnd.ToCard(card))}
        index>
        #Children(children)
      </CardDnd.Cards.DraggableItem>
    </CardDnd.Cards.DroppableContainer>
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
        switch isDraggable {
        | true =>
          <DndWrapper key={Card.cardToString(card) ++ index->string_of_int} card index>
            <CardUI card disabled={disabled || isCardDisabled(card)} />
          </DndWrapper>
        | false =>
          <CardUI
            key={Card.cardToString(card) ++ index->string_of_int}
            card
            disabled={disabled || isCardDisabled(card)}
          />
        }
      })}
    </div>
  }
