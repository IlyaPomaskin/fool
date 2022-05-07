open Types
open Utils

@react.component
let make = (
  ~deck: deck,
  ~className: string="",
  ~disabled: bool=false,
  ~isDraggable: bool=false,
  ~isCardSelected: card => bool=_ => false,
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
          <CardDnd.Cards.DroppableContainer
            key={Card.cardToString(card) ++ index->string_of_int}
            accept={_ => false}
            id={CardDnd.ContainerId.make(CardDnd.ToCard(card))}
            axis=X>
            <CardDnd.Cards.DraggableItem
              className={(~dragging: bool) => cx(["", dragging ? "" : ""])}
              id=card
              containerId={CardDnd.ContainerId.make(CardDnd.ToCard(card))}
              index>
              #Children(
                <CardUI
                  selected={isCardSelected(card)} card disabled={disabled || isCardDisabled(card)}
                />,
              )
            </CardDnd.Cards.DraggableItem>
          </CardDnd.Cards.DroppableContainer>
        | false =>
          <CardUI
            key={Card.cardToString(card) ++ index->string_of_int}
            selected={isCardSelected(card)}
            card
            disabled={disabled || isCardDisabled(card)}
          />
        }
      })}
    </div>
  }
