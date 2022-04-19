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
  let make = (~game: inProgress) =>
    <div>
      {uiStr("inProgress")}
      <br />
      <br />
      {uiStr("deck:")}
      <br />
      <div> <CardUI.deck deck={game.deck} /> </div>
      {uiStr("players:")}
      <br />
      <div> {uiList(game.players, p => <PlayerUI key={p.id} player={p} />)} </div>
      <br />
      {uiStr("trump:")}
      <br />
      <CardUI.trump suit={game.trump} />
    </div>
}

@react.component
let make = (~game: state) =>
  switch game {
  | InLobby(g) => <InLobbyUI game={g} />
  | InProgress(g) => <InProgressUI game={g} />
  }
