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

type movementMode = Fluid | Snap

type dragPositions = {
  client: clientPositions,
  page: pagePositions,
}

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

type dropReason = Drop | Cancel

type dropResult = {
  draggableId: DraggableId.t,
  mode: movementMode,
  source: draggableLocation,
  destination: Js.Nullable.t<draggableLocation>,
  combine: option<combine>,
  reason: dropReason,
}

type scrollOptions = {shouldPublishImmediately: bool}

type liftRequest = {
  draggableId: DraggableId.t,
  scrollOptions: scrollOptions,
}

type critical = {
  draggable: draggableDescriptor,
  droppable: droppableDescriptor,
}

type viewport = {
  frame: rect,
  scroll: scrollDetails,
}

type liftEffect = {
  inVirtualList: bool,
  effected: draggableIdMap,
  displacedBy: displacedBy,
}

type dimensionMap = {
  draggables: draggableDimensionMap,
  droppables: droppableDimensionMap,
}

type droppablePublish = {
  droppableId: DroppableId.t,
  scroll: position,
}
type published = {
  additions: array<draggableDimension>,
  removals: array<DraggableId.t>,
  modified: array<droppablePublish>,
}

type completedDrag = {
  critical: critical,
  result: dropResult,
  impact: dragImpact,
  afterCritical: liftEffect,
}

type statePhase = Idle | Dragging | Collecting | DropPending | DropAnimating

type idleState = {
  phase: statePhase,
  completed: option<completedDrag>,
  shouldFlush: bool,
}

type draggingState = {
  phase: statePhase,
  isDragging: bool,
  critical: critical,
  movementMode: movementMode,
  dimensions: dimensionMap,
  initial: dragPositions,
  current: dragPositions,
  impact: dragImpact,
  viewport: viewport,
  afterCritical: liftEffect,
  onLiftImpact: dragImpact,
  isWindowScrollAllowed: bool,
  scrollJumpRequest: option<position>,
  forceShouldAnimate: option<bool>,
}

type collectingState = {
  phase: statePhase,
  isDragging: bool,
  critical: critical,
  movementMode: movementMode,
  dimensions: dimensionMap,
  initial: dragPositions,
  current: dragPositions,
  impact: dragImpact,
  viewport: viewport,
  afterCritical: liftEffect,
  onLiftImpact: dragImpact,
  isWindowScrollAllowed: bool,
  scrollJumpRequest: option<position>,
  forceShouldAnimate: option<bool>,
}

type dropPendingState = {
  phase: statePhase,
  isDragging: bool,
  critical: critical,
  movementMode: movementMode,
  dimensions: dimensionMap,
  initial: dragPositions,
  current: dragPositions,
  impact: dragImpact,
  viewport: viewport,
  afterCritical: liftEffect,
  onLiftImpact: dragImpact,
  isWindowScrollAllowed: bool,
  scrollJumpRequest: option<position>,
  forceShouldAnimate: option<bool>,
  isWaiting: bool,
  reason: dropReason,
}

type dropAnimatingState = {
  phase: statePhase,
  completed: completedDrag,
  newHomeClientOffset: position,
  dropDuration: int,
  dimensions: dimensionMap,
}

type stateWhenUpdatesAllowed = DraggingState | CollectingState

type inOutAnimationMode = None | Open | Close

type responderProvided = {announce: string => unit}

type onBeforeCaptureResponder = beforeCapture => unit

type onBeforeDragStartResponder = dragStartBeforeCapture => unit

type onDragStartResponder = (dragStartBeforeCapture, responderProvided) => unit

type onDragUpdateResponder = (dragUpdate, responderProvided) => unit

type onDragEndResponder = (dropResult, responderProvided) => unit

type responders = {
  onBeforeCapture: option<onBeforeCaptureResponder>,
  onBeforeDragStart: option<onBeforeDragStartResponder>,
  onDragStart: option<onDragStartResponder>,
  onDragUpdate: option<onDragUpdateResponder>,
  onDragEnd: onDragEndResponder,
}

type tryGetLockOptions = {sourceEvent: option<Dom.event>}

type preDragActions = {todo: int}

type tryGetLock = (
  DraggableId.t,
  option<unit => unit>,
  option<tryGetLockOptions>,
) => Js.Nullable.t<preDragActions>

type sensorApi = {
  tryGetLock: tryGetLock,
  canGetLock: DraggableId.t => bool,
  isLockClaimed: unit => bool,
  tryReleaseLock: unit => unit,
  findClosestDraggableId: Dom.event => Js.Nullable.t<DraggableId.t>,
  findOptionsForDraggable: DraggableId.t => Js.Nullable.t<draggableOptions>,
}

module DragDropContext = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~onBeforeCapture: option<onBeforeCaptureResponder>=?,
    ~onBeforeDragStart: option<onBeforeDragStartResponder>=?,
    ~onDragStart: option<onDragStartResponder>=?,
    ~onDragUpdate: option<onDragUpdateResponder>=?,
    ~onDragEnd: onDragEndResponder,
    ~children: React.element,
    ~dragHandleUsageInstructions: option<string>=?,
    ~nonce: option<string>=?,
    ~sensors: option<array<sensorApi => unit>>=?,
    ~enableDefaultSensors: option<bool>=?,
  ) => React.element = "DragDropContext"
}

type todo = int

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

type droppableProvided = {
  innerRef: ReactDOM.domRef,
  draggableProps: draggableProvidedDraggableProps,
  dragHandleProps: Js.Undefined.t<draggableProvidedDragHandleProps>,
}

type droppableStateSnapshot = {
  isDraggingOver: bool,
  draggingOverWith: option<DraggableId.t>,
  draggingFromThisWith: option<DraggableId.t>,
  isUsingPlaceholder: bool,
}

type droppableChildrenRef = {
  innerRef: ReactDOM.domRef,
  placeholder: React.element,
  droppableProps: todo,
}

module Droppable = {
  type droppableMode = Standard | Virtual
  type direction = Horizontal | Vertical

  @module("react-beautiful-dnd") @react.component
  external make: (
    ~droppableId: DroppableId.t,
    @as("type") ~type_: option<TypeId.t>=?,
    ~mode: option<droppableMode>=?,
    ~isDropDisabled: option<bool>=?,
    ~isCombineEnabled: option<bool>=?,
    ~direction: option<direction>=?,
    ~ignoreContainerClipping: option<bool>=?,
    ~renderClone: option<todo>=?,
    ~getContainerForClone: option<unit => Dom.htmlElement>=?,
    ~children: (droppableChildrenRef, droppableStateSnapshot) => React.element,
    unit,
  ) => React.element = "Droppable"
}

type draggableProvided = {
  innerRef: ReactDOM.domRef,
  draggableProps: draggableProvidedDraggableProps,
  dragHandleProps: option<draggableProvidedDragHandleProps>,
}

type draggableStateSnapshot = {
  isDragging: bool,
  isDropAnimating: bool,
  // dropAnimation: option<dropAnimation>,
  draggingOver: option<DroppableId.t>,
  combineWith: option<DraggableId.t>,
  combineTargetFor: option<DraggableId.t>,
  mode: option<movementMode>,
}

module Draggable = {
  @module("react-beautiful-dnd") @react.component
  external make: (
    ~draggableId: DraggableId.t,
    ~index: int,
    ~isDragDisabled: option<bool>=?,
    ~disableInteractiveElementBlocking: option<bool>=?,
    ~shouldRespectForcePress: option<bool>=?,
    ~children: (draggableProvided, draggableStateSnapshot, draggableRubric) => React.element,
    unit,
  ) => React.element = "Draggable"
}
