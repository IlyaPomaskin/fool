module type DragObject = {
  type t
}

module type DropResult = {
  type t
}

module type CollectedProps = {
  type t
}

type identifier = string

type xyCoords = {x: float, y: float}
type nullableXyCoords = Js.Nullable.t<xyCoords>

module MakeUseDragLayer = (DO: DragObject, CP: CollectedProps) => {
  module DragLayerMonitor = {
    type t

    @send external isDragging: t => bool = "isDragging"
    @send external getItemType: t => Js.Nullable.t<identifier> = "getItemType"
    @send external getItem: t => DO.t = "getItem"
    @send external getInitialClientOffset: t => nullableXyCoords = "getInitialClientOffset"
    @send
    external getInitialSourceClientOffset: t => nullableXyCoords = "getInitialSourceClientOffset"
    @send external getClientOffset: t => nullableXyCoords = "getClientOffset"
    @send
    external getDifferenceFromInitialOffset: t => nullableXyCoords =
      "getDifferenceFromInitialOffset"
    @send external getSourceClientOffset: t => nullableXyCoords = "getSourceClientOffset"
  }

  module UseDragLayer = {
    @module("react-dnd")
    external makeInstance: (DragLayerMonitor.t => CP.t) => CP.t = "useDragLayer"
  }
}

module MakeUseDrop = (DO: DragObject, DR: DropResult, CP: CollectedProps) => {
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
    @send external getInitialClientOffset: t => nullableXyCoords = "getInitialClientOffset"
    @send
    external getInitialSourceClientOffset: t => nullableXyCoords = "getInitialSourceClientOffset"
    @send external getClientOffset: t => nullableXyCoords = "getClientOffset"
    @send
    external getDifferenceFromInitialOffset: t => nullableXyCoords =
      "getDifferenceFromInitialOffset"
    @send external getSourceClientOffset: t => nullableXyCoords = "getSourceClientOffset"
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
}

module MakeUseDrag = (DO: DragObject, DR: DropResult, CP: CollectedProps) => {
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
    @send external getInitialClientOffset: t => nullableXyCoords = "getInitialClientOffset"
    @send external getClientOffset: t => nullableXyCoords = "getClientOffset"
    @send
    external getDifferenceFromInitialOffset: t => nullableXyCoords =
      "getDifferenceFromInitialOffset"
    @send external getSourceClientOffset: t => nullableXyCoords = "getSourceClientOffset"
    @send external getTargetIds: t => array<identifier> = "getTargetIds"
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

module Backend = {
  type factoryHtml5
  type factoryTouch

  @module("react-dnd-html5-backend")
  external html5: factoryHtml5 = "HTML5Backend"

  @module("react-dnd-touch-backend")
  external touch: factoryTouch = "TouchBackend"
}

module Provider = {
  @module("react-dnd") @react.component
  external makeHtml5: (~backend: Backend.factoryHtml5, ~children: React.element) => React.element =
    "DndProvider"

  type options = {
    enableTouchEvents: bool,
    enableMouseEvents: bool,
    ignoreContextMenu: bool,
  }

  @obj
  external makeOptions: (
    ~enableTouchEvents: bool,
    ~enableMouseEvents: bool,
    ~ignoreContextMenu: bool,
    unit,
  ) => options = ""

  @module("react-dnd") @react.component
  external makeTouch: (
    ~backend: Backend.factoryTouch,
    ~options: options,
    ~children: React.element,
  ) => React.element = "DndProvider"
}
