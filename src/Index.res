open Types
open Utils

module Client = {
  @react.component
  let make = (~playerId) => {
    let {player, inLobby, inProgress, error, handleMove, sendMessage} = UseWs.hook(playerId)

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
      <LobbyUI playerId game={inLobby} onLobbyMessage={message => sendMessage(message)} />
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
                onMove={handleMove(game)}
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
  <div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <Client playerId="alice" />
    </div>
    <div className="my-2 w-1/2 inline-block border rounded-md border-solid border-slate-500">
      <Client playerId="bob" />
    </div>
  </div>
}
