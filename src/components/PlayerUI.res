open UiUtils

@react.component
let make = (~className: string="", ~player: Player.player, ()) => {
  <div className={className}>
    <div>
      <span className="font-bold"> {uiStr(player.id)} </span>
      {uiStr(" (" ++ player.sessionId ++ ")")}
    </div>
    <div> <CardUI.deck deck={player.cards} /> </div>
  </div>
}
