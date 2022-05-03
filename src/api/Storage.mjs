// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Caml from "rescript/lib/es6/caml.js";
import * as Game from "../fool/Game.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as Player from "../fool/Player.mjs";
import * as Belt_Id from "rescript/lib/es6/belt_Id.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Belt_MutableMap from "rescript/lib/es6/belt_MutableMap.js";

function MakeGameMap(Item) {
  var cmp = Caml.caml_string_compare;
  var GameId = Belt_Id.MakeComparable({
        cmp: cmp
      });
  var empty = function (param) {
    return Belt_MutableMap.make(GameId);
  };
  var get = function (map, gameId) {
    return Utils.toResult(Belt_MutableMap.get(map, gameId), "Game \"" + gameId + "\" not found");
  };
  var set = function (map, gameId, game) {
    Belt_MutableMap.set(map, gameId, game);
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
  var remove = Belt_MutableMap.remove;
  var update = function (map, gameId, fn) {
    return Belt_Result.flatMap(get(map, gameId), (function (game) {
                  return set(map, gameId, Curry._1(fn, game));
                }));
  };
  return {
          GameId: GameId,
          empty: empty,
          get: get,
          set: set,
          create: create,
          remove: remove,
          update: update
        };
}

function createGame(player) {
  return {
          TAG: /* Ok */0,
          _0: {
            gameId: "gameId",
            players: {
              hd: player,
              tl: /* [] */0
            },
            ready: /* [] */0
          }
        };
}

function getId(game) {
  return game.gameId;
}

var cmp = Caml.caml_string_compare;

var GameId = Belt_Id.MakeComparable({
      cmp: cmp
    });

function empty(param) {
  return Belt_MutableMap.make(GameId);
}

function get(map, gameId) {
  return Utils.toResult(Belt_MutableMap.get(map, gameId), "Game \"" + gameId + "\" not found");
}

function set(map, gameId, game) {
  Belt_MutableMap.set(map, gameId, game);
  return {
          TAG: /* Ok */0,
          _0: game
        };
}

function create(map, arg) {
  var game = createGame(arg);
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

var remove = Belt_MutableMap.remove;

function update(map, gameId, fn) {
  return Belt_Result.flatMap(get(map, gameId), (function (game) {
                return set(map, gameId, Curry._1(fn, game));
              }));
}

var LobbyGameMap = {
  GameId: GameId,
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

var cmp$1 = Caml.caml_string_compare;

var GameId$1 = Belt_Id.MakeComparable({
      cmp: cmp$1
    });

function empty$1(param) {
  return Belt_MutableMap.make(GameId$1);
}

function get$1(map, gameId) {
  return Utils.toResult(Belt_MutableMap.get(map, gameId), "Game \"" + gameId + "\" not found");
}

function set$1(map, gameId, game) {
  Belt_MutableMap.set(map, gameId, game);
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

var remove$1 = Belt_MutableMap.remove;

function update$1(map, gameId, fn) {
  return Belt_Result.flatMap(get$1(map, gameId), (function (game) {
                return set$1(map, gameId, Curry._1(fn, game));
              }));
}

var ProgressGameMap = {
  GameId: GameId$1,
  empty: empty$1,
  get: get$1,
  set: set$1,
  create: create$1,
  remove: remove$1,
  update: update$1
};

var cmp$2 = Caml.caml_string_compare;

var PlayerId = Belt_Id.MakeComparable({
      cmp: cmp$2
    });

function empty$2(param) {
  return Belt_MutableMap.make(PlayerId);
}

function get$2(map, playerId) {
  return Utils.toResult(Belt_MutableMap.get(map, playerId), "Player \"" + playerId + "\" not found");
}

function set$2(map, game) {
  return function (param) {
    return Belt_MutableMap.set(map, game, param);
  };
}

function create$2(map, playerId) {
  var match = Belt_MutableMap.get(map, playerId);
  if (match !== undefined) {
    return {
            TAG: /* Error */1,
            _0: "Player " + playerId + " already exists"
          };
  }
  var player = Player.make(playerId);
  Belt_MutableMap.set(map, playerId, player);
  return {
          TAG: /* Ok */0,
          _0: player
        };
}

var PlayersMap = {
  PlayerId: PlayerId,
  empty: empty$2,
  get: get$2,
  set: set$2,
  create: create$2
};

export {
  MakeGameMap ,
  LobbyGameMap ,
  ProgressGameMap ,
  PlayersMap ,
  
}
/* GameId Not a pure module */
