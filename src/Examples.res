open UiUtils

module CardUI = {
  @react.component
  let make = (~className: string="", ~card: Card.card, ()) =>
    <div className={cx(["card", Card.suitToString(fst(card)), className])}>
      <div className="suit"> {uiStr(Card.suitToString(fst(card)))} </div>
      <div className="rank"> {uiStr(Card.rankToString(snd(card)))} </div>
    </div>

  @react.component
  let trump = (~className: string="", ~suit: Card.suit, ()) =>
    <div className={cx(["card", Card.suitToString(suit), className])}>
      <div className="suit"> {uiStr(Card.suitToString(suit))} </div>
      <div className="rank"> {uiStr("")} </div>
    </div>
}

module DeckUI = {
  @react.component
  let make = (~deck: Card.deck) =>
    switch deck {
    | list{} => <div> {uiStr("No cards in deck")} </div>
    | _ =>
      <div>
        {uiList(deck, card =>
          <CardUI key={Card.cardToString(card)} className="deck-card" card={card} />
        )}
      </div>
    }
}

module PlayerUI = {
  @react.component
  let make = (~player: Player.player) => {
    <div>
      {uiStr("id: " ++ player.id)}
      <br />
      {uiStr("sessionId: " ++ Int.toString(player.sessionId))}
      <br />
      <DeckUI.make deck={player.cards} />
    </div>
  }
}

module InLobbyUI = {
  @react.component
  let make = (~game: Game.inLobby) =>
    <div>
      {uiStr("inLobby")}
      <br />
      <br />
      {uiStr("players:")}
      <br />
      <div> {uiList(game.players, p => <PlayerUI player={p} />)} </div>
      <br />
      {uiStr("ready:")}
      <br />
      <div> {uiList(game.ready, p => <PlayerUI player={p} />)} </div>
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
      <div> <DeckUI deck={game.deck} /> </div>
      {uiStr("players:")}
      <br />
      <div> {uiList(game.players, p => <PlayerUI player={p} />)} </div>
      <br />
      {uiStr("trump:")}
      <br />
      <CardUI.trump suit={game.trump} />
    </div>
}

module GameUI = {
  @react.component
  let make = (~game: Game.state) =>
    switch game {
    | Game.InLobby(g) => <InLobbyUI game={g} />
    | Game.InProgress(g) => <InProgressUI game={g} />
    }
}

let players = list{Player.make("aaa"), Player.make("bbb"), Player.make("ccc")}

let gameInProgress = Result.getExn(
  Game.startGame({
    players: players,
    ready: players,
  }),
)

let gameInLobby = Game.makeGameInLobby("owner")

type props = {none: int}
let default = (_: _) =>
  <div> <GameUI game={gameInProgress} /> <br /> <GameUI game={gameInLobby} /> </div>
let getServerSideProps = _ctx => Js.Promise.resolve({"props": {none: 0}})
