// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "../Log.mjs";
import * as Card from "./Card.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Table from "./Table.mjs";
import * as Utils from "../Utils.mjs";
import * as Player from "./Player.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

function isDefender(game, player) {
  return game.defender === player.id;
}

function isAttacker(game, player) {
  return game.attacker === player.id;
}

function isPlayerHasCard(player, card) {
  return Belt_List.has(player.cards, card, Card.isEquals);
}

function isCorrectAdditionalCard(game, card) {
  return Belt_List.has(Table.getFlatCards(game.table), card, Card.isEqualsByRank);
}

function isPlayerCanMove(game, player) {
  if (Table.hasCards(game.table)) {
    if (isDefender(game, player)) {
      return false;
    } else {
      return true;
    }
  } else {
    return isAttacker(game, player);
  }
}

function getTrump(deck, players) {
  var lastCard = Utils.lastListItem(deck);
  var lastPlayer = Utils.lastListItem(Belt_List.keep(players, (function (p) {
              return Belt_List.length(p.cards) !== 0;
            })));
  if (lastCard !== undefined) {
    if (lastCard) {
      return lastCard._0[0];
    } else {
      return ;
    }
  } else if (lastPlayer !== undefined) {
    return Belt_Option.flatMap(Utils.lastListItem(lastPlayer.cards), (function (card) {
                  if (card) {
                    return card._0[0];
                  }
                  
                }));
  } else {
    return ;
  }
}

function isPlayerDone(game, player) {
  if (Utils.isEmpty(game.deck)) {
    return Utils.isEmpty(player.cards);
  } else {
    return false;
  }
}

function isPlayerLose(game, player) {
  var playersWithCards = Belt_List.keep(game.players, (function (p) {
          return Belt_List.length(p.cards) > 0;
        }));
  var isOnlyOnePlayerLeft = Belt_List.length(playersWithCards) === 1;
  var isCurrentPlayerLeft = Belt_List.has(game.players, player, Utils.equals);
  if (isOnlyOnePlayerLeft) {
    return isCurrentPlayerLeft;
  } else {
    return false;
  }
}

function isCanTake(game, player) {
  if (isDefender(game, player) && Table.hasCards(game.table)) {
    return !Table.isAllBeaten(game.table);
  } else {
    return false;
  }
}

function isCanPass(game, player) {
  if (Table.hasCards(game.table)) {
    return !isDefender(game, player);
  } else {
    return false;
  }
}

function isPassed(game, playerId) {
  var inPassedList = Belt_List.has(game.pass, playerId, Utils.equals);
  var hasCards = Belt_Option.getWithDefault(Belt_Option.map(Player.getById(game.players, playerId), (function (p) {
              return !Utils.isEmpty(p.cards);
            })), true);
  if (hasCards) {
    return inPassedList;
  } else {
    return true;
  }
}

function isAllPassed(game) {
  return Belt_List.every(Belt_List.keep(game.players, (function (p) {
                    return !isDefender(game, p);
                  })), (function (p) {
                return isPassed(game, p.id);
              }));
}

function isPlayerCanBeat(game, player) {
  var isThereCardsOnTable = !Utils.isEmpty(game.table);
  var unbeatedCards = Table.getUnbeatedCards(game.table);
  var isSameAmountOfCards = Belt_List.length(unbeatedCards) === Belt_List.length(player.cards);
  var canBeatEveryCard = Belt_List.every(unbeatedCards, (function (toCard) {
          return Belt_List.some(player.cards, (function (byCard) {
                        return Card.isValidBeat(toCard, byCard, game.trump);
                      }));
        }));
  if (isThereCardsOnTable && isSameAmountOfCards) {
    return canBeatEveryCard;
  } else {
    return false;
  }
}

function getPlayerGameState(game, player) {
  var isPlayerHasCards = !Utils.isEmpty(player.cards);
  var isThereCardsInDeck = !Utils.isEmpty(game.deck);
  var hasCardsForRound = isPlayerHasCards || isThereCardsInDeck;
  var otherPlayersWithCardsAmount = Belt_List.length(Belt_List.keep(Belt_List.keep(game.players, (function (p) {
                  return !Utils.equals(p, player);
                })), (function (p) {
              return !Utils.isEmpty(p.cards);
            })));
  var isThereArePlayersWithCards = otherPlayersWithCardsAmount > 0;
  if (hasCardsForRound) {
    if (isThereArePlayersWithCards || isPlayerCanBeat(game, player)) {
      return /* Playing */0;
    } else {
      return /* Lose */2;
    }
  } else if (isThereArePlayersWithCards) {
    return /* Won */1;
  } else {
    return /* Draw */3;
  }
}

function findPlayerById(game, playerId) {
  return Belt_List.getBy(game.players, (function (p) {
                return p.id === playerId;
              }));
}

function isOwner(game, player) {
  return Belt_Option.getWithDefault(Belt_Option.map(Belt_List.get(game.players, Belt_List.length(game.players) - 1 | 0), (function (p) {
                    return p.id === player.id;
                  })), false);
}

function isCanStart(game, player) {
  var isEnoughPlayers = Belt_List.length(game.players) > 1;
  var isAllPlayersAreReady = Belt_List.length(game.players) === Belt_List.length(game.ready);
  var isOwner$1 = isOwner(game, player);
  if (isOwner$1) {
    if (isEnoughPlayers) {
      if (isAllPlayersAreReady) {
        return {
                TAG: /* Ok */0,
                _0: game
              };
      } else {
        return {
                TAG: /* Error */1,
                _0: "Not all players are ready"
              };
      }
    } else {
      return {
              TAG: /* Error */1,
              _0: "Not enough players"
            };
    }
  } else {
    return {
            TAG: /* Error */1,
            _0: "Only owner can start game"
          };
  }
}

function getGameId(game) {
  if (game.TAG === /* InLobby */0) {
    return game._0.gameId;
  } else {
    return game._0.gameId;
  }
}

function mapLobby(game, fn) {
  if (game.TAG === /* InLobby */0) {
    return {
            TAG: /* InLobby */0,
            _0: Curry._1(fn, game._0)
          };
  }
  var g = game._0;
  Log.info([
        "Try to map InProgress with mapLobby",
        g.gameId
      ]);
  return {
          TAG: /* InProgress */1,
          _0: g
        };
}

function flatMapLobbyResult(game, fn) {
  if (game.TAG !== /* Ok */0) {
    return game;
  }
  var g = game._0;
  if (g.TAG !== /* InLobby */0) {
    return game;
  }
  var x = Curry._1(fn, g._0);
  if (x.TAG === /* Ok */0) {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InLobby */0,
              _0: x._0
            }
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: x._0
          };
  }
}

function unpackLobby(game) {
  if (game.TAG === /* InLobby */0) {
    return {
            TAG: /* Ok */0,
            _0: game._0
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Unpack InProgress gameId: " + game._0.gameId
          };
  }
}

function unpackProgress(game) {
  if (game.TAG === /* InLobby */0) {
    return {
            TAG: /* Error */1,
            _0: "Unpack InLobby gameId: " + game._0.gameId
          };
  } else {
    return {
            TAG: /* Ok */0,
            _0: game._0
          };
  }
}

function mapLobbyResult(game, fn) {
  return Belt_Result.map(game, (function (game) {
                if (game.TAG === /* InLobby */0) {
                  return {
                          TAG: /* InLobby */0,
                          _0: Curry._1(fn, game._0)
                        };
                } else {
                  return game;
                }
              }));
}

function fMapLobbyResult(a, fn) {
  return Belt_Result.flatMap(a, (function (game) {
                if (game.TAG === /* InLobby */0) {
                  return Curry._1(fn, game._0);
                } else {
                  return a;
                }
              }));
}

function mapProgress(game, fn) {
  if (game.TAG !== /* InLobby */0) {
    return Curry._1(fn, game._0);
  }
  var game$1 = game._0;
  Log.info([
        "Try to map InLobby with mapOverProgress",
        game$1.gameId
      ]);
  return {
          TAG: /* InLobby */0,
          _0: game$1
        };
}

export {
  isDefender ,
  isAttacker ,
  isPlayerHasCard ,
  isCorrectAdditionalCard ,
  isPlayerCanMove ,
  getTrump ,
  isPlayerDone ,
  isPlayerLose ,
  isCanTake ,
  isCanPass ,
  isPassed ,
  isAllPassed ,
  isPlayerCanBeat ,
  getPlayerGameState ,
  findPlayerById ,
  isOwner ,
  isCanStart ,
  getGameId ,
  mapLobby ,
  flatMapLobbyResult ,
  unpackLobby ,
  unpackProgress ,
  mapLobbyResult ,
  fMapLobbyResult ,
  mapProgress ,
  
}
/* Table Not a pure module */
