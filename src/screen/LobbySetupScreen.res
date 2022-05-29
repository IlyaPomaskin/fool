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

  let (isWaiting, _) = useStateValue(false)
  React.useEffect1(() => {
    switch gameId {
    | Some(gameId) => handleConnect(gameId)
    | _ => ignore()
    }

    None
  }, [gameId])

  <div className="flex flex-col gap-2">
    <div className="flex flex-col gap-2">
      <Base.Heading size={Base.Heading.H5}> {uiStr("Create new game")} </Base.Heading>
      <Base.Button onClick={_ => onMessage(Lobby(Create, player.id, ""))}>
        {uiStr("New")}
      </Base.Button>
    </div>
    <div className="flex flex-col gap-2">
      <Base.Heading size={Base.Heading.H5}> {uiStr("Connect to game")} </Base.Heading>
      <Base.Input
        disabled={isWaiting} value={inputGameId} onChange={value => setInputGameId(_ => value)}
      />
      <Base.Button disabled={isWaiting} onClick={_ => handleConnect(inputGameId)}>
        {uiStr("Connect")}
      </Base.Button>
    </div>
  </div>
}
