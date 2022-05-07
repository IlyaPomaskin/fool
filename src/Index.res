open Types
open Utils

let delay = (send, msg, ~timeout=100, ()) =>
  Promise.make((resolve, _) => Js.Global.setTimeout(() => resolve(. send(msg)), timeout)->ignore)

module PlayerScreen = {
  @react.component
  let make = (~pId) => {
    let (player, setPlayer) = React.useState(_ => None)
    let (screen, setScreen) = React.useState(_ => AuthorizationScreen)

    let onMessage = React.useCallback1(message => {
      Log.logMessageFromServer(
        message,
        player->Option.map(p => p.id)->Option.getWithDefault("no player"),
      )

      switch message {
      | Connected(player) => {
          setPlayer(_ => Some(player))
          setScreen(_ => LobbySetupScreen)
        }
      | LobbyCreated(game)
      | LobbyUpdated(game) =>
        setScreen(_ => InLobbyScreen(game))
      | ProgressCreated(game)
      | ProgressUpdated(game) =>
        setScreen(_ => InProgressScreen(game))
      | ServerError(msg) => Log.info(["ServerError", msg])
      }
    }, [player])

    let {error, sendMessage} = UseWs.hook(onMessage)

    // FIXME remove debug code
    React.useEffect1(() => {
      if 1 === 2 {
        open Promise

        let delayM = delay(sendMessage)

        if pId === "session:p1" {
          delayM(Login(pId), ())
          ->then(() => delayM(~timeout=100, Lobby(Create, "p1", ""), ()))
          ->then(() => delayM(~timeout=100, Lobby(Enter, "p1", "g1"), ()))
          ->then(() => delayM(~timeout=100, Lobby(Ready, "p1", "g1"), ()))
          ->then(() => delayM(~timeout=300, Lobby(Start, "p1", "g1"), ()))
          ->ignore
        }

        if pId === "session:p2" {
          delayM(Login(pId), ())
          ->then(() => delayM(~timeout=250, Lobby(Enter, "p2", "g1"), ()))
          ->then(() => delayM(~timeout=100, Lobby(Ready, "p2", "g1"), ()))
          ->ignore
        }
      }

      None
    }, [sendMessage])

    <div>
      <div>
        {switch player {
        | Some(player) =>
          <div> {uiStr("Player: ")} <PlayerUI.Short className="inline-block" player /> </div>
        | None => uiStr("No player")
        }}
      </div>
      <div>
        {switch error {
        | Some(err) => <div> {uiStr("error: " ++ err)} </div>
        | None => <div> {uiStr("No error")} </div>
        }}
      </div>
      {switch (screen, player) {
      | (AuthorizationScreen, _) => <AuthorizationScreen onMessage={sendMessage} />
      | (LobbySetupScreen, Some(player)) => <LobbySetupScreen player onMessage={sendMessage} />
      | (InLobbyScreen(game), Some(player)) => <InLobbyScreen player game onMessage={sendMessage} />
      | (InProgressScreen(game), Some(player)) =>
        <InProgressScreen player game onMessage={sendMessage} />
      | _ => <div> {uiStr("unhandled case")} </div>
      }}
    </div>
  }
}

module ReactDndTest = {
  let spread2: ('a1, 'a2) => 'b = %raw(`(x1,x2) => ({ ...x1, ...x2 })`)
  let spread3: ('a1, 'a2, 'a3) => 'b = %raw(`(x1,x2,x3) => ({ ...x1, ...x2, ...x3 })`)

  type itemType = {
    id: string,
    content: string,
  }

  let makeItem = (index: string) => {
    id: `item-${index}`,
    content: `item ${index}`,
  }

  let reorder: (array<'a>, int, int) => array<'a> = %raw(`(list, startIndex, endIndex) => {
  const result = Array.from(list);
  const [removed] = result.splice(startIndex, 1);
  result.splice(endIndex, 0, removed);

  return result;
}`)

  @react.component
  let make = () => {
    let (items, setItems) = React.useState(_ => list{
      makeItem("1"),
      makeItem("2"),
      makeItem("3"),
      makeItem("4"),
      makeItem("5"),
    })

    let handleDragEnd = (result: ReactDnd.dropResult, _) => {
      let dest = result.destination->Js.Undefined.toOption

      switch dest {
      | Some(dest) =>
        setItems(items =>
          reorder(items->List.toArray, result.source.index, dest.index)->List.fromArray
        )
      | _ => ()
      }->ignore
    }

    <ReactDnd.DragDropContext onDragEnd={handleDragEnd}>
      <ReactDnd.Droppable droppableId="droppable">
        {(droppableProvided, droppableSnapshot) => {
          <div
            ref={droppableProvided.innerRef}
            style={ReactDOMStyle.make(
              ~background=droppableSnapshot.isDraggingOver ? "lightblue" : "grey",
              ~padding="8px",
              ~width="250px",
              (),
            )}>
            {items->Utils.uiListWithIndex((index, item) =>
              <ReactDnd.Draggable key={item.id} draggableId={item.id} index>
                {(draggableProvided, draggableSnapshot, _) =>
                  React.cloneElement(
                    <div> {item.id->uiStr} </div>,
                    spread3(
                      draggableProvided.draggableProps,
                      draggableProvided.dragHandleProps,
                      {
                        "ref": draggableProvided.innerRef,
                        "style": ReactDOMStyle.combine(
                          ReactDOMStyle.make(
                            ~userSelect="none",
                            ~padding="16px",
                            ~margin="0 0 16px 0",
                            ~background=draggableSnapshot.isDragging ? "lightgreen" : "red",
                            (),
                          ),
                          draggableProvided.draggableProps["style"],
                        ),
                      },
                    ),
                  )}
              </ReactDnd.Draggable>
            )}
            droppableProvided.placeholder
          </div>
        }}
      </ReactDnd.Droppable>
    </ReactDnd.DragDropContext>
  }
}

let default = () => {
  <div className="flex flex-col">
    <ReactDndTest />
    <div className="border rounded-md border-solid border-slate-500">
      <PlayerScreen pId="session:p1" />
    </div>
    <div className="border rounded-md border-solid border-slate-500">
      <PlayerScreen pId="session:p2" />
    </div>
  </div>
}
