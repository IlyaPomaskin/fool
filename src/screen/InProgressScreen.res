open Types
open Utils

module PlayerActionsUI = {
  @react.component
  let make = (
    ~className: string="",
    ~game: inProgress,
    ~player: player,
    ~onPass: _ => unit,
    ~onTake: _ => unit,
  ) => {
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player.id)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)
    let isDefender = GameUtils.isDefender(game, player)
    let isDuel =
      game.players->List.keep(player => !GameUtils.isPlayerDone(game, player))->List.length <= 2

    <div className={cx(["grid grid-flow-col gap-1", className])}>
      {switch (isDefender, isDuel) {
      | (true, _) =>
        <Base.Button disabled={isTakeDisabled} onClick={onTake}> {uiStr("take")} </Base.Button>
      | (false, true) =>
        <Base.Button disabled={isPassDisabled} onClick={onPass}> {uiStr("pass")} </Base.Button>
      | (false, false) =>
        <Base.Switch disabled={isPassDisabled} onClick={onPass} checked={isPassed} text="pass" />
      }}
    </div>
  }
}

module PlayerTableUI = {
  module DragObject = {
    type t = Types.card
  }

  module EmptyDropResult = {
    type t
  }

  module CollectedProps = {
    type t = {isDragging: bool}
  }

  include ReactDnd.MakeUseDrop(DragObject, EmptyDropResult, CollectedProps)

  @react.component
  let make = (~game, ~draggedCard, ~player, ~onDrop, ~onBeat) => {
    let isDefender = GameUtils.isDefender(game, player)
    let draggedCard = MOption.toResult(draggedCard, "No card")

    let (cProps, ref) = UseDrop.makeInstance(
      UseDrop.makeConfig(
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
          "w-full flex flex-row bg-pink-200",
          cProps.isDragging
            ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70"
            : "opacity-100",
        ])}>
        <TableUI
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
    </div>
  }
}

module ClientUI = {
  @react.component
  let make = (~className: string="", ~player, ~game: inProgress, ~onDrag, ~onMessage, ()) => {
    let isDefender = GameUtils.isDefender(game, player)
    let isThereCardsOnTable = Table.hasCards(game.table)
    let isPlayerCanMove = GameUtils.isPlayerCanMove(game, player)
    let isDeckEnabled = isDefender ? isThereCardsOnTable : isPlayerCanMove
    let onMove = move => onMessage(Progress(move, player.id, game.gameId))

    <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
      {switch GameUtils.getPlayerGameState(game, player) {
      | Won => uiStr("Won")
      | Lose => uiStr("Lose")
      | Draw => uiStr("Draw")
      | Playing => uiStr("Playing")
      }}
      <div>
        <DeckUI onDrag disabled={!isDeckEnabled} isDraggable={true} deck={player.cards} />
        <PlayerActionsUI
          className="py-2" game player onPass={_ => onMove(Pass)} onTake={_ => onMove(Take)}
        />
      </div>
    </div>
  }
}

module OpponentUI = {
  @react.component
  let make = (~player, ~className, ~isDefender, ~isAttacker) => {
    <div className={cx(["flex flex-col gap-2", className])}>
      <DeckUI.hidden deck={player.cards} />
      <div className="vertial-align">
        <PlayerUI.Short player className="inline-block" />
        {uiStr(isDefender ? ` 🛡️` : "")}
        {uiStr(isAttacker ? ` 🔪` : "")}
      </div>
    </div>
  }
}

module DragLayer = {
  module DragObject = {
    type t = Types.card
  }

  module DragLayerCP = {
    type t = {
      item: DragObject.t,
      itemType: Js.nullable<ReactDnd.identifier>,
      currentOffset: ReactDnd.nullableXyCoords,
    }
  }

  module DndL = ReactDnd.MakeUseDragLayer(DragObject, DragLayerCP)

  let floatToString = float => float->int_of_float->string_of_int

  let getItemStyles = (currentOffset: ReactDnd.nullableXyCoords) => {
    let coords =
      currentOffset
      ->Js.Nullable.toOption
      ->Option.map(({x, y}) => (floatToString(x), floatToString(y)))

    switch coords {
    | Some((x, y)) => ReactDOMStyle.make(~transform=`translate(${x}px, ${y}px)`, ())
    | _ => ReactDOMStyle.make(~display="none", ())
    }
  }

  @react.component
  let make = () => {
    let {itemType, item, currentOffset} = DndL.UseDragLayer.makeInstance(monitor => {
      item: DndL.DragLayerMonitor.getItem(monitor),
      itemType: DndL.DragLayerMonitor.getItemType(monitor),
      currentOffset: DndL.DragLayerMonitor.getSourceClientOffset(monitor),
    })

    <div className="fixed pointer-events-none z-10 left-0 top-0 w-full h-full">
      <div style={getItemStyles(currentOffset)}>
        {switch Js.Nullable.toOption(itemType) {
        | Some("card") => <CardUI className="relative z-40" card={item} />
        | _ => React.null
        }}
      </div>
    </div>
  }
}

type destination =
  | ToUnknown
  | ToTable
  | ToCard(card)

let useOptimisticGame = (~game, ~player, ~onMessage) => {
  let (optimisticGame, setOptimisticGame) = React.useState(_ => game)
  React.useEffect1(() => {
    setOptimisticGame(_ => game)
    None
  }, [game])

  let handleOptimisticMessage = msg => {
    switch msg {
    | Progress(move, _, _) =>
      setOptimisticGame(prevGame =>
        Game.dispatch(prevGame, player, move)
        ->Result.flatMap(GameUtils.unpackProgress)
        ->Result.getWithDefault(prevGame)
      )
    | _ => ()
    }->ignore

    onMessage(msg)
  }

  (optimisticGame, handleOptimisticMessage)
}

@react.component
let make = (~game as realGame, ~player, ~onMessage) => {
  let (game, handleOptimisticMessage) = useOptimisticGame(~game=realGame, ~player, ~onMessage)

  let (draggedCard, setDraggedCard) = React.useState(_ => None)

  let handleDrop = card => {
    handleOptimisticMessage(Progress(Move(card), player.id, game.gameId))
    None
  }

  let handleBeat = (toCard, byCard) => {
    handleOptimisticMessage(Progress(Beat(toCard, byCard), player.id, game.gameId))
    None
  }

  let handleDrag = card => setDraggedCard(_ => Some(card))

  let reorderedPlayers =
    game.players
    ->listIndexOf(item => Player.equals(item, player))
    ->Option.flatMap(index => List.splitAt(game.players, index))
    ->Option.map(((before, after)) => List.concat(after, before))
    ->Option.map(players => List.keep(players, p => !Player.equals(p, player)))
    ->Option.getWithDefault(game.players)

  <div>
    <div className="flex">
      <div className="flex m-2 flex-row">
        <StackUI.deck deck={game.deck} trump={game.trump} />
      </div>
      <div className="flex m-2 w-full justify-evenly">
        {uiList(reorderedPlayers, player =>
          <OpponentUI
            key={player.id}
            isDefender={GameUtils.isDefender(game, player)}
            isAttacker={GameUtils.isAttacker(game, player)}
            className="m-1 flex flex-col"
            player
          />
        )}
      </div>
    </div>
    <div>
      <DragLayer />
      <div className="m-1">
        <PlayerTableUI draggedCard game player onDrop={handleDrop} onBeat={handleBeat} />
      </div>
      <ClientUI
        className="m-1 flex flex-col"
        player
        game
        onDrag={handleDrag}
        onMessage={handleOptimisticMessage}
      />
    </div>
  </div>
}
