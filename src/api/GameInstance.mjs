// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Game from "../fool/Game.mjs";
import * as Utils from "../Utils.mjs";
import * as Player from "../fool/Player.mjs";
import * as $$Storage from "./Storage.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

var gamesInLobby = $$Storage.LobbyGameMap.empty(undefined);

var gamesInProgress = $$Storage.ProgressGameMap.empty(undefined);

var players = $$Storage.PlayersMap.empty(undefined);

function connectPlayer(playerId) {
  var player = $$Storage.PlayersMap.get(players, playerId);
  if (player.TAG === /* Ok */0) {
    return {
            TAG: /* Ok */0,
            _0: player._0
          };
  } else {
    return $$Storage.PlayersMap.create(players, playerId);
  }
}

function createLobby(playerId) {
  return Belt_Result.flatMap($$Storage.PlayersMap.get(players, playerId), (function (player) {
                return $$Storage.LobbyGameMap.create(gamesInLobby, player);
              }));
}

function enterGame(playerId, gameId) {
  return Belt_Result.flatMap(Belt_Result.flatMap($$Storage.PlayersMap.get(players, playerId), (function (player) {
                    return Belt_Result.flatMap($$Storage.LobbyGameMap.get(gamesInLobby, gameId), (function (lobby) {
                                  return Game.enterGame(lobby, player);
                                }));
                  })), (function (game) {
                return $$Storage.LobbyGameMap.set(gamesInLobby, game.gameId, game);
              }));
}

function toggleReady(playerId, gameId) {
  return Belt_Result.flatMap($$Storage.PlayersMap.get(players, playerId), (function (player) {
                return $$Storage.LobbyGameMap.update(gamesInLobby, gameId, (function (game) {
                              return Belt_Result.getWithDefault(Game.toggleReady(game, player), game);
                            }));
              }));
}

function startGame(playerId, gameId) {
  return Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.PlayersMap.get(players, playerId), (function (param) {
                        return $$Storage.LobbyGameMap.get(gamesInLobby, gameId);
                      })), Game.startGame), (function (game) {
                $$Storage.LobbyGameMap.remove(gamesInLobby, gameId);
                return $$Storage.ProgressGameMap.set(gamesInProgress, gameId, game);
              }));
}

function initiateGame(param) {
  var alicePlayer = $$Storage.PlayersMap.create(players, "alice");
  var bobPlayer = $$Storage.PlayersMap.create(players, "bob");
  var tmp;
  if (alicePlayer.TAG === /* Ok */0) {
    var alice = alicePlayer._0;
    if (bobPlayer.TAG === /* Ok */0) {
      var bob = bobPlayer._0;
      tmp = Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.LobbyGameMap.create(gamesInLobby, alice), (function (game) {
                                  return Game.enterGame(game, bob);
                                })), (function (game) {
                              return Game.toggleReady(game, alice);
                            })), (function (game) {
                          return Game.toggleReady(game, bob);
                        })), (function (game) {
                      return $$Storage.LobbyGameMap.set(gamesInLobby, game.gameId, game);
                    })), (function (game) {
                  return $$Storage.ProgressGameMap.create(gamesInProgress, game);
                })), (function (game) {
              $$Storage.LobbyGameMap.remove(gamesInLobby, game.gameId);
              return {
                      TAG: /* Ok */0,
                      _0: game
                    };
            }));
    } else {
      tmp = {
        TAG: /* Error */1,
        _0: "Can't create alice or bob"
      };
    }
  } else {
    tmp = {
      TAG: /* Error */1,
      _0: "Can't create alice or bob"
    };
  }
  console.log(tmp, "game created");
  
}

function dispatch(playerId, gameId, action) {
  var game = $$Storage.ProgressGameMap.get(gamesInProgress, gameId);
  var player = Belt_Result.flatMap(game, (function (game) {
          return Utils.toResult(GameUtils.findPlayerById(game, playerId), "Player " + playerId + " not found");
        }));
  console.log("[predispatch]", Belt_Result.map(game, Game.toObject), Belt_Result.map(player, Player.toObject), Game.actionToObject(action));
  var nextGame = Belt_Result.flatMap(player, (function (player) {
          return Belt_Result.flatMap(game, (function (game) {
                        return Game.dispatch(game, player, action);
                      }));
        }));
  var result;
  if (nextGame.TAG === /* Ok */0) {
    var game$1 = nextGame._0;
    result = $$Storage.ProgressGameMap.set(gamesInProgress, game$1.gameId, game$1);
  } else {
    result = {
      TAG: /* Error */1,
      _0: nextGame._0
    };
  }
  if (result.TAG === /* Ok */0) {
    console.log("[dispatch] ok ", Game.toObject(result._0));
  } else {
    console.log("[dispatch] error ", result._0);
  }
  return result;
}

export {
  gamesInLobby ,
  gamesInProgress ,
  players ,
  connectPlayer ,
  createLobby ,
  enterGame ,
  toggleReady ,
  startGame ,
  initiateGame ,
  dispatch ,
  
}
/* gamesInLobby Not a pure module */
