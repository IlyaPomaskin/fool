open Types
open Utils

module DndBeatableCard = {
  @react.component
  let make = (~card, ~isDropDisabled, ~beatByClassName) =>
    <ReactDnd.Droppable
      isDropDisabled={isDropDisabled(card)}
      direction="horizontal"
      droppableId={Card.cardToString(card)}>
      {(provided, snapshot) => {
        <div className={cx([beatByClassName, "w-12 h-16"])} ref={provided.innerRef}>
          <CardUI.Base className={cx([snapshot.isDraggingOver ? "bg-pink-200 opacity-50" : ""])}>
            provided.placeholder
          </CardUI.Base>
          <div />
        </div>
      }}
    </ReactDnd.Droppable>
}

type prop = {opacity: string, transform: string}

module TransitionHookBeatBy = Spring.MakeTransition({
  type t = prop
  type item = option<card>
})

module TransitionHookTableCards = Spring.MakeTransition({
  type t = prop
  type item = tableCards
})

module CardsPair = {
  @react.component
  let attacker = (~to, ~by, ()) => {
    let transitions = TransitionHookBeatBy.use(
      [by],
      card => card->Option.map(Card.cardToString)->Option.getWithDefault(""),
      TransitionHookBeatBy.config(
        ~from={opacity: "0", transform: "scale(1.5)"},
        ~enter={opacity: "1", transform: "scale(1)"},
        ~leave={opacity: "0", transform: "scale(1.5)"},
        ~config=Spring.config(~tension=200., ()),
        (),
      ),
    )

    <div className="flex flex-col gap-3 relative">
      {switch by {
      | Some(byCard) =>
        <React.Fragment>
          <CardUI className={Utils.leftRotationClassName} card={to} />
          {transitions
          ->Array.map(({props, key}) => {
            <Spring.Div
              key
              className="absolute left-1 top-1"
              style={ReactDOM.Style.make(~opacity=props.opacity, ~transform=props.transform, ())}>
              <CardUI className=Utils.rightRotationClassName card={byCard} />
            </Spring.Div>
          })
          ->React.array}
        </React.Fragment>
      | None => <CardUI className={Utils.leftRotationClassName} card={to} />
      }}
    </div>
  }

  @react.component
  let defender = (~to, ~by, ~isDropDisabled, ()) => {
    let beatByClassName = `${Utils.rightRotationClassName} absolute left-1 top-1`

    <div className="flex flex-col gap-3 relative">
      {switch by {
      | Some(byCard) =>
        <React.Fragment>
          <CardUI className={Utils.leftRotationClassName} card={to} />
          <div className=beatByClassName> <CardUI card={byCard} /> </div>
        </React.Fragment>
      | None =>
        <React.Fragment>
          <CardUI className={Utils.leftRotationClassName} card={to} />
          <DndBeatableCard isDropDisabled beatByClassName card={to} />
        </React.Fragment>
      }}
    </div>
  }
}

let tableCardToKey = ((to, _)) => Card.cardToString(to)

@react.component
let make = (~className: string="", ~isDefender=false, ~isDropDisabled=_ => true, ~table: table) => {
  let transitions = TransitionHookTableCards.use(
    table->List.toArray->Array.reverse,
    tableCardToKey,
    TransitionHookTableCards.config(
      ~from={opacity: "0", transform: "scale(1.5)"},
      ~enter={opacity: "1", transform: "scale(1)"},
      ~leave={opacity: "0", transform: "scale(1.5)"},
      ~config=Spring.config(~tension=200., ()),
      (),
    ),
  )

  <div className={cx(["flex gap-1 flex-row", className])}>
    {transitions
    ->Array.map(({TransitionHookTableCards.item: (to, by), props, key}) =>
      <Spring.Div
        key style={ReactDOM.Style.make(~opacity=props.opacity, ~transform=props.transform, ())}>
        {switch isDefender {
        | true => <CardsPair.defender to by isDropDisabled />
        | false => <CardsPair.attacker to by />
        }}
      </Spring.Div>
    )
    ->React.array}
  </div>
}
