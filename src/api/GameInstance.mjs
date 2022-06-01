// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "../Log.mjs";
import * as Game from "../fool/Game.mjs";
import * as Utils from "../Utils.mjs";
import * as $$Storage from "./Storage.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Pervasives from "rescript/lib/es6/pervasives.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

$$Storage.PlayersMap.set($$Storage.players, "p1", {
      id: "p1",
      sessionId: "s:p1",
      cards: /* [] */0
    });

$$Storage.PlayersMap.set($$Storage.players, "p2", {
      id: "p2",
      sessionId: "s:p2",
      cards: /* [] */0
    });

$$Storage.PlayersMap.set($$Storage.players, "p3", {
      id: "p3",
      sessionId: "s:p3",
      cards: /* [] */0
    });

$$Storage.PlayersMap.set($$Storage.players, "p4", {
      id: "p4",
      sessionId: "s:p4",
      cards: /* [] */0
    });

function registerPlayer(playerId) {
  var player = $$Storage.PlayersMap.get($$Storage.players, playerId);
  if (player.TAG === /* Ok */0) {
    return {
            TAG: /* Error */1,
            _0: "Player with same name already exists"
          };
  } else {
    return $$Storage.PlayersMap.create($$Storage.players, playerId);
  }
}

var instanceId = {
  contents: 0
};

function loginPlayer(sessionId) {
  if (instanceId.contents === 0) {
    instanceId.contents = Math.random();
  }
  Log.debug(/* LoginPlayer */0, [
        "Login Player",
        Pervasives.string_of_float(instanceId.contents)
      ]);
  return $$Storage.PlayersMap.findBySessionId($$Storage.players, sessionId);
}

function createLobby(playerId) {
  return Belt_Result.flatMap($$Storage.PlayersMap.get($$Storage.players, playerId), (function (player) {
                return $$Storage.LobbyGameMap.create($$Storage.gamesInLobby, player);
              }));
}

function enterGame(playerId, gameId) {
  return Belt_Result.flatMap(Belt_Result.flatMap($$Storage.PlayersMap.get($$Storage.players, playerId), (function (player) {
                    return Belt_Result.flatMap($$Storage.LobbyGameMap.get($$Storage.gamesInLobby, gameId), (function (lobby) {
                                  return Game.enterGame(lobby, player);
                                }));
                  })), (function (game) {
                return $$Storage.LobbyGameMap.set($$Storage.gamesInLobby, game.gameId, game);
              }));
}

function toggleReady(playerId, gameId) {
  return Belt_Result.flatMap($$Storage.PlayersMap.get($$Storage.players, playerId), (function (player) {
                return $$Storage.LobbyGameMap.update($$Storage.gamesInLobby, gameId, (function (game) {
                              return Belt_Result.getWithDefault(Game.toggleReady(game, player), game);
                            }));
              }));
}

function startGame(playerId, gameId) {
  return Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.PlayersMap.get($$Storage.players, playerId), (function (player) {
                        return Belt_Result.flatMap($$Storage.LobbyGameMap.get($$Storage.gamesInLobby, gameId), (function (game) {
                                      return GameUtils.isCanStart(game, player);
                                    }));
                      })), Game.startGame), (function (game) {
                $$Storage.LobbyGameMap.remove($$Storage.gamesInLobby, gameId);
                return $$Storage.ProgressGameMap.set($$Storage.gamesInProgress, gameId, game);
              }));
}

function move(playerId, gameId, action) {
  return Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.ProgressGameMap.get($$Storage.gamesInProgress, gameId), (function (game) {
                        return Belt_Result.map(Utils.toResult(GameUtils.findPlayerById(game, playerId), "Player " + playerId + " not found"), (function (player) {
                                      return [
                                              player,
                                              game
                                            ];
                                    }));
                      })), (function (param) {
                    return Game.dispatch(param[1], param[0], action);
                  })), (function (game) {
                return $$Storage.ProgressGameMap.set($$Storage.gamesInProgress, game.gameId, game);
              }));
}

export {
  registerPlayer ,
  instanceId ,
  loginPlayer ,
  createLobby ,
  enterGame ,
  toggleReady ,
  startGame ,
  move ,
  
}
/*  Not a pure module */
