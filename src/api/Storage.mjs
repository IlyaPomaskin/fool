// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Log from "../Log.mjs";
import * as Game from "../fool/Game.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as Player from "../fool/Player.mjs";
import * as Belt_Id from "rescript/lib/es6/belt_Id.js";
import * as Hashtbl from "rescript/lib/es6/hashtbl.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Belt_HashMap from "rescript/lib/es6/belt_HashMap.js";

function eq(a, b) {
  return a === b;
}

var PlayerId = Belt_Id.MakeHashable({
      hash: Hashtbl.hash,
      eq: eq
    });

function eq$1(a, b) {
  return a === b;
}

var GameId = Belt_Id.MakeHashable({
      hash: Hashtbl.hash,
      eq: eq$1
    });

function MakeGameMap(Item) {
  var empty = function (param) {
    return Belt_HashMap.make(10, GameId);
  };
  var get = function (map, gameId) {
    return Utils.toResult(Belt_HashMap.get(map, gameId), "Game \"" + gameId + "\" not found");
  };
  var set = function (map, gameId, game) {
    Belt_HashMap.set(map, gameId, game);
    return {
            TAG: /* Ok */0,
            _0: game
          };
  };
  var create = function (map, arg) {
    var game = Curry._1(Item.createGame, arg);
    var gameWithSameIdFound = Belt_Result.flatMap(Belt_Result.map(game, Item.getId), (function (id) {
            return get(map, id);
          }));
    if (game.TAG !== /* Ok */0) {
      return game;
    }
    if (gameWithSameIdFound.TAG === /* Ok */0) {
      return {
              TAG: /* Error */1,
              _0: "Game " + Curry._1(Item.getId, gameWithSameIdFound._0) + " already exists"
            };
    }
    var game$1 = game._0;
    return set(map, Curry._1(Item.getId, game$1), game$1);
  };
  var remove = Belt_HashMap.remove;
  var update = function (map, gameId, fn) {
    return Belt_Result.flatMap(get(map, gameId), (function (game) {
                  return set(map, gameId, Curry._1(fn, game));
                }));
  };
  return {
          empty: empty,
          get: get,
          set: set,
          create: create,
          remove: remove,
          update: update
        };
}

function getId(game) {
  return game.gameId;
}

function empty(param) {
  return Belt_HashMap.make(10, GameId);
}

function get(map, gameId) {
  return Utils.toResult(Belt_HashMap.get(map, gameId), "Game \"" + gameId + "\" not found");
}

function set(map, gameId, game) {
  Belt_HashMap.set(map, gameId, game);
  return {
          TAG: /* Ok */0,
          _0: game
        };
}

function create(map, arg) {
  var game = Game.makeGameInLobby(arg);
  var gameWithSameIdFound = Belt_Result.flatMap(Belt_Result.map(game, getId), (function (id) {
          return get(map, id);
        }));
  if (game.TAG !== /* Ok */0) {
    return game;
  }
  if (gameWithSameIdFound.TAG === /* Ok */0) {
    return {
            TAG: /* Error */1,
            _0: "Game " + gameWithSameIdFound._0.gameId + " already exists"
          };
  }
  var game$1 = game._0;
  return set(map, game$1.gameId, game$1);
}

var remove = Belt_HashMap.remove;

function update(map, gameId, fn) {
  return Belt_Result.flatMap(get(map, gameId), (function (game) {
                return set(map, gameId, Curry._1(fn, game));
              }));
}

var LobbyGameMap = {
  empty: empty,
  get: get,
  set: set,
  create: create,
  remove: remove,
  update: update
};

function getId$1(game) {
  return game.gameId;
}

function empty$1(param) {
  return Belt_HashMap.make(10, GameId);
}

function get$1(map, gameId) {
  return Utils.toResult(Belt_HashMap.get(map, gameId), "Game \"" + gameId + "\" not found");
}

function set$1(map, gameId, game) {
  Belt_HashMap.set(map, gameId, game);
  return {
          TAG: /* Ok */0,
          _0: game
        };
}

function create$1(map, arg) {
  var game = Game.startGame(arg);
  var gameWithSameIdFound = Belt_Result.flatMap(Belt_Result.map(game, getId$1), (function (id) {
          return get$1(map, id);
        }));
  if (game.TAG !== /* Ok */0) {
    return game;
  }
  if (gameWithSameIdFound.TAG === /* Ok */0) {
    return {
            TAG: /* Error */1,
            _0: "Game " + gameWithSameIdFound._0.gameId + " already exists"
          };
  }
  var game$1 = game._0;
  return set$1(map, game$1.gameId, game$1);
}

var remove$1 = Belt_HashMap.remove;

function update$1(map, gameId, fn) {
  return Belt_Result.flatMap(get$1(map, gameId), (function (game) {
                return set$1(map, gameId, Curry._1(fn, game));
              }));
}

var ProgressGameMap = {
  empty: empty$1,
  get: get$1,
  set: set$1,
  create: create$1,
  remove: remove$1,
  update: update$1
};

function log(map) {
  return JSON.stringify(Belt_Array.map(Belt_HashMap.toArray(map), (function (param) {
                    return [
                            param[0],
                            param[1]
                          ];
                  })), null, 2);
}

function empty$2(param) {
  return Belt_HashMap.make(10, PlayerId);
}

function get$2(map, playerId) {
  return Utils.toResult(Belt_HashMap.get(map, playerId), "Player \"" + playerId + "\" not found");
}

function findBySessionId(map, sessionId) {
  Log.debug(/* PlayersMap */3, [
        "findBySessionId",
        log(map)
      ]);
  return Utils.toResult(Belt_HashMap.reduce(map, undefined, (function (acc, param, value) {
                    if (acc !== undefined) {
                      return acc;
                    } else if (value.sessionId === sessionId) {
                      return value;
                    } else {
                      return ;
                    }
                  })), "Player " + sessionId + " not found");
}

function set$2(map, key, nextValue) {
  Belt_HashMap.set(map, key, nextValue);
  return Log.debug(/* PlayersMap */3, [
              "set",
              key,
              log(map)
            ]);
}

function create$2(map, playerId) {
  var match = Belt_HashMap.get(map, playerId);
  if (match !== undefined) {
    return {
            TAG: /* Error */1,
            _0: "Player " + playerId + " already exists"
          };
  }
  var player = Player.make(playerId);
  set$2(map, playerId, player);
  return {
          TAG: /* Ok */0,
          _0: player
        };
}

var PlayersMap = {
  log: log,
  empty: empty$2,
  get: get$2,
  findBySessionId: findBySessionId,
  set: set$2,
  create: create$2
};

function empty$3(param) {
  return Belt_HashMap.make(10, PlayerId);
}

function get$3(map, playerId) {
  return Utils.toResult(Belt_HashMap.get(map, playerId), "Player \"" + playerId + "\" socket not found");
}

var set$3 = Belt_HashMap.set;

var remove$2 = Belt_HashMap.remove;

var PlayersSocketMap = {
  empty: empty$3,
  get: get$3,
  set: set$3,
  remove: remove$2
};

var gamesInLobby = Belt_HashMap.make(10, GameId);

var gamesInProgress = Belt_HashMap.make(10, GameId);

var players = Belt_HashMap.make(10, PlayerId);

export {
  PlayerId ,
  GameId ,
  MakeGameMap ,
  LobbyGameMap ,
  ProgressGameMap ,
  PlayersMap ,
  PlayersSocketMap ,
  gamesInLobby ,
  gamesInProgress ,
  players ,
  
}
/* PlayerId Not a pure module */
