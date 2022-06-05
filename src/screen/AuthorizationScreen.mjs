// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Base from "../components/Base.mjs";
import * as Jzon from "rescript-jzon/src/Jzon.mjs";
import * as Curry from "rescript/lib/es6/curry.js";
import * as Utils from "../Utils.mjs";
import * as React from "react";
import * as Serializer from "../Serializer.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";

function AuthorizationScreen(Props) {
  var onLogin = Props.onLogin;
  var sessionIdOpt = Props.sessionId;
  var sessionId = sessionIdOpt !== undefined ? Caml_option.valFromOption(sessionIdOpt) : undefined;
  var match = React.useState(function () {
        return "";
      });
  var setLogin = match[1];
  var login = match[0];
  var match$1 = React.useState(function () {
        
      });
  var setError = match$1[1];
  var error = match$1[0];
  var match$2 = React.useState(function () {
        return false;
      });
  var setIsLoading = match$2[1];
  var makeAuthRequest = function (arg, value) {
    Curry._1(setIsLoading, (function (param) {
            return true;
          }));
    fetch(Utils.getFullUrl(false, undefined) + "/api/user?" + arg + "=" + value).then(function (prim) {
                  return prim.text();
                }).then(function (json) {
                return Promise.resolve(Serializer.deserializeUserApiResponse(json));
              }).then(function (response) {
              var tmp;
              if (response.TAG === /* Ok */0) {
                var err = response._0;
                var exit = 0;
                switch (err.TAG | 0) {
                  case /* Registered */0 :
                  case /* LoggedIn */1 :
                      exit = 1;
                      break;
                  case /* UserError */2 :
                      var err$1 = err._0;
                      tmp = Curry._1(setError, (function (param) {
                              return err$1;
                            }));
                      break;
                  
                }
                if (exit === 1) {
                  var player = err._0;
                  if (Belt_Option.isNone(sessionId)) {
                    sessionStorage.setItem("sessionId", player.sessionId);
                  }
                  tmp = Curry._1(onLogin, player);
                }
                
              } else {
                var err$2 = response._0;
                sessionStorage.setItem("sessionId", "");
                tmp = Curry._1(setError, (function (param) {
                        return Jzon.DecodingError.toString(err$2);
                      }));
              }
              return Promise.resolve(tmp);
            }).catch(function (param) {
            return Promise.resolve(undefined);
          }).then(function (param) {
          return Promise.resolve(Curry._1(setIsLoading, (function (param) {
                            return false;
                          })));
        });
    
  };
  React.useEffect((function () {
          var lsSessionId = sessionStorage.getItem("sessionId");
          var sessionId$1 = sessionId !== undefined ? sessionId : (
              (lsSessionId == null) ? "" : lsSessionId
            );
          if (sessionId$1 !== "") {
            makeAuthRequest("sessionId", sessionId$1);
          }
          
        }), []);
  var handleRegistrationClick = function (param) {
    return makeAuthRequest("playerId", login);
  };
  return React.createElement("div", {
              className: "flex flex-col gap-2"
            }, React.createElement(Base.Heading.make, {
                  size: /* H5 */3,
                  children: Utils.uiStr("Authorization")
                }), error !== undefined ? React.createElement("span", undefined, Utils.uiStr("Error: " + error)) : null, React.createElement(Base.Input.make, {
                  value: login,
                  disabled: match$2[0],
                  onChange: (function (value) {
                      return Curry._1(setLogin, (function (param) {
                                    return value;
                                  }));
                    })
                }), React.createElement(Base.Button.make, {
                  disabled: login === "",
                  onClick: handleRegistrationClick,
                  children: Utils.uiStr("Register")
                }));
}

var make = AuthorizationScreen;

export {
  make ,
  
}
/* Base Not a pure module */
