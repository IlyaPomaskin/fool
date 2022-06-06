open Types
open Utils

module DndBeatableCard = {
  @react.component
  let make = (~card, ~isDropDisabled, ~beatByClassName, ~onDrop) => {
    let (cProps, ref) = Dnd.UseDrop.makeInstance(
      Dnd.UseDrop.makeConfig(
        ~canDrop=(card, _) => isDropDisabled(card),
        ~accept="card",
        ~drop=(item, _) => {
          onDrop(card, item)

          None
        },
        ~collect=monitor => {
          isDragging: !(monitor->Dnd.DropTargetMonitor.isOver({shallow: false})),
          draggedCard: monitor->Dnd.DropTargetMonitor.getItem,
          isOver: monitor->Dnd.DropTargetMonitor.isOver({shallow: false}),
          isOverCurrent: monitor->Dnd.DropTargetMonitor.isOver({shallow: true}),
        },
        (),
      ),
      [],
    )

    <div ref className={cx([beatByClassName, "w-12 h-16"])}>
      <CardUI.EmptyCard className={cx([cProps.isOverCurrent ? "bg-pink-200 opacity-50" : ""])} />
    </div>
  }
}

type prop = {opacity: string, transform: string}
module CardTransition = Spring.MakeTransition({
  type t = prop
  type item = tableCards
})

let makeTransitions = cards =>
  CardTransition.use(
    cards,
    ((to, _)) => Card.cardToString(to),
    CardTransition.config(
      ~from={opacity: "0", transform: "scale(1.5)"},
      ~enter={opacity: "1", transform: "scale(1)"},
      ~leave={opacity: "0", transform: "scale(1.5)"},
      ~config=Spring.config(~tension=100., ()),
      (),
    ),
  )

module CardsPair = {
  @react.component
  let attacker = (~pair, ()) => {
    let transitions = makeTransitions(Array.keep([pair], ((_, by)) => Option.isSome(by)))

    <div className="flex flex-col gap-3 relative">
      <CardUI className={Utils.leftRotationClassName} card={fst(pair)} />
      {transitions
      ->Array.map(({item, props, key}) => {
        <Spring.Div
          key
          className="absolute left-1 top-1"
          style={ReactDOM.Style.make(~opacity=props.opacity, ~transform=props.transform, ())}>
          <CardUI
            className=Utils.rightRotationClassName card={Option.getWithDefault(snd(item), Hidden)}
          />
        </Spring.Div>
      })
      ->React.array}
    </div>
  }

  @react.component
  let defender = (~pair, ~isDropDisabled, ~onDrop, ()) => {
    let (to, by) = pair
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
          <DndBeatableCard isDropDisabled beatByClassName card={to} onDrop />
        </React.Fragment>
      }}
    </div>
  }
}

@react.component
let make = (
  ~className: string="",
  ~isDefender=false,
  ~isDropDisabled=_ => true,
  ~table: table,
  ~onDrop,
) => {
  let transitions = makeTransitions(table->List.toArray->Array.reverse)

  <div className={cx(["flex gap-1 flex-row", className])}>
    {transitions
    ->Array.map(({CardTransition.item: pair, props, key}) =>
      <Spring.Div
        key style={ReactDOM.Style.make(~opacity=props.opacity, ~transform=props.transform, ())}>
        {switch isDefender {
        | true => <CardsPair.defender pair isDropDisabled onDrop />
        | false => <CardsPair.attacker pair />
        }}
      </Spring.Div>
    )
    ->React.array}
  </div>
}
