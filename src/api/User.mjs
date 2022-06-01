// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "../Log.mjs";
import * as WsServer from "./WsServer.mjs";
import * as Serializer from "../Serializer.mjs";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as ServerUtils from "./ServerUtils.mjs";
import * as GameInstance from "./GameInstance.mjs";

function $$default(req, res) {
  WsServer.setWsServer(res);
  var searchParams = ServerUtils.getSearchParams(ServerUtils.getUrl(req, "http"));
  var playerId = ServerUtils.getParam(searchParams, "playerId");
  var sessionId = ServerUtils.getParam(searchParams, "sessionId");
  var response = sessionId !== undefined ? (Log.debug(/* User */1, [
            "login",
            sessionId
          ]), Belt_Result.map(GameInstance.loginPlayer(sessionId), (function (player) {
              return {
                      TAG: /* LoggedIn */1,
                      _0: player
                    };
            }))) : (
      playerId !== undefined ? (Log.debug(/* User */1, [
                "register",
                playerId
              ]), Belt_Result.map(GameInstance.registerPlayer(playerId), (function (player) {
                  return {
                          TAG: /* Registered */0,
                          _0: player
                        };
                }))) : ({
            TAG: /* Error */1,
            _0: "No way to authorize"
          })
    );
  var json;
  json = response.TAG === /* Ok */0 ? Serializer.serializeUserApiResponse(response._0) : Serializer.serializeUserApiResponse({
          TAG: /* UserError */2,
          _0: response._0
        });
  res.end(Buffer.from(json));
  
}

export {
  $$default ,
  $$default as default,
  
}
/* WsServer Not a pure module */
