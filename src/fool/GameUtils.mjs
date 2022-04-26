// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./Card.mjs";
import * as Table from "./Table.mjs";
import * as Utils from "./Utils.mjs";
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
  return Belt_List.has(Table.getFlatCards(game.table), card, Card.isCardEqualsByRank);
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

function toggleReady(game, player) {
  return {
          TAG: /* InLobby */0,
          _0: {
            players: Utils.toggleArrayItem(game.players, player),
            ready: game.ready
          }
        };
}

function getTrump(deck, players) {
  var lastCard = Utils.lastListItem(deck);
  var lastPlayer = Utils.lastListItem(Belt_List.keep(players, (function (p) {
              return Belt_List.length(p.cards) !== 0;
            })));
  if (lastCard !== undefined) {
    return lastCard[0];
  } else if (lastPlayer !== undefined) {
    return Belt_Option.map(Utils.lastListItem(lastPlayer.cards), (function (prim) {
                  return prim[0];
                }));
  } else {
    return ;
  }
}

function isPlayerDone(game, player) {
  if (Card.isDeckEmpty(game.deck)) {
    return Card.isDeckEmpty(player.cards);
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
  var hasCards = !Card.isDeckEmpty(player.cards);
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
  var isThereCardsInDeck = !Card.isDeckEmpty(game.deck);
  var isPlayerHasCards = !Card.isDeckEmpty(player.cards);
  var isOtherPlayersHasCards = Belt_List.length(Belt_List.keep(Belt_List.keep(game.players, (function (p) {
                  return !Utils.equals(p, player);
                })), (function (p) {
              return !Card.isDeckEmpty(p.cards);
            }))) > 0;
  if (isThereCardsInDeck) {
    return /* Playing */0;
  } else if (isOtherPlayersHasCards) {
    if (isPlayerHasCards) {
      return /* Playing */0;
    } else {
      return /* Done */1;
    }
  } else if (isPlayerHasCards) {
    return /* Lose */2;
  } else {
    return /* Draw */3;
  }
}

export {
  isDefender ,
  isAttacker ,
  isPlayerHasCard ,
  isCorrectAdditionalCard ,
  isPlayerCanMove ,
  toggleReady ,
  getTrump ,
  isPlayerDone ,
  isPlayerLose ,
  isCanTake ,
  isCanPass ,
  isPassed ,
  isAllPassed ,
  getPlayerGameState ,
  
}
/* No side effect */
