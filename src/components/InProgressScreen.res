open Types
open Utils

@react.component
let make = (~game, ~playerId, ~onMessage) => {
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
          onMove={move => onMessage(Progress(move, playerId, game.gameId))}
        />
      )}
    </div>
  </div>
}
