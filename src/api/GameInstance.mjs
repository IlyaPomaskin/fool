// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Game from "../fool/Game.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as Player from "../fool/Player.mjs";
import * as Socket from "../Socket.mjs";
import * as GameMap from "../GameMap.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as GameUtils from "../fool/GameUtils.mjs";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";

var LobbyGameMap = GameMap.MakeGameMap({});

var ProgressGameMap = GameMap.MakeGameMap({});

var gamesInLobby = Curry._1(LobbyGameMap.empty, undefined);

var gamesInProgress = Curry._1(ProgressGameMap.empty, undefined);

var author = Player.make("owner");

var client = Player.make("user2");

var players_1 = {
  hd: client,
  tl: /* [] */0
};

var players = {
  hd: author,
  tl: players_1
};

Curry._3(LobbyGameMap.set, gamesInLobby, "GAME_ID", {
      gameId: "GAME_ID",
      players: players,
      ready: players
    });

function startGame(gameId) {
  var nextGame = Belt_Result.flatMap(Curry._2(LobbyGameMap.get, gamesInLobby, gameId), Game.startGame);
  if (nextGame.TAG !== /* Ok */0) {
    return Socket.SServer.broadcast(gameId, {
                error: nextGame._0
              });
  }
  var game = nextGame._0;
  Curry._3(ProgressGameMap.set, gamesInProgress, gameId, game);
  return Belt_List.forEach(game.players, (function (player) {
                return Socket.SServer.send(player, Game.toObject(Game.maskForPlayer(player, game)));
              }));
}

function dispatch(gameId, playerId, action) {
  var game = Curry._2(ProgressGameMap.get, gamesInProgress, gameId);
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
    if (player.TAG === /* Ok */0) {
      Curry._3(ProgressGameMap.set, gamesInProgress, game$1.gameId, game$1);
      result = {
        TAG: /* Ok */0,
        _0: Game.maskForPlayer(player._0, game$1)
      };
    } else {
      result = {
        TAG: /* Error */1,
        _0: player._0
      };
    }
  } else {
    result = {
      TAG: /* Error */1,
      _0: nextGame._0
    };
  }
  if (result.TAG === /* Ok */0) {
    console.log("[dispatch] ok ", Game.toObject(result._0));
    return ;
  }
  console.log("[dispatch] error ", result._0);
  
}

startGame("GAME_ID");

export {
  LobbyGameMap ,
  ProgressGameMap ,
  gamesInLobby ,
  gamesInProgress ,
  author ,
  client ,
  players ,
  startGame ,
  dispatch ,
  
}
/* LobbyGameMap Not a pure module */