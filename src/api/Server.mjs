// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Ws from "ws";
import * as Log from "../Log.mjs";
import * as Url from "url";
import * as Game from "../fool/Game.mjs";
import * as Utils from "../Utils.mjs";
import * as $$Storage from "./Storage.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Serializer from "../Serializer.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as WsWebSocket from "../bindings/WsWebSocket.mjs";
import * as GameInstance from "./GameInstance.mjs";
import * as WsWebSocketServer from "../bindings/WsWebSocketServer.mjs";

var playersSocket = $$Storage.PlayersSocketMap.empty(undefined);

var wsServer = new Ws.WebSocketServer({
      backlog: 101,
      clientTracking: true,
      maxPayload: 104857600,
      noServer: false,
      path: "/ws",
      server: restartServer(),
      skipUTF8Validation: true
    });

function sendToPlayer(playerId, $$event) {
  var result = Belt_Result.map($$Storage.PlayersSocketMap.get(playersSocket, playerId), (function (socket) {
          var tmp;
          switch ($$event.TAG | 0) {
            case /* ProgressCreated */3 :
                tmp = {
                  TAG: /* ProgressCreated */3,
                  _0: Game.maskForPlayer($$event._0, playerId)
                };
                break;
            case /* ProgressUpdated */4 :
                tmp = {
                  TAG: /* ProgressUpdated */4,
                  _0: Game.maskForPlayer($$event._0, playerId)
                };
                break;
            default:
              tmp = $$event;
          }
          socket.send(Serializer.serializeServerMessage(tmp));
          
        }));
  if (result.TAG === /* Ok */0) {
    Log.info([
          "[server]",
          "sent to " + playerId + ":",
          Log.serverMsgToString($$event)
        ]);
  } else {
    Log.error([
          "[server]",
          "Unable to send to player " + playerId + ":",
          result._0
        ]);
  }
  
}

function broadcastToPlayers(players, $$event) {
  return Belt_List.forEach(players, (function (player) {
                return sendToPlayer(player.id, $$event);
              }));
}

wsServer.on(WsWebSocketServer.ServerEvents.connection, (function (ws, req) {
        var playerId = Belt_Option.map(Belt_Option.map(Belt_Option.flatMap(Belt_Option.map(Caml_option.some(req), (function (prim) {
                            return prim.headers;
                          })), (function (headers) {
                        return headers.host;
                      })), (function (host) {
                    return new Url.URL(req.url, "ws://" + host);
                  })), (function (url) {
                return url.username;
              }));
        if (playerId !== undefined) {
          ws.on(WsWebSocket.ClientEvents.close, (function (param, param$1) {
                    return $$Storage.PlayersSocketMap.remove(playersSocket, playerId);
                  })).on(WsWebSocket.ClientEvents.message, (function (msg, param) {
                  var ws = this ;
                  Belt_Result.map(Utils.tapResult(Serializer.deserializeClientMessage(Belt_Option.getWithDefault(WsWebSocket.RawData.toString(msg), "")), Log.logMessageFromClient), (function (msg) {
                          var result;
                          switch (msg.TAG | 0) {
                            case /* Register */0 :
                                result = Belt_Result.map(GameInstance.registerPlayer(msg._0), (function (player) {
                                        $$Storage.PlayersSocketMap.set(playersSocket, player.id, ws);
                                        return sendToPlayer(player.id, {
                                                    TAG: /* Connected */0,
                                                    _0: player
                                                  });
                                      }));
                                break;
                            case /* Login */1 :
                                result = Belt_Result.map(GameInstance.loginPlayer(msg._0), (function (player) {
                                        $$Storage.PlayersSocketMap.set(playersSocket, player.id, ws);
                                        return sendToPlayer(player.id, {
                                                    TAG: /* Connected */0,
                                                    _0: player
                                                  });
                                      }));
                                break;
                            case /* Player */2 :
                                result = {
                                  TAG: /* Error */1,
                                  _0: "Message from server cannot be parsed as text"
                                };
                                break;
                            case /* Lobby */3 :
                                switch (msg._0) {
                                  case /* Create */0 :
                                      result = Belt_Result.map(GameInstance.createLobby(msg._1), (function (lobby) {
                                              return broadcastToPlayers(lobby.players, {
                                                          TAG: /* LobbyCreated */1,
                                                          _0: lobby
                                                        });
                                            }));
                                      break;
                                  case /* Enter */1 :
                                      result = Belt_Result.map(GameInstance.enterGame(msg._1, msg._2), (function (lobby) {
                                              return broadcastToPlayers(lobby.players, {
                                                          TAG: /* LobbyUpdated */2,
                                                          _0: lobby
                                                        });
                                            }));
                                      break;
                                  case /* Ready */2 :
                                      result = Belt_Result.map(GameInstance.toggleReady(msg._1, msg._2), (function (lobby) {
                                              return broadcastToPlayers(lobby.players, {
                                                          TAG: /* LobbyUpdated */2,
                                                          _0: lobby
                                                        });
                                            }));
                                      break;
                                  case /* Start */3 :
                                      result = Belt_Result.map(GameInstance.startGame(msg._1, msg._2), (function (progress) {
                                              return broadcastToPlayers(progress.players, {
                                                          TAG: /* ProgressCreated */3,
                                                          _0: progress
                                                        });
                                            }));
                                      break;
                                  
                                }
                                break;
                            case /* Progress */4 :
                                result = Belt_Result.map(GameInstance.dispatchMove(msg._1, msg._2, msg._0), (function (progress) {
                                        return broadcastToPlayers(progress.players, {
                                                    TAG: /* ProgressUpdated */4,
                                                    _0: progress
                                                  });
                                      }));
                                break;
                            
                          }
                          if (result.TAG === /* Ok */0) {
                            return ;
                          }
                          ws.send(Serializer.serializeServerMessage({
                                    TAG: /* ServerError */5,
                                    _0: result._0
                                  }));
                          
                        }));
                  
                }));
          return ;
        } else {
          return Log.error([
                      "Connection without playerId",
                      "url.toString()"
                    ]);
        }
      }));

function $$default(param, res) {
  res.end(Buffer.from("response"));
  
}

export {
  $$default ,
  $$default as default,
  
}
/* playersSocket Not a pure module */
