open Types
open Utils

type destination =
  | ToUnknown
  | ToTable
  | ToCard(card)

let useOptimisticGame = (~game, ~player, ~onMessage) => {
  let (optimisticGame, setOptimisticGame) = React.useState(_ => game)
  React.useEffect1(() => {
    setOptimisticGame(_ => game)
    None
  }, [game])

  let handleOptimisticMessage = msg => {
    switch msg {
    | Progress(move, _, _) =>
      setOptimisticGame(prevGame =>
        Game.dispatch(prevGame, player, move)
        ->Result.flatMap(GameUtils.unpackProgress)
        ->Result.getWithDefault(prevGame)
      )
    | _ => ()
    }->ignore

    onMessage(msg)
  }

  (optimisticGame, handleOptimisticMessage)
}

@react.component
let make = (~game as realGame, ~player, ~onMessage) => {
  let (game, handleOptimisticMessage) = useOptimisticGame(~game=realGame, ~player, ~onMessage)

  let (draggedCard, setDraggedCard) = React.useState(_ => None)

  let handleDrop = card => {
    handleOptimisticMessage(Progress(Move(card), player.id, game.gameId))
    None
  }

  let handleBeat = (toCard, byCard) => {
    handleOptimisticMessage(Progress(Beat(toCard, byCard), player.id, game.gameId))
    None
  }

  let handleDrag = card => setDraggedCard(_ => Some(card))

  let reorderedPlayers =
    game.players
    ->listIndexOf(item => Player.equals(item, player))
    ->Option.flatMap(index => List.splitAt(game.players, index))
    ->Option.map(((before, after)) => List.concat(after, before))
    ->Option.map(players => List.keep(players, p => !Player.equals(p, player)))
    ->Option.getWithDefault(game.players)

  <div>
    <div className="flex">
      <div className="flex m-2 flex-row">
        <StackUI.deck deck={game.deck} trump={game.trump} />
      </div>
      <div className="flex m-2 w-full justify-evenly">
        {uiList(reorderedPlayers, player =>
          <OpponentUI
            key={player.id}
            isDefender={GameUtils.isDefender(game, player)}
            isAttacker={GameUtils.isAttacker(game, player)}
            className="m-1 flex flex-col"
            player
          />
        )}
      </div>
    </div>
    <div>
      <DragLayerUI />
      <div className="m-1">
        <TableUI draggedCard game player onDrop={handleDrop} onBeat={handleBeat} />
      </div>
      <ClientUI
        className="m-1 flex flex-col"
        player
        game
        onDrag={handleDrag}
        onMessage={handleOptimisticMessage}
      />
    </div>
  </div>
}
