// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Player from "./fool/Player.mjs";

function broadcast(gameId, payload) {
  setTimeout((function (param) {
          console.log("[server] broadcast: ", gameId, payload);
          
        }), 100);
  
}

function send(player, payload) {
  setTimeout((function (param) {
          console.log("[server] send: ", Player.toObject(player), payload);
          
        }), 100);
  
}

var SServer = {
  broadcast: broadcast,
  send: send
};

function send$1(gameId, playerId, payload) {
  setTimeout((function (param) {
          console.log("[client] send: ", gameId, playerId, payload);
          
        }), 100);
  
}

var SClient = {
  send: send$1
};

export {
  SServer ,
  SClient ,
  
}
/* No side effect */