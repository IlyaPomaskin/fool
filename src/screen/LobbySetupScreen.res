open Types
open Utils

@react.component
let make = (~player, ~gameId, ~onMessage) => {
  let (inputGameId, setInputGameId) = React.useState(_ =>
    switch gameId {
    | Some(gameId) => gameId
    | None => ""
    }
  )

  let handleConnect = gameId => onMessage(Lobby(Enter, player.id, gameId))

  let (isWaiting, setIsWaiting) = useStateValue(false)
  React.useEffect1(() => {
    switch gameId {
    | Some(gameId) => {
        setIsWaiting(true)
        handleConnect(gameId)
      }
    | _ => ignore()
    }

    None
  }, [gameId])

  <div className="m-2">
    <Base.Heading size={Base.Heading.H5}> {uiStr("Lobby select")} </Base.Heading>
    <Base.Button onClick={_ => onMessage(Lobby(Create, player.id, ""))}>
      {uiStr("New")}
    </Base.Button>
    <br />
    <br />
    <span> {uiStr("Connect:")} </span>
    <Base.Input
      disabled={isWaiting}
      className="my-2"
      value={inputGameId}
      onChange={value => setInputGameId(_ => value)}
    />
    <Base.Button disabled={isWaiting} onClick={_ => handleConnect(inputGameId)}>
      {uiStr("Connect")}
    </Base.Button>
  </div>
}
