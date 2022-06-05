// https://codesandbox.io/s/github/react-dnd/react-dnd/tree/gh-pages/examples_ts/02-drag-around/naive?from-embed=&file=/src/Container.tsx:1176-1204

open Utils

type box = {
  id: string,
  top: float,
  left: float,
  title: string,
}

module DragObject = {
  type t = box
}

module DropResult = {
  type t = {isDragging: bool}
}

module CollectedProps = {
  type t = {isDragging: bool}
}

module Dnd = RDnd.MakeDnd(DragObject, DropResult, CollectedProps)

module Item = {
  @react.component
  let make = (~box) => {
    let (cProps, ref, _) = Dnd.UseDrag.makeInstance(
      Dnd.UseDrag.makeConfig(
        ~\"type"="box",
        ~item=box,
        ~collect=monitor => {
          isDragging: Dnd.DragSourceMonitor.isDragging(monitor),
        },
        (),
      ),
      [box.left, box.top],
    )

    if cProps.isDragging {
      <div ref />
    } else {
      <div
        ref
        style={ReactDOMStyle.make(
          ~position="absolute",
          ~border="1px dashed gray",
          ~backgroundColor="white",
          ~padding="0.5rem 1rem",
          ~cursor="move",
          ~left=Belt.Float.toString(box.left) ++ "px",
          ~top=Belt.Float.toString(box.top) ++ "px",
          (),
        )}>
        {uiStr(box.title)}
      </div>
    }
  }
}

module Container = {
  open Dnd

  @react.component
  let make = () => {
    let (boxes, setBoxes) = React.useState(_ =>
      {
        "a": {id: "a", top: 10., left: 20., title: "Box 1"},
        "b": {id: "b", top: 40., left: 40., title: "Box 2"},
      }
    )

    let moveBox = React.useCallback1((id, left, top) => {
      setBoxes(boxes => {
        switch id {
        | "a" => {
            "a": {id: "a", top: top, left: left, title: "Box 1"},
            "b": boxes["b"],
          }
        | "b" => {
            "a": boxes["a"],
            "b": {id: "b", top: top, left: left, title: "Box 2"},
          }
        | _ => boxes
        }
      })
    }, [setBoxes])

    let (_, ref) = UseDrop.makeInstance(
      UseDrop.makeConfig(
        ~accept="box",
        ~drop=(item, monitor) => {
          let delta = DragSourceMonitor.getDifferenceFromInitialOffset(monitor)
          switch delta->Js.Nullable.toOption {
          | Some(delta) => {
              let left = Js.Math.round(item.left +. delta.x)
              let top = Pervasives.floor(item.top +. delta.y)
              moveBox(item.id, left, top)
            }
          | _ => ignore()
          }

          None
        },
        (),
      ),
      [],
    )

    <div ref className="w-64 h-64 bg-slate-300 relative">
      <Item box={boxes["a"]} /> <Item box={boxes["b"]} />
    </div>
  }
}

let default = () => {
  <div className="flex flex-row flex-wrap justify-items-center w-full container px-12 py-6 gap-12">
    <RDnd.Provider backend={RDnd.Backend.html5}> <Container /> </RDnd.Provider>
    // <PlayerScreen sessionId={Some("s:p1")} gameId={Some("g1")} />
    // <PlayerScreen sessionId={Some("s:p2")} gameId={Some("g1")} />
  </div>
}
