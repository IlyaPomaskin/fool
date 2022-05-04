// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "./Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as Belt_List from "rescript/lib/es6/belt_List.js";

function InLobbyScreen(Props) {
  var game = Props.game;
  var onMessage = Props.onMessage;
  var playerId = Props.playerId;
  return React.createElement("div", undefined, React.createElement("div", undefined, Utils.uiStr("Lobby Id: " + game.gameId)), React.createElement(Base.Button.make, {
                  pressed: Belt_List.has(game.ready, playerId, (function (player, id) {
                          return player.id === id;
                        })),
                  onClick: (function (param) {
                      return Curry._1(onMessage, {
                                  TAG: /* Lobby */3,
                                  _0: /* Ready */2,
                                  _1: playerId,
                                  _2: game.gameId
                                });
                    }),
                  children: Utils.uiStr("lobby ready")
                }), React.createElement(Base.Button.make, {
                  onClick: (function (param) {
                      return Curry._1(onMessage, {
                                  TAG: /* Lobby */3,
                                  _0: /* Start */3,
                                  _1: playerId,
                                  _2: game.gameId
                                });
                    }),
                  children: Utils.uiStr("lobby start")
                }));
}

var make = InLobbyScreen;

export {
  make ,
  
}
/* Base Not a pure module */
