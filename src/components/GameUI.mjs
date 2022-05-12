// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
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
  var card = Utils.lastListItem(game.deck);
  return React.createElement("div", undefined, React.createElement("div", {
                  className: "my-2"
                }, Utils.uiList(game.players, (function (p) {
                        return React.createElement("div", {
                                    key: p.id,
                                    className: "inline-block mr-4"
                                  }, React.createElement("div", {
                                        className: "grid grid-flow-col gap-1"
                                      }, React.createElement(PlayerUI.Short.make, {
                                            className: "inline-block",
                                            player: p
                                          }), React.createElement("div", undefined, Utils.uiStr(Utils.numbersToEmoji(Belt_List.length(p.cards)))), GameUtils.isPassed(game, p) ? React.createElement("div", undefined, Utils.uiStr("⏩")) : null, GameUtils.isAttacker(game, p) ? React.createElement("div", undefined, Utils.uiStr("🔪")) : null, GameUtils.isDefender(game, p) ? React.createElement("div", undefined, Utils.uiStr("🛡️")) : null));
                      }))), React.createElement("div", {
                  className: "my-2"
                }, React.createElement("div", undefined, Utils.uiStr("Deck: " + Utils.numbersToEmoji(Belt_List.length(game.deck))), React.createElement("span", {
                          className: "mx-1"
                        }), card !== undefined ? React.createElement(CardUI.Short.make, {
                            card: card
                          }) : React.createElement(CardUI.trump, {
                            suit: game.trump,
                            className: "inline-block"
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
