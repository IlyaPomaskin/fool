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
  let make = (~className: string="", ~card: card, ~onClick: option<card => unit>=?, ()) => {
    <div
      onClick={switch onClick {
      | Some(fn) => _ => fn(card)
      | None => _ => ()
      }}
      className={cx([
        "relative w-12 h-16",
        "border rounded-md border-solid border-slate-500",
        "cursor-pointer select-none",
        suitToColor(fst(card)),
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
let trump = (~suit: suit, ()) =>
  <div className={suitToColor(suit)}> {uiStr(Card.suitToString(suit))} </div>

@react.component
let deck = (~deck: deck, ~onCardClick: option<card => unit>=?, ()) =>
  switch deck {
  | list{} => <div> {uiStr("No cards in deck")} </div>
  | _ =>
    <div className="leading">
      {uiList(deck, card =>
        <CardUILocal
          key={Card.cardToString(card)}
          className="inline-block mx-1"
          card={card}
          onClick={Option.getWithDefault(onCardClick, noop)}
        />
      )}
    </div>
  }
