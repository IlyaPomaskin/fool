// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "../components/Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

function InLobbyScreen(Props) {
  var game = Props.game;
  var onMessage = Props.onMessage;
  var player = Props.player;
  var isCanStart = Belt_Result.isOk(GameUtils.isCanStart(game, player));
  return React.createElement("div", {
              className: "m-2"
            }, React.createElement(Base.Heading.make, {
                  size: /* H5 */3,
                  children: Utils.uiStr("Lobby Id: " + game.gameId)
                }), React.createElement(Base.Switch.make, {
                  checked: Belt_List.has(game.ready, player.id, (function (player, id) {
                          return player.id === id;
                        })),
                  onClick: (function (param) {
                      return Curry._1(onMessage, {
                                  TAG: /* Lobby */3,
                                  _0: /* Ready */2,
                                  _1: player.id,
                                  _2: game.gameId
                                });
                    }),
                  text: "Ready?",
                  className: "my-2"
                }), React.createElement(Base.Button.make, {
                  disabled: !isCanStart,
                  onClick: (function (param) {
                      return Curry._1(onMessage, {
                                  TAG: /* Lobby */3,
                                  _0: /* Start */3,
                                  _1: player.id,
                                  _2: game.gameId
                                });
                    }),
                  children: Utils.uiStr("Start")
                }));
}

var make = InLobbyScreen;

export {
  make ,
  
}
/* Base Not a pure module */