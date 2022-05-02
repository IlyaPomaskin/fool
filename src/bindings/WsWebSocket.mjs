// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.mjs";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";

function readyStateToInt(state) {
  return state;
}

function binaryTypeToString(bType) {
  switch (bType) {
    case /* NodeBuffer */0 :
        return "nodebuffer";
    case /* ArrayBuffer */1 :
        return "arraybuffer";
    case /* Fragments */2 :
        return "fragments";
    
  }
}

function classify(x) {
  var match = Utils.Classify.constructorName(x);
  switch (match) {
    case "Array" :
        return {
                TAG: /* ArrayOfBuffers */2,
                _0: x
              };
    case "ArrayBuffer" :
        return {
                TAG: /* ArrayBuffer */1,
                _0: x
              };
    case "Buffer" :
        return {
                TAG: /* Buffer */0,
                _0: x
              };
    default:
      return /* Unknown */0;
  }
}

function toString(rawData) {
  var buf = classify(rawData);
  if (typeof buf === "number") {
    return ;
  }
  switch (buf.TAG | 0) {
    case /* Buffer */0 :
        return buf._0.toString();
    case /* ArrayBuffer */1 :
        return Buffer.from(buf._0).toString();
    case /* ArrayOfBuffers */2 :
        return Belt_Array.joinWith(buf._0, "", (function (prim) {
                      return prim.toString();
                    }));
    
  }
}

var RawData = {
  classify: classify,
  toString: toString
};

var EventWithThis = {};

var ClientEvents = {
  close: "close",
  error: "error",
  upgrade: "upgrade",
  message: "message",
  open_: "open",
  ping: "ping",
  pong: "pong",
  unexpected_response: "unexpected-response"
};

function makeSendOptions(mask, binary, compress, fin, param) {
  return {
          mask: mask,
          binary: binary,
          compress: compress,
          fin: fin
        };
}

function makeOptions(protocol, followRedirects, generateMask, handshakeTimeout, maxRedirects, localAddress, protocolVersion, origin, agent, host, family, rejectUnauthorized, maxPayload, skipUTF8Validation, param) {
  return {
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
          skipUTF8Validation: skipUTF8Validation
        };
}

export {
  readyStateToInt ,
  binaryTypeToString ,
  RawData ,
  EventWithThis ,
  ClientEvents ,
  makeSendOptions ,
  makeOptions ,
  
}
/* No side effect */
