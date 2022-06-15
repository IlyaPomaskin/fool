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
    type t = {isOverCurrent: bool}
  }

  include ReactDnd.MakeUseDrop(DragObject, EmptyDropResult, CollectedProps)

  @react.component
  let make = (~card, ~canDrop, ~onDrop) => {
    let canDrop = canDrop(card)

    let (cProps, ref) = UseDrop.makeInstance(
      UseDrop.makeConfig(
        ~canDrop=(_, _) => canDrop,
        ~accept="card",
        ~drop=(item, _) => onDrop(card, item),
        ~collect=monitor => {
          isOverCurrent: monitor->DropTargetMonitor.isOver({shallow: true}),
        },
        (),
      ),
      [any(onDrop), any(card), any(canDrop)],
    )

    <div ref className={cx(["w-12 h-16"])}>
      <CardUI.EmptyCard
        className={cx([
          cProps.isOverCurrent && canDrop ? "bg-pink-500 opacity-70" : "",
          "border-dashed",
        ])}
      />
    </div>
  }
}

type prop = {opacity: string, transform: string}
module CardTransition = Spring.MakeTransition({
  type t = prop
  type item = tableCards
})

let useCardsTransition = items => {
  CardTransition.use(
    items,
    ((to, _)) => Card.cardToString(to),
    CardTransition.config(
      ~from={opacity: "0", transform: "scale(1.5)"},
      ~enter={opacity: "1", transform: "scale(1)"},
      ~leave={opacity: "0", transform: "scale(1.5)"},
      ~config=Spring.config(~tension=100., ()),
      (),
    ),
  )
}

module CardsPair = {
  @react.component
  let attacker = (~pair, ()) => {
    let cards = Array.keep([pair], ((_, by)) => Option.isSome(by))
    let transitions = useCardsTransition(cards)

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

    <div className="flex flex-col gap-3 relative">
      <CardUI className={Utils.leftRotationClassName} card={toCard} />
      <div className={`${Utils.rightRotationClassName} absolute left-1 top-1`}>
        {switch byCard {
        | Some(byCard) => <CardUI card={byCard} />
        | None => <DndBeatableCard card={toCard} canDrop onDrop />
        }}
      </div>
    </div>
  }
}

module CardsList = {
  @react.component
  let make = (
    ~className: string="",
    ~isDefender=false,
    ~canDrop=_ => true,
    ~table: table,
    ~onDrop,
  ) => {
    let transitions = useCardsTransition(table->List.toArray->Array.reverse)

    <div className={cx(["flex gap-2 flex-row", className])}>
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
      <CardUI.Base className="invisible" />
    </div>
  }
}

module DragObject = {
  type t = Types.card
}

module EmptyDropResult = {
  type t
}

module CollectedProps = {
  type t = {isDragging: bool}
}

module Drop = ReactDnd.MakeUseDrop(DragObject, EmptyDropResult, CollectedProps)

@react.component
let make = (~game, ~draggedCard, ~player, ~onDrop, ~onBeat) => {
  let isDefender = GameUtils.isDefender(game, player)
  let draggedCard = MOption.toResult(draggedCard, "No card")

  let (_, ref) = Drop.UseDrop.makeInstance(
    Drop.UseDrop.makeConfig(
      ~accept="card",
      ~drop=(card, _) => onDrop(card),
      ~canDrop=(card, _) => Game.isValidMove(game, player, card)->Result.isOk,
      (),
    ),
    [any(game), any(player), any(onDrop)],
  )

  <div className="relative">
    <div
      ref
      className={cx([
        "absolute -mx-6 -my-8 z-[0]",
        "h-[calc(100%+3rem)]",
        "w-[calc(100%+3rem)]",
        "flex flex-row bg-emerald-600 bg-opacity-40",
      ])}
    />
    <CardsList
      isDefender
      canDrop={toCard =>
        draggedCard
        ->Result.flatMap(byCard => Game.isValidBeat(game, player, toCard, byCard))
        ->Result.isOk}
      className="my-1 h-16"
      table={game.table}
      onDrop={onBeat}
    />
  </div>
}
