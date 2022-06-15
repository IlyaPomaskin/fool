open Utils

module DragObject = {
  type t = Types.card
}

module DragLayerCP = {
  type t = {
    item: DragObject.t,
    itemType: Js.nullable<ReactDnd.identifier>,
    currentOffset: ReactDnd.nullableXyCoords,
  }
}

module DndL = ReactDnd.MakeUseDragLayer(DragObject, DragLayerCP)

let floatToString = float => float->int_of_float->string_of_int

let getItemStyles = (offset: ReactDnd.nullableXyCoords) => {
  let coords =
    offset->Js.Nullable.toOption->Option.map(({x, y}) => (floatToString(x), floatToString(y)))

  switch coords {
  | Some((x, y)) => ReactDOMStyle.make(~transform=`translate(${x}px, ${y}px)`, ())
  | _ => ReactDOMStyle.make(~visibility="hidden", ())
  }
}

@react.component
let make = () => {
  let {itemType, item, currentOffset} = DndL.UseDragLayer.makeInstance(monitor => {
    item: DndL.DragLayerMonitor.getItem(monitor),
    itemType: DndL.DragLayerMonitor.getItemType(monitor),
    currentOffset: DndL.DragLayerMonitor.getSourceClientOffset(monitor),
  })

  let itemType = Js.Nullable.toOption(itemType)->Option.getWithDefault("")
  let isCard = itemType === "card"

  <div className="absolute pointer-events-none left-0 top-0 w-full h-full">
    <div
      className={cx([
        "inline-block overflow-hidden rounded-md transition-shadow",
        isCard ? "shadow-lg" : "",
      ])}
      style={getItemStyles(currentOffset)}>
      {switch isCard {
      | true => <CardUI card={item} />
      | false => React.null
      }}
    </div>
  </div>
}
