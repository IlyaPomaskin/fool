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

  module Monitor = {
    @send external receiveHandlerId: Js.Nullable.t<identifier> => unit = "receiveHandlerId"
    @send external getHandlerId: unit => identifier = "getHandlerId"
  }

  module DragSourceMonitor = {
    type t

    type xyCoords = {x: float, y: float}

    include Monitor

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

  module UseDrop = {
    type options
    type config

    @obj
    external makeConfig: (
      ~accept: identifier,
      ~options: options=?,
      ~drop: (DO.t, 'a) => option<DR.t>=?,
      ~hover: (DO.t, DO.t) => unit=?,
      ~canDrop: (DO.t, DO.t) => bool=?,
      ~collect: DO.t => CP.t=?,
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
