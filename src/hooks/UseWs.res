open Types

type hookReturn = {
  error: option<string>,
  sendMessage: gameMessageFromClient => unit,
}

let hook = (~onMessage, ~player): hookReturn => {
  let (error, setError) = React.useState(_ => None)

  let sessionId = player->Option.map(player => player.sessionId)->Option.getWithDefault("")
  let (ws, sendMessage) = React.useMemo1(_ => {
    Js.log2("usews sessionId", sessionId)
    let ws = WebSocket.make(`ws://localhost:3001/ws?sessionId=${sessionId}`)

    WebSocket.addCloseListener(ws, event => Js.log2("close", event))
    WebSocket.addErrorListener(ws, event => Js.log2("error", event))
    WebSocket.addOpenListener(ws, event => Js.log2("open", event))

    let sendMessage = message => {
      if ws->WebSocket.isOpen {
        Log.logMessageFromClient(message)
        ws->WebSocket.sendText(Serializer.serializeClientMessage(message))
      } else {
        Log.error(["Not connected", Log.clientMsgToString(message)])
      }
    }

    (ws, sendMessage)
  }, [sessionId])

  React.useEffect2(() => {
    let handleMessage = event => {
      event
      ->WebSocket.messageAsText
      ->Utils.toResult(#SyntaxError("Message from server cannot be parsed as text"))
      ->Result.flatMap(Serializer.deserializeServerMessage)
      ->Result.map(message => {
        switch message {
        | ServerError(msg) => setError(_ => Some(msg))
        | _ => setError(_ => None)
        }

        onMessage(message)
      })
      ->ignore
    }

    ws->WebSocket.addMessageListener(handleMessage)

    Some(() => ws->WebSocket.removeMessageListener(handleMessage))
  }, (ws, onMessage))

  {
    error: error,
    sendMessage: sendMessage,
  }
}
