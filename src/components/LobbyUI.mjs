// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "./Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as Belt_List from "rescript/lib/es6/belt_List.js";

function LobbyUI(Props) {
  var game = Props.game;
  var onLobbyMessage = Props.onLobbyMessage;
  var playerId = Props.playerId;
  return React.createElement("div", undefined, React.createElement(Base.Button.make, {
                  onClick: (function (param) {
                      return Curry._1(onLobbyMessage, {
                                  TAG: /* Player */0,
                                  _0: /* Connect */0,
                                  _1: playerId
                                });
                    }),
                  children: Utils.uiStr("create player")
                }), React.createElement(Base.Button.make, {
                  onClick: (function (param) {
                      return Curry._1(onLobbyMessage, {
                                  TAG: /* Lobby */1,
                                  _0: /* Create */0,
                                  _1: playerId,
                                  _2: ""
                                });
                    }),
                  children: Utils.uiStr("create lobby")
                }), React.createElement(Base.Button.make, {
                  onClick: (function (param) {
                      return Curry._1(onLobbyMessage, {
                                  TAG: /* Lobby */1,
                                  _0: /* Enter */1,
                                  _1: playerId,
                                  _2: "gameId"
                                });
                    }),
                  children: Utils.uiStr("lobby connect")
                }), game !== undefined ? React.createElement("div", undefined, React.createElement(Base.Button.make, {
                        pressed: Belt_List.has(game.ready, playerId, (function (player, id) {
                                return player.id === id;
                              })),
                        onClick: (function (param) {
                            return Curry._1(onLobbyMessage, {
                                        TAG: /* Lobby */1,
                                        _0: /* Ready */2,
                                        _1: playerId,
                                        _2: game.gameId
                                      });
                          }),
                        children: Utils.uiStr("lobby ready")
                      }), React.createElement(Base.Button.make, {
                        onClick: (function (param) {
                            return Curry._1(onLobbyMessage, {
                                        TAG: /* Lobby */1,
                                        _0: /* Start */3,
                                        _1: playerId,
                                        _2: game.gameId
                                      });
                          }),
                        children: Utils.uiStr("lobby start")
                      })) : null);
}

var make = LobbyUI;

export {
  make ,
  
}
/* Base Not a pure module */
