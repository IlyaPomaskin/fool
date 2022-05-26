// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "./Log.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as UseWs from "./hooks/UseWs.mjs";
import * as Utils from "./Utils.mjs";
import * as React from "react";
import * as PlayerUI from "./components/PlayerUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as InLobbyScreen from "./screen/InLobbyScreen.mjs";
import * as InProgressScreen from "./screen/InProgressScreen.mjs";
import * as LobbySetupScreen from "./screen/LobbySetupScreen.mjs";
import * as AuthorizationScreen from "./screen/AuthorizationScreen.mjs";

function Index$PlayerScreen(Props) {
  var match = React.useState(function () {
        
      });
  var setPlayer = match[1];
  var player = match[0];
  var match$1 = React.useState(function () {
        return /* AuthorizationScreen */0;
      });
  var setScreen = match$1[1];
  var screen = match$1[0];
  var onMessage = React.useCallback((function (message) {
          Log.logMessageFromServer(message, player);
          var exit = 0;
          switch (message.TAG | 0) {
            case /* Connected */0 :
                var player$1 = message._0;
                Curry._1(setPlayer, (function (param) {
                        return player$1;
                      }));
                return Curry._1(setScreen, (function (param) {
                              return /* LobbySetupScreen */1;
                            }));
            case /* LobbyCreated */1 :
            case /* LobbyUpdated */2 :
                exit = 1;
                break;
            case /* ProgressCreated */3 :
            case /* ProgressUpdated */4 :
                exit = 2;
                break;
            case /* ServerError */5 :
                return Log.info([
                            "ServerError",
                            message._0
                          ]);
            
          }
          switch (exit) {
            case 1 :
                if (player === undefined) {
                  return ;
                }
                var game = message._0;
                Curry._1(setScreen, (function (param) {
                        return {
                                TAG: /* InLobbyScreen */0,
                                _0: game
                              };
                      }));
                return Curry._1(setPlayer, (function (param) {
                              return Belt_List.getBy(game.players, (function (p) {
                                            return p.id === player.id;
                                          }));
                            }));
            case 2 :
                if (player === undefined) {
                  return ;
                }
                var game$1 = message._0;
                Curry._1(setScreen, (function (param) {
                        return {
                                TAG: /* InProgressScreen */1,
                                _0: game$1
                              };
                      }));
                return Curry._1(setPlayer, (function (param) {
                              return Belt_List.getBy(game$1.players, (function (p) {
                                            return p.id === player.id;
                                          }));
                            }));
            
          }
        }), [player]);
  var match$2 = UseWs.hook(onMessage);
  var sendMessage = match$2.sendMessage;
  var error = match$2.error;
  var tmp;
  var exit = 0;
  if (typeof screen === "number") {
    if (screen === /* AuthorizationScreen */0) {
      tmp = React.createElement(AuthorizationScreen.make, {
            onMessage: sendMessage
          });
    } else if (player !== undefined) {
      tmp = React.createElement(LobbySetupScreen.make, {
            player: player,
            onMessage: sendMessage
          });
    } else {
      exit = 1;
    }
  } else if (screen.TAG === /* InLobbyScreen */0) {
    if (player !== undefined) {
      tmp = React.createElement(InLobbyScreen.make, {
            game: screen._0,
            onMessage: sendMessage,
            player: player
          });
    } else {
      exit = 1;
    }
  } else if (player !== undefined) {
    tmp = React.createElement(InProgressScreen.make, {
          game: screen._0,
          player: player,
          onMessage: sendMessage
        });
  } else {
    exit = 1;
  }
  if (exit === 1) {
    tmp = React.createElement("div", undefined, Utils.uiStr("unhandled case"));
  }
  return React.createElement("div", {
              className: "w-96 h-128 border rounded-md border-solid border-slate-500"
            }, React.createElement("div", undefined, player !== undefined ? React.createElement("div", undefined, Utils.uiStr("Player: "), React.createElement(PlayerUI.Short.make, {
                            className: "inline-block",
                            player: player
                          })) : Utils.uiStr("No player")), React.createElement("div", undefined, error !== undefined ? React.createElement("div", undefined, Utils.uiStr("error: " + error)) : React.createElement("div", undefined, Utils.uiStr("No error"))), tmp);
}

function $$default(param) {
  var match = React.useState(function () {
        return false;
      });
  var setIsLoaded = match[1];
  var isLoaded = match[0];
  React.useEffect((function () {
          if (!isLoaded) {
            fetch("/api/server").then(function (param) {
                  Curry._1(setIsLoaded, (function (param) {
                          return true;
                        }));
                  return Promise.resolve(1);
                });
          }
          
        }), [isLoaded]);
  if (isLoaded) {
    return React.createElement("div", {
                className: "flex flex-row flex-wrap w-full"
              }, React.createElement(Index$PlayerScreen, {}), React.createElement(Index$PlayerScreen, {}));
  } else {
    return React.createElement("div", undefined, "Loading...");
  }
}

export {
  $$default ,
  $$default as default,
  
}
/* UseWs Not a pure module */
