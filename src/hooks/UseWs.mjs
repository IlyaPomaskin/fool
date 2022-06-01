// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "../Log.mjs";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as $$WebSocket from "../bindings/WebSocket.mjs";
import * as Serializer from "../Serializer.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

function hook(player, onMessage, onConnectOpt, onDisconnectOpt, onErrorOpt) {
  var onConnect = onConnectOpt !== undefined ? onConnectOpt : Utils.noop;
  var onDisconnect = onDisconnectOpt !== undefined ? onDisconnectOpt : Utils.noop;
  var onError = onErrorOpt !== undefined ? onErrorOpt : Utils.noop;
  var sessionId = Belt_Option.getWithDefault(Belt_Option.map(player, (function (player) {
              return player.sessionId;
            })), "");
  var match = React.useMemo((function () {
          if (sessionId === "") {
            return [
                    undefined,
                    Utils.noop
                  ];
          }
          var ws = new WebSocket("ws" + Utils.getProtocolSuffix(undefined) + "://" + Utils.getServerUrl(undefined) + "/ws?sessionId=" + sessionId);
          var sendMessage = function (message) {
            if ($$WebSocket.isOpen(ws)) {
              Log.logMessageFromClient(message);
              ws.send(Serializer.serializeClientMessage(message));
              return ;
            } else {
              return Log.error([
                          "Not connected",
                          Log.clientMsgToString(message)
                        ]);
            }
          };
          ws.addEventListener("close", onDisconnect);
          ws.addEventListener("error", onError);
          ws.addEventListener("open", onConnect);
          return [
                  ws,
                  sendMessage
                ];
        }), [sessionId]);
  var ws = match[0];
  React.useEffect((function () {
          var handleMessage = function ($$event) {
            Belt_Result.map(Belt_Result.flatMap(Utils.toResult($$WebSocket.messageAsText($$event), {
                          NAME: "SyntaxError",
                          VAL: "Message from server cannot be parsed as text"
                        }), Serializer.deserializeServerMessage), onMessage);
            
          };
          if (ws !== undefined) {
            ws.addEventListener("message", handleMessage);
            return (function (param) {
                      ws.removeEventListener("message", handleMessage);
                      
                    });
          }
          
        }), [
        ws,
        onMessage
      ]);
  return match[1];
}

export {
  hook ,
  
}
/* Utils Not a pure module */
