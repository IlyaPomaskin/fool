module type DragObject = {
  type t
}

module type DropResult = {
  type t
}

module type CollectedProps = {
  type t
}

module MakeDnd = (DO: DragObject, DR: DropResult, CP: CollectedProps) => {
  type identifier = string

  module Backend = {
    type factory

    @module("react-dnd-html5-backend")
    external html5: factory = "HTML5Backend"
  }

  module Provider = {
    @module("react-dnd") @react.component
    external make: (~backend: Backend.factory, ~children: React.element, unit) => React.element =
      "DndProvider"
  }

  type xyCoords = {x: float, y: float}

  module DragSourceMonitor = {
    type t

    @send external receiveHandlerId: (t, Js.Nullable.t<identifier>) => unit = "receiveHandlerId"
    @send external getHandlerId: t => identifier = "getHandlerId"

    @send external canDrag: t => bool = "canDrag"
    @send external isDragging: t => bool = "isDragging"
    @send external getItemType: t => Js.Nullable.t<identifier> = "getItemType"
    @send external getItem: t => DO.t = "getItem"
    @send external getDropResult: t => Js.Nullable.t<DR.t> = "getDropResult"
    @send external didDrop: t => bool = "didDrop"
    @send external getInitialClientOffset: t => Js.Nullable.t<xyCoords> = "getInitialClientOffset"
    @send external getClientOffset: t => Js.Nullable.t<xyCoords> = "getClientOffset"
    @send
    external getDifferenceFromInitialOffset: t => Js.Nullable.t<xyCoords> =
      "getDifferenceFromInitialOffset"
    @send external getSourceClientOffset: t => Js.Nullable.t<xyCoords> = "getSourceClientOffset"
    @send external getTargetIds: t => array<identifier> = "getTargetIds"
  }

  module DropTargetMonitor = {
    type t

    type isOverOptions = {shallow: bool}

    @send external receiveHandlerId: (t, Js.Nullable.t<identifier>) => unit = "receiveHandlerId"
    @send external getHandlerId: t => identifier = "getHandlerId"

    @send external canDrag: t => bool = "canDrag"
    @send external isOver: (t, isOverOptions) => bool = "isOver"
    @send external getItemType: t => Js.Nullable.t<identifier> = "getItemType"
    @send external getItem: t => DO.t = "getItem"
    @send external getDropResult: t => Js.Nullable.t<DR.t> = "getDropResult"
    @send external didDrop: t => bool = "didDrop"
    @send external getInitialClientOffset: t => Js.Nullable.t<xyCoords> = "getInitialClientOffset"
    @send
    external getInitialSourceClientOffset: t => Js.Nullable.t<xyCoords> =
      "getInitialSourceClientOffset"
    @send external getClientOffset: t => Js.Nullable.t<xyCoords> = "getClientOffset"
    @send
    external getDifferenceFromInitialOffset: t => Js.Nullable.t<xyCoords> =
      "getDifferenceFromInitialOffset"
    @send external getSourceClientOffset: t => Js.Nullable.t<xyCoords> = "getSourceClientOffset"
  }

  module UseDrop = {
    type options
    type config

    @obj
    external makeConfig: (
      ~accept: identifier,
      ~options: options=?,
      ~drop: (DO.t, DropTargetMonitor.t) => option<DR.t>=?,
      ~hover: (DO.t, DropTargetMonitor.t) => unit=?,
      ~canDrop: (DO.t, DropTargetMonitor.t) => bool=?,
      ~collect: DropTargetMonitor.t => CP.t=?,
      unit,
    ) => config = ""

    @module("react-dnd")
    external makeInstance: (config, array<'dep>) => (CP.t, ReactDOM.Ref.t) = "useDrop"
  }

  module UseDrag = {
    type options
    type config
    type previewOptions

    type dragSourceOptions = {dropEffect: option<string>}

    @obj
    external makePreviewOptions: (
      ~captureDraggingState: bool=?,
      ~anchorX: int=?,
      ~anchorY: int=?,
      ~offsetX: int=?,
      ~offsetY: int=?,
    ) => previewOptions = ""

    @obj
    external makeConfig: (
      ~\"type": identifier,
      ~item: DO.t=?,
      ~options: options=?,
      ~previewOptions: previewOptions=?,
      ~end: (DO.t, DragSourceMonitor.t) => unit=?,
      ~canDrag: DragSourceMonitor.t => bool=?,
      ~isDragging: DragSourceMonitor.t => bool=?,
      ~collect: DragSourceMonitor.t => CP.t=?,
      unit,
    ) => config = ""

    @module("react-dnd")
    external makeInstance: (config, array<'dep>) => (CP.t, ReactDOM.Ref.t, 'preview) = "useDrag"
  }
}
