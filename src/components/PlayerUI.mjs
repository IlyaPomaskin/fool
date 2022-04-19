// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as UiUtils from "../UiUtils.mjs";

function PlayerUI(Props) {
  var classNameOpt = Props.className;
  var player = Props.player;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  return React.createElement("div", {
              className: className
            }, React.createElement("div", undefined, React.createElement("span", {
                      className: "font-bold"
                    }, UiUtils.uiStr(player.id)), UiUtils.uiStr(" (" + player.sessionId + ")")), React.createElement("div", undefined, React.createElement(CardUI.deck, {
                      deck: player.cards
                    })));
}

var make = PlayerUI;

export {
  make ,
  
}
/* react Not a pure module */
