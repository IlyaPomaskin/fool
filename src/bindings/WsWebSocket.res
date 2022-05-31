open NodeJs

type t

type readyState =
  | Connecting
  | Open
  | Closing
  | Closed

let readyStateToInt = state =>
  switch state {
  | Connecting => 0
  | Open => 1
  | Closing => 2
  | Closed => 3
  }

type binaryType =
  | NodeBuffer
  | ArrayBuffer
  | Fragments

let binaryTypeToString = bType =>
  switch bType {
  | NodeBuffer => "nodebuffer"
  | ArrayBuffer => "arraybuffer"
  | Fragments => "fragments"
  }

module RawData = {
  type t

  type rawDataType =
    | Buffer(Buffer.t)
    | ArrayBuffer(Js.TypedArray2.ArrayBuffer.t)
    | ArrayOfBuffers(array<Buffer.t>)
    | Unknown

  let classify: t => rawDataType = x =>
    switch Utils.Classify.constructorName(x->Obj.magic) {
    | "Buffer" => Buffer(Obj.magic(x))
    | "ArrayBuffer" => ArrayBuffer(Obj.magic(x))
    | "Array" => ArrayOfBuffers(Obj.magic(x))
    | _ => Unknown
    }

  let toString = rawData =>
    switch classify(rawData) {
    | Buffer(buf) => Some(buf->Buffer.toString)
    | ArrayBuffer(arrayBuf) => Some(arrayBuf->Buffer.fromArrayBuffer->Buffer.toString)
    | ArrayOfBuffers(arrayOfBuf) => Some(arrayOfBuf->Belt.Array.joinWith("", Buffer.toString))
    | Unknown => None
    }
}

module EventWithThis = {
  type t<'listener, 'ty>
  external fromString0: string => t<@this ('this => 'b), 'ty> = "%identity"
  external fromString1: string => t<@this ('this, 'a1) => 'b, 'ty> = "%identity"
  external fromString2: string => t<@this ('this, 'a1, 'a2) => 'b, 'ty> = "%identity"
  external fromString3: string => t<@this ('this, 'a1, 'a2, 'a3) => 'b, 'ty> = "%identity"
  external fromStringTest: string => t<@this ('a, 'a1, 'a2) => 'b, 'ty> = "%identity"
}

module ClientEvents = {
  let close: EventWithThis.t<@this (t, int, Buffer.t) => unit, t> = EventWithThis.fromString2(
    "close",
  )
  let error: EventWithThis.t<@this (t, Errors.Error.t) => unit, t> = EventWithThis.fromString1(
    "error",
  )
  let upgrade: EventWithThis.t<
    @this (t, Http.IncomingMessage.t) => unit,
    t,
  > = EventWithThis.fromString1("upgrade")
  let message: EventWithThis.t<
    @this (t, RawData.t, bool) => unit,
    t,
  > = EventWithThis.fromStringTest("message")
  let open_: EventWithThis.t<@this (t => unit), t> = EventWithThis.fromString0("open")
  let ping: EventWithThis.t<@this (t, Buffer.t) => unit, t> = EventWithThis.fromString1("ping")
  let pong: EventWithThis.t<@this (t, Buffer.t) => unit, t> = EventWithThis.fromString1("pong")
  let unexpected_response: EventWithThis.t<
    @this (t, Http.ClientRequest.t, Http.IncomingMessage.t) => unit,
    t,
  > = EventWithThis.fromString2("unexpected-response")
}

@send
external on: (t, EventWithThis.t<@this 'f, t>, @this 'f) => t = "on"
@send
external off: (t, EventWithThis.t<@this 'f, t>, @this 'f) => t = "off"
@send
external emit: (t, EventWithThis.t<@this 'f, t>) => t = "emit"
@send
external emit1: (t, EventWithThis.t<@this 'f, t>, 'a) => t = "emit"
@send
external emit2: (t, EventWithThis.t<@this 'f, t>, 'a1, 'a2) => t = "emit"

@val external bufferedAmount: int = "bufferedAmount"
@val external extensions: string = "extensions"
@val external isPaused: bool = "isPaused"
@val external protocol: string = "protocol"
@val external readyState: readyState = "readyState"
@val external url: string = "url"

@send
external close: t => unit = "close"
@send
external closeWithCode: (t, int) => unit = "close"
@send
external closeWithCodeAndReason: (t, int, string) => unit = "close"
@send
external ping: t => unit = "ping"
@send
external pingWithData: (t, string) => unit = "ping"
@send
external pingWithDataAndMask: (t, string, bool) => unit = "ping"
@send
external pingWithDataAndMaskAndCb: (t, string, bool, Errors.Error.t => unit) => unit = "ping"
@send
external pong: t => unit = "pong"
@send
external pongWithData: (t, string) => unit = "pong"
@send
external pongWithDataAndMask: (t, string, bool) => unit = "pong"
@send
external pongWithDataAndMaskAndCb: (t, string, bool, Errors.Error.t => unit) => unit = "pong"
@send
external send: (t, string) => unit = "send"
@send
external sendWithCb: (t, string, Errors.Error.t => unit) => unit = "send"

type sendOptions = {
  mask: option<bool>,
  binary: option<bool>,
  compress: option<bool>,
  fin: option<bool>,
}

let makeSendOptions = (~mask=?, ~binary=?, ~compress=?, ~fin=?, ()): sendOptions => {
  mask: mask,
  binary: binary,
  compress: compress,
  fin: fin,
}

@send
external sendWithOptions: (t, string, sendOptions) => unit = "send"
@send
external sendWithOptionsAndCb: (t, string, sendOptions, Errors.Error.t => unit) => unit = "send"
@send
external terminate: t => unit = "terminate"
@send
external pause: t => unit = "pause"
@send
external resume: t => unit = "resume"

type options = {
  protocol: option<string>,
  followRedirects: option<bool>,
  generateMask: option<Buffer.t => unit>,
  handshakeTimeout: option<int>,
  maxRedirects: option<int>,
  localAddress: option<string>,
  protocolVersion: option<int>,
  origin: option<string>,
  agent: option<NodeJs.Http.Agent.t>,
  host: option<string>,
  family: option<int>,
  rejectUnauthorized: option<bool>,
  maxPayload: option<int>,
  skipUTF8Validation: option<bool>,
  // headers: option<a'>,
  // perMessageDeflate: option<bool | PerMessageDeflateOptions>,
  // checkServerIdentity?(servername: string, cert: CertMeta): bool,
}

let makeOptions = (
  ~protocol=?,
  ~followRedirects=?,
  ~generateMask=?,
  ~handshakeTimeout=?,
  ~maxRedirects=?,
  ~localAddress=?,
  ~protocolVersion=?,
  ~origin=?,
  ~agent=?,
  ~host=?,
  ~family=?,
  ~rejectUnauthorized=?,
  ~maxPayload=?,
  ~skipUTF8Validation=?,
  (),
): options => {
  protocol: protocol,
  followRedirects: followRedirects,
  generateMask: generateMask,
  handshakeTimeout: handshakeTimeout,
  maxRedirects: maxRedirects,
  localAddress: localAddress,
  protocolVersion: protocolVersion,
  origin: origin,
  agent: agent,
  host: host,
  family: family,
  rejectUnauthorized: rejectUnauthorized,
  maxPayload: maxPayload,
  skipUTF8Validation: skipUTF8Validation,
}

@module("ws") @new
external make: string => t = "WebSocket"
@module("ws") @new
external makeWithOptions: (string, options) => t = "WebSocket"
@module("ws") @new
external makeWithoutAddress: unit => t = "WebSocket"
@module("ws") @new
external makeWithAddressProtocolAndOptions: (string, string, options) => t = "WebSocket"
@module("ws") @new
external makeWithAddressProtocolsAndOptions: (string, array<string>, options) => t = "WebSocket"
