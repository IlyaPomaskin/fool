open UiUtils
open Types

module Short = {
  @react.component
  let make = (~className: string="", ~player: player) =>
    <div className>
      <span className="font-bold"> {uiStr(player.id)} </span>
      {uiStr(" (" ++ player.sessionId ++ ")")}
    </div>
}

@react.component
let make = (~className: string="", ~player: player, ~onCardClick: option<card => unit>=?, ()) => {
  <div className={className}>
    <Short player={player} />
    <div>
      <CardUI.deck
        deck={player.cards}
        onCardClick={switch onCardClick {
        | Some(fn) => fn
        | None => _ => ()
        }}
      />
    </div>
  </div>
}
