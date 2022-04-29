open NodeJs

let default = (_: Http.ClientRequest.t, res: Http.ServerResponse.t) => {
  let wsServer = Ws.MakeWebSocketServer.make({
    backlog: 100,
    clientTracking: true,
    maxPayload: 104857600,
    path: "/ws",
    noServer: false,
    server: Ws.restartServer(),
    skipUTF8Validation: true,
  })

  wsServer
  ->Ws.WebSocketServer.addListener(Ws.WebSocketServer.Events.connection, ws => {
    ws
    ->Ws.WebSocket.addListener(Ws.WebSocket.Events.message, msg => {
      Js.log2("msg:", msg->Buffer.toString)
    })
    ->ignore
  })
  ->ignore

  res->Http.ServerResponse.endWithData(Buffer.fromString("response"))
}
