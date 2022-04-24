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
    ~className: string="",
    ~onClick: ReactEvent.Mouse.t => unit=noop,
    ~children: React.element,
  ) => {
    <button
      disabled
      className={cx([
        className,
        "p-1 border rounded-md border-solid border-slate-500",
        disabled ? "border-slate-400 text-slate-400 cursor-not-allowed" : "",
      ])}
      onClick>
      children
    </button>
  }
}

module ClientUI = {
  @react.component
  let make = (~className: string="", ~player: player, ~game: inProgress, ~onMove: move => unit) => {
    let handleMove = (card: card) => {
      onMove(Move(player, card))
    }

    <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
      <div className="mb-1">
        {uiStr("Player: ")} <PlayerUI.Short className="inline-block" player />
      </div>
      {switch GameUtils.isPlayerDone(game, player) {
      | true => uiStr("Done!")
      | false =>
        <CardUI.deck
          className="mt-1"
          disabled={!GameUtils.isPlayerCanMove(game, player)}
          deck={player.cards}
          onCardClick={handleMove}
        />
      }}
      <Button
        disabled={!GameUtils.isCanPass(game, player)}
        className="mr-1"
        onClick={_ => onMove(Pass(player))}>
        {uiStr("pass " ++ string_of_bool(GameUtils.isPassed(game, player)))}
      </Button>
      <Button disabled={!GameUtils.isCanTake(game, player)} onClick={_ => onMove(Take(player))}>
        {uiStr("take")}
      </Button>
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
          <div key={p.id}>
            <PlayerUI.Short className="inline-block" player={p} />
            {uiStr(" Cards: " ++ p.cards->List.length->string_of_int)}
            {uiStr(GameUtils.isPassed(game, p) ? " pass" : "")}
            {uiStr(GameUtils.isAttacker(game, p) ? " ATT" : "")}
            {uiStr(GameUtils.isDefender(game, p) ? " DEF" : "")}
          </div>
        )}
      </div>
      <div> {uiStr("Trump: ")} <CardUI.trump className="inline-block" suit={game.trump} /> </div>
      <div> {uiStr("Deck: " ++ game.deck->List.length->string_of_int)} </div>
      <div className="my-2"> {uiStr("Table:")} <CardUI.table table={game.table} /> </div>
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
