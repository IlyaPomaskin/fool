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
    ~onClick: _ => unit=noop,
    ~children: option<React.element>=?,
    (),
  ) => {
    <div
      onClick={disabled ? noop : onClick}
      className={cx([
        "relative w-12 h-16",
        "border rounded-md border-solid border-slate-500",
        "cursor-pointer select-none",
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

type cardProps = {
  "card": card,
  "className": option<string>,
  "disabled": option<bool>,
  "onClick": option<card => unit>,
  "selected": option<bool>,
}

type eCardProps = {
  "className": string,
  "disabled": bool,
  "selected": bool,
  "card": plainCard,
  "onClick": card => unit,
}

module VisibleCard = {
  let makeProps = (
    ~card: plainCard,
    ~className: string="",
    ~disabled: bool=false,
    ~selected: bool=false,
    ~onClick: card => unit=noop,
    ~key as _: option<string>=?,
    (),
  ) =>
    {
      "className": className,
      "disabled": disabled,
      "selected": selected,
      "card": card,
      "onClick": onClick,
    }

  let make = (props: eCardProps) => {
    let className = props["className"]
    let disabled = props["disabled"]
    let selected = props["selected"]
    let card = props["card"]
    let onClick = props["onClick"]

    <Base
      disabled
      selected
      className={cx([
        className,
        disabled ? "text-slate-400" : suitToColor(fst(card)),
        "overflow-hidden",
      ])}
      onClick={_ => onClick(Visible(card))}>
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
  let make = (~className: string="", ~onClick: card => unit=noop) => {
    <Base className={cx([className, "overflow-hidden"])} onClick>
      <div
        className="absolute w-full h-full bg-gradient-to-tl from-purple-500 to-pink-500 bg-opacity-50"
      />
    </Base>
  }
}

module EmptyCard = {
  @react.component
  let make = (~className: string="", ~onClick: card => unit=noop) => {
    <Base className={cx([className, "overflow-hidden"])} onClick />
  }
}

module Local = {
  @react.component
  let make = (
    ~card: card,
    ~className: string="",
    ~disabled: bool=false,
    ~selected: bool=false,
    ~onClick: card => unit=noop,
  ) => {
    switch card {
    | Visible(card) => <VisibleCard card className disabled selected onClick />
    | Hidden => <HiddenCard className onClick />
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
  ~onCardClick: card => unit=noop,
  (),
) =>
  switch deck {
  | list{} => <div className> {uiStr("No cards in deck")} </div>
  | _ =>
    <div className={cx([className, "leading"])}>
      <CardDnd.Cards.DroppableContainer accept={_ => false} id={CardDnd.DeckId.make("deck")} axis=X>
        {deck->uiListWithIndex((index, card) => {
          switch isDraggable {
          | true =>
            <CardDnd.Cards.DraggableItem
              className={(~dragging: bool) => cx(["inline-block mx-1", dragging ? "" : ""])}
              key={Card.cardToString(card) ++ index->string_of_int}
              id=card
              containerId={CardDnd.DeckId.make("deck")}
              index>
              #Children(
                <Local
                  selected={isCardSelected(card)}
                  card
                  disabled={disabled || isCardDisabled(card)}
                  onClick={onCardClick}
                />,
              )
            </CardDnd.Cards.DraggableItem>
          | false =>
            <Local
              key={Card.cardToString(card) ++ index->string_of_int}
              selected={isCardSelected(card)}
              className="inline-block mx-1"
              card
              disabled={disabled || isCardDisabled(card)}
              onClick={onCardClick}
            />
          }
        })}
      </CardDnd.Cards.DroppableContainer>
    </div>
  }

@react.component
let table = (
  ~className: string="",
  ~isCardSelected: card => bool=_ => false,
  ~isCardDisabled: card => bool=_ => false,
  ~table: table,
  ~onCardClick: card => unit=noop,
) =>
  <div className>
    {switch table {
    | list{} => uiStr("Table empty")
    | _ =>
      table->uiList(((to, by)) => {
        let isDisabled = Option.isSome(by) || isCardDisabled(to)

        <div
          className="inline-block mx-1 relative"
          key={Card.cardToString(to) ++
          by->Option.map(Card.cardToString)->Option.getWithDefault("")}>
          {switch by {
          | Some(byCard) =>
            <div>
              <Local disabled={Option.isSome(by)} card={byCard} />
              <Local
                className="mb-1"
                selected={isCardSelected(to)}
                card={to}
                disabled={isDisabled}
                onClick={onCardClick}
              />
            </div>
          | None =>
            <CardDnd.Cards.DroppableContainer
              className={(~draggingOver: bool) =>
                cx([
                  "inline-block",
                  // "absolute",
                  "w-12 h-16",
                  "border rounded-md border-solid border-slate-500",
                  draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-50" : "",
                ])}
              accept={_ => true}
              id={CardDnd.DeckId.make(Card.cardToString(to))}
              axis=X>
              <Local
                className="mb-1"
                selected={isCardSelected(to)}
                card={to}
                disabled={isDisabled}
                onClick={onCardClick}
              />
            </CardDnd.Cards.DroppableContainer>
          }}
        </div>
      })
    }}
  </div>
