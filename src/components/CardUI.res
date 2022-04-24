open UiUtils
open Types

let suitToColor = (suit: suit) =>
  switch suit {
  | Spades => "text-slate-500"
  | Clubs => "text-slate-500"
  | Hearts => "text-red-900 dark:text-cyan-300"
  | Diamonds => "text-red-900 dark:text-cyan-300"
  }

module CardUILocal = {
  @react.component
  let make = (
    ~className: string="",
    ~disabled: bool=false,
    ~card: card,
    ~onClick: card => unit=noop,
    (),
  ) => {
    <div
      onClick={disabled ? noop : _ => onClick(card)}
      className={cx([
        "relative w-12 h-16",
        "border rounded-md border-solid border-slate-500",
        "cursor-pointer select-none",
        disabled ? "text-slate-300 border-slate-400" : suitToColor(fst(card)),
        className,
      ])}>
      <div className="absolute text-[18px] leading-[18px] inset-1">
        {uiStr(Card.suitToString(fst(card)))}
      </div>
      <div
        className={"absolute top-1/2 left-1/2 " ++
        "font-bold text-[18px] leading-[18px] " ++ "translate-y-[-50%] translate-x-[-50%]"}>
        {uiStr(Card.rankToString(snd(card)))}
      </div>
    </div>
  }
}

let make = (~className: string="", ~card: card, ~onClick: option<card => unit>=?, ()) => {
  <CardUILocal className card onClick={onClick->Option.getWithDefault(noop)} />
}

@react.component
let trump = (~suit: suit, ~className: string="", ()) =>
  <div className={cx([className, suitToColor(suit)])}> {uiStr(Card.suitToString(suit))} </div>

@react.component
let deck = (~deck: deck, ~disabled: bool=false, ~onCardClick: option<card => unit>=?, ()) =>
  switch deck {
  | list{} => <div> {uiStr("No cards in deck")} </div>
  | _ =>
    <div className="leading">
      {uiList(deck, card =>
        <CardUILocal
          key={Card.cardToString(card)}
          className="inline-block mx-1"
          card={card}
          disabled
          onClick={Option.getWithDefault(onCardClick, noop)}
        />
      )}
    </div>
  }

@react.component
let table = (~table: table) =>
  <div>
    {switch table {
    | list{} => uiStr("Table empty")
    | _ =>
      table->uiList(((to, by)) =>
        <div
          className="inline-block mx-1"
          key={Card.cardToString(to) ++
          Option.getWithDefault(Option.map(by, Card.cardToString), "a")}>
          <CardUILocal card={to} />
          {switch by {
          | Some(byCard) => <CardUILocal card={byCard} />
          | None => <div> {uiStr("None")} </div>
          }}
        </div>
      )
    }}
  </div>
