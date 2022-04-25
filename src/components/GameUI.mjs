// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../fool/Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as UiUtils from "../UiUtils.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";
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

function GameUI$Button(Props) {
  var disabledOpt = Props.disabled;
  var pressedOpt = Props.pressed;
  var classNameOpt = Props.className;
  var onClickOpt = Props.onClick;
  var children = Props.children;
  var disabled = disabledOpt !== undefined ? disabledOpt : false;
  var pressed = pressedOpt !== undefined ? pressedOpt : false;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var onClick = onClickOpt !== undefined ? onClickOpt : UiUtils.noop;
  return React.createElement("button", {
              className: UiUtils.cx([
                    className,
                    "p-1 border rounded-md border-solid border-slate-500 bg-slate-100 shadow-sm hover:shadow-md",
                    pressed ? UiUtils.selected : "",
                    disabled ? "border-slate-400 text-slate-400 cursor-not-allowed shadow-none hover:shadow-none" : ""
                  ]),
              disabled: disabled,
              onClick: onClick
            }, children);
}

var Button = {
  make: GameUI$Button
};

function GameUI$ClientUI(Props) {
  var classNameOpt = Props.className;
  var player = Props.player;
  var game = Props.game;
  var onMove = Props.onMove;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var match = React.useState(function () {
        return [
                undefined,
                undefined
              ];
      });
  var setBeat = match[1];
  var match$1 = match[0];
  var beatBy = match$1[1];
  var toBeat = match$1[0];
  var handleSelectToBeat = function (isToCard, card) {
    return Curry._1(setBeat, (function (param) {
                  var beatBy = param[1];
                  var toBeat = param[0];
                  if (isToCard) {
                    var isSame = Belt_Option.getWithDefault(Belt_Option.map(toBeat, (function (param) {
                                return Utils.equals(card, param);
                              })), false);
                    if (isSame) {
                      return [
                              undefined,
                              beatBy
                            ];
                    } else {
                      return [
                              card,
                              beatBy
                            ];
                    }
                  }
                  var isSame$1 = Belt_Option.getWithDefault(Belt_Option.map(beatBy, (function (param) {
                              return Utils.equals(card, param);
                            })), false);
                  if (isSame$1) {
                    return [
                            toBeat,
                            undefined
                          ];
                  } else {
                    return [
                            toBeat,
                            card
                          ];
                  }
                }));
  };
  var handleBeat = function (param) {
    if (toBeat !== undefined && beatBy !== undefined) {
      Curry._1(setBeat, (function (param) {
              return [
                      undefined,
                      undefined
                    ];
            }));
      return Curry._1(onMove, {
                  TAG: /* Beat */1,
                  _0: player,
                  _1: toBeat,
                  _2: beatBy
                });
    }
    
  };
  var handleMove = function (card) {
    return Curry._1(onMove, {
                TAG: /* Move */3,
                _0: player,
                _1: card
              });
  };
  var isDef = GameUtils.isDefender(game, player);
  React.useEffect((function () {
          if (!isDef && (Belt_Option.isSome(toBeat) || Belt_Option.isSome(beatBy))) {
            Curry._1(setBeat, (function (param) {
                    return [
                            undefined,
                            undefined
                          ];
                  }));
          }
          
        }), [isDef]);
  var match$2 = GameUtils.isAttacker(game, player);
  return React.createElement("div", {
              className: UiUtils.cx([
                    className,
                    "p-1 border rounded-md border-solid border-slate-500"
                  ])
            }, React.createElement("div", {
                  className: "mb-1"
                }, UiUtils.uiStr("Player: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: player
                    }), isDef ? UiUtils.uiStr(" def") : (
                    match$2 ? UiUtils.uiStr(" att") : null
                  )), GameUtils.isPlayerDone(game, player) ? UiUtils.uiStr("Done!") : React.createElement(CardUI.deck, {
                    deck: player.cards,
                    disabled: isDef ? !GameUtils.isTableHasCards(game) : !GameUtils.isPlayerCanMove(game, player),
                    isCardSelected: (function (card) {
                        return Belt_Option.getWithDefault(Belt_Option.map(beatBy, (function (param) {
                                          return Utils.equals(card, param);
                                        })), false);
                      }),
                    isCardDisabled: (function (by) {
                        if (toBeat !== undefined) {
                          return !Card.isValidTableBeat(toBeat, by, game.trump);
                        } else {
                          return false;
                        }
                      }),
                    onCardClick: isDef ? (function (param) {
                          return handleSelectToBeat(false, param);
                        }) : handleMove
                  }), React.createElement("div", {
                  className: "grid grid-flow-col gap-1"
                }, React.createElement(GameUI$Button, {
                      disabled: !GameUtils.isCanPass(game, player),
                      pressed: GameUtils.isPassed(game, player),
                      onClick: (function (param) {
                          return Curry._1(onMove, {
                                      TAG: /* Pass */2,
                                      _0: player
                                    });
                        }),
                      children: UiUtils.uiStr("pass")
                    }), React.createElement(GameUI$Button, {
                      disabled: !GameUtils.isCanTake(game, player),
                      onClick: (function (param) {
                          return Curry._1(onMove, {
                                      TAG: /* Take */0,
                                      _0: player
                                    });
                        }),
                      children: UiUtils.uiStr("take")
                    }), React.createElement(GameUI$Button, {
                      disabled: !isDef || Belt_Option.isNone(toBeat) || Belt_Option.isNone(beatBy),
                      onClick: handleBeat,
                      children: UiUtils.uiStr("beat")
                    })), React.createElement("div", {
                  className: "mt-1"
                }, isDef ? React.createElement(CardUI.table, {
                        className: "my-1",
                        isCardSelected: (function (card) {
                            return Belt_Option.getWithDefault(Belt_Option.map(toBeat, (function (param) {
                                              return Utils.equals(card, param);
                                            })), false);
                          }),
                        isCardDisabled: (function (to) {
                            if (beatBy !== undefined) {
                              return !Card.isValidTableBeat(to, beatBy, game.trump);
                            } else {
                              return false;
                            }
                          }),
                        table: game.table,
                        onCardClick: (function (param) {
                            return handleSelectToBeat(true, param);
                          })
                      }) : null), React.createElement("div", undefined, UiUtils.uiStr("to: " + Belt_Option.getWithDefault(Belt_Option.map(toBeat, Card.cardToString), "None")), UiUtils.uiStr(" by: " + Belt_Option.getWithDefault(Belt_Option.map(beatBy, Card.cardToString), "None"))));
}

var ClientUI = {
  make: GameUI$ClientUI
};

function GameUI$InProgressUI(Props) {
  var game = Props.game;
  var onMove = Props.onMove;
  return React.createElement("div", undefined, React.createElement("div", undefined, UiUtils.uiStr("Attacker: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: game.attacker
                    })), React.createElement("div", undefined, UiUtils.uiStr("Defender: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: game.defender
                    })), React.createElement("div", undefined, UiUtils.uiList(game.players, (function (p) {
                        return React.createElement("div", {
                                    key: p.id,
                                    className: "inline-block mr-3"
                                  }, React.createElement(PlayerUI.Short.make, {
                                        className: "inline-block",
                                        player: p
                                      }), UiUtils.uiStr(" (" + String(Belt_List.length(p.cards)) + ")"), UiUtils.uiStr(GameUtils.isPassed(game, p) ? " (pass) " : ""), UiUtils.uiStr(GameUtils.isAttacker(game, p) ? " (ATT) " : ""), UiUtils.uiStr(GameUtils.isDefender(game, p) ? " (DEF) " : ""));
                      }))), React.createElement("div", undefined, UiUtils.uiStr("Trump: "), React.createElement(CardUI.trump, {
                      suit: game.trump,
                      className: "inline-block"
                    })), React.createElement("div", undefined, UiUtils.uiStr("Deck: " + String(Belt_List.length(game.deck)))), React.createElement("div", {
                  className: "flex flex-wrap"
                }, UiUtils.uiList(game.players, (function (p) {
                        return React.createElement(GameUI$ClientUI, {
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
  Button ,
  ClientUI ,
  InProgressUI ,
  make ,
  
}
/* react Not a pure module */
