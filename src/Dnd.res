open Types

module DragObject = {
  type t = Types.card
}

module DropResult = {
  type t = {isDragging: bool}
}

module CollectedProps = {
  type t = {
    isDragging: bool,
    draggedCard: card,
    isOver: bool,
    isOverCurrent: bool,
  }
}

include RDnd.MakeDnd(DragObject, DropResult, CollectedProps)
