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
  let make = (~game: inProgress) =>
    <div>
      <div className="my-2">
        {game.players->uiList(p =>
          <div key={p.id} className="inline-block mr-4">
            <div className="grid grid-flow-col gap-1">
              <PlayerUI.Short className="inline-block" player={p} />
              <div> {p.cards->List.length->Utils.numbersToEmoji->uiStr} </div>
              {GameUtils.isPassed(game, p) ? <div> {uiStr(`⏩`)} </div> : React.null}
              {GameUtils.isAttacker(game, p) ? <div> {uiStr(`🔪`)} </div> : React.null}
              {GameUtils.isDefender(game, p) ? <div> {uiStr(`🛡️`)} </div> : React.null}
            </div>
          </div>
        )}
      </div>
      <div className="my-2">
        <div>
          {uiStr("Deck: " ++ game.deck->List.length->numbersToEmoji)}
          <span className="mx-1" />
          {switch lastListItem(game.deck) {
          | Some(card) => <CardUI.Short card />
          | None => <CardUI.trump suit={game.trump} />
          }}
        </div>
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
