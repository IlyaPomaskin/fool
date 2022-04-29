const Http = require("http");

global.httpServer = null;

console.log("RELOAD");

function restartServer() {
  if (global.httpServer && global.httpServer.listening) {
    console.log("LISTENING");
    global.httpServer.close(function (err) {
      if (!(err == null)) {
        console.log("CLOSE ERROR", err);
        return;
      }

      console.log("CLOSE");
    });
  } else {
    console.log("NOT LISTENING");
  }

  global.httpServer = Http.createServer();
  global.httpServer.listen(3001, "localhost", undefined);
  return global.httpServer;
}

global.restartServer = restartServer;
