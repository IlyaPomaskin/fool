open Types

type useProgressActionsReturn = {
  handleBeat: unit => unit,
  handleTake: unit => unit,
  handleMove: card => unit,
  handlePass: unit => unit,
}

let hook = (~toBeat, ~beatBy, ~setBeat, ~onMove): useProgressActionsReturn => {
  let handleBeat = _ => {
    switch (toBeat, beatBy) {
    | (Some(to), Some(by)) => {
        setBeat(_ => (None, None))
        onMove(Beat(to, by))
      }
    | _ => ()
    }
  }
  let handleTake = _ => {
    setBeat(_ => (None, None))
    onMove(Take)
  }
  let handleMove = card => onMove(Move(card))
  let handlePass = _ => onMove(Pass)

  {
    handleBeat: handleBeat,
    handleTake: handleTake,
    handleMove: handleMove,
    handlePass: handlePass,
  }
}
