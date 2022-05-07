open Utils
open Types

module Parts = {
  @react.component
  let actions = (
    ~game: inProgress,
    ~player: player,
    ~beat: (option<card>, option<card>),
    ~onPass: _ => unit,
    ~onTake: _ => unit,
    ~onBeat: _ => unit,
  ) => {
    let (toBeat, beatBy) = beat
    let isDefender = GameUtils.isDefender(game, player)
    let isPassDisabled = !GameUtils.isCanPass(game, player)
    let isPassed = GameUtils.isPassed(game, player)
    let isTakeDisabled = !GameUtils.isCanTake(game, player)
    let isBeatDisabled = !isDefender || Option.isNone(toBeat) || Option.isNone(beatBy)

    <div className="grid grid-flow-col gap-1">
      <Base.Switch disabled={isPassDisabled} onClick={onPass} checked={isPassed} text="pass" />
      <Base.Button disabled={isTakeDisabled} onClick={onTake}> {uiStr("take")} </Base.Button>
      <Base.Button disabled={isBeatDisabled} onClick={onBeat}> {uiStr("beat")} </Base.Button>
    </div>
  }

  @react.component
  let table = (
    ~game: inProgress,
    ~player: player,
    ~beat: (option<card>, option<card>),
    ~onCardClick: _ => unit,
  ) => {
    let (toBeat, beatBy) = beat
    let isDefender = GameUtils.isDefender(game, player)

    <div className="mt-1">
      {switch isDefender {
      | true => {
          let isCardSelected = card =>
            toBeat->Option.map(Utils.equals(card))->Option.getWithDefault(false)

          let isCardDisabled = to =>
            beatBy
            ->Option.map(by => !Card.isValidBeat(to, by, game.trump))
            ->Option.getWithDefault(false)

          <CardUI.table
            isCardSelected isCardDisabled className="my-1" table={game.table} onCardClick
          />
        }
      | false => React.null
      }}
    </div>
  }

  @react.component
  let deck = (
    ~game: inProgress,
    ~player: player,
    ~beat: (option<card>, option<card>),
    ~isDraggable: bool=false,
    ~onCardClick: _ => unit,
  ) => {
    let (toBeat, beatBy) = beat
    let isDefender = GameUtils.isDefender(game, player)
    let disabled = isDefender
      ? !Table.hasCards(game.table)
      : !GameUtils.isPlayerCanMove(game, player)

    let isCardSelected = card =>
      beatBy->Option.map(Utils.equals(card))->Option.getWithDefault(false)

    let isCardDisabled = by =>
      toBeat->Option.map(to => !Card.isValidBeat(to, by, game.trump))->Option.getWithDefault(false)

    <CardUI.deck
      disabled isDraggable isCardSelected isCardDisabled deck={player.cards} onCardClick
    />
  }
}

@react.component
let make = (
  ~className: string="",
  ~player: player,
  ~isOwner: bool=false,
  ~game: inProgress,
  ~onMove: move => unit,
) => {
  let {toBeat, beatBy, setBeat, handleSelectToBeat} = UseBeatCard.hook(~game, ~player)
  let {handleBeat, handleTake, handleMove, handlePass} = UseInProgressActions.hook(
    ~toBeat,
    ~beatBy,
    ~setBeat,
    ~onMove,
  )

  let isDefender = GameUtils.isDefender(game, player)

  let handleReorder = (
    result: option<
      Dnd__Types.ReorderResult.t<
        CardDnd.Cards.DndManager.Item.t,
        CardDnd.Cards.DndManager.Container.t,
      >,
    >,
  ) => {
    Js.log2("NNNNN", result)
    switch result {
    | Some(rResult) =>
      switch rResult {
      | SameContainer(item, placement) =>
        Js.logMany(["same container", item->Card.cardToString, placement->Obj.magic])

      | NewContainer(item, containerId, placement) =>
        Js.logMany([
          "same container",
          item->Card.cardToString,
          containerId->Obj.magic,
          placement->Obj.magic,
        ])
      }
    | x => Js.log2("unknown", x)
    }->ignore
    ()
  }

  let handleDropEnd = (~itemId as _itemId) => {
    Js.log2("dropEnd", _itemId)
  }

  <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
    <div className="mb-1">
      {uiStr("Player: ")}
      <PlayerUI.Short className="inline-block" player />
      {uiStr(isDefender ? ` 🛡️` : "")}
      {uiStr(GameUtils.isAttacker(game, player) ? ` 🔪` : "")}
    </div>
    {switch GameUtils.getPlayerGameState(game, player) {
    | Done => uiStr("Done")
    | Lose => uiStr("Lose")
    | Draw => uiStr("Draw")
    | Playing =>
      <div>
        <CardDnd.Cards.DndManager onDropEnd={handleDropEnd} onReorder={handleReorder}>
          {switch isOwner {
          | true =>
            <div className="my-2">
              <Parts.actions
                game
                player
                beat={(toBeat, beatBy)}
                onPass={handlePass}
                onTake={handleTake}
                onBeat={handleBeat}
              />
            </div>
          | false => React.null
          }}
          <Parts.deck
            isDraggable={true}
            game
            player
            beat={(toBeat, beatBy)}
            onCardClick={isDefender ? handleSelectToBeat(false) : handleMove}
          />
          <Parts.table game player beat={(toBeat, beatBy)} onCardClick={handleSelectToBeat(true)} />
        </CardDnd.Cards.DndManager>
      </div>
    }}
  </div>
}
