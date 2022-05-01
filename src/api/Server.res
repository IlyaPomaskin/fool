open NodeJs

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  let wsServer = WebSocketServer.Make.make({
    backlog: 101,
    clientTracking: true,
    maxPayload: 104857600,
    path: "/ws",
    noServer: false,
    server: WebSocketServer.restartServer(),
    skipUTF8Validation: true,
  })

  wsServer
  ->WebSocketServer.addListener(WebSocketServer.Events.connection, ws => {
    ws
    ->WebSocket.on(WebSocket.Events.message, @this (this, msg, isBinary) => {
      Js.log2("THIS", this)
      Js.log2("MSG", msg)
      Js.log2("isBinary", isBinary)
      switch msg->WebSocket.RawData.classify {
      | Buffer(b) => Js.log2("b", b)
      | ArrayBuffer(ab) => Js.log2("ab", ab)
      | ArrayOfBuffers(aob) => Js.log2("aob", aob)
      | Unknown => Js.log("unknown")
      }
    })
    ->ignore
  })
  ->ignore

  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
