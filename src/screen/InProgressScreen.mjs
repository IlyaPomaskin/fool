// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as GameUI from "../components/GameUI.mjs";
import * as TableUI from "../components/TableUI.mjs";
import * as ClientUI from "../components/ClientUI.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as ReactBeautifulDnd from "react-beautiful-dnd";

function InProgressScreen$Parts$table(Props) {
  var game = Props.game;
  var player = Props.player;
  var isDefender = GameUtils.isDefender(game, player);
  var match = game.table;
  if (isDefender) {
    return React.createElement(TableUI.make, {
                className: "my-1",
                table: match
              });
  }
  var table = game.table;
  return React.createElement("div", {
              className: "flex flex-row gap-1"
            }, table ? React.createElement(TableUI.make, {
                    className: "my-1",
                    table: table
                  }) : React.createElement("div", {
                    className: Utils.cx(["w-12 h-16 border rounded-md border-solid border-slate-500"])
                  }), React.createElement(ReactBeautifulDnd.Droppable, {
                  droppableId: "table",
                  isDropDisabled: Belt_Result.isError(GameUtils.isValidMove(game, player)),
                  children: (function (provided, snapshot) {
                      return React.createElement("div", {
                                  ref: provided.innerRef,
                                  className: Utils.cx([
                                        "w-full flex flex-row",
                                        snapshot.isDraggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : ""
                                      ])
                                }, provided.placeholder);
                    })
                }));
}

var Parts = {
  table: InProgressScreen$Parts$table
};

function InProgressScreen(Props) {
  var game = Props.game;
  var player = Props.player;
  var onMessage = Props.onMessage;
  var handleDragEnd = function (result, param) {
    console.log("result", result);
    var byCard = Card.stringToCard(result.draggableId);
    var dst = Belt_Option.map(Caml_option.nullable_to_opt(result.destination), (function (d) {
            return d.droppableId;
          }));
    var isTable = Belt_Option.getWithDefault(Belt_Option.map(dst, (function (dst) {
                return dst === "table";
              })), false);
    var toCard = Belt_Option.flatMap(dst, Card.stringToCard);
    if (isTable) {
      if (byCard !== undefined) {
        return Curry._1(onMessage, {
                    TAG: /* Progress */4,
                    _0: {
                      TAG: /* Move */1,
                      _0: byCard
                    },
                    _1: player.id,
                    _2: game.gameId
                  });
      } else {
        console.log("unknown move");
        return ;
      }
    } else if (toCard !== undefined) {
      if (byCard !== undefined) {
        return Curry._1(onMessage, {
                    TAG: /* Progress */4,
                    _0: {
                      TAG: /* Beat */0,
                      _0: toCard,
                      _1: byCard
                    },
                    _1: player.id,
                    _2: game.gameId
                  });
      } else {
        console.log("unknown move");
        return ;
      }
    } else {
      console.log("No destination");
      return ;
    }
  };
  return React.createElement(ReactBeautifulDnd.DragDropContext, {
              onDragEnd: handleDragEnd,
              children: null
            }, React.createElement(GameUI.InProgressUI.make, {
                  game: game
                }), React.createElement("div", {
                  className: "m-1"
                }, React.createElement(InProgressScreen$Parts$table, {
                      game: game,
                      player: player
                    })), React.createElement("div", {
                  className: "flex flex-wrap"
                }, Utils.uiList(game.players, (function (p) {
                        return React.createElement(ClientUI.make, {
                                    className: "m-1 flex flex-col",
                                    player: p,
                                    isOwner: p.id === player.id,
                                    game: game,
                                    onMove: (function (move) {
                                        return Curry._1(onMessage, {
                                                    TAG: /* Progress */4,
                                                    _0: move,
                                                    _1: player.id,
                                                    _2: game.gameId
                                                  });
                                      }),
                                    key: p.id
                                  });
                      }))));
}

var make = InProgressScreen;

export {
  Parts ,
  make ,
  
}
/* react Not a pure module */
