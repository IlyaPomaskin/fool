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

module ClientUI = {
  @react.component
  let make = (~className: string="", ~player: player, ~game: inProgress, ~onMove: move => unit) => {
    <div className={cx([className, "p-1 border rounded-md border-solid border-slate-500"])}>
      <div> {uiStr("Current player:")} <PlayerUI.Short player /> </div>
      <br />
      <div>
        {game.players->uiList(p =>
          <div key={p.sessionId}>
            <PlayerUI.Short player={p} /> {uiStr("Cards: " ++ p.cards->List.length->string_of_int)}
          </div>
        )}
      </div>
      <div className="my-2"> <CardUI.table table={game.table} /> </div>
      <br />
      <CardUI.deck disabled={GameUtils.isPlayerCanMove(game, player)} deck={player.cards} />
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
      <div> {uiStr("Trump: ")} <CardUI.trump className="inline-block" suit={game.trump} /> </div>
      <div> {uiStr("Deck: " ++ game.deck->List.length->string_of_int)} </div>
      <div className="my-2"> {uiStr("Table:")} <CardUI.table table={game.table} /> </div>
      <div className="flex flex-wrap">
        {game.players->uiList(p =>
          <ClientUI className="m-1 flex-initial w-96" player={p} game={game} onMove={onMove} />
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
