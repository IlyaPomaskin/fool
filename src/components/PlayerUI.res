open UiUtils

@react.component
let make = (~player: Player.player) => {
  <div>
    {uiStr("id: " ++ player.id)}
    <br />
    {uiStr("sessionId: " ++ Int.toString(player.sessionId))}
    <br />
    <CardUI.deck deck={player.cards} />
  </div>
}
