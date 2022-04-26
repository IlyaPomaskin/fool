open Utils
open Types

@react.component
let make = (~className: string="", ~player: player, ~game: inProgress, ~onMove: move => unit) => {
  let ((toBeat, beatBy), setBeat) = React.useState(() => (None, None))
  let handleSelectToBeat = (isToCard: bool, card: card) => {
    setBeat(((toBeat, beatBy)) => {
      if isToCard {
        let isSame = toBeat->Option.map(Utils.equals(card))->Option.getWithDefault(false)

        isSame ? (None, beatBy) : (Some(card), beatBy)
      } else {
        let isSame = beatBy->Option.map(Utils.equals(card))->Option.getWithDefault(false)

        isSame ? (toBeat, None) : (toBeat, Some(card))
      }
    })
  }

  let handleBeat = _ => {
    switch (toBeat, beatBy) {
    | (Some(to), Some(by)) => {
        setBeat(_ => (None, None))
        onMove(Beat(player, to, by))
      }
    | _ => ()
    }
  }

  let handleMove = (card: card) => {
    onMove(Move(player, card))
  }

  let handleTake = _ => {
    setBeat(_ => (None, None))
    onMove(Take(player))
  }

  let isDef = GameUtils.isDefender(game, player)

  React.useEffect1(() => {
    if !isDef {
      setBeat(_ => (None, None))
    }

    None
  }, [isDef])

  <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
    <div className="mb-1">
      {uiStr("Player: ")}
      <PlayerUI.Short className="inline-block" player />
      {switch (isDef, GameUtils.isAttacker(game, player)) {
      | (true, _) => uiStr(" def")
      | (_, true) => uiStr(" att")
      | _ => React.null
      }}
    </div>
    {switch GameUtils.getPlayerGameState(game, player) {
    | Done => uiStr("Done")
    | Lose => uiStr("Lose")
    | Draw => uiStr("Draw")
    | Playing => {
        let disabled = isDef
          ? !Table.hasCards(game.table)
          : !GameUtils.isPlayerCanMove(game, player)

        let isCardSelected = card =>
          beatBy->Option.map(Utils.equals(card))->Option.getWithDefault(false)

        let isCardDisabled = by =>
          toBeat
          ->Option.map(to => !Card.isValidBeat(to, by, game.trump))
          ->Option.getWithDefault(false)

        <CardUI.deck
          disabled
          isCardSelected
          isCardDisabled
          deck={player.cards}
          onCardClick={isDef ? handleSelectToBeat(false) : handleMove}
        />
      }
    }}
    <div className="grid grid-flow-col gap-1">
      <Base.Button
        disabled={!GameUtils.isCanPass(game, player)}
        pressed={GameUtils.isPassed(game, player)}
        onClick={_ => onMove(Pass(player))}>
        {uiStr("pass")}
      </Base.Button>
      <Base.Button disabled={!GameUtils.isCanTake(game, player)} onClick={handleTake}>
        {uiStr("take")}
      </Base.Button>
      <Base.Button
        disabled={!isDef || Option.isNone(toBeat) || Option.isNone(beatBy)} onClick={handleBeat}>
        {uiStr("beat")}
      </Base.Button>
    </div>
    <div className="mt-1">
      {switch isDef {
      | true => {
          let isCardSelected = card =>
            toBeat->Option.map(Utils.equals(card))->Option.getWithDefault(false)

          let isCardDisabled = to =>
            beatBy
            ->Option.map(by => !Card.isValidBeat(to, by, game.trump))
            ->Option.getWithDefault(false)

          <CardUI.table
            isCardSelected
            isCardDisabled
            className="my-1"
            table={game.table}
            onCardClick={handleSelectToBeat(true)}
          />
        }
      | false => React.null
      }}
    </div>
    <div>
      {uiStr("to: " ++ toBeat->Option.map(Card.cardToString)->Option.getWithDefault("None"))}
      {uiStr(" by: " ++ beatBy->Option.map(Card.cardToString)->Option.getWithDefault("None"))}
    </div>
  </div>
}
