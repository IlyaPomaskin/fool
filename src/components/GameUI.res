open UiUtils

module InLobbyUI = {
  @react.component
  let make = (~game: Game.inLobby) =>
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
  let make = (~game: Game.inProgress) =>
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
let make = (~game: Game.state) =>
  switch game {
  | Game.InLobby(g) => <InLobbyUI game={g} />
  | Game.InProgress(g) => <InProgressUI game={g} />
  }
