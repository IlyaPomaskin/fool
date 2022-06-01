open NodeJs
include WsWebSocket

type wss

module Make = {
  type options = {
    backlog: int, // The maximum length of the queue of pending connections
    clientTracking: bool, //Specifies whether or not to track clients.
    // handleProtocols:  {Function} A function which can be used to handle the WebSocket subprotocols. See description below.
    maxPayload: int, // The maximum allowed message size in bytes. Defaults to 100 MiB (104857600 bytes).
    noServer: bool, // Enable no server mode.
    path: string, // Accept only connections matching this path.
    // perMessageDeflate {Boolean|Object} Enable/disable permessage-deflate.
    // host: string, // The hostname where to bind the server.
    // port: int, // The port where to bind the server.
    server: NodeJs.Http.Server.t, // {http.Server|https.Server} A pre-created Node.js HTTP/S server.
    skipUTF8Validation: bool, // Specifies whether or not to skip UTF-8 validation for text and close messages. Defaults to false. Set to true only if clients are trusted.
    // verifyClient {Function} A function which can be used to validate incoming connections. See description below. (Usage is discouraged: see Issue #337)
  }

  @module("ws") @new external make: options => t = "WebSocketServer"
}

@val external options: Make.options = "options"
@val external path: string = "path"
// FIXME add Set typings
// @val external clients: Set.t<WsWebSocket.t> = "clients"

module ServerEvents = {
  let connection: EventWithThis.t<
    @this (wss, WsWebSocket.t, Http.IncomingMessage.t) => unit,
    t,
  > = EventWithThis.fromString2("connection")
  let error: EventWithThis.t<@this (wss, Errors.Error.t) => unit, t> = EventWithThis.fromString1(
    "error",
  )
  let headers: EventWithThis.t<
    @this (wss, array<string>, Http.IncomingMessage.t) => unit,
    t,
  > = EventWithThis.fromString2("headers")
  let close: EventWithThis.t<@this (wss => unit), t> = EventWithThis.fromString0("close")
  let listening: EventWithThis.t<@this (wss => unit), t> = EventWithThis.fromString0("listening")
}

@send
external address: t => Js.Nullable.t<{"port": int, "family": string, "address": string}> = "address"
@send
external close: t => unit = "close"
@send
external handleUpgrade: (
  t,
  Http.IncomingMessage.t,
  Net.TcpSocket.t,
  Js.nullable<Buffer.t>,
  (WsWebSocket.t, Http.IncomingMessage.t) => unit,
) => unit = "handleUpgrade"
@send
external shouldHandle: Http.IncomingMessage.t => bool = "shouldHandle"

// FIXME Remove debug fn
@val external restartServer: unit => Http.Server.t = "restartServer"

@get
external getServerFromSocket: NodeJs.Net.TcpSocket.t => NodeJs.Http.Server.t = "server"
