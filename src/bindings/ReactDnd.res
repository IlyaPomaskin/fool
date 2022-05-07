module Id = {
  type t = string
}
module DraggableId = {
  type t = string
}
module DroppableId = {
  type t = string
}
module TypeId = {
  type t = string
}
module ContextId = {
  type t = string
}
module ElementId = {
  type t = string
}

type position = {
  x: int,
  y: int,
}

type draggableOptions = {
  canDragInteractiveElements: bool,
  shouldRespectForcePress: bool,
  isEnabled: bool,
}

type draggableLocation = {
  droppableId: DroppableId.t,
  index: int,
}

type combine = {
  draggableId: DraggableId.t,
  droppableId: DroppableId.t,
}

type reorderImpact = {
  @as("type") type_: string,
  destination: draggableLocation,
}

type combineImpact = {
  @as("type") type_: string,
  combine: combine,
}

type clientPositions = {
  selection: position,
  borderBoxCenter: position,
  offset: position,
}

type pagePositions = {
  selection: position,
  borderBoxCenter: position,
  offset: position,
}

type movementMode = string

type beforeCapture = {
  draggableId: DraggableId.t,
  mode: movementMode,
}

type dragStartBeforeCapture = {
  draggableId: DraggableId.t,
  mode: movementMode,
  @as("type")
  type_: TypeId.t,
  source: draggableLocation,
}

type draggableRubric = {
  draggableId: DraggableId.t,
  mode: movementMode,
  source: draggableLocation,
}

type dragStartDraggableRubric = {
  draggableId: DraggableId.t,
  mode: movementMode,
  source: draggableLocation,
}

type dragUpdate = {
  draggableId: DraggableId.t,
  mode: movementMode,
  source: draggableLocation,
  destination: option<draggableLocation>,
  combine: option<combine>,
}

type dropResult = {
  draggableId: DraggableId.t,
  mode: movementMode,
  source: draggableLocation,
  destination: Js.Nullable.t<draggableLocation>,
  combine: Js.Undefined.t<combine>,
  reason: string,
}

type responderProvided = {announce: string => unit}

type tryGetLockOptions = {sourceEvent: option<Dom.event>}

type stopDragOptions = {shouldBlockNextClick: bool}

type dragActions = {
  drop: Js.Undefined.t<stopDragOptions> => unit,
  cancel: Js.Undefined.t<stopDragOptions> => unit,
  isActive: unit => bool,
  shouldRespectForcePress: unit => bool,
}

type fluidDragActions = {
  drop: Js.Undefined.t<stopDragOptions> => unit,
  cancel: Js.Undefined.t<stopDragOptions> => unit,
  isActive: unit => bool,
  shouldRespectForcePress: unit => bool,
  move: position => unit,
}

type snapDragActions = {
  drop: Js.Undefined.t<stopDragOptions> => unit,
  cancel: Js.Undefined.t<stopDragOptions> => unit,
  isActive: unit => bool,
  shouldRespectForcePress: unit => bool,
  moveUp: unit => unit,
  moveDown: unit => unit,
  moveRight: unit => unit,
  moveLeft: unit => unit,
}

type preDragActions = {
  isActive: unit => bool,
  shouldRespectForcePress: unit => bool,
  fluidLift: position => fluidDragActions,
  snapLift: unit => snapDragActions,
  abort: unit => unit,
}

type sensorApi = {
  tryGetLock: (
    DraggableId.t,
    option<unit => unit>,
    option<tryGetLockOptions>,
  ) => Js.Nullable.t<preDragActions>,
  canGetLock: DraggableId.t => bool,
  isLockClaimed: unit => bool,
  tryReleaseLock: unit => unit,
  findClosestDraggableId: Dom.event => Js.Nullable.t<DraggableId.t>,
  findOptionsForDraggable: DraggableId.t => Js.Nullable.t<draggableOptions>,
}

type draggableProvidedDraggableProps = {
  "style": ReactDOMStyle.t,
  "data-rbd-draggable-context-id": string,
  "data-rbd-draggable-id": string,
  "onTransitionEnd": Js.Undefined.t<ReactEvent.Transition.t>,
}

type draggableProvidedDragHandleProps = {
  "data-rbd-drag-handle-draggable-id": DraggableId.t,
  "data-rbd-drag-handle-context-id": ContextId.t,
  "aria-describedby": ElementId.t,
  "role": string,
  "tabIndex": int,
  "draggable": bool,
  "onDragStart": ReactEvent.Mouse.t => unit,
}

type draggableProvided = {
  innerRef: ReactDOM.domRef,
  draggableProps: draggableProvidedDraggableProps,
  dragHandleProps: Js.Undefined.t<draggableProvidedDragHandleProps>,
}

type dropAnimation = {
  duration: int,
  curve: string,
  moveTo: position,
  opacity: Js.Undefined.t<int>,
  scale: Js.Undefined.t<int>,
}

type draggableStateSnapshot = {
  isDragging: bool,
  isDropAnimating: bool,
  dropAnimation: Js.Undefined.t<dropAnimation>,
  draggingOver: Js.Undefined.t<DroppableId.t>,
  combineWith: Js.Undefined.t<DraggableId.t>,
  combineTargetFor: Js.Undefined.t<DraggableId.t>,
  mode: Js.Undefined.t<string>,
}

type draggableChildrenFn = (
  draggableProvided,
  draggableStateSnapshot,
  draggableRubric,
) => React.element

type droppableProvidedProps = {
  "data-rbd-droppable-context-id": string,
  "data-rbd-droppable-id": DroppableId.t,
}

type droppableProvided = {
  innerRef: ReactDOM.domRef,
  placeholder: React.element,
  droppableProps: droppableProvidedProps,
}

type droppableStateSnapshot = {
  isDraggingOver: bool,
  draggingOverWith: Js.Undefined.t<DraggableId.t>,
  draggingFromThisWith: Js.Undefined.t<DraggableId.t>,
  isUsingPlaceholder: bool,
}

module DragDropContext = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~onBeforeCapture: option<beforeCapture => unit>=?,
    ~onBeforeDragStart: option<dragStartBeforeCapture => unit>=?,
    ~onDragStart: option<(dragStartBeforeCapture, responderProvided) => unit>=?,
    ~onDragUpdate: option<(dragUpdate, responderProvided) => unit>=?,
    ~onDragEnd: (dropResult, responderProvided) => unit,
    ~dragHandleUsageInstructions: option<string>=?,
    ~nonce: option<string>=?,
    ~sensors: option<array<sensorApi => unit>>=?,
    ~enableDefaultSensors: option<bool>=?,
    ~children: React.element,
  ) => React.element = "DragDropContext"
}

module Droppable = {
  type droppableMode = Standard | Virtual
  type direction = Horizontal | Vertical

  @module("react-beautiful-dnd") @react.component
  external make: (
    ~droppableId: DroppableId.t,
    @as("type") ~type_: option<TypeId.t>=?,
    ~mode: option<string>=?,
    ~isDropDisabled: option<bool>=?,
    ~isCombineEnabled: option<bool>=?,
    ~direction: option<string>=?,
    ~ignoreContainerClipping: option<bool>=?,
    ~renderClone: option<draggableChildrenFn>=?,
    ~getContainerForClone: option<unit => Dom.htmlElement>=?,
    ~children: (droppableProvided, droppableStateSnapshot) => React.element,
    unit,
  ) => React.element = "Droppable"
}

module Draggable = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~draggableId: DraggableId.t,
    ~index: int,
    ~isDragDisabled: option<bool>=?,
    ~disableInteractiveElementBlocking: option<bool>=?,
    ~shouldRespectForcePress: option<bool>=?,
    ~children: draggableChildrenFn,
    unit,
  ) => React.element = "Draggable"
}
