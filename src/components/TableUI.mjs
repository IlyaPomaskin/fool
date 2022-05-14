// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as Spring from "bs-react-spring/src/Spring.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as ReactSpring from "react-spring";
import * as ReactBeautifulDnd from "react-beautiful-dnd";

function TableUI$DndBeatableCard(Props) {
  var card = Props.card;
  var isDropDisabled = Props.isDropDisabled;
  var beatByClassName = Props.beatByClassName;
  return React.createElement(ReactBeautifulDnd.Droppable, {
              droppableId: Card.cardToString(card),
              isDropDisabled: Curry._1(isDropDisabled, card),
              direction: "horizontal",
              children: (function (provided, snapshot) {
                  return React.createElement("div", {
                              ref: provided.innerRef,
                              className: Utils.cx([
                                    beatByClassName,
                                    "w-12 h-16"
                                  ])
                            }, React.createElement(CardUI.Base.make, {
                                  className: Utils.cx([snapshot.isDraggingOver ? "bg-pink-200 opacity-50" : ""]),
                                  children: provided.placeholder
                                }), React.createElement("div", undefined));
                })
            });
}

var DndBeatableCard = {
  make: TableUI$DndBeatableCard
};

var TransitionHookBeatBy = Spring.MakeTransition({});

var TransitionHookTableCards = Spring.MakeTransition({});

function TableUI$CardsPair$wAnimation(Props) {
  var to = Props.to;
  var by = Props.by;
  var isDropDisabled = Props.isDropDisabled;
  var beatByClassName = Utils.rightRotationClassName + " absolute left-1 top-1";
  var transitions = ReactSpring.useTransition([by], (function (card) {
          return Belt_Option.getWithDefault(Belt_Option.map(card, Card.cardToString), "");
        }), {
        from: {
          opacity: "0",
          transform: "scale(1.5)"
        },
        enter: {
          opacity: "1",
          transform: "scale(1)"
        },
        leave: {
          opacity: "0",
          transform: "scale(1.5)"
        },
        config: {
          tension: 200
        }
      });
  return React.createElement("div", {
              className: "flex flex-col gap-3 relative"
            }, by !== undefined ? React.createElement(React.Fragment, {
                    children: null
                  }, React.createElement(CardUI.make, {
                        card: to,
                        className: Utils.leftRotationClassName
                      }), Belt_Array.map(transitions, (function (param) {
                          var props = param.props;
                          return React.createElement(Spring.Div.make, {
                                      className: "absolute left-1 top-1",
                                      style: {
                                        opacity: props.opacity,
                                        transform: props.transform
                                      },
                                      children: React.createElement(CardUI.make, {
                                            card: by,
                                            className: Utils.rightRotationClassName
                                          }),
                                      key: param.key
                                    });
                        }))) : React.createElement(React.Fragment, {
                    children: null
                  }, React.createElement(CardUI.make, {
                        card: to,
                        className: Utils.leftRotationClassName
                      }), React.createElement(TableUI$DndBeatableCard, {
                        card: to,
                        isDropDisabled: isDropDisabled,
                        beatByClassName: beatByClassName
                      })));
}

function TableUI$CardsPair$woAnimation(Props) {
  var to = Props.to;
  var by = Props.by;
  var isDropDisabled = Props.isDropDisabled;
  var beatByClassName = Utils.rightRotationClassName + " absolute left-1 top-1";
  return React.createElement("div", {
              className: "flex flex-col gap-3 relative"
            }, by !== undefined ? React.createElement(React.Fragment, {
                    children: null
                  }, React.createElement(CardUI.make, {
                        card: to,
                        className: Utils.leftRotationClassName
                      }), React.createElement("div", {
                        className: beatByClassName
                      }, React.createElement(CardUI.make, {
                            card: by
                          }))) : React.createElement(React.Fragment, {
                    children: null
                  }, React.createElement(CardUI.make, {
                        card: to,
                        className: Utils.leftRotationClassName
                      }), React.createElement(TableUI$DndBeatableCard, {
                        card: to,
                        isDropDisabled: isDropDisabled,
                        beatByClassName: beatByClassName
                      })));
}

var CardsPair = {
  wAnimation: TableUI$CardsPair$wAnimation,
  woAnimation: TableUI$CardsPair$woAnimation
};

function tableCardToKey(param) {
  return Card.cardToString(param[0]);
}

function TableUI(Props) {
  var classNameOpt = Props.className;
  var isDefenderOpt = Props.isDefender;
  var isDropDisabledOpt = Props.isDropDisabled;
  var table = Props.table;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isDefender = isDefenderOpt !== undefined ? isDefenderOpt : false;
  var isDropDisabled = isDropDisabledOpt !== undefined ? isDropDisabledOpt : (function (param) {
        return true;
      });
  var transitions = ReactSpring.useTransition(Belt_Array.reverse(Belt_List.toArray(table)), tableCardToKey, {
        from: {
          opacity: "0",
          transform: "scale(1.5)"
        },
        enter: {
          opacity: "1",
          transform: "scale(1)"
        },
        leave: {
          opacity: "0",
          transform: "scale(1.5)"
        },
        config: {
          tension: 200
        }
      });
  return React.createElement("div", {
              className: Utils.cx([
                    "flex gap-1 flex-row",
                    className
                  ])
            }, Belt_Array.map(transitions, (function (param) {
                    var props = param.props;
                    var match = param.item;
                    var by = match[1];
                    var to = match[0];
                    return React.createElement(Spring.Div.make, {
                                style: {
                                  opacity: props.opacity,
                                  transform: props.transform
                                },
                                children: isDefender ? React.createElement(TableUI$CardsPair$woAnimation, {
                                        to: to,
                                        by: by,
                                        isDropDisabled: isDropDisabled
                                      }) : React.createElement(TableUI$CardsPair$wAnimation, {
                                        to: to,
                                        by: by,
                                        isDropDisabled: isDropDisabled
                                      }),
                                key: param.key
                              });
                  })));
}

var make = TableUI;

export {
  DndBeatableCard ,
  TransitionHookBeatBy ,
  TransitionHookTableCards ,
  CardsPair ,
  tableCardToKey ,
  make ,
  
}
/* TransitionHookBeatBy Not a pure module */
