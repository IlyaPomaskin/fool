open Utils
open Types

let suitToString = suit => {
  switch suit {
  | Spades => `♤`
  | Hearts => `♡`
  | Diamonds => `♢`
  | Clubs => `♧`
  }
}

let rankToString = rank => {
  switch rank {
  | Six => "6"
  | Seven => "7"
  | Eight => "8"
  | Nine => "9"
  | Ten => "10"
  | Jack => "J"
  | Queen => "Q"
  | King => "K"
  | Ace => "A"
  }
}

let suitToColor = (suit: suit) =>
  switch suit {
  | Spades => "text-slate-500"
  | Clubs => "text-slate-500"
  | Hearts => "text-red-900 dark:text-red-600"
  | Diamonds => "text-red-900 dark:text-red-600"
  }

module Short = {
  @react.component
  let make = (~className="", ~card, ()) => {
    switch card {
    | Visible((suit, rank)) =>
      <span className> {uiStr(suitToString(suit) ++ rankToString(rank))} </span>
    | Hidden => <span className> {uiStr("Hidden")} </span>
    }
  }
}

module Base = {
  @react.component
  let make = (
    ~className: string="",
    ~disabled: bool=false,
    ~children: option<React.element>=?,
    (),
  ) => {
    <div
      className={cx([
        "relative w-12 h-16",
        "border rounded-md border-solid border-slate-500",
        "select-none",
        disabled ? "border-slate-400" : "",
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
    ~key as _: option<string>=?,
    (),
  ) =>
    {
      "className": className,
      "disabled": disabled,
      "card": card,
    }

  let make = props => {
    let className = props["className"]
    let disabled = props["disabled"]
    let card = props["card"]

    <Base
      disabled
      className={cx([
        className,
        disabled ? "text-slate-400" : suitToColor(fst(card)),
        "overflow-hidden",
        "font-bold text-[16px] leading-[16px] ",
      ])}>
      <div className="absolute w-full h-full bg-gradient-to-tl from-purple-200 to-pink-200 " />
      <div className="flex flex-col gap-0.5 absolute top-1 left-1 ">
        <div className="text-center"> {uiStr(suitToString(fst(card)))} </div>
        <div className="text-center"> {uiStr(rankToString(snd(card)))} </div>
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
  let make = (~className: string="", ~children=React.null) => {
    <Base className={cx([className, "overflow-hidden"])}> children </Base>
  }
}

@react.component
let make = (~card: card, ~className: string="", ~disabled: bool=false) => {
  switch card {
  | Visible(card) => <VisibleCard card className disabled />
  | Hidden => <HiddenCard className />
  }
}

@react.component
let trump = (~suit: suit, ~className: string="", ()) =>
  <div className={cx([className, suitToColor(suit)])}> {suit->suitToString->uiStr} </div>
