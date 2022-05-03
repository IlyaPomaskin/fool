let createLogger = (prefix: string, logFn, list: array<'a>) =>
  logFn(Array.concat([`[${prefix}]`], list))

let error = createLogger("error", Js.Console.errorMany)
let log = createLogger("log", Js.Console.logMany)
let info = createLogger("debug", Js.Console.infoMany)
