open Types
open Utils

module Parts = {
  @react.component
  let table = (~game: inProgress, ~player: player) => {
    let isDefender = GameUtils.isDefender(game, player)

    switch (isDefender, game.table) {
    | (true, table) => <TableUI className="my-1" table={table} />
    | (false, _) =>
      <CardDnd.Cards.DroppableContainer
        className={(~draggingOver: bool) =>
          cx([draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : ""])}
        accept={_ => GameUtils.isValidMove(game, player)->Result.isOk}
        id={CardDnd.ContainerId.make(CardDnd.ToTable)}
        axis=X>
        {switch game.table {
        | list{} =>
          <div className={cx(["w-12 h-16 border rounded-md border-solid border-slate-500"])} />
        | table => <TableUI className="my-1" table={table} />
        }}
      </CardDnd.Cards.DroppableContainer>
    }
  }
}

@react.component
let make = (~game, ~player, ~onMessage) => {
  let handleReorder = result =>
    switch result {
    | Some(Dnd.ReorderResult.NewContainer(byCard, CardDnd.ToCard(toCard), _)) =>
      onMessage(Progress(Beat(toCard, byCard), player.id, game.gameId))
    | Some(Dnd.ReorderResult.NewContainer(card, CardDnd.ToTable, _)) =>
      onMessage(Progress(Move(card), player.id, game.gameId))
    | _ => ()
    }

  <CardDnd.Cards.DndManager onReorder={handleReorder}>
    <GameUI.InProgressUI game />
    <div className="m-1"> <Parts.table game player /> </div>
    <div className="flex flex-wrap">
      {game.players->uiList(p =>
        <ClientUI
          key={p.id}
          isOwner={p.id === player.id}
          className="m-1 flex flex-col"
          player={p}
          game
          onMove={move => onMessage(Progress(move, player.id, game.gameId))}
        />
      )}
    </div>
  </CardDnd.Cards.DndManager>
}
