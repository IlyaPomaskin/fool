// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as CardDnd from "./CardDnd.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";

function TableUI(Props) {
  var classNameOpt = Props.className;
  var isCardSelectedOpt = Props.isCardSelected;
  var isCardDisabledOpt = Props.isCardDisabled;
  var table = Props.table;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isCardSelected = isCardSelectedOpt !== undefined ? isCardSelectedOpt : (function (param) {
        return false;
      });
  var isCardDisabled = isCardDisabledOpt !== undefined ? isCardDisabledOpt : (function (param) {
        return false;
      });
  return React.createElement("div", {
              className: Utils.cx([
                    "flex gap-1 flex-row",
                    className
                  ])
            }, Utils.uiList(table, (function (param) {
                    var by = param[1];
                    var to = param[0];
                    var isDisabled = Belt_Option.isSome(by) || Curry._1(isCardDisabled, to);
                    return React.createElement("div", {
                                key: Card.cardToString(to) + Belt_Option.getWithDefault(Belt_Option.map(by, Card.cardToString), ""),
                                className: "relative"
                              }, by !== undefined ? React.createElement("div", {
                                      className: "flex flex-col gap-1"
                                    }, React.createElement(CardUI.make, {
                                          card: to,
                                          disabled: true
                                        }), React.createElement(CardUI.make, {
                                          card: by,
                                          className: "absolute opacity-0.5",
                                          disabled: true
                                        })) : React.createElement("div", {
                                      className: "flex flex-col gap-1"
                                    }, React.createElement(CardUI.make, {
                                          card: to,
                                          disabled: isDisabled,
                                          selected: Curry._1(isCardSelected, to)
                                        }), React.createElement(CardDnd.Cards.DroppableContainer.make, {
                                          id: /* ToCard */{
                                            _0: to
                                          },
                                          axis: /* Y */1,
                                          lockAxis: true,
                                          accept: (function (param) {
                                              return true;
                                            }),
                                          className: (function (draggingOver) {
                                              return Utils.cx([
                                                          "top-0",
                                                          "left-0",
                                                          "w-12 h-16",
                                                          draggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : ""
                                                        ]);
                                            }),
                                          children: React.createElement("div", {
                                                className: Utils.cx([
                                                      "w-12 h-16",
                                                      "inline-block",
                                                      "transform-x-[-100%]",
                                                      "border rounded-md border-solid border-slate-500"
                                                    ])
                                              })
                                        })));
                  })));
}

var make = TableUI;

export {
  make ,
  
}
/* react Not a pure module */
