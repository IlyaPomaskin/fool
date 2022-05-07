open Utils
open Types

module Short = {
  @react.component
  let make = (~className: string="", ~player: player) =>
    <div className>
      <span className="font-bold"> {uiStr(player.id)} </span>
      // {uiStr(" (" ++ player.sessionId ++ ")")}
    </div>
}

@react.component
let make = (~className: string="", ~player: player, ()) => {
  <div className={className}>
    <Short player={player} /> <div> <DeckUI deck={player.cards} /> </div>
  </div>
}
