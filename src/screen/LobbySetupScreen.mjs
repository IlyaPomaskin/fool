// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "../components/Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";

function LobbySetupScreen(Props) {
  var player = Props.player;
  var gameId = Props.gameId;
  var onMessage = Props.onMessage;
  var match = React.useState(function () {
        if (gameId !== undefined) {
          return gameId;
        } else {
          return "";
        }
      });
  var setInputGameId = match[1];
  var inputGameId = match[0];
  var handleConnect = function (gameId) {
    return Curry._1(onMessage, {
                TAG: /* Lobby */1,
                _0: /* Enter */1,
                _1: player.id,
                _2: gameId
              });
  };
  var match$1 = Utils.useStateValue(false);
  var isWaiting = match$1[0];
  React.useEffect((function () {
          if (gameId !== undefined) {
            handleConnect(gameId);
          }
          
        }), [gameId]);
  return React.createElement("div", {
              className: "flex flex-col gap-2"
            }, React.createElement("div", {
                  className: "flex flex-col gap-2"
                }, React.createElement(Base.Heading.make, {
                      size: /* H5 */3,
                      children: Utils.uiStr("Create new game")
                    }), React.createElement(Base.Button.make, {
                      onClick: (function (param) {
                          return Curry._1(onMessage, {
                                      TAG: /* Lobby */1,
                                      _0: /* Create */0,
                                      _1: player.id,
                                      _2: ""
                                    });
                        }),
                      children: Utils.uiStr("New")
                    })), React.createElement("div", {
                  className: "flex flex-col gap-2"
                }, React.createElement(Base.Heading.make, {
                      size: /* H5 */3,
                      children: Utils.uiStr("Connect to game")
                    }), React.createElement(Base.Input.make, {
                      value: inputGameId,
                      disabled: isWaiting,
                      onChange: (function (value) {
                          return Curry._1(setInputGameId, (function (param) {
                                        return value;
                                      }));
                        })
                    }), React.createElement(Base.Button.make, {
                      disabled: isWaiting,
                      onClick: (function (param) {
                          return handleConnect(inputGameId);
                        }),
                      children: Utils.uiStr("Connect")
                    })));
}

var make = LobbySetupScreen;

export {
  make ,
  
}
/* Base Not a pure module */
