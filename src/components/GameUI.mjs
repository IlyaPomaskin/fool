// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as ClientUI from "./ClientUI.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";

function GameUI$InLobbyUI(Props) {
  var game = Props.game;
  return React.createElement("div", undefined, Utils.uiStr("inLobby"), React.createElement("br", undefined), React.createElement("br", undefined), Utils.uiStr("players:"), React.createElement("br", undefined), React.createElement("div", undefined, Utils.uiList(game.players, (function (p) {
                        return React.createElement(PlayerUI.make, {
                                    player: p,
                                    key: p.id
                                  });
                      }))), React.createElement("br", undefined), Utils.uiStr("ready:"), React.createElement("br", undefined), React.createElement("div", undefined, Utils.uiList(game.ready, (function (p) {
                        return React.createElement(PlayerUI.make, {
                                    player: p,
                                    key: p.id
                                  });
                      }))));
}

var InLobbyUI = {
  make: GameUI$InLobbyUI
};

function GameUI$InProgressUI(Props) {
  var game = Props.game;
  var onMove = Props.onMove;
  return React.createElement("div", undefined, React.createElement("div", undefined, Utils.uiStr("Attacker: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: game.attacker
                    })), React.createElement("div", undefined, Utils.uiStr("Defender: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: game.defender
                    })), React.createElement("div", undefined, Utils.uiList(game.players, (function (p) {
                        return React.createElement("div", {
                                    key: p.id,
                                    className: "inline-block mr-3"
                                  }, React.createElement(PlayerUI.Short.make, {
                                        className: "inline-block",
                                        player: p
                                      }), Utils.uiStr(" (" + String(Belt_List.length(p.cards)) + ")"), Utils.uiStr(GameUtils.isPassed(game, p) ? " (pass) " : ""), Utils.uiStr(GameUtils.isAttacker(game, p) ? " (ATT) " : ""), Utils.uiStr(GameUtils.isDefender(game, p) ? " (DEF) " : ""));
                      }))), React.createElement("div", undefined, Utils.uiStr("Trump: "), React.createElement(CardUI.trump, {
                      suit: game.trump,
                      className: "inline-block"
                    })), React.createElement("div", undefined, Utils.uiStr("Deck: " + String(Belt_List.length(game.deck)))), React.createElement("div", {
                  className: "flex flex-wrap"
                }, Utils.uiList(game.players, (function (p) {
                        return React.createElement(ClientUI.make, {
                                    className: "m-1 flex-initial w-96",
                                    player: p,
                                    game: game,
                                    onMove: onMove,
                                    key: p.id
                                  });
                      }))));
}

var InProgressUI = {
  make: GameUI$InProgressUI
};

function GameUI(Props) {
  var game = Props.game;
  if (game.TAG === /* InLobby */0) {
    return React.createElement(GameUI$InLobbyUI, {
                game: game._0
              });
  } else {
    return React.createElement("div", undefined);
  }
}

var make = GameUI;

export {
  InLobbyUI ,
  InProgressUI ,
  make ,
  
}
/* react Not a pure module */
