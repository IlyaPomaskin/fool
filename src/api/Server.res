open NodeJs

let wsServer = WsWebSocketServer.Make.make({
  backlog: 101,
  clientTracking: true,
  maxPayload: 104857600,
  path: "/ws",
  noServer: false,
  server: WsWebSocketServer.restartServer(),
  skipUTF8Validation: true,
})

wsServer
->WsWebSocketServer.on(WsWebSocketServer.ServerEvents.connection, @this (_, ws, _) => {
  ws
  ->WsWebSocket.on(WsWebSocket.ClientEvents.open_, @this client => {
    Js.log("connection open")
    client->WsWebSocket.send("connected")
  })
  ->WsWebSocket.on(WsWebSocket.ClientEvents.message, @this (_, msg, _) => {
    Js.log2("msg:", WsWebSocket.RawData.toString(msg))
  })
  ->WsWebSocket.on(WsWebSocket.ClientEvents.close, @this (_, _, _) => {
    Js.log("connection close")
  })
  ->ignore
})
->ignore

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  GameInstance.initiateGame()
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
