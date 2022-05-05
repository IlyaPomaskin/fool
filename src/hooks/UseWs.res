open Types
open Webapi

type hookReturn = {
  error: option<string>,
  sendMessage: gameMessageFromClient => unit,
}

let hook = (onMessage): hookReturn => {
  let (error, setError) = React.useState(_ => None)

  let ws = React.useMemo0(_ => WebSocket.make(`ws://localhost:3001/ws`))

  let sendMessage = React.useCallback1(message => {
    Log.logMessageFromClient(message)
    ws->WebSocket.sendText(Serializer.serializeClientMessage(message))
  }, [ws])

  React.useEffect1(() => {
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
  }, [ws])

  {
    error: error,
    sendMessage: sendMessage,
  }
}
