// https://codesandbox.io/s/github/react-dnd/react-dnd/tree/gh-pages/examples_ts/02-drag-around/naive?from-embed=&file=/src/Container.tsx:1176-1204

/*
open Utils

module Item = {
  open Dnd

  @react.component
  let make = (~box) => {
    let (cProps, ref, _) = UseDrag.makeInstance(
      UseDrag.makeConfig(
        ~\"type"="box",
        ~item=box,
        ~collect=monitor => {
          isDragging: DragSourceMonitor.isDragging(monitor),
          draggedCard: DragSourceMonitor.getItem(monitor),
        },
        (),
      ),
      [box],
    )

    <div
      ref
      className="select-none absolute cursor-move p-2 bg-slate-100 border border-dashed border-gray-300 rounded-md"
      style={ReactDOMStyle.make(
        ~left=Belt.Float.toString(box.left) ++ "px",
        ~top=Belt.Float.toString(box.top) ++ "px",
        ~visibility=cProps.isDragging ? "hidden" : "visible",
        (),
      )}>
      {uiStr(box.title)}
    </div>
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
          let delta =
            monitor->DragSourceMonitor.getDifferenceFromInitialOffset->Js.Nullable.toOption

          switch delta {
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
 */

let default = () => {
  <div className="flex flex-row flex-wrap justify-items-center w-full container px-12 py-6 gap-12">
    // <RDnd.Provider backend={RDnd.Backend.html5}> <Container /> </RDnd.Provider>
    <Dnd.Provider backend={Dnd.Backend.html5}>
      <PlayerScreen sessionId={Some("s:p1")} gameId={Some("g1")} />
      // <PlayerScreen sessionId={Some("s:p2")} gameId={Some("g1")} />
    </Dnd.Provider>
  </div>
}
