// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "./Card.mjs";
import * as Deck from "./Deck.mjs";
import * as Table from "./Table.mjs";
import * as Utils from "../Utils.mjs";
import * as Player from "./Player.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "./GameUtils.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

function makeGameInLobby(player) {
  return {
          TAG: /* Ok */0,
          _0: {
            gameId: "g1",
            players: {
              hd: player,
              tl: /* [] */0
            },
            ready: /* [] */0
          }
        };
}

function logoutPlayer(game, player) {
  return {
          gameId: game.gameId,
          players: Belt_List.keep(game.players, (function (item) {
                  return item !== player;
                })),
          ready: game.ready
        };
}

function enterGame(game, player) {
  var isPlayerInGame = Belt_List.has(game.players, player, (function (p1, p2) {
          return p1.id === p2.id;
        }));
  return {
          TAG: /* Ok */0,
          _0: {
            gameId: game.gameId,
            players: isPlayerInGame ? game.players : Belt_List.add(game.players, player),
            ready: game.ready
          }
        };
}

function isValidToggleReady(game, player) {
  if (Belt_List.has(game.players, player, (function (p1, p2) {
            return p1.id === p2.id;
          }))) {
    return {
            TAG: /* Ok */0,
            _0: game
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Player not in game"
          };
  }
}

function toggleReady(game, player) {
  var isValid = isValidToggleReady(game, player);
  if (Belt_Result.isError(isValid)) {
    return isValid;
  }
  var inList = Belt_List.has(game.ready, player, (function (p1, p2) {
          return p1.id === p2.id;
        }));
  return {
          TAG: /* Ok */0,
          _0: {
            gameId: game.gameId,
            players: game.players,
            ready: inList ? Belt_List.keep(game.ready, (function (p) {
                      return p.id !== player.id;
                    })) : Belt_List.add(game.ready, player)
          }
        };
}

function startGame(game) {
  var match = Player.dealDeckToPlayers(Deck.makeShuffled(undefined), game.players);
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
                gameId: game.gameId,
                attacker: attacker,
                defender: defender,
                players: players,
                trump: trump,
                deck: deck,
                table: /* [] */0,
                pass: /* [] */0
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
              _0: game
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
              gameId: game.gameId,
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
          };
  }
}

function isValidPass(game, player) {
  if (GameUtils.isCanPass(game, player)) {
    return {
            TAG: /* Ok */0,
            _0: game
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
              gameId: game.gameId,
              attacker: nextAttacker,
              defender: nextDefender,
              players: match[0],
              trump: game.trump,
              deck: match[1],
              table: /* [] */0,
              pass: /* [] */0
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
  var nextGameWithPassed_gameId = game.gameId;
  var nextGameWithPassed_attacker = game.attacker;
  var nextGameWithPassed_defender = game.defender;
  var nextGameWithPassed_players = game.players;
  var nextGameWithPassed_trump = game.trump;
  var nextGameWithPassed_deck = game.deck;
  var nextGameWithPassed_table = game.table;
  var nextGameWithPassed_pass = Utils.toggleArrayItem(game.pass, player);
  var nextGameWithPassed = {
    gameId: nextGameWithPassed_gameId,
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
            _0: nextGameWithPassed
          };
  }
}

function isValidBeat(game, player, to, by) {
  if (GameUtils.isDefender(game, player)) {
    if (GameUtils.isPlayerHasCard(player, by)) {
      if (Card.isValidBeat(to, by, game.trump)) {
        return {
                TAG: /* Ok */0,
                _0: game
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

function beat(game, player, to, by) {
  var isValid = isValidBeat(game, player, to, by);
  if (Belt_Result.isError(isValid)) {
    return isValid;
  } else {
    return {
            TAG: /* Ok */0,
            _0: {
              gameId: game.gameId,
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
                      if (Card.isEquals(firstCard, to)) {
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
          };
  }
}

function isValidTake(game, player) {
  if (GameUtils.isDefender(game, player)) {
    if (Table.hasCards(game.table)) {
      return {
              TAG: /* Ok */0,
              _0: game
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
  var nextPlayers = Belt_List.map(game.players, (function (p) {
          if (GameUtils.isDefender(game, p)) {
            return {
                    id: p.id,
                    sessionId: p.sessionId,
                    cards: Belt_List.concat(p.cards, Table.getFlatCards(game.table))
                  };
          } else {
            return p;
          }
        }));
  var match = Player.dealDeckToPlayers(game.deck, nextPlayers);
  if (nextAttacker !== undefined && nextDefender !== undefined) {
    return {
            TAG: /* Ok */0,
            _0: {
              gameId: game.gameId,
              attacker: nextAttacker,
              defender: nextDefender,
              players: match[0],
              trump: game.trump,
              deck: match[1],
              table: /* [] */0,
              pass: /* [] */0
            }
          };
  } else {
    return {
            TAG: /* Error */1,
            _0: "Can't find next attacker/defender"
          };
  }
}

function dispatch(game, player, action) {
  if (typeof action === "number") {
    if (action === /* Take */0) {
      return take(game, player);
    } else {
      return pass(game, player);
    }
  } else if (action.TAG === /* Beat */0) {
    return beat(game, player, action._0, action._1);
  } else {
    return move(game, player, action._0);
  }
}

function maskGameDeck(deck) {
  var lastCardIndex = Belt_List.length(deck) - 1 | 0;
  return Belt_List.mapWithIndex(deck, (function (index, card) {
                if (index === lastCardIndex) {
                  return card;
                } else {
                  return /* Hidden */0;
                }
              }));
}

function maskForPlayer(game, playerId) {
  return {
          gameId: game.gameId,
          attacker: Player.mask(playerId, game.attacker),
          defender: Player.mask(playerId, game.defender),
          players: Belt_List.map(game.players, (function (param) {
                  return Player.mask(playerId, param);
                })),
          trump: game.trump,
          deck: maskGameDeck(game.deck),
          table: game.table,
          pass: Belt_List.map(game.pass, (function (param) {
                  return Player.mask(playerId, param);
                }))
        };
}

function toObject(game) {
  return {
          gameId: game.gameId,
          table: Table.toObject(game.table),
          trump: Card.suitToString(game.trump),
          attacker: Player.toStringShort(game.attacker),
          defender: Player.toStringShort(game.defender),
          players: Belt_List.toArray(Belt_List.map(game.players, Player.toObject)),
          deck: Deck.toObject(game.deck),
          pass: Belt_List.toArray(Belt_List.map(game.pass, Player.toStringShort))
        };
}

function actionToObject(action) {
  if (typeof action === "number") {
    if (action === /* Take */0) {
      return "take";
    } else {
      return "pass";
    }
  } else if (action.TAG === /* Beat */0) {
    return "beat to:" + Card.cardToString(action._0) + " by:" + Card.cardToString(action._1);
  } else {
    return "move " + Card.cardToString(action._0);
  }
}

export {
  makeGameInLobby ,
  logoutPlayer ,
  enterGame ,
  isValidToggleReady ,
  toggleReady ,
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
  dispatch ,
  maskGameDeck ,
  maskForPlayer ,
  toObject ,
  actionToObject ,
  
}
/* No side effect */
