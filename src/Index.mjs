// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as ReactDnd from "react-dnd";
import * as PlayerScreen from "./PlayerScreen.mjs";
import * as ReactDndTouchBackend from "react-dnd-touch-backend";

function $$default(param) {
  return React.createElement("div", {
              className: "select-none flex flex-row flex-wrap justify-items-center w-full container px-12 py-6 gap-12"
            }, React.createElement(ReactDnd.DndProvider, {
                  backend: ReactDndTouchBackend.TouchBackend,
                  options: {
                    enableTouchEvents: false,
                    enableMouseEvents: false,
                    ignoreContextMenu: false
                  },
                  children: null
                }, React.createElement(PlayerScreen.make, {
                      gameId: "g1",
                      sessionId: "s:p1"
                    }), React.createElement(PlayerScreen.make, {
                      gameId: "g1",
                      sessionId: "s:p2"
                    })));
}

export {
  $$default ,
  $$default as default,
  
}
/* react Not a pure module */
