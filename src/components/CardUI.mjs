// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

function suitToString(suit) {
  switch (suit) {
    case /* Spades */0 :
        return "♤";
    case /* Hearts */1 :
        return "♡";
    case /* Diamonds */2 :
        return "♢";
    case /* Clubs */3 :
        return "♧";
    
  }
}

function rankToString(rank) {
  switch (rank) {
    case /* Six */0 :
        return "6";
    case /* Seven */1 :
        return "7";
    case /* Eight */2 :
        return "8";
    case /* Nine */3 :
        return "9";
    case /* Ten */4 :
        return "10";
    case /* Jack */5 :
        return "J";
    case /* Queen */6 :
        return "Q";
    case /* King */7 :
        return "K";
    case /* Ace */8 :
        return "A";
    
  }
}

function suitToColor(suit) {
  switch (suit) {
    case /* Hearts */1 :
    case /* Diamonds */2 :
        return "text-red-900 dark:text-red-600";
    case /* Spades */0 :
    case /* Clubs */3 :
        return "text-slate-500";
    
  }
}

function CardUI$Short(Props) {
  var classNameOpt = Props.className;
  var card = Props.card;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  if (!card) {
    return React.createElement("span", {
                className: className
              }, Utils.uiStr("Hidden"));
  }
  var match = card._0;
  var suit = match[0];
  return React.createElement("span", {
              className: Utils.cx([
                    className,
                    suitToColor(suit)
                  ])
            }, Utils.uiStr(suitToString(suit) + rankToString(match[1])));
}

var Short = {
  make: CardUI$Short
};

function CardUI$Base(Props) {
  var classNameOpt = Props.className;
  var disabledOpt = Props.disabled;
  var children = Props.children;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var disabled = disabledOpt !== undefined ? disabledOpt : false;
  return React.createElement("div", {
              className: Utils.cx([
                    "relative w-12 h-16",
                    "border rounded-md border-solid border-slate-500",
                    "select-none",
                    disabled ? "border-slate-400" : "",
                    className
                  ])
            }, children !== undefined ? Caml_option.valFromOption(children) : null);
}

var Base = {
  make: CardUI$Base
};

function makeProps(card, classNameOpt, disabledOpt, param, param$1) {
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var disabled = disabledOpt !== undefined ? disabledOpt : false;
  return {
          className: className,
          disabled: disabled,
          card: card
        };
}

function make(props) {
  var className = props.className;
  var disabled = props.disabled;
  var card = props.card;
  return React.createElement(CardUI$Base, {
              className: Utils.cx([
                    className,
                    disabled ? "text-slate-400" : suitToColor(card[0]),
                    "overflow-hidden",
                    "font-bold text-[16px] leading-[16px] "
                  ]),
              disabled: disabled,
              children: null
            }, React.createElement("div", {
                  className: "absolute w-full h-full bg-gradient-to-tl from-purple-200 to-pink-200 "
                }), React.createElement("div", {
                  className: "flex flex-col gap-0.5 absolute top-1 left-1 "
                }, React.createElement("div", {
                      className: "text-center"
                    }, Utils.uiStr(suitToString(card[0]))), React.createElement("div", {
                      className: "text-center"
                    }, Utils.uiStr(rankToString(card[1])))));
}

var VisibleCard = {
  makeProps: makeProps,
  make: make
};

function CardUI$HiddenCard(Props) {
  var classNameOpt = Props.className;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  return React.createElement(CardUI$Base, {
              className: Utils.cx([
                    className,
                    "overflow-hidden"
                  ]),
              children: React.createElement("div", {
                    className: "absolute w-full h-full bg-gradient-to-tl from-purple-500 to-pink-500 bg-opacity-50"
                  })
            });
}

var HiddenCard = {
  make: CardUI$HiddenCard
};

function CardUI$EmptyCard(Props) {
  var classNameOpt = Props.className;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  return React.createElement(CardUI$Base, {
              className: Utils.cx([
                    className,
                    "overflow-hidden"
                  ])
            });
}

var EmptyCard = {
  make: CardUI$EmptyCard
};

function CardUI(Props) {
  var card = Props.card;
  var classNameOpt = Props.className;
  var disabledOpt = Props.disabled;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var disabled = disabledOpt !== undefined ? disabledOpt : false;
  if (card) {
    return React.createElement(make, makeProps(card._0, className, disabled, undefined, undefined));
  } else {
    return React.createElement(CardUI$HiddenCard, {
                className: className
              });
  }
}

function CardUI$trump(Props) {
  var suit = Props.suit;
  var classNameOpt = Props.className;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  return React.createElement("div", {
              className: Utils.cx([
                    className,
                    suitToColor(suit)
                  ])
            }, Utils.uiStr(suitToString(suit)));
}

var make$1 = CardUI;

var trump = CardUI$trump;

export {
  suitToString ,
  rankToString ,
  suitToColor ,
  Short ,
  Base ,
  VisibleCard ,
  HiddenCard ,
  EmptyCard ,
  make$1 as make,
  trump ,
  
}
/* react Not a pure module */
