open Types
open Utils

module Stack = {
  @react.component
  let make = (~className="", ~deck) => {
    let cardsAmount = deck->List.length
    let cardsList =
      deck->List.keepWithIndex((_, index) => index <= 2)->List.mapWithIndex((index, _) => index)
    let deckText = switch cardsAmount {
    | 0 => uiStr("0")
    | amount => uiStr(string_of_int(amount))
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
}

@react.component
let deck = (~deck, ~trump) => {
  let trumpCard = lastListItem(deck)

  switch trumpCard {
  | Some(Visible(card)) =>
    <div className="relative flex h-min">
      <Stack className="z-10" deck={deck} />
      <div className="z-0 relative top-1 -left-2 rotate-90"> <CardUI.VisibleCard card /> </div>
    </div>
  | Some(Hidden) => <div> <Stack deck={deck} /> <CardUI.trump suit={trump} /> </div>
  | None =>
    <CardUI.EmptyCard className="flex items-center justify-center">
      <CardUI.trump className="" suit={trump} />
    </CardUI.EmptyCard>
  }
}

@react.component
let opponent = (~deck) => <Stack deck />
