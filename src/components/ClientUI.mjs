// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "./Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Table from "../fool/Table.mjs";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as CardDnd from "./CardDnd.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";

function ClientUI$Parts$actions(Props) {
  var game = Props.game;
  var player = Props.player;
  var onPass = Props.onPass;
  var onTake = Props.onTake;
  var isPassDisabled = !GameUtils.isCanPass(game, player);
  var isPassed = GameUtils.isPassed(game, player);
  var isTakeDisabled = !GameUtils.isCanTake(game, player);
  return React.createElement("div", {
              className: "grid grid-flow-col gap-1"
            }, React.createElement(Base.Switch.make, {
                  disabled: isPassDisabled,
                  checked: isPassed,
                  onClick: onPass,
                  text: "pass"
                }), React.createElement(Base.Button.make, {
                  disabled: isTakeDisabled,
                  onClick: onTake,
                  children: Utils.uiStr("take")
                }));
}

function ClientUI$Parts$table(Props) {
  var game = Props.game;
  var player = Props.player;
  var isDefender = GameUtils.isDefender(game, player);
  return React.createElement("div", {
              className: "mt-1"
            }, isDefender ? React.createElement(CardUI.table, {
                    className: "my-1",
                    table: game.table
                  }) : null);
}

function ClientUI$Parts$deck(Props) {
  var game = Props.game;
  var player = Props.player;
  var isDraggableOpt = Props.isDraggable;
  var isDraggable = isDraggableOpt !== undefined ? isDraggableOpt : false;
  var isDefender = GameUtils.isDefender(game, player);
  var disabled = isDefender ? !Table.hasCards(game.table) : !GameUtils.isPlayerCanMove(game, player);
  return React.createElement(CardUI.deck, {
              deck: player.cards,
              disabled: disabled,
              isDraggable: isDraggable
            });
}

var Parts = {
  actions: ClientUI$Parts$actions,
  table: ClientUI$Parts$table,
  deck: ClientUI$Parts$deck
};

function ClientUI(Props) {
  var classNameOpt = Props.className;
  var player = Props.player;
  var isOwnerOpt = Props.isOwner;
  var game = Props.game;
  var onMove = Props.onMove;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isOwner = isOwnerOpt !== undefined ? isOwnerOpt : false;
  var isDefender = GameUtils.isDefender(game, player);
  var handleReorder = function (result) {
    if (result !== undefined && result.TAG !== /* SameContainer */0) {
      Curry._1(onMove, {
            TAG: /* Beat */0,
            _0: result._1,
            _1: result._0
          });
    } else {
      console.log("unknown", result);
    }
    
  };
  var match = GameUtils.getPlayerGameState(game, player);
  var tmp;
  switch (match) {
    case /* Playing */0 :
        tmp = React.createElement("div", undefined, React.createElement(CardDnd.Cards.DndManager.make, {
                  onReorder: handleReorder,
                  children: null
                }, isOwner ? React.createElement("div", {
                        className: "my-2"
                      }, React.createElement(ClientUI$Parts$actions, {
                            game: game,
                            player: player,
                            onPass: (function (param) {
                                return Curry._1(onMove, /* Pass */1);
                              }),
                            onTake: (function (param) {
                                return Curry._1(onMove, /* Take */0);
                              })
                          })) : null, React.createElement(ClientUI$Parts$deck, {
                      game: game,
                      player: player,
                      isDraggable: true
                    }), React.createElement(ClientUI$Parts$table, {
                      game: game,
                      player: player
                    })));
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
                    }), Utils.uiStr(isDefender ? " 🛡️" : ""), Utils.uiStr(GameUtils.isAttacker(game, player) ? " 🔪" : "")), tmp);
}

var make = ClientUI;

export {
  Parts ,
  make ,
  
}
/* Base Not a pure module */
