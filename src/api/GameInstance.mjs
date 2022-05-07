// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Game from "../fool/Game.mjs";
import * as Utils from "../Utils.mjs";
import * as $$Storage from "./Storage.mjs";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

var gamesInLobby = $$Storage.LobbyGameMap.empty(undefined);

var gamesInProgress = $$Storage.ProgressGameMap.empty(undefined);

var players = $$Storage.PlayersMap.empty(undefined);

$$Storage.PlayersMap.set(players, "p1")({
      id: "p1",
      sessionId: "session:p1",
      cards: /* [] */0
    });

$$Storage.PlayersMap.set(players, "p2")({
      id: "p2",
      sessionId: "session:p2",
      cards: /* [] */0
    });

function registerPlayer(playerId) {
  var player = $$Storage.PlayersMap.get(players, playerId);
  if (player.TAG === /* Ok */0) {
    return {
            TAG: /* Error */1,
            _0: "Player with same name already exists"
          };
  } else {
    return $$Storage.PlayersMap.create(players, playerId);
  }
}

function loginPlayer(sessionId) {
  return $$Storage.PlayersMap.findBySessionId(players, sessionId);
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
  return Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.PlayersMap.get(players, playerId), (function (player) {
                        return Belt_Result.flatMap($$Storage.LobbyGameMap.get(gamesInLobby, gameId), (function (game) {
                                      return GameUtils.isCanStart(game, player);
                                    }));
                      })), Game.startGame), (function (game) {
                $$Storage.LobbyGameMap.remove(gamesInLobby, gameId);
                return $$Storage.ProgressGameMap.set(gamesInProgress, gameId, game);
              }));
}

function dispatchMove(playerId, gameId, action) {
  return Belt_Result.flatMap(Belt_Result.flatMap(Belt_Result.flatMap($$Storage.ProgressGameMap.get(gamesInProgress, gameId), (function (game) {
                        return Belt_Result.map(Utils.toResult(GameUtils.findPlayerById(game, playerId), "Player " + playerId + " not found"), (function (player) {
                                      return [
                                              player,
                                              game
                                            ];
                                    }));
                      })), (function (param) {
                    return Game.dispatch(param[1], param[0], action);
                  })), (function (game) {
                return $$Storage.ProgressGameMap.set(gamesInProgress, game.gameId, game);
              }));
}

export {
  gamesInLobby ,
  gamesInProgress ,
  players ,
  registerPlayer ,
  loginPlayer ,
  createLobby ,
  enterGame ,
  toggleReady ,
  startGame ,
  dispatchMove ,
  
}
/* gamesInLobby Not a pure module */
