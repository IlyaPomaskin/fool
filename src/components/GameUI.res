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

module InProgressUI = {
  @react.component
  let make = (~game: inProgress, ~onMove: move => unit) =>
    <div>
      {uiStr("inProgress")}
      <div> {uiStr("deck:")} </div>
      <div> <CardUI.deck deck={game.deck} /> </div>
      {uiStr("players:")}
      <div>
        {uiList(game.players, p =>
          <PlayerUI key={p.id} player={p} onCardClick={(c: card) => onMove(Move(p, c))} />
        )}
      </div>
      <div> {uiStr("trump:")} <CardUI.trump suit={game.trump} /> </div>
      <div> {uiStr("attacker:")} <PlayerUI.Short player={game.attacker} /> </div>
      <div> {uiStr("defender:")} <PlayerUI.Short player={game.defender} /> </div>
      <br />
      <div>
        {uiStr("table:")}
        {uiList(game.table, ((to, by)) =>
          <div
            className="inline-block mx-1"
            key={Card.cardToString(to) ++
            Option.getWithDefault(Option.map(by, Card.cardToString), "a")}>
            <CardUI.CardUILocal card={to} />
            {switch by {
            | Some(byCard) => <CardUI.CardUILocal card={byCard} />
            | None => <div> {uiStr("None")} </div>
            }}
          </div>
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
