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
    case /* Player */0 :
        var tmp$1;
        switch (msg._0) {
          case /* Connect */0 :
              tmp$1 = "Connect";
              break;
          case /* Disconnect */1 :
              tmp$1 = "Disconnect";
              break;
          case /* Ping */2 :
              tmp$1 = "Ping";
              break;
          case /* Pong */3 :
              tmp$1 = "Pong";
              break;
          
        }
        tmp = "player [" + msg._1 + "] " + tmp$1;
        break;
    case /* Lobby */1 :
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
    case /* Progress */2 :
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

function logMessageFromServer(msg, playerId) {
  var tmp;
  switch (msg.TAG | 0) {
    case /* Connected */0 :
        tmp = "Connected " + msg._0.id;
        break;
    case /* LobbyCreated */1 :
        tmp = "[" + msg._0.gameId + "] LobbyCreated";
        break;
    case /* LobbyUpdated */2 :
        tmp = "[" + msg._0.gameId + "] LobbyUpdated";
        break;
    case /* ProgressCreated */3 :
        tmp = "[" + msg._0.gameId + "] ProgressCreated";
        break;
    case /* ProgressUpdated */4 :
        tmp = "[" + msg._0.gameId + "] ProgressUpdated";
        break;
    case /* ServerError */5 :
        tmp = "ServerError: " + msg._0;
        break;
    
  }
  return info([
              "[server] [" + playerId + "]",
              tmp
            ]);
}

export {
  createLogger ,
  error ,
  log ,
  info ,
  logMessageFromClient ,
  logMessageFromServer ,
  
}
/* No side effect */
