type position = {
  x: int,
  y: int,
}

type rect = {
  top: int,
  right: int,
  bottom: int,
  left: int,
  width: int,
  height: int,
  x: int,
  y: int,
  center: position,
}

type spacing = {
  top: int,
  right: int,
  bottom: int,
  left: int,
}

type boxModel = {
  marginBox: rect,
  borderBox: rect,
  paddingBox: rect,
  contentBox: rect,
  border: spacing,
  padding: spacing,
  margin: spacing,
}

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

type droppableMode =
  | Standard
  | Virtual

type droppableDescriptor = {
  id: DroppableId.t,
  type_: TypeId.t,
  mode: droppableMode,
}

type draggableDescriptor = {
  id: DraggableId.t,
  index: int,
  droppableId: DroppableId.t,
  type_: TypeId.t,
}

type draggableOptions = {
  canDragInteractiveElements: bool,
  shouldRespectForcePress: bool,
  isEnabled: bool,
}

type direction =
  | Horizontal
  | Vertical

type cssProperties =
  | X
  | Y
  | Top
  | Right
  | Bottom
  | Left
  | Width
  | Height

type verticalAxis = {
  direction: string, // Vertical,
  line: string, // Y,
  start: string, // Top,
  end: string, // Bottom,
  size: string, // Height,
  crossAxisLine: string, // X,
  crossAxisStart: string, // Left,
  crossAxisEnd: string, // Right,
  crossAxisSize: string, // Width,
}

type horizontalAxis = {
  direction: string, // Horizontal,
  line: string, // X,
  start: string, // Left,
  end: string, // Right,
  size: string, // Width,
  crossAxisLine: string, // Y,
  crossAxisStart: string, // Top,
  crossAxisEnd: string, // Bottom,
  crossAxisSize: string, // Height,
}

type axis = VerticalAxis(verticalAxis) | HorizontalAxis(horizontalAxis)

type scrollSize = {
  scrollHeight: int,
  scrollWidth: int,
}

type scrollDifference = {
  value: position,
  displacement: position,
}

type scrollDetails = {
  initial: position,
  current: position,
  max: position,
  diff: scrollDifference,
}

type placeholder = {
  client: boxModel,
  tagName: string,
  display: string,
}

type draggableDimension = {
  descriptor: draggableDescriptor,
  placeholder: placeholder,
  client: boxModel,
  page: boxModel,
  displaceBy: position,
}

type scrollable = {
  pageMarginBox: rect,
  frameClient: boxModel,
  scrollSize: scrollSize,
  shouldClipSubject: bool,
  scroll: scrollDetails,
}

type placeholderInSubject = {
  increasedBy: option<position>,
  placeholderSize: position,
  oldFrameMaxScroll: option<position>,
}

type droppableSubject = {
  page: boxModel,
  withPlaceholder: option<placeholderInSubject>,
  active: option<rect>,
}

type droppableDimension = {
  descriptor: droppableDescriptor,
  axis: axis,
  isEnabled: bool,
  isCombineEnabled: bool,
  client: boxModel,
  isFixedOnPage: bool,
  page: boxModel,
  frame: option<scrollable>,
  subject: droppableSubject,
}

type draggableLocation = {
  droppableId: DroppableId.t,
  index: int,
}

type draggableIdMap = {
  a: int,
  // [id: string]: true;
}

type droppableIdMap = {
  a: int,
  // [id: string]: true;
}

type draggableDimensionMap = {
  a: int,
  // [key: string]: DraggableDimension;
}
type droppableDimensionMap = {
  a: int,
  // [key: string]: DroppableDimension;
}

type displacement = {
  draggableId: DraggableId.t,
  shouldAnimate: bool,
}

type displacementMap = {
  a: int,
  // [key: string]: Displacement;
}

type displacedBy = {
  value: int,
  point: position,
}

//
type combine = {
  draggableId: DraggableId.t,
  droppableId: DroppableId.t,
}

type displacementGroups = {
  all: array<DraggableId.t>,
  visible: displacementMap,
  invisible: draggableIdMap,
}

type impact = Reorder | Combine

type reorderImpact = {
  // type_: Reorder,
  @as("type") type_: string,
  destination: draggableLocation,
}

type combineImpact = {
  // type_: Combine,
  @as("type") type_: string,
  combine: combine,
}

type impactLocation = ReoderImpact(reorderImpact) | CombineImpact(combineImpact)

type displaced = {
  forwards: displacementGroups,
  backwards: displacementGroups,
}

type dragImpact = {
  displaced: displacementGroups,
  displacedBy: displacedBy,
  at: option<impactLocation>,
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
  destination: Js.Undefined.t<draggableLocation>,
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
  "onTransitionEnd": option<ReactEvent.Transition.t>,
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
  dragHandleProps: option<draggableProvidedDragHandleProps>,
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
