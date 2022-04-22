// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as UiUtils from "../UiUtils.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";

function GameUI$InLobbyUI(Props) {
  var game = Props.game;
  return React.createElement("div", undefined, UiUtils.uiStr("inLobby"), React.createElement("br", undefined), React.createElement("br", undefined), UiUtils.uiStr("players:"), React.createElement("br", undefined), React.createElement("div", undefined, UiUtils.uiList(game.players, (function (p) {
                        return React.createElement(PlayerUI.make, {
                                    player: p,
                                    key: p.id
                                  });
                      }))), React.createElement("br", undefined), UiUtils.uiStr("ready:"), React.createElement("br", undefined), React.createElement("div", undefined, UiUtils.uiList(game.ready, (function (p) {
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
  return React.createElement("div", undefined, UiUtils.uiStr("inProgress"), React.createElement("div", undefined, UiUtils.uiStr("deck:")), React.createElement("div", undefined, React.createElement(CardUI.deck, {
                      deck: game.deck
                    })), UiUtils.uiStr("players:"), React.createElement("div", undefined, UiUtils.uiList(game.players, (function (p) {
                        return React.createElement(PlayerUI.make, {
                                    player: p,
                                    onCardClick: (function (c) {
                                        return Curry._1(onMove, {
                                                    TAG: /* Move */3,
                                                    _0: p,
                                                    _1: c
                                                  });
                                      }),
                                    key: p.id
                                  });
                      }))), React.createElement("div", undefined, UiUtils.uiStr("trump:"), React.createElement(CardUI.trump, {
                      suit: game.trump
                    })), React.createElement("div", undefined, UiUtils.uiStr("attacker:"), React.createElement(PlayerUI.Short.make, {
                      player: game.attacker
                    })), React.createElement("div", undefined, UiUtils.uiStr("defender:"), React.createElement(PlayerUI.Short.make, {
                      player: game.defender
                    })), React.createElement("br", undefined), React.createElement("div", undefined, UiUtils.uiStr("table:"), UiUtils.uiList(game.table, (function (param) {
                        var by = param[1];
                        var to = param[0];
                        return React.createElement("div", {
                                    key: Card.cardToString(to) + Belt_Option.getWithDefault(Belt_Option.map(by, Card.cardToString), "a"),
                                    className: "inline-block mx-1"
                                  }, React.createElement(CardUI.CardUILocal.make, {
                                        card: to
                                      }), by !== undefined ? React.createElement(CardUI.CardUILocal.make, {
                                          card: by
                                        }) : React.createElement("div", undefined, UiUtils.uiStr("None")));
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
