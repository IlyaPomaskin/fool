// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../utils/Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";

function StackUI$Stack(Props) {
  var classNameOpt = Props.className;
  var deck = Props.deck;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var cardsAmount = Belt_List.length(deck);
  var cardsList = Belt_List.mapWithIndex(Belt_List.keepWithIndex(deck, (function (param, index) {
              return index <= 2;
            })), (function (index, param) {
          return index;
        }));
  var deckText = cardsAmount !== 0 ? Utils.uiStr(String(cardsAmount)) : Utils.uiStr("0");
  return React.createElement("div", {
              className: Utils.cx([
                    "relative",
                    className
                  ])
            }, cardsAmount !== 0 ? Utils.uiList(cardsList, (function (index) {
                      var offset = String((index << 1)) + "px";
                      return React.createElement("div", {
                                  key: offset,
                                  className: index === 0 ? "relative" : "absolute",
                                  style: {
                                    left: offset,
                                    top: offset
                                  }
                                }, React.createElement(CardUI.HiddenCard.make, {
                                      className: "flex items-center justify-center text-slate-200",
                                      children: deckText
                                    }));
                    })) : React.createElement(CardUI.EmptyCard.make, {}));
}

var Stack = {
  make: StackUI$Stack
};

function StackUI$deck(Props) {
  var deck = Props.deck;
  var trump = Props.trump;
  var trumpCard = Utils.lastListItem(deck);
  if (trumpCard !== undefined) {
    if (trumpCard) {
      return React.createElement("div", {
                  className: "relative flex h-min"
                }, React.createElement(StackUI$Stack, {
                      className: "z-10",
                      deck: deck
                    }), React.createElement("div", {
                      className: "z-0 relative top-1 -left-2 rotate-90"
                    }, React.createElement(CardUI.VisibleCard.make, CardUI.VisibleCard.makeProps(trumpCard._0, undefined, undefined, undefined, undefined))));
    } else {
      return React.createElement("div", undefined, React.createElement(StackUI$Stack, {
                      deck: deck
                    }), React.createElement(CardUI.trump, {
                      suit: trump
                    }));
    }
  } else {
    return React.createElement(CardUI.EmptyCard.make, {
                className: "flex items-center justify-center",
                children: React.createElement(CardUI.trump, {
                      suit: trump
                    })
              });
  }
}

function StackUI$opponent(Props) {
  var deck = Props.deck;
  return React.createElement(StackUI$Stack, {
              deck: deck
            });
}

var deck = StackUI$deck;

var opponent = StackUI$opponent;

export {
  Stack ,
  deck ,
  opponent ,
  
}
/* Utils Not a pure module */
