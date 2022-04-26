// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./Card.mjs";
import * as Table from "./Table.mjs";
import * as Utils from "./Utils.mjs";
import * as Player from "./Player.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "./GameUtils.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

function makeGameInLobby(authorId) {
  return {
          TAG: /* InLobby */0,
          _0: {
            players: {
              hd: Player.make(authorId),
              tl: /* [] */0
            },
            ready: /* [] */0
          }
        };
}

function logoutPlayer(game, player) {
  return {
          TAG: /* InLobby */0,
          _0: {
            players: Belt_List.keep(game.players, (function (item) {
                    return item !== player;
                  })),
            ready: game.ready
          }
        };
}

function enterGame(game, player) {
  return {
          TAG: /* InLobby */0,
          _0: {
            players: Belt_List.add(game.players, player),
            ready: game.ready
          }
        };
}

function startGame(game) {
  var match = Player.dealDeckToPlayers(Card.makeShuffledDeck(undefined), game.players);
  var deck = match[1];
  var players = match[0];
  var trump = GameUtils.getTrump(deck, players);
  var attacker = Belt_Option.flatMap(trump, (function (tr) {
          return Player.findFirstAttacker(tr, players);
        }));
  var defender = Belt_Option.flatMap(attacker, (function (at) {
          return Player.getNextPlayer(at, players);
        }));
  if (trump !== undefined) {
    if (attacker !== undefined && defender !== undefined) {
      return {
              TAG: /* Ok */0,
              _0: {
                TAG: /* InProgress */1,
                _0: {
                  attacker: attacker,
                  defender: defender,
                  players: players,
                  trump: trump,
                  deck: deck,
                  table: /* [] */0,
                  pass: /* [] */0
                }
              }
            };
    } else {
      return {
              TAG: /* Error */1,
              _0: "Can't find next attacker/defender"
            };
    }
  } else {
    return {
            TAG: /* Error */1,
            _0: "Can't find trump"
          };
  }
}

function isValidMove(game, player, card) {
  if (GameUtils.isDefender(game, player)) {
    return {
            TAG: /* Error */1,
            _0: "Defender can't make move"
          };
  } else if (!Table.hasCards(game.table) && !GameUtils.isAttacker(game, player)) {
    return {
            TAG: /* Error */1,
            _0: "First move made not by attacker"
          };
  } else if (GameUtils.isPlayerHasCard(player, card)) {
    if (Table.isMaximumCards(game.table)) {
      return {
              TAG: /* Error */1,
              _0: "Maximum cards on table"
            };
    } else if (Table.hasCards(game.table) && !GameUtils.isCorrectAdditionalCard(game, card)) {
      return {
              TAG: /* Error */1,
              _0: "Incorrect card"
            };
    } else {
      return {
              TAG: /* Ok */0,
              _0: {
                TAG: /* InProgress */1,
                _0: game
              }
            };
    }
  } else {
    return {
            TAG: /* Error */1,
            _0: "Player don't have card"
          };
  }
}

function move(game, player, card) {
  var isValid = isValidMove(game, player, card);
  if (Belt_Result.isError(isValid)) {
    return isValid;
  } else {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: {
                attacker: game.attacker,
                defender: game.defender,
                players: Belt_List.map(game.players, (function (p) {
                        return {
                                id: p.id,
                                sessionId: p.sessionId,
                                cards: Player.removeCard(p, card)
                              };
                      })),
                trump: game.trump,
                deck: game.deck,
                table: Belt_List.add(game.table, [
                      card,
                      undefined
                    ]),
                pass: game.pass
              }
            }
          };
  }
}

function isValidPass(game, player) {
  if (GameUtils.isCanPass(game, player)) {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: game
            }
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Can't pass"
          };
  }
}

function finishRound(game) {
  var nextAttacker = Player.getNextPlayer(game.attacker, game.players);
  var nextDefender = Belt_Option.flatMap(nextAttacker, (function (p) {
          return Player.getNextPlayer(p, game.players);
        }));
  var match = Player.dealDeckToPlayers(game.deck, game.players);
  if (nextAttacker !== undefined && nextDefender !== undefined) {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: {
                attacker: nextAttacker,
                defender: nextDefender,
                players: match[0],
                trump: game.trump,
                deck: match[1],
                table: /* [] */0,
                pass: /* [] */0
              }
            }
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Can't find next attacker/defender"
          };
  }
}

function pass(game, player) {
  var isValid = isValidPass(game, player);
  var nextGameWithPassed_attacker = game.attacker;
  var nextGameWithPassed_defender = game.defender;
  var nextGameWithPassed_players = game.players;
  var nextGameWithPassed_trump = game.trump;
  var nextGameWithPassed_deck = game.deck;
  var nextGameWithPassed_table = game.table;
  var nextGameWithPassed_pass = Utils.toggleArrayItem(game.pass, player);
  var nextGameWithPassed = {
    attacker: nextGameWithPassed_attacker,
    defender: nextGameWithPassed_defender,
    players: nextGameWithPassed_players,
    trump: nextGameWithPassed_trump,
    deck: nextGameWithPassed_deck,
    table: nextGameWithPassed_table,
    pass: nextGameWithPassed_pass
  };
  if (Belt_Result.isError(isValid)) {
    return isValid;
  } else if (GameUtils.isAllPassed(nextGameWithPassed) && Table.isAllBeaten(game.table)) {
    return finishRound(nextGameWithPassed);
  } else {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: nextGameWithPassed
            }
          };
  }
}

function isValidBeat(game, to, by, player) {
  if (GameUtils.isDefender(game, player)) {
    if (GameUtils.isPlayerHasCard(player, by)) {
      if (Card.isValidTableBeat(to, by, game.trump)) {
        return {
                TAG: /* Ok */0,
                _0: {
                  TAG: /* InProgress */1,
                  _0: game
                }
              };
      } else {
        return {
                TAG: /* Error */1,
                _0: "Invalid card beat"
              };
      }
    } else {
      return {
              TAG: /* Error */1,
              _0: "Player dont have card"
            };
    }
  } else {
    return {
            TAG: /* Error */1,
            _0: "Is not deffender"
          };
  }
}

function beat(game, to, by, player) {
  var isValid = isValidBeat(game, to, by, player);
  if (Belt_Result.isError(isValid)) {
    return isValid;
  } else {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: {
                attacker: game.attacker,
                defender: game.defender,
                players: Belt_List.map(game.players, (function (p) {
                        return {
                                id: p.id,
                                sessionId: p.sessionId,
                                cards: Player.removeCard(p, by)
                              };
                      })),
                trump: game.trump,
                deck: game.deck,
                table: Belt_List.map(game.table, (function (param) {
                        var firstCard = param[0];
                        if (Card.isCardEquals(firstCard, to)) {
                          return [
                                  firstCard,
                                  by
                                ];
                        } else {
                          return [
                                  firstCard,
                                  param[1]
                                ];
                        }
                      })),
                pass: /* [] */0
              }
            }
          };
  }
}

function isValidTake(game, player) {
  if (GameUtils.isDefender(game, player)) {
    if (Table.hasCards(game.table)) {
      return {
              TAG: /* Ok */0,
              _0: {
                TAG: /* InProgress */1,
                _0: game
              }
            };
    } else {
      return {
              TAG: /* Error */1,
              _0: "Table is empty"
            };
    }
  } else {
    return {
            TAG: /* Error */1,
            _0: "Player is not defender"
          };
  }
}

function take(game, player) {
  var isValid = isValidTake(game, player);
  if (Belt_Result.isError(isValid)) {
    return isValid;
  }
  var nextAttacker = Player.getNextPlayer(game.defender, game.players);
  var nextDefender = Belt_Option.flatMap(nextAttacker, (function (p) {
          return Player.getNextPlayer(p, game.players);
        }));
  if (nextAttacker !== undefined && nextDefender !== undefined) {
    return {
            TAG: /* Ok */0,
            _0: {
              TAG: /* InProgress */1,
              _0: {
                attacker: nextAttacker,
                defender: nextDefender,
                players: Belt_List.map(game.players, (function (p) {
                        if (GameUtils.isDefender(game, p)) {
                          return {
                                  id: p.id,
                                  sessionId: p.sessionId,
                                  cards: Belt_List.concat(p.cards, Table.getFlatCards(game.table))
                                };
                        } else {
                          return p;
                        }
                      })),
                trump: game.trump,
                deck: game.deck,
                table: /* [] */0,
                pass: /* [] */0
              }
            }
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Can't find next attacker/defender"
          };
  }
}

export {
  makeGameInLobby ,
  logoutPlayer ,
  enterGame ,
  startGame ,
  isValidMove ,
  move ,
  isValidPass ,
  finishRound ,
  pass ,
  isValidBeat ,
  beat ,
  isValidTake ,
  take ,
  
}
/* No side effect */
