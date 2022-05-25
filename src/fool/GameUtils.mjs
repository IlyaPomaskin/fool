// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./Card.mjs";
import * as Deck from "./Deck.mjs";
import * as Table from "./Table.mjs";
import * as Utils from "../Utils.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";

function isDefender(game, player) {
  return game.defender.id === player.id;
}

function isAttacker(game, player) {
  return game.attacker.id === player.id;
}

function isPlayerHasCard(player, card) {
  return Belt_List.has(player.cards, card, Utils.equals);
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
  if (Deck.isEmpty(game.deck)) {
    return Deck.isEmpty(player.cards);
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

function isPassed(game, player) {
  var inPassedList = Belt_List.has(game.pass, player, Utils.equals);
  var hasCards = !Deck.isEmpty(player.cards);
  if (hasCards) {
    return inPassedList;
  } else {
    return true;
  }
}

function isAllPassed(game) {
  return Belt_List.every(Belt_List.keep(game.players, (function (p) {
                    return !isDefender(game, p);
                  })), (function (param) {
                return isPassed(game, param);
              }));
}

function getPlayerGameState(game, player) {
  var isThereCardsInDeck = !Deck.isEmpty(game.deck);
  var isPlayerHasCards = !Deck.isEmpty(player.cards);
  var hasCardsForNextRound = isPlayerHasCards || isThereCardsInDeck;
  var otherPlayersWithCardsAmount = Belt_List.length(Belt_List.keep(Belt_List.keep(game.players, (function (p) {
                  return !Utils.equals(p, player);
                })), (function (p) {
              return !Deck.isEmpty(p.cards);
            })));
  if (hasCardsForNextRound) {
    if (otherPlayersWithCardsAmount !== 0 || isThereCardsInDeck) {
      return /* Playing */0;
    } else {
      return /* Lose */3;
    }
  } else if (otherPlayersWithCardsAmount !== 0) {
    return /* Done */1;
  } else {
    return /* Won */2;
  }
}

function findPlayerById(game, playerId) {
  return Belt_List.getBy(game.players, (function (p) {
                return p.id === playerId;
              }));
}

function isFirstPlayerAddedToList(players, player) {
  return Belt_Option.getWithDefault(Belt_Option.map(Belt_List.get(players, Belt_List.length(players) - 1 | 0), (function (p) {
                    return p.id === player.id;
                  })), false);
}

function isCanStart(game, player) {
  var isEnoughPlayers = Belt_List.length(game.players) > 1;
  var isAllPlayersAreReady = Belt_List.cmpByLength(game.players, game.ready) === 0;
  var isOwner = isFirstPlayerAddedToList(game.players, player);
  if (isOwner) {
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

function isValidMove(game, player) {
  if (isDefender(game, player)) {
    return {
            TAG: /* Error */1,
            _0: "Defender can't make move"
          };
  } else if (!Table.hasCards(game.table) && !isAttacker(game, player)) {
    return {
            TAG: /* Error */1,
            _0: "First move made not by attacker"
          };
  } else if (Table.isMaximumCards(game.table)) {
    return {
            TAG: /* Error */1,
            _0: "Maximum cards on table"
          };
  } else {
    return {
            TAG: /* Ok */0,
            _0: game
          };
  }
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
  getPlayerGameState ,
  findPlayerById ,
  isFirstPlayerAddedToList ,
  isCanStart ,
  isValidMove ,
  
}
/* No side effect */
