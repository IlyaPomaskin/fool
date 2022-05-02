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
    switch msg->WsWebSocket.RawData.classify {
    | Buffer(b) => Js.log2("msg", Buffer.toString(b))
    | ArrayBuffer(ab) => Js.log2("ab", ab)
    | ArrayOfBuffers(aob) => Js.log2("aob", aob)
    | Unknown => Js.log("unknown")
    }
  })
  ->WsWebSocket.on(WsWebSocket.ClientEvents.close, @this (_, _, _) => {
    Js.log("connection close")
  })
  ->ignore
})
->ignore

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
