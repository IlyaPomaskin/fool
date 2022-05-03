open Types
open Utils

module Client = {
  @react.component
  let make = (~playerId) => {
    let {player, inLobby, inProgress, error, sendMessage} = UseWs.hook(playerId)

    Js.logMany([{"player": player, "inLobby": inLobby, "inProgress": inProgress}])

    <div>
      <div>
        {switch player {
        | Some(player) => <PlayerUI.Short player />
        | None => <div />
        }}
      </div>
      <div>
        {switch error {
        | Some(error) => <div> {uiStr("server error: " ++ error)} </div>
        | None => <div> {uiStr("no server error")} </div>
        }}
      </div>
      <LobbyUI playerId game={inLobby} onLobbyMessage={sendMessage} />
      {switch inProgress {
      | Some(game) =>
        <div>
          <GameUI.InProgressUI game />
          <div className="flex flex-wrap">
            {game.players->uiList(player =>
              <ClientUI
                key={player.id}
                isOwner={player.id === playerId}
                className="m-1 flex-initial w-96"
                player
                game
                onMove={move => sendMessage(Progress(move, playerId, game.gameId))}
              />
            )}
          </div>
          <div>
            {error->Option.map(err => "Error: " ++ err)->Option.getWithDefault("No errors")->uiStr}
          </div>
        </div>
      | _ => <div />
      }}
    </div>
  }
}

let default = () => {
  let (first, setFirst) = React.useState(_ => "")
  let (firstPlayerId, setFirstPlayerId) = React.useState(_ => None)
  let (second, setSecond) = React.useState(_ => "")
  let (secondPlayerId, setSecondPlayerId) = React.useState(_ => None)

  <div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      {switch firstPlayerId {
      | Some(playerId) => <Client playerId />
      | None =>
        <div>
          <input value={first} onChange={e => setFirst(_ => ReactEvent.Form.target(e)["value"])} />
          <Base.Button onClick={_ => setFirstPlayerId(_ => Some(first))}>
            {uiStr("connect")}
          </Base.Button>
        </div>
      }}
    </div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      {switch secondPlayerId {
      | Some(playerId) => <Client playerId />
      | None =>
        <div>
          <input
            value={second} onChange={e => setSecond(_ => ReactEvent.Form.target(e)["value"])}
          />
          <Base.Button onClick={_ => setSecondPlayerId(_ => Some(second))}>
            {uiStr("connect")}
          </Base.Button>
        </div>
      }}
    </div>
  </div>
}
