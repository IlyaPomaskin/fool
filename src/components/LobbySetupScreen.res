open Types
open Utils

@react.component
let make = (~player, ~onMessage) => {
  let (gameId, setGameId) = React.useState(_ => "")

  <div className="m-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Lobby select")} </Base.Heading>
    <Base.Button onClick={_ => onMessage(Lobby(Create, player.id, ""))}>
      {uiStr("New")}
    </Base.Button>
    <br />
    <br />
    <span> {uiStr("Connect:")} </span>
    <Base.Input className="my-2" value={gameId} onChange={value => setGameId(_ => value)} />
    <Base.Button onClick={_ => onMessage(Lobby(Enter, player.id, gameId))}>
      {uiStr("Connect")}
    </Base.Button>
  </div>
}
