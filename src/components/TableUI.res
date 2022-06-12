open Types
open Utils

module DndBeatableCard = {
  module DragObject = {
    type t = Types.card
  }
  module EmptyDropResult = {
    type t
  }

  module CollectedProps = {
    type t = {
      canDrop: bool,
      isDragging: bool,
      draggedCard: card,
      isOver: bool,
      isOverCurrent: bool,
    }
  }

  include RDnd.MakeUseDrop(DragObject, EmptyDropResult, CollectedProps)

  @react.component
  let make = (~card, ~canDrop, ~onDrop) => {
    let (cProps, ref) = UseDrop.makeInstance(
      UseDrop.makeConfig(
        ~canDrop=(_, _) => canDrop(card),
        ~accept="card",
        ~drop=(item, monitor) => {
          let didDrop = monitor->DropTargetMonitor.didDrop

          Js.log3("TU beat", card->Card.cardToString, item->Card.cardToString)
          Js.log2("TU didDrop", didDrop)

          onDrop(card, item)

          None
        },
        ~collect=monitor => {
          {
            canDrop: canDrop(card),
            isDragging: !(monitor->DropTargetMonitor.isOver({shallow: false})),
            draggedCard: monitor->DropTargetMonitor.getItem,
            isOver: monitor->DropTargetMonitor.isOver({shallow: false}),
            isOverCurrent: monitor->DropTargetMonitor.isOver({shallow: true}),
          }
        },
        (),
      ),
      [],
    )

    <div ref className={cx(["relative z-100 w-12 h-16"])}>
      <CardUI.EmptyCard
        className={cx([cProps.isOverCurrent && !cProps.canDrop ? "bg-pink-500 opacity-70" : ""])}
      />
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
  let defender = (~pair, ~canDrop, ~onDrop, ()) => {
    let (toCard, byCard) = pair
    let beatByClassName = `${Utils.rightRotationClassName} absolute left-1 top-1`

    <div className="flex flex-col gap-3 relative">
      <CardUI className={Utils.leftRotationClassName} card={toCard} />
      <div className=beatByClassName>
        {switch byCard {
        | Some(byCard) => <CardUI card={byCard} />
        | None => <DndBeatableCard card={toCard} canDrop onDrop />
        }}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~className: string="",
  ~isDefender=false,
  ~canDrop=_ => true,
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
        | true => <CardsPair.defender pair canDrop onDrop />
        | false => <CardsPair.attacker pair />
        }}
      </Spring.Div>
    )
    ->React.array}
  </div>
}
