// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "../components/Base.mjs";
import * as Card from "../fool/Card.mjs";
import * as Game from "../fool/Game.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Table from "../fool/Table.mjs";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as CardUI from "../components/CardUI.mjs";
import * as DeckUI from "../components/DeckUI.mjs";
import * as Player from "../fool/Player.mjs";
import * as TableUI from "../components/TableUI.mjs";
import * as PlayerUI from "../components/PlayerUI.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as ReactBeautifulDnd from "react-beautiful-dnd";

function InProgressScreen$PlayerActionsUI(Props) {
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

var PlayerActionsUI = {
  make: InProgressScreen$PlayerActionsUI
};

function InProgressScreen$PlayerTableUI(Props) {
  var game = Props.game;
  var draggedCard = Props.draggedCard;
  var player = Props.player;
  var isDefender = GameUtils.isDefender(game, player);
  var draggedCard$1 = Utils.toResult(draggedCard, "No card");
  return React.createElement("div", {
              className: "relative"
            }, React.createElement(ReactBeautifulDnd.Droppable, {
                  droppableId: "table",
                  isDropDisabled: isDefender || Belt_Result.isError(Belt_Result.flatMap(draggedCard$1, (function (card) {
                              return Game.isValidMove(game, player, card);
                            }))),
                  direction: "horizontal",
                  children: (function (provided, snapshot) {
                      var container = React.createElement("div", {
                            ref: provided.innerRef,
                            className: Utils.cx([
                                  "w-full flex flex-row bg-pink-200",
                                  snapshot.isDraggingOver ? "bg-gradient-to-tl from-purple-200 to-pink-200 opacity-70" : "opacity-100"
                                ])
                          }, React.createElement(TableUI.make, {
                                className: "my-1 h-16",
                                isDefender: isDefender,
                                isDropDisabled: (function (toCard) {
                                    if (isDefender) {
                                      return Belt_Result.isError(Belt_Result.flatMap(draggedCard$1, (function (byCard) {
                                                        return Game.isValidBeat(game, player, toCard, byCard);
                                                      })));
                                    } else {
                                      return true;
                                    }
                                  }),
                                table: game.table,
                                placeholder: provided.placeholder
                              }));
                      return React.cloneElement(container, provided.droppableProps);
                    })
                }));
}

var PlayerTableUI = {
  make: InProgressScreen$PlayerTableUI
};

function InProgressScreen$ClientUI(Props) {
  var classNameOpt = Props.className;
  var player = Props.player;
  var game = Props.game;
  var onMessage = Props.onMessage;
  var className = classNameOpt !== undefined ? classNameOpt : "";
  var isDefender = GameUtils.isDefender(game, player);
  var isThereCardsOnTable = Table.hasCards(game.table);
  var isPlayerCanMove = GameUtils.isPlayerCanMove(game, player);
  var isDeckEnabled = isDefender ? isThereCardsOnTable : isPlayerCanMove;
  var onMove = function (move) {
    return Curry._1(onMessage, {
                TAG: /* Progress */4,
                _0: move,
                _1: player.id,
                _2: game.gameId
              });
  };
  var match = GameUtils.getPlayerGameState(game, player);
  var tmp;
  switch (match) {
    case /* Playing */0 :
        tmp = Utils.uiStr("Playing");
        break;
    case /* Won */1 :
        tmp = Utils.uiStr("Won");
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
            }, tmp, React.createElement("div", undefined, React.createElement(DeckUI.make, {
                      deck: player.cards,
                      disabled: !isDeckEnabled,
                      isDraggable: true
                    }), React.createElement(InProgressScreen$PlayerActionsUI, {
                      className: "py-2",
                      game: game,
                      player: player,
                      onPass: (function (param) {
                          return onMove(/* Pass */1);
                        }),
                      onTake: (function (param) {
                          return onMove(/* Take */0);
                        })
                    })));
}

var ClientUI = {
  make: InProgressScreen$ClientUI
};

function InProgressScreen$OpponentUI(Props) {
  var player = Props.player;
  var className = Props.className;
  var isDefender = Props.isDefender;
  var isAttacker = Props.isAttacker;
  return React.createElement("div", {
              className: Utils.cx([
                    "flex flex-col gap-2",
                    className
                  ])
            }, React.createElement(DeckUI.hidden, {
                  deck: player.cards
                }), React.createElement("div", {
                  className: "vertial-align"
                }, React.createElement(PlayerUI.Short.make, {
                      className: "inline-block",
                      player: player
                    }), Utils.uiStr(isDefender ? " 🛡️" : ""), Utils.uiStr(isAttacker ? " 🔪" : "")));
}

var OpponentUI = {
  make: InProgressScreen$OpponentUI
};

function useOptimisticGame(game, player, onMessage) {
  var match = React.useState(function () {
        return game;
      });
  var setOptimisticGame = match[1];
  React.useEffect((function () {
          Curry._1(setOptimisticGame, (function (param) {
                  return game;
                }));
          
        }), [game]);
  var handleOptimisticMessage = function (msg) {
    if (msg.TAG === /* Progress */4) {
      var move = msg._0;
      Curry._1(setOptimisticGame, (function (prevGame) {
              return Belt_Result.getWithDefault(Game.dispatch(prevGame, player, move), prevGame);
            }));
    }
    return Curry._1(onMessage, msg);
  };
  return [
          match[0],
          handleOptimisticMessage
        ];
}

function InProgressScreen(Props) {
  var realGame = Props.game;
  var player = Props.player;
  var onMessage = Props.onMessage;
  var match = useOptimisticGame(realGame, player, onMessage);
  var handleOptimisticMessage = match[1];
  var game = match[0];
  var match$1 = React.useState(function () {
        
      });
  var setDraggedCard = match$1[1];
  var handleDragStart = function (beforeCapture, param) {
    return Curry._1(setDraggedCard, (function (param) {
                  return Card.stringToCard(beforeCapture.draggableId);
                }));
  };
  var handleDragEnd = function (result, param) {
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
        Curry._1(handleOptimisticMessage, {
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
      }
    } else if (toCard !== undefined) {
      if (byCard !== undefined) {
        Curry._1(handleOptimisticMessage, {
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
      }
    } else {
      console.log("No destination");
    }
    return Curry._1(setDraggedCard, (function (param) {
                  
                }));
  };
  var reorderedPlayers = Belt_Option.getWithDefault(Belt_Option.map(Belt_Option.map(Belt_Option.flatMap(Utils.listIndexOf(game.players, (function (item) {
                          return Player.equals(item, player);
                        })), (function (index) {
                      return Belt_List.splitAt(game.players, index);
                    })), (function (param) {
                  return Belt_List.concat(param[1], param[0]);
                })), (function (players) {
              return Belt_List.keep(players, (function (p) {
                            return !Player.equals(p, player);
                          }));
            })), game.players);
  var trumpCard = Utils.lastListItem(game.deck);
  return React.createElement("div", undefined, React.createElement("div", {
                  className: "flex"
                }, React.createElement("div", {
                      className: "flex m-2 flex-row"
                    }, trumpCard !== undefined ? (
                        trumpCard ? React.createElement("div", {
                                className: "relative flex h-min"
                              }, React.createElement(DeckUI.hidden, {
                                    className: "z-10",
                                    deck: game.deck
                                  }), React.createElement("div", {
                                    className: "z-0 relative top-1 -left-2 rotate-90"
                                  }, React.createElement(CardUI.VisibleCard.make, CardUI.VisibleCard.makeProps(trumpCard._0, undefined, undefined, undefined, undefined)))) : React.createElement("div", undefined, React.createElement(DeckUI.hidden, {
                                    deck: game.deck
                                  }), React.createElement(CardUI.trump, {
                                    suit: game.trump
                                  }))
                      ) : React.createElement(CardUI.EmptyCard.make, {
                            children: React.createElement(CardUI.trump, {
                                  suit: game.trump
                                })
                          })), React.createElement("div", {
                      className: "flex m-2 w-full justify-evenly"
                    }, Utils.uiList(reorderedPlayers, (function (player) {
                            return React.createElement(InProgressScreen$OpponentUI, {
                                        player: player,
                                        className: "m-1 flex flex-col",
                                        isDefender: GameUtils.isDefender(game, player),
                                        isAttacker: GameUtils.isAttacker(game, player),
                                        key: player.id
                                      });
                          })))), React.createElement(ReactBeautifulDnd.DragDropContext, {
                  onDragStart: handleDragStart,
                  onDragEnd: handleDragEnd,
                  children: null
                }, React.createElement("div", {
                      className: "m-1"
                    }, React.createElement(InProgressScreen$PlayerTableUI, {
                          game: game,
                          draggedCard: match$1[0],
                          player: player
                        })), React.createElement(InProgressScreen$ClientUI, {
                      className: "m-1 flex flex-col",
                      player: player,
                      game: game,
                      onMessage: handleOptimisticMessage
                    })));
}

var make = InProgressScreen;

export {
  PlayerActionsUI ,
  PlayerTableUI ,
  ClientUI ,
  OpponentUI ,
  useOptimisticGame ,
  make ,
  
}
/* Base Not a pure module */
