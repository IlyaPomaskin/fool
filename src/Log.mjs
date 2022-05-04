// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_splice_call from "rescript/lib/es6/caml_splice_call.js";

function createLogger(prefix, logFn, list) {
  return Curry._1(logFn, Belt_Array.concat(["[" + prefix + "]"], list));
}

function error(param) {
  return createLogger("error", (function (prim) {
                Caml_splice_call.spliceApply(console.error, [prim]);
                
              }), param);
}

function log(param) {
  return createLogger("log", (function (prim) {
                Caml_splice_call.spliceApply(console.log, [prim]);
                
              }), param);
}

function info(param) {
  return createLogger("debug", (function (prim) {
                Caml_splice_call.spliceApply(console.info, [prim]);
                
              }), param);
}

function logMessageFromClient(msg) {
  var tmp;
  switch (msg.TAG | 0) {
    case /* Register */0 :
        tmp = "Register " + msg._0;
        break;
    case /* Login */1 :
        tmp = "Login " + msg._0;
        break;
    case /* Player */2 :
        var tmp$1;
        switch (msg._0) {
          case /* Disconnect */0 :
              tmp$1 = "Disconnect";
              break;
          case /* Ping */1 :
              tmp$1 = "Ping";
              break;
          case /* Pong */2 :
              tmp$1 = "Pong";
              break;
          
        }
        tmp = "player [" + msg._1 + "] " + tmp$1;
        break;
    case /* Lobby */3 :
        var tmp$2;
        switch (msg._0) {
          case /* Create */0 :
              tmp$2 = "Create";
              break;
          case /* Enter */1 :
              tmp$2 = "Enter";
              break;
          case /* Ready */2 :
              tmp$2 = "Ready";
              break;
          case /* Start */3 :
              tmp$2 = "Start";
              break;
          
        }
        tmp = "lobby [" + msg._2 + "][" + msg._1 + "] " + tmp$2;
        break;
    case /* Progress */4 :
        var game = msg._0;
        var tmp$3;
        tmp$3 = typeof game === "number" ? (
            game === /* Take */0 ? "Take" : "Pass"
          ) : (
            game.TAG === /* Beat */0 ? "Beat to: " + Card.cardToString(game._0) + " by: " + Card.cardToString(game._1) : "Move " + Card.cardToString(game._0)
          );
        tmp = "progress [" + msg._2 + "][" + msg._1 + "] " + tmp$3;
        break;
    
  }
  return info([
              "[client]",
              tmp
            ]);
}

function serverMsgToString(msg) {
  switch (msg.TAG | 0) {
    case /* Connected */0 :
        return "Connected " + msg._0.id;
    case /* LobbyCreated */1 :
        return "[" + msg._0.gameId + "] LobbyCreated";
    case /* LobbyUpdated */2 :
        return "[" + msg._0.gameId + "] LobbyUpdated";
    case /* LobbyClosed */3 :
        return "[" + msg._0 + "] LobbyUpdated";
    case /* ProgressCreated */4 :
        return "[" + msg._0.gameId + "] ProgressCreated";
    case /* ProgressUpdated */5 :
        return "[" + msg._0.gameId + "] ProgressUpdated";
    case /* ServerError */6 :
        return "ServerError: " + msg._0;
    
  }
}

function logMessageFromServer(msg, playerId) {
  return info([
              "[server] [" + playerId + "]",
              serverMsgToString(msg)
            ]);
}

export {
  createLogger ,
  error ,
  log ,
  info ,
  logMessageFromClient ,
  serverMsgToString ,
  logMessageFromServer ,
  
}
/* No side effect */
