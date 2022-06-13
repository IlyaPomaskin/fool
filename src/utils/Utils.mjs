// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Curry from "rescript/lib/es6/curry.js";
import * as React from "react";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

function cx(names) {
  return Belt_Array.reduce(names, "", (function (acc, c) {
                return acc + " " + c;
              }));
}

function uiList(items, fn) {
  return Belt_Array.map(Belt_List.toArray(items), fn);
}

function uiReverseList(items, fn) {
  return Belt_Array.reverse(Belt_Array.map(Belt_List.toArray(items), fn));
}

function uiListWithIndex(items, fn) {
  return Belt_Array.mapWithIndex(Belt_List.toArray(items), fn);
}

function uiStr(text) {
  return text;
}

function noop(param) {
  
}

function noop2(param, param$1) {
  
}

function noop3(param, param$1, param$2) {
  
}

var equals = Caml_obj.caml_equal;

function toggleListItem(list, item) {
  var hasItem = Belt_List.has(list, item, equals);
  if (hasItem) {
    return Belt_List.keep(list, (function (i) {
                  return !Caml_obj.caml_equal(i, item);
                }));
  } else {
    return Belt_List.add(list, item);
  }
}

function lastListItem(list) {
  return Belt_List.get(list, Belt_List.size(list) - 1 | 0);
}

function findInList(list, fn) {
  return Belt_List.reduce(list, undefined, (function (acc, item) {
                var match = Curry._1(fn, item);
                if (acc !== undefined) {
                  return acc;
                } else if (match) {
                  return Caml_option.some(item);
                } else {
                  return ;
                }
              }));
}

function identity(a) {
  return a;
}

function numbersToEmoji(number) {
  switch (number) {
    case 0 :
        return "0️⃣";
    case 1 :
        return "1️⃣";
    case 2 :
        return "2️⃣";
    case 3 :
        return "3️⃣";
    case 4 :
        return "4️⃣";
    case 5 :
        return "5️⃣";
    case 6 :
        return "6️⃣";
    case 7 :
        return "7️⃣";
    case 8 :
        return "8️⃣";
    case 9 :
        return "9️⃣";
    default:
      return numbersToEmoji(number / 10 | 0) + numbersToEmoji(number % 10);
  }
}

var constructorName = (x => {
        if (x && 'constructor' in x && x.constructor.name) {
          return x.constructor.name;
        } 

        return "";
    });

var Classify = {
  constructorName: constructorName
};

function listIndexOf(list, equalsFn) {
  return Belt_List.reduceWithIndex(list, undefined, (function (acc, item, index) {
                if (Curry._1(equalsFn, item)) {
                  return index;
                } else {
                  return acc;
                }
              }));
}

function isEmpty(list) {
  return Belt_List.length(list) === 0;
}

function useStateValue(initialValue) {
  var match = React.useState(function () {
        return initialValue;
      });
  var setValue = match[1];
  var handleSetValue = React.useCallback((function (nextValue) {
          return Curry._1(setValue, (function (param) {
                        return nextValue;
                      }));
        }), [setValue]);
  return [
          match[0],
          handleSetValue
        ];
}

function getFullUrl(isWsOpt, param) {
  var isWs = isWsOpt !== undefined ? isWsOpt : false;
  var protocol = document.location.protocol;
  var hostname = document.location.hostname;
  var port = document.location.port;
  var protocol$1;
  if (isWs) {
    switch (protocol) {
      case "http:" :
          protocol$1 = "ws:";
          break;
      case "https:" :
          protocol$1 = "wss:";
          break;
      default:
        protocol$1 = protocol;
    }
  } else {
    protocol$1 = protocol;
  }
  return protocol$1 + "//" + hostname + ":" + port;
}

function any(a) {
  return a;
}

var leftRotationClassName = "-rotate-12 -translate-x-1.5";

var rightRotationClassName = "rotate-12 translate-x-1.5";

export {
  cx ,
  uiList ,
  uiReverseList ,
  uiListWithIndex ,
  uiStr ,
  noop ,
  noop2 ,
  noop3 ,
  equals ,
  toggleListItem ,
  lastListItem ,
  findInList ,
  identity ,
  numbersToEmoji ,
  Classify ,
  leftRotationClassName ,
  rightRotationClassName ,
  listIndexOf ,
  isEmpty ,
  useStateValue ,
  getFullUrl ,
  any ,
  
}
/* react Not a pure module */
