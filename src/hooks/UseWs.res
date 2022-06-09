open Types
open Utils

let hook = (~player, ~onMessage, ~onConnect=noop, ~onDisconnect=noop, ~onError=noop) => {
  let sessionId = player->Option.map(player => player.sessionId)->Option.getWithDefault("")
  let (ws, sendMessage) = React.useMemo1(_ => {
    if sessionId != "" {
      let ws = WebSocket.make(`${getFullUrl(~isWs=true, ())}/ws?sessionId=${sessionId}`)

      let sendMessage = message => {
        if ws->WebSocket.isOpen {
          Log.logMessageFromClient(message)
          ws->WebSocket.sendText(Serializer.serializeClientMessage(message))
        } else {
          Log.error(["Not connected", Log.clientMsgToString(message)])
        }
      }

      WebSocket.addCloseListener(ws, onDisconnect)
      WebSocket.addErrorListener(ws, onError)
      WebSocket.addOpenListener(ws, onConnect)

      (Some(ws), sendMessage)
    } else {
      (None, Utils.noop)
    }
  }, [sessionId])

  React.useEffect2(() => {
    let handleMessage = event => {
      event
      ->WebSocket.messageAsText
      ->MOption.toResult(#SyntaxError("Message from server cannot be parsed as text"))
      ->Result.flatMap(Serializer.deserializeServerMessage)
      ->Result.map(onMessage)
      ->ignore
    }

    switch ws {
    | Some(ws) => {
        WebSocket.addMessageListener(ws, handleMessage)

        Some(
          () => {
            WebSocket.removeMessageListener(ws, handleMessage)
          },
        )
      }
    | _ => None
    }
  }, (ws, onMessage))

  sendMessage
}
