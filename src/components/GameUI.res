open Utils
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
