// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "./Base.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Table from "../fool/Table.mjs";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as DeckUI from "./DeckUI.mjs";
import * as PlayerUI from "./PlayerUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";

function ClientUI$Parts$actions(Props) {
  var classNameOpt = Props.className;
  var game = Props.game;
  var player = Props.player;
  var onPass = Props.onPass;
  var onTake = Props.onTake;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isPassDisabled = !GameUtils.isCanPass(game, player);
  var isPassed = GameUtils.isPassed(game, player);
  var isTakeDisabled = !GameUtils.isCanTake(game, player);
  var isDefender = GameUtils.isDefender(game, player);
  var isDuel = Belt_List.length(Belt_List.keep(game.players, (function (player) {
              return !GameUtils.isPlayerDone(game, player);
            }))) === 2;
  return React.createElement("div", {
              className: Utils.cx([
                    "grid grid-flow-col gap-1",
                    className
                  ])
            }, isDefender ? React.createElement(Base.Button.make, {
                    disabled: isTakeDisabled,
                    onClick: onTake,
                    children: Utils.uiStr("take")
                  }) : (
                isDuel ? React.createElement(Base.Button.make, {
                        disabled: isPassDisabled,
                        onClick: onPass,
                        children: Utils.uiStr("pass")
                      }) : React.createElement(Base.Switch.make, {
                        disabled: isPassDisabled,
                        checked: isPassed,
                        onClick: onPass,
                        text: "pass"
                      })
              ));
}

function ClientUI$Parts$deck(Props) {
  var game = Props.game;
  var player = Props.player;
  var isDraggableOpt = Props.isDraggable;
  var isDraggable = isDraggableOpt !== undefined ? isDraggableOpt : false;
  var isDefender = GameUtils.isDefender(game, player);
  var disabled = isDefender ? !Table.hasCards(game.table) : !GameUtils.isPlayerCanMove(game, player);
  return React.createElement(DeckUI.make, {
              deck: player.cards,
              disabled: disabled,
              isDraggable: isDraggable
            });
}

var Parts = {
  actions: ClientUI$Parts$actions,
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
  var match = GameUtils.getPlayerGameState(game, player);
  var tmp;
  switch (match) {
    case /* Playing */0 :
        tmp = React.createElement("div", undefined, React.createElement(ClientUI$Parts$deck, {
                  game: game,
                  player: player,
                  isDraggable: isOwner
                }), isOwner ? React.createElement(ClientUI$Parts$actions, {
                    className: "py-2",
                    game: game,
                    player: player,
                    onPass: (function (param) {
                        return Curry._1(onMove, /* Pass */1);
                      }),
                    onTake: (function (param) {
                        return Curry._1(onMove, /* Take */0);
                      })
                  }) : null);
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
