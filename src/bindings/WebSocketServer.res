open NodeJs
include EventEmitter.Make()

type wss

module Events = {
  let connection: Event.t<WebSocket.t => unit, t> = Event.fromString("connection")
}

@send
external address: t => Js.Nullable.t<{"port": int, "family": string, "address": string}> = "address"

@send
external close: t => unit = "close"

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

// DEBUG
@val external restartServer: unit => Http.Server.t = "restartServer"
