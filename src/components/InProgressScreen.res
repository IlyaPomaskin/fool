open Types
open Utils

@react.component
let make = (~game, ~player, ~onMessage) => {
  <div>
    <GameUI.InProgressUI game />
    <div className="flex flex-wrap">
      {game.players->uiList(p =>
        <ClientUI
          key={p.id}
          isOwner={p.id === player.id}
          className="m-1 flex-initial w-96"
          player={p}
          game
          onMove={move => onMessage(Progress(move, player.id, game.gameId))}
        />
      )}
    </div>
  </div>
}
