open Utils
open Types

let suitToColor = (suit: suit) =>
  switch suit {
  | Spades => "text-slate-500"
  | Clubs => "text-slate-500"
  | Hearts => "text-red-900 dark:text-cyan-300"
  | Diamonds => "text-red-900 dark:text-cyan-300"
  }

module Base = {
  @react.component
  let make = (
    ~className: string="",
    ~disabled: bool=false,
    ~selected: bool=false,
    ~children: option<React.element>=?,
    (),
  ) => {
    <div
      className={cx([
        "relative w-12 h-16",
        "border rounded-md border-solid border-slate-500",
        "select-none",
        disabled ? "border-slate-400" : "",
        selected ? Utils.selected : Utils.unselected,
        className,
      ])}>
      {switch children {
      | Some(children) => children
      | None => React.null
      }}
    </div>
  }
}

module VisibleCard = {
  let makeProps = (
    ~card: plainCard,
    ~className: string="",
    ~disabled: bool=false,
    ~selected: bool=false,
    ~key as _: option<string>=?,
    (),
  ) =>
    {
      "className": className,
      "disabled": disabled,
      "selected": selected,
      "card": card,
    }

  let make = props => {
    let className = props["className"]
    let disabled = props["disabled"]
    let selected = props["selected"]
    let card = props["card"]

    <Base
      disabled
      selected
      className={cx([
        className,
        disabled ? "text-slate-400" : suitToColor(fst(card)),
        "overflow-hidden",
      ])}>
      <div className="absolute w-full h-full bg-gradient-to-tl from-purple-200 to-pink-200 " />
      <div className="absolute text-[18px] leading-[18px] inset-1">
        {uiStr(Card.suitToString(fst(card)))}
      </div>
      <div
        className={"absolute top-1/2 left-1/2 " ++
        "font-bold text-[18px] leading-[18px] " ++ "translate-y-[-50%] translate-x-[-50%]"}>
        {uiStr(Card.rankToString(snd(card)))}
      </div>
    </Base>
  }
}

module HiddenCard = {
  @react.component
  let make = (~className: string="") => {
    <Base className={cx([className, "overflow-hidden"])}>
      <div
        className="absolute w-full h-full bg-gradient-to-tl from-purple-500 to-pink-500 bg-opacity-50"
      />
    </Base>
  }
}

module EmptyCard = {
  @react.component
  let make = (~className: string="") => {
    <Base className={cx([className, "overflow-hidden"])} />
  }
}

module Local = {
  @react.component
  let make = (~card: card, ~className: string="", ~disabled: bool=false, ~selected: bool=false) => {
    switch card {
    | Visible(card) => <VisibleCard card className disabled selected />
    | Hidden => <HiddenCard className />
    }
  }
}

include Local

@react.component
let trump = (~suit: suit, ~className: string="", ()) =>
  <div className={cx([className, suitToColor(suit)])}> {uiStr(Card.suitToString(suit))} </div>

@react.component
let deck = (
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
            id={CardDnd.DeckId.make(card)}
            axis=X>
            <CardDnd.Cards.DraggableItem
              className={(~dragging: bool) => cx(["", dragging ? "" : ""])}
              id=card
              containerId={CardDnd.DeckId.make(card)}
              index>
              #Children(
                <Local
                  selected={isCardSelected(card)} card disabled={disabled || isCardDisabled(card)}
                />,
              )
            </CardDnd.Cards.DraggableItem>
          </CardDnd.Cards.DroppableContainer>
        | false =>
          <Local
            key={Card.cardToString(card) ++ index->string_of_int}
            selected={isCardSelected(card)}
            className="inline-block mx-1"
            card
            disabled={disabled || isCardDisabled(card)}
          />
        }
      })}
    </div>
  }

@react.component
let table = (
  ~className: string="",
  ~isCardSelected: card => bool=_ => false,
  ~isCardDisabled: card => bool=_ => false,
  ~table: table,
) =>
  <div className={cx(["flex gap-1 flex-row", className])}>
    {switch table {
    | list{} => uiStr("Table empty")
    | _ =>
      table->uiList(((to, by)) => {
        let isDisabled = Option.isSome(by) || isCardDisabled(to)

        <div
          className="relative"
          key={Card.cardToString(to) ++
          by->Option.map(Card.cardToString)->Option.getWithDefault("")}>
          {switch by {
          | Some(byCard) =>
            <div className="flex flex-col gap-1">
              <Local card={to} disabled={true} />
              <Local card={byCard} className="absolute opacity-0.5" disabled={true} />
            </div>
          | None =>
            <div className="flex flex-col gap-1">
              <Local selected={isCardSelected(to)} card={to} disabled={isDisabled} />
              <CardDnd.Cards.DroppableContainer
                className={(~draggingOver: bool) =>
                  cx([
                    "top-0",
                    "left-0",
                    "w-12 h-16",
                    draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : "",
                  ])}
                accept={_ => true}
                id={CardDnd.DeckId.make(to)}
                axis=Y
                lockAxis={true}>
                <div
                  className={cx([
                    // "absolute",
                    "w-12 h-16",
                    "inline-block",
                    "transform-x-[-100%]",
                    "border rounded-md border-solid border-slate-500",
                  ])}
                />
              </CardDnd.Cards.DroppableContainer>
            </div>
          }}
        </div>
      })
    }}
  </div>
