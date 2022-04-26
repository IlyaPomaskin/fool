open UiUtils
open Types

module InLobbyUI = {
  @react.component
  let make = (~game: inLobby) =>
    <div>
      {uiStr("inLobby")}
      <br />
      <br />
      {uiStr("players:")}
      <br />
      <div> {uiList(game.players, p => <PlayerUI key={p.id} player={p} />)} </div>
      <br />
      {uiStr("ready:")}
      <br />
      <div> {uiList(game.ready, p => <PlayerUI key={p.id} player={p} />)} </div>
    </div>
}

module Button = {
  @react.component
  let make = (
    ~disabled: bool=false,
    ~pressed: bool=false,
    ~className: string="",
    ~onClick: ReactEvent.Mouse.t => unit=noop,
    ~children: React.element,
  ) => {
    <button
      disabled
      className={cx([
        className,
        "p-1 border rounded-md border-solid border-slate-500 bg-slate-100 shadow-sm hover:shadow-md",
        pressed ? selected : "",
        disabled
          ? "border-slate-400 text-slate-400 cursor-not-allowed shadow-none hover:shadow-none"
          : "",
      ])}
      onClick>
      children
    </button>
  }
}

module ClientUI = {
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
            ->Option.map(to => !Card.isValidTableBeat(to, by, game.trump))
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
        <Button
          disabled={!GameUtils.isCanPass(game, player)}
          pressed={GameUtils.isPassed(game, player)}
          onClick={_ => onMove(Pass(player))}>
          {uiStr("pass")}
        </Button>
        <Button disabled={!GameUtils.isCanTake(game, player)} onClick={handleTake}>
          {uiStr("take")}
        </Button>
        <Button
          disabled={!isDef || Option.isNone(toBeat) || Option.isNone(beatBy)} onClick={handleBeat}>
          {uiStr("beat")}
        </Button>
      </div>
      <div className="mt-1">
        {switch isDef {
        | true => {
            let isCardSelected = card =>
              toBeat->Option.map(Utils.equals(card))->Option.getWithDefault(false)

            let isCardDisabled = to =>
              beatBy
              ->Option.map(by => !Card.isValidTableBeat(to, by, game.trump))
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
}

module InProgressUI = {
  @react.component
  let make = (~game: inProgress, ~onMove: move => unit) =>
    <div>
      <div>
        {uiStr("Attacker: ")} <PlayerUI.Short className="inline-block" player={game.attacker} />
      </div>
      <div>
        {uiStr("Defender: ")} <PlayerUI.Short className="inline-block" player={game.defender} />
      </div>
      <div>
        {game.players->uiList(p =>
          <div key={p.id} className="inline-block mr-3">
            <PlayerUI.Short className="inline-block" player={p} />
            {uiStr(" (" ++ p.cards->List.length->string_of_int ++ ")")}
            {uiStr(GameUtils.isPassed(game, p) ? " (pass) " : "")}
            {uiStr(GameUtils.isAttacker(game, p) ? " (ATT) " : "")}
            {uiStr(GameUtils.isDefender(game, p) ? " (DEF) " : "")}
          </div>
        )}
      </div>
      <div> {uiStr("Trump: ")} <CardUI.trump className="inline-block" suit={game.trump} /> </div>
      <div> {uiStr("Deck: " ++ game.deck->List.length->string_of_int)} </div>
      <div className="flex flex-wrap">
        {game.players->uiList(p =>
          <ClientUI
            key={p.id} className="m-1 flex-initial w-96" player={p} game={game} onMove={onMove}
          />
        )}
      </div>
    </div>
}

@react.component
let make = (~game: state) =>
  switch game {
  // | InProgress(g) => <InProgressUI game={g} />
  | InLobby(g) => <InLobbyUI game={g} />
  | _ => <div />
  }
