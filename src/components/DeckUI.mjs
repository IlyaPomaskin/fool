// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../utils/Utils.mjs";
import * as React from "react";
import * as CardUI from "./CardUI.mjs";
import * as ReactDnd from "../bindings/ReactDnd.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as ReactDnd$1 from "react-dnd";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

var DragObject = {};

var EmptyDropResult = {};

var CollectedProps = {};

var include = ReactDnd.MakeUseDrag(DragObject, EmptyDropResult, CollectedProps);

function DeckUI$DndWrapper(Props) {
  var card = Props.card;
  var children = Props.children;
  var onDrag = Props.onDrag;
  var match = ReactDnd$1.useDrag({
        type: "card",
        item: card,
        collect: (function (monitor) {
            return {
                    draggedCard: monitor.getItem()
                  };
          })
      }, []);
  var props = match[0];
  React.useEffect((function () {
          Curry._1(onDrag, props.draggedCard);
          
        }), [props.draggedCard]);
  return React.createElement("div", {
              ref: match[1],
              className: Utils.cx(["transition duration-150 ease-in-out"])
            }, children);
}

var DndWrapper_DragSourceMonitor = include.DragSourceMonitor;

var DndWrapper_UseDrag = include.UseDrag;

var DndWrapper = {
  DragObject: DragObject,
  EmptyDropResult: EmptyDropResult,
  CollectedProps: CollectedProps,
  DragSourceMonitor: DndWrapper_DragSourceMonitor,
  UseDrag: DndWrapper_UseDrag,
  make: DeckUI$DndWrapper
};

function DeckUI$hidden(Props) {
  var classNameOpt = Props.className;
  var deck = Props.deck;
  var text = Props.text;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var cardsAmount = Belt_List.length(deck);
  var cardsList = Belt_List.mapWithIndex(Belt_List.keepWithIndex(deck, (function (param, index) {
              return index <= 2;
            })), (function (index, param) {
          return index;
        }));
  var deckText = text !== undefined ? Caml_option.valFromOption(text) : (
      cardsAmount !== 0 ? Utils.uiStr(String(cardsAmount)) : Utils.uiStr("0")
    );
  return React.createElement("div", {
              className: Utils.cx([
                    "relative",
                    className
                  ])
            }, cardsAmount !== 0 ? Utils.uiList(cardsList, (function (index) {
                      var offset = String((index << 1)) + "px";
                      return React.createElement("div", {
                                  key: String(index),
                                  className: index === 0 ? "relative" : "absolute",
                                  style: {
                                    left: offset,
                                    top: offset
                                  }
                                }, React.createElement(CardUI.HiddenCard.make, {}));
                    })) : React.createElement(CardUI.EmptyCard.make, {}), React.createElement("div", {
                  className: "absolute top-1/2 left-1/2 -translate-y-1/2 -translate-x-1/2 text-slate-200"
                }, deckText));
}

function DeckUI(Props) {
  var deck = Props.deck;
  var classNameOpt = Props.className;
  var disabledOpt = Props.disabled;
  var isDraggableOpt = Props.isDraggable;
  var isCardDisabledOpt = Props.isCardDisabled;
  var onDragOpt = Props.onDrag;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var disabled = disabledOpt !== undefined ? disabledOpt : false;
  var isDraggable = isDraggableOpt !== undefined ? isDraggableOpt : false;
  var isCardDisabled = isCardDisabledOpt !== undefined ? isCardDisabledOpt : (function (param) {
        return false;
      });
  var onDrag = onDragOpt !== undefined ? onDragOpt : Utils.noop;
  if (deck) {
    return React.createElement("div", {
                className: Utils.cx([
                      className,
                      "leading flex flex-row gap-1"
                    ])
              }, Utils.uiListWithIndex(deck, (function (index, card) {
                      var key = Card.cardToString(card) + String(index);
                      var disabled$1 = disabled || Curry._1(isCardDisabled, card);
                      if (isDraggable) {
                        return React.createElement(DeckUI$DndWrapper, {
                                    card: card,
                                    children: React.createElement(CardUI.make, {
                                          card: card,
                                          disabled: disabled$1
                                        }),
                                    onDrag: onDrag,
                                    key: key
                                  });
                      } else {
                        return React.createElement(CardUI.make, {
                                    card: card,
                                    disabled: disabled$1,
                                    key: key
                                  });
                      }
                    })));
  } else {
    return React.createElement("div", {
                className: className
              }, Utils.uiStr("No cards in deck"));
  }
}

var hidden = DeckUI$hidden;

var make = DeckUI;

export {
  DndWrapper ,
  hidden ,
  make ,
  
}
/* include Not a pure module */
