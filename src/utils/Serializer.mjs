// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Card from "../fool/Card.mjs";
import * as Jzon from "rescript-jzon/src/Jzon.mjs";
import * as Js_json from "rescript/lib/es6/js_json.js";
import * as MOption from "./MOption.mjs";
import * as Belt_List from "rescript/lib/es6/belt_List.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Belt_Result from "rescript/lib/es6/belt_Result.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

var card = Jzon.custom(Card.cardToString, (function (json) {
        var parsedCard = Card.stringToCard(Belt_Option.getWithDefault(Js_json.decodeString(json), ""));
        if (parsedCard !== undefined) {
          return {
                  TAG: /* Ok */0,
                  _0: parsedCard
                };
        } else {
          return {
                  TAG: /* Error */1,
                  _0: {
                    NAME: "UnexpectedJsonValue",
                    VAL: [
                      [{
                          TAG: /* Field */0,
                          _0: "card"
                        }],
                      JSON.stringify(json)
                    ]
                  }
                };
        }
      }));

var suit = Jzon.custom(Card.suitToString, (function (json) {
        var suit = Belt_Option.flatMap(Js_json.decodeString(json), Card.stringToSuit);
        if (suit !== undefined) {
          return {
                  TAG: /* Ok */0,
                  _0: suit
                };
        } else {
          return {
                  TAG: /* Error */1,
                  _0: {
                    NAME: "UnexpectedJsonValue",
                    VAL: [
                      [{
                          TAG: /* Field */0,
                          _0: "suit"
                        }],
                      "s"
                    ]
                  }
                };
        }
      }));

var tablePair = Jzon.object2((function (param) {
        return [
                param[0],
                param[1]
              ];
      }), (function (param) {
        return {
                TAG: /* Ok */0,
                _0: [
                  param[0],
                  param[1]
                ]
              };
      }), Jzon.field("to", card), Jzon.optional(Jzon.field("by", card)));

var playerMsg = Jzon.object2((function (kind) {
        if (typeof kind !== "number") {
          return [
                  "connect",
                  kind._0
                ];
        }
        switch (kind) {
          case /* Disconnect */0 :
              return [
                      "disconnect",
                      undefined
                    ];
          case /* Ping */1 :
              return [
                      "ping",
                      undefined
                    ];
          case /* Pong */2 :
              return [
                      "pong",
                      undefined
                    ];
          
        }
      }), (function (param) {
        var gameId = param[1];
        var kind = param[0];
        switch (kind) {
          case "connect" :
              if (gameId !== undefined) {
                return {
                        TAG: /* Ok */0,
                        _0: /* Connect */{
                          _0: gameId
                        }
                      };
              }
              break;
          case "disconnect" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Disconnect */0
                    };
          case "ping" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Ping */1
                    };
          case "pong" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Pong */2
                    };
          default:
            
        }
        return {
                TAG: /* Error */1,
                _0: {
                  NAME: "UnexpectedJsonValue",
                  VAL: [
                    [{
                        TAG: /* Field */0,
                        _0: "kind"
                      }],
                    kind
                  ]
                }
              };
      }), Jzon.field("kind", Jzon.string), Jzon.optional(Jzon.field("payload", Jzon.string)));

var lobbyMsg = Jzon.object1((function (kind) {
        switch (kind) {
          case /* Create */0 :
              return "create";
          case /* Enter */1 :
              return "enter";
          case /* Ready */2 :
              return "ready";
          case /* Start */3 :
              return "start";
          
        }
      }), (function (kind) {
        switch (kind) {
          case "create" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Create */0
                    };
          case "enter" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Enter */1
                    };
          case "ready" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Ready */2
                    };
          case "start" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Start */3
                    };
          default:
            return {
                    TAG: /* Error */1,
                    _0: {
                      NAME: "UnexpectedJsonValue",
                      VAL: [
                        [{
                            TAG: /* Field */0,
                            _0: "kind"
                          }],
                        kind
                      ]
                    }
                  };
        }
      }), Jzon.field("kind", Jzon.string));

var beatPayload = Jzon.object2((function (param) {
        return [
                param.to,
                param.by
              ];
      }), (function (param) {
        return {
                TAG: /* Ok */0,
                _0: {
                  to: param[0],
                  by: param[1]
                }
              };
      }), Jzon.field("to", card), Jzon.field("by", card));

var movePayload = Jzon.object1((function (param) {
        return param.card;
      }), (function (card) {
        return {
                TAG: /* Ok */0,
                _0: {
                  card: card
                }
              };
      }), Jzon.field("card", card));

var progressMsg = Jzon.object2((function (kind) {
        if (typeof kind === "number") {
          if (kind === /* Take */0) {
            return [
                    "take",
                    undefined
                  ];
          } else {
            return [
                    "pass",
                    undefined
                  ];
          }
        } else if (kind.TAG === /* Beat */0) {
          return [
                  "beat",
                  Caml_option.some(Jzon.encodeWith({
                            to: kind._0,
                            by: kind._1
                          }, beatPayload))
                ];
        } else {
          return [
                  "move",
                  Caml_option.some(Jzon.encodeWith({
                            card: kind._0
                          }, movePayload))
                ];
        }
      }), (function (param) {
        var payload = param[1];
        var kind = param[0];
        switch (kind) {
          case "beat" :
              if (payload !== undefined) {
                return Belt_Result.map(Jzon.decodeWith(Caml_option.valFromOption(payload), beatPayload), (function (param) {
                              return {
                                      TAG: /* Beat */0,
                                      _0: param.to,
                                      _1: param.by
                                    };
                            }));
              }
              break;
          case "move" :
              if (payload !== undefined) {
                return Belt_Result.map(Jzon.decodeWith(Caml_option.valFromOption(payload), movePayload), (function (param) {
                              return {
                                      TAG: /* Move */1,
                                      _0: param.card
                                    };
                            }));
              }
              break;
          case "pass" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Pass */1
                    };
          case "take" :
              return {
                      TAG: /* Ok */0,
                      _0: /* Take */0
                    };
          default:
            
        }
        return {
                TAG: /* Error */1,
                _0: {
                  NAME: "UnexpectedJsonValue",
                  VAL: [
                    [{
                        TAG: /* Field */0,
                        _0: "kind"
                      }],
                    kind
                  ]
                }
              };
      }), Jzon.field("kind", Jzon.string), Jzon.optional(Jzon.field("payload", Jzon.json)));

var gameMsg = Jzon.object4((function (kind) {
        switch (kind.TAG | 0) {
          case /* Player */0 :
              return [
                      "player",
                      Jzon.encodeWith(kind._0, playerMsg),
                      kind._1,
                      undefined
                    ];
          case /* Lobby */1 :
              return [
                      "lobby",
                      Jzon.encodeWith(kind._0, lobbyMsg),
                      kind._1,
                      kind._2
                    ];
          case /* Progress */2 :
              return [
                      "progress",
                      Jzon.encodeWith(kind._0, progressMsg),
                      kind._1,
                      kind._2
                    ];
          
        }
      }), (function (param) {
        var gameId = param[3];
        var playerId = param[2];
        var msg = param[1];
        var kind = param[0];
        switch (kind) {
          case "lobby" :
              return Belt_Result.flatMap(MOption.toResult(gameId, {
                              NAME: "UnexpectedJsonValue",
                              VAL: [
                                [{
                                    TAG: /* Field */0,
                                    _0: "gameId"
                                  }],
                                JSON.stringify(msg)
                              ]
                            }), (function (gameId) {
                            return Belt_Result.flatMap(Jzon.decodeWith(msg, lobbyMsg), (function (lobbyMessage) {
                                          return {
                                                  TAG: /* Ok */0,
                                                  _0: {
                                                    TAG: /* Lobby */1,
                                                    _0: lobbyMessage,
                                                    _1: playerId,
                                                    _2: gameId
                                                  }
                                                };
                                        }));
                          }));
          case "player" :
              return Belt_Result.map(Jzon.decodeWith(msg, playerMsg), (function (msg) {
                            return {
                                    TAG: /* Player */0,
                                    _0: msg,
                                    _1: playerId
                                  };
                          }));
          case "progress" :
              return Belt_Result.flatMap(MOption.toResult(gameId, {
                              NAME: "UnexpectedJsonValue",
                              VAL: [
                                [{
                                    TAG: /* Field */0,
                                    _0: "gameId"
                                  }],
                                JSON.stringify(msg)
                              ]
                            }), (function (gameId) {
                            return Belt_Result.flatMap(Jzon.decodeWith(msg, progressMsg), (function (move) {
                                          return {
                                                  TAG: /* Ok */0,
                                                  _0: {
                                                    TAG: /* Progress */2,
                                                    _0: move,
                                                    _1: playerId,
                                                    _2: gameId
                                                  }
                                                };
                                        }));
                          }));
          default:
            return {
                    TAG: /* Error */1,
                    _0: {
                      NAME: "UnexpectedJsonValue",
                      VAL: [
                        [{
                            TAG: /* Field */0,
                            _0: "kind"
                          }],
                        kind
                      ]
                    }
                  };
        }
      }), Jzon.field("kind", Jzon.string), Jzon.field("payload", Jzon.json), Jzon.field("playerId", Jzon.string), Jzon.optional(Jzon.field("gameId", Jzon.string)));

function serializeClientMessage(msg) {
  return Jzon.encodeStringWith(msg, gameMsg);
}

function deserializeClientMessage(msg) {
  return Jzon.decodeStringWith(msg, gameMsg);
}

function listViaArray(elementCodec) {
  return Jzon.custom((function (list) {
                return Jzon.encodeWith(Belt_List.toArray(list), Jzon.array(elementCodec));
              }), (function (json) {
                return Belt_Result.map(Jzon.decodeWith(json, Jzon.array(elementCodec)), Belt_List.fromArray);
              }));
}

var tableCards = listViaArray(tablePair);

var listOfPlayerIds = listViaArray(Jzon.string);

var playerMsg$1 = Jzon.object3((function (param) {
        return [
                param.id,
                param.sessionId,
                param.cards
              ];
      }), (function (param) {
        return {
                TAG: /* Ok */0,
                _0: {
                  id: param[0],
                  sessionId: param[1],
                  cards: param[2]
                }
              };
      }), Jzon.field("id", Jzon.string), Jzon.field("sessionId", Jzon.string), Jzon.field("cards", listViaArray(card)));

var inLobbyMsg = Jzon.object4((function (param) {
        return [
                param.gameId,
                param.players,
                param.ready,
                param.owner
              ];
      }), (function (param) {
        return {
                TAG: /* Ok */0,
                _0: {
                  owner: param[3],
                  gameId: param[0],
                  players: param[1],
                  ready: param[2]
                }
              };
      }), Jzon.field("gameId", Jzon.string), Jzon.field("players", listViaArray(playerMsg$1)), Jzon.field("ready", listOfPlayerIds), Jzon.field("owner", Jzon.string));

var inProgressMsg = Jzon.object9((function (param) {
        return [
                param.gameId,
                param.attacker,
                param.defender,
                param.players,
                param.trump,
                param.deck,
                param.table,
                param.pass,
                param.disconnected
              ];
      }), (function (param) {
        return {
                TAG: /* Ok */0,
                _0: {
                  gameId: param[0],
                  attacker: param[1],
                  defender: param[2],
                  players: param[3],
                  disconnected: param[8],
                  trump: param[4],
                  deck: param[5],
                  table: param[6],
                  pass: param[7]
                }
              };
      }), Jzon.field("gameId", Jzon.string), Jzon.field("attacker", Jzon.string), Jzon.field("defender", Jzon.string), Jzon.field("players", listViaArray(playerMsg$1)), Jzon.field("trump", suit), Jzon.field("deck", listViaArray(card)), Jzon.field("table", tableCards), Jzon.field("pass", listOfPlayerIds), Jzon.field("disconnected", listOfPlayerIds));

var serverGameMsg = Jzon.object2((function (kind) {
        switch (kind.TAG | 0) {
          case /* Connected */0 :
              return [
                      "connected",
                      Jzon.encodeWith(kind._0, playerMsg$1)
                    ];
          case /* LobbyCreated */1 :
              return [
                      "lobbyCreated",
                      Jzon.encodeWith(kind._0, inLobbyMsg)
                    ];
          case /* LobbyUpdated */2 :
              return [
                      "lobbyUpdated",
                      Jzon.encodeWith(kind._0, inLobbyMsg)
                    ];
          case /* ProgressCreated */3 :
              return [
                      "progressCreated",
                      Jzon.encodeWith(kind._0, inProgressMsg)
                    ];
          case /* ProgressUpdated */4 :
              return [
                      "progressUpdated",
                      Jzon.encodeWith(kind._0, inProgressMsg)
                    ];
          case /* ServerError */5 :
              return [
                      "error",
                      Jzon.encodeWith(kind._0, Jzon.string)
                    ];
          case /* LoginError */6 :
              return [
                      "loginError",
                      Jzon.encodeWith(kind._0, Jzon.string)
                    ];
          case /* RegisterError */7 :
              return [
                      "registerError",
                      Jzon.encodeWith(kind._0, Jzon.string)
                    ];
          
        }
      }), (function (param) {
        var payload = param[1];
        var kind = param[0];
        switch (kind) {
          case "connected" :
              return Belt_Result.map(Jzon.decodeWith(payload, playerMsg$1), (function (player) {
                            return {
                                    TAG: /* Connected */0,
                                    _0: player
                                  };
                          }));
          case "error" :
              return Belt_Result.map(Jzon.decodeWith(payload, Jzon.string), (function (msg) {
                            return {
                                    TAG: /* ServerError */5,
                                    _0: msg
                                  };
                          }));
          case "lobbyCreated" :
              return Belt_Result.map(Jzon.decodeWith(payload, inLobbyMsg), (function (game) {
                            return {
                                    TAG: /* LobbyCreated */1,
                                    _0: game
                                  };
                          }));
          case "lobbyUpdated" :
              return Belt_Result.map(Jzon.decodeWith(payload, inLobbyMsg), (function (game) {
                            return {
                                    TAG: /* LobbyUpdated */2,
                                    _0: game
                                  };
                          }));
          case "progressCreated" :
              return Belt_Result.map(Jzon.decodeWith(payload, inProgressMsg), (function (game) {
                            return {
                                    TAG: /* ProgressCreated */3,
                                    _0: game
                                  };
                          }));
          case "progressUpdated" :
              return Belt_Result.map(Jzon.decodeWith(payload, inProgressMsg), (function (game) {
                            return {
                                    TAG: /* ProgressUpdated */4,
                                    _0: game
                                  };
                          }));
          default:
            return {
                    TAG: /* Error */1,
                    _0: {
                      NAME: "UnexpectedJsonValue",
                      VAL: [
                        [{
                            TAG: /* Field */0,
                            _0: "kind"
                          }],
                        kind
                      ]
                    }
                  };
        }
      }), Jzon.field("kind", Jzon.string), Jzon.field("payload", Jzon.json));

function serializeServerMessage(msg) {
  return Jzon.encodeStringWith(msg, serverGameMsg);
}

function deserializeServerMessage(msg) {
  return Jzon.decodeStringWith(msg, serverGameMsg);
}

var userApiResponseMsg = Jzon.object2((function (kind) {
        switch (kind.TAG | 0) {
          case /* Registered */0 :
              return [
                      "registered",
                      Jzon.encodeWith(kind._0, playerMsg$1)
                    ];
          case /* LoggedIn */1 :
              return [
                      "loggedin",
                      Jzon.encodeWith(kind._0, playerMsg$1)
                    ];
          case /* UserError */2 :
              return [
                      "userError",
                      Jzon.encodeWith(kind._0, Jzon.string)
                    ];
          
        }
      }), (function (param) {
        var payload = param[1];
        var kind = param[0];
        switch (kind) {
          case "loggedin" :
              return Belt_Result.map(Jzon.decodeWith(payload, playerMsg$1), (function (player) {
                            return {
                                    TAG: /* LoggedIn */1,
                                    _0: player
                                  };
                          }));
          case "registered" :
              return Belt_Result.map(Jzon.decodeWith(payload, playerMsg$1), (function (player) {
                            return {
                                    TAG: /* Registered */0,
                                    _0: player
                                  };
                          }));
          case "userError" :
              return Belt_Result.map(Jzon.decodeWith(payload, Jzon.string), (function (err) {
                            return {
                                    TAG: /* UserError */2,
                                    _0: err
                                  };
                          }));
          default:
            return {
                    TAG: /* Error */1,
                    _0: {
                      NAME: "UnexpectedJsonValue",
                      VAL: [
                        [{
                            TAG: /* Field */0,
                            _0: "kind"
                          }],
                        kind
                      ]
                    }
                  };
        }
      }), Jzon.field("kind", Jzon.string), Jzon.field("payload", Jzon.json));

function serializeUserApiResponse(response) {
  return Jzon.encodeStringWith(response, userApiResponseMsg);
}

function deserializeUserApiResponse(response) {
  return Jzon.decodeStringWith(response, userApiResponseMsg);
}

export {
  card ,
  suit ,
  tablePair ,
  lobbyMsg ,
  beatPayload ,
  movePayload ,
  progressMsg ,
  gameMsg ,
  serializeClientMessage ,
  deserializeClientMessage ,
  listViaArray ,
  tableCards ,
  listOfPlayerIds ,
  playerMsg$1 as playerMsg,
  inLobbyMsg ,
  inProgressMsg ,
  serverGameMsg ,
  serializeServerMessage ,
  deserializeServerMessage ,
  userApiResponseMsg ,
  serializeUserApiResponse ,
  deserializeUserApiResponse ,
  
}
/* card Not a pure module */
