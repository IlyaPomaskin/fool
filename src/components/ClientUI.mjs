// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "./Base.mjs";
import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Table from "../fool/Table.mjs";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";

function ClientUI$Parts$actions(Props) {
  var game = Props.game;
  var player = Props.player;
  var beat = Props.beat;
  var onPass = Props.onPass;
  var onTake = Props.onTake;
  var onBeat = Props.onBeat;
  var isDefender = GameUtils.isDefender(game, player);
  var isPassDisabled = !GameUtils.isCanPass(game, player);
  var isTakeDisabled = !GameUtils.isCanTake(game, player);
  var isBeatDisabled = !isDefender || Belt_Option.isNone(beat[0]) || Belt_Option.isNone(beat[1]);
  return React.createElement("div", {
              className: "grid grid-flow-col gap-1"
            }, React.createElement(Base.Button.make, {
                  disabled: isPassDisabled,
                  pressed: GameUtils.isPassed(game, player),
                  onClick: onPass,
                  children: Utils.uiStr("pass")
                }), React.createElement(Base.Button.make, {
                  disabled: isTakeDisabled,
                  onClick: onTake,
                  children: Utils.uiStr("take")
                }), React.createElement(Base.Button.make, {
                  disabled: isBeatDisabled,
                  onClick: onBeat,
                  children: Utils.uiStr("beat")
                }));
}

function ClientUI$Parts$table(Props) {
  var game = Props.game;
  var player = Props.player;
  var beat = Props.beat;
  var onCardClick = Props.onCardClick;
  var beatBy = beat[1];
  var toBeat = beat[0];
  var isDefender = GameUtils.isDefender(game, player);
  var tmp;
  if (isDefender) {
    var isCardSelected = function (card) {
      return Belt_Option.getWithDefault(Belt_Option.map(toBeat, (function (param) {
                        return Utils.equals(card, param);
                      })), false);
    };
    var isCardDisabled = function (to) {
      return Belt_Option.getWithDefault(Belt_Option.map(beatBy, (function (by) {
                        return !Card.isValidBeat(to, by, game.trump);
                      })), false);
    };
    tmp = React.createElement(CardUI.table, {
          className: "my-1",
          isCardSelected: isCardSelected,
          isCardDisabled: isCardDisabled,
          table: game.table,
          onCardClick: onCardClick
        });
  } else {
    tmp = null;
  }
  return React.createElement("div", {
              className: "mt-1"
            }, tmp);
}

function ClientUI$Parts$deck(Props) {
  var game = Props.game;
  var player = Props.player;
  var beat = Props.beat;
  var onCardClick = Props.onCardClick;
  var beatBy = beat[1];
  var toBeat = beat[0];
  var isDefender = GameUtils.isDefender(game, player);
  var disabled = isDefender ? !Table.hasCards(game.table) : !GameUtils.isPlayerCanMove(game, player);
  var isCardSelected = function (card) {
    return Belt_Option.getWithDefault(Belt_Option.map(beatBy, (function (param) {
                      return Utils.equals(card, param);
                    })), false);
  };
  var isCardDisabled = function (by) {
    return Belt_Option.getWithDefault(Belt_Option.map(toBeat, (function (to) {
                      return !Card.isValidBeat(to, by, game.trump);
                    })), false);
  };
  return React.createElement(CardUI.deck, {
              deck: player.cards,
              disabled: disabled,
              isCardSelected: isCardSelected,
              isCardDisabled: isCardDisabled,
              onCardClick: onCardClick
            });
}

var Parts = {
  actions: ClientUI$Parts$actions,
  table: ClientUI$Parts$table,
  deck: ClientUI$Parts$deck
};

function useBeatCard(game, player) {
  var match = React.useState(function () {
        return [
                undefined,
                undefined
              ];
      });
  var setBeat = match[1];
  var match$1 = match[0];
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
  var isDefender = GameUtils.isDefender(game, player);
  React.useEffect((function () {
          if (!isDefender) {
            Curry._1(setBeat, (function (param) {
                    return [
                            undefined,
                            undefined
                          ];
                  }));
          }
          
        }), [isDefender]);
  return {
          toBeat: match$1[0],
          beatBy: match$1[1],
          setBeat: setBeat,
          handleSelectToBeat: handleSelectToBeat
        };
}

function ClientUI(Props) {
  var classNameOpt = Props.className;
  var player = Props.player;
  var isOwnerOpt = Props.isOwner;
  var game = Props.game;
  var onMove = Props.onMove;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isOwner = isOwnerOpt !== undefined ? isOwnerOpt : false;
  var match = useBeatCard(game, player);
  var handleSelectToBeat = match.handleSelectToBeat;
  var setBeat = match.setBeat;
  var beatBy = match.beatBy;
  var toBeat = match.toBeat;
  var handleBeat = function (param) {
    if (toBeat !== undefined && beatBy !== undefined) {
      Curry._1(setBeat, (function (param) {
              return [
                      undefined,
                      undefined
                    ];
            }));
      return Curry._1(onMove, {
                  TAG: /* Beat */0,
                  _0: toBeat,
                  _1: beatBy
                });
    }
    
  };
  var handleTake = function (param) {
    Curry._1(setBeat, (function (param) {
            return [
                    undefined,
                    undefined
                  ];
          }));
    return Curry._1(onMove, /* Take */0);
  };
  var handleMove = function (card) {
    return Curry._1(onMove, {
                TAG: /* Move */1,
                _0: card
              });
  };
  var handlePass = function (param) {
    return Curry._1(onMove, /* Pass */1);
  };
  var isDefender = GameUtils.isDefender(game, player);
  var match$1 = GameUtils.getPlayerGameState(game, player);
  var tmp;
  switch (match$1) {
    case /* Playing */0 :
        tmp = React.createElement(ClientUI$Parts$deck, {
              game: game,
              player: player,
              beat: [
                toBeat,
                beatBy
              ],
              onCardClick: isDefender ? Curry._1(handleSelectToBeat, false) : handleMove
            });
        break;
    case /* Done */1 :
        tmp = Utils.uiStr("Done");
        break;
    case /* Lose */2 :
        tmp = Utils.uiStr("Lose");
        break;
    case /* Draw */3 :
        tmp = Utils.uiStr("Draw");
        break;
    
  }
  return React.createElement("div", {
              className: Utils.cx([
                    className,
                    "p-1 border rounded-md border-solid border-slate-500"
                  ])
            }, React.createElement("div", {
                  className: "mb-1"
                }, Utils.uiStr("Player: "), React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: player
                    }), Utils.uiStr(isDefender ? " 🛡️" : ""), Utils.uiStr(GameUtils.isAttacker(game, player) ? " 🔪" : "")), tmp, isOwner ? React.createElement(ClientUI$Parts$actions, {
                    game: game,
                    player: player,
                    beat: [
                      toBeat,
                      beatBy
                    ],
                    onPass: handlePass,
                    onTake: handleTake,
                    onBeat: handleBeat
                  }) : null, React.createElement(ClientUI$Parts$table, {
                  game: game,
                  player: player,
                  beat: [
                    toBeat,
                    beatBy
                  ],
                  onCardClick: Curry._1(handleSelectToBeat, true)
                }));
}

var make = ClientUI;

export {
  Parts ,
  useBeatCard ,
  make ,
  
}
/* Base Not a pure module */
