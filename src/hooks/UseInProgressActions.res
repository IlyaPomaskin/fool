open Types

type useProgressActionsReturn = {
  handleBeat: (card, card) => unit,
  handleTake: unit => unit,
  handleMove: card => unit,
  handlePass: unit => unit,
}

let hook = (~onMove): useProgressActionsReturn => {
  let handleBeat = (toCard, byCard) => onMove(Beat(toCard, byCard))
  let handleTake = _ => onMove(Take)
  let handleMove = card => onMove(Move(card))
  let handlePass = _ => onMove(Pass)

  {
    handleBeat: handleBeat,
    handleTake: handleTake,
    handleMove: handleMove,
    handlePass: handlePass,
  }
}
