// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Ws from "ws";
import * as Log from "../Log.mjs";
import * as Game from "../fool/Game.mjs";
import * as Utils from "../Utils.mjs";
import * as $$Storage from "./Storage.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Serializer from "../Serializer.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as ServerUtils from "./ServerUtils.mjs";
import * as WsWebSocket from "../bindings/WsWebSocket.mjs";
import * as GameInstance from "./GameInstance.mjs";
import * as WsWebSocketServer from "../bindings/WsWebSocketServer.mjs";

var playersSocket = $$Storage.PlayersSocketMap.empty(undefined);

function createServer(server) {
  var wsServer = new Ws.WebSocketServer({
        backlog: 101,
        clientTracking: true,
        maxPayload: 104857600,
        noServer: false,
        path: "/ws",
        server: server,
        skipUTF8Validation: true
      });
  var sendToWs = function (ws, $$event) {
    ws.send(Serializer.serializeServerMessage($$event));
    
  };
  var sendToPlayer = function (playerId, $$event) {
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
            return sendToWs(socket, tmp);
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
    
  };
  var broadcastToPlayers = function (players, $$event) {
    return Belt_List.forEach(players, (function (player) {
                  return sendToPlayer(player.id, $$event);
                }));
  };
  wsServer.on(WsWebSocketServer.ServerEvents.connection, (function (ws, req) {
          var sessionId = Utils.toResult(Belt_Option.flatMap(ServerUtils.getParam(ServerUtils.getSearchParams(ServerUtils.getUrl(req, "ws")), "sessionId"), (function (sessionId) {
                      if (sessionId === "") {
                        return ;
                      } else {
                        return sessionId;
                      }
                    })), "No sessionId");
          Log.debug(/* Ws */0, ["login " + Belt_Result.getWithDefault(sessionId, "No sessionId")]);
          var player = Belt_Result.flatMap(sessionId, GameInstance.loginPlayer);
          if (sessionId.TAG === /* Ok */0) {
            if (player.TAG === /* Ok */0) {
              var player$1 = player._0;
              var playerId = player$1.id;
              $$Storage.PlayersSocketMap.set(playersSocket, playerId, ws);
              sendToPlayer(playerId, {
                    TAG: /* Connected */0,
                    _0: player$1
                  });
              ws.on(WsWebSocket.ClientEvents.close, (function (param, param$1) {
                        return $$Storage.PlayersSocketMap.remove(playersSocket, playerId);
                      })).on(WsWebSocket.ClientEvents.message, (function (msg, param) {
                      var ws = this ;
                      Belt_Result.map(Utils.tapResult(Serializer.deserializeClientMessage(Belt_Option.getWithDefault(WsWebSocket.RawData.toString(msg), "")), Log.logMessageFromClient), (function (msg) {
                              var tmp;
                              switch (msg.TAG | 0) {
                                case /* Player */0 :
                                    tmp = {
                                      TAG: /* Error */1,
                                      _0: "Message from server cannot be parsed as text"
                                    };
                                    break;
                                case /* Lobby */1 :
                                    switch (msg._0) {
                                      case /* Create */0 :
                                          tmp = Belt_Result.map(GameInstance.createLobby(msg._1), (function (lobby) {
                                                  return broadcastToPlayers(lobby.players, {
                                                              TAG: /* LobbyCreated */1,
                                                              _0: lobby
                                                            });
                                                }));
                                          break;
                                      case /* Enter */1 :
                                          tmp = Belt_Result.map(GameInstance.enterGame(msg._1, msg._2), (function (lobby) {
                                                  return broadcastToPlayers(lobby.players, {
                                                              TAG: /* LobbyUpdated */2,
                                                              _0: lobby
                                                            });
                                                }));
                                          break;
                                      case /* Ready */2 :
                                          tmp = Belt_Result.map(GameInstance.toggleReady(msg._1, msg._2), (function (lobby) {
                                                  return broadcastToPlayers(lobby.players, {
                                                              TAG: /* LobbyUpdated */2,
                                                              _0: lobby
                                                            });
                                                }));
                                          break;
                                      case /* Start */3 :
                                          tmp = Belt_Result.map(GameInstance.startGame(msg._1, msg._2), (function (progress) {
                                                  return broadcastToPlayers(progress.players, {
                                                              TAG: /* ProgressCreated */3,
                                                              _0: progress
                                                            });
                                                }));
                                          break;
                                      
                                    }
                                    break;
                                case /* Progress */2 :
                                    tmp = Belt_Result.map(GameInstance.move(msg._1, msg._2, msg._0), (function (progress) {
                                            return broadcastToPlayers(progress.players, {
                                                        TAG: /* ProgressUpdated */4,
                                                        _0: progress
                                                      });
                                          }));
                                    break;
                                
                              }
                              return Utils.tapErrorResult(tmp, (function (msg) {
                                            return sendToWs(ws, {
                                                        TAG: /* ServerError */5,
                                                        _0: msg
                                                      });
                                          }));
                            }));
                      
                    }));
              return ;
            }
            Log.error([
                  "Player not found error:",
                  player._0
                ]);
            ws.close();
            return ;
          }
          Log.error([
                "Can't get sessionId error:",
                sessionId._0
              ]);
          ws.close();
          
        }));
  
}

var isWsServerSet = {
  contents: false
};

function setWsServer(res) {
  if (!isWsServerSet.contents) {
    console.log("Set handlers");
    isWsServerSet.contents = true;
    return createServer(res.socket.server);
  }
  
}

export {
  playersSocket ,
  createServer ,
  isWsServerSet ,
  setWsServer ,
  
}
/* playersSocket Not a pure module */
