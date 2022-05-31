import { createServer } from "http";
import { parse } from "url";
import next from "next";

const hostname = "localhost";
const port = 3000;
const app = next({ dev: true, hostname, port });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  const server = createServer();

  server.on("request", async (req, res) => {
    try {
      const parsedUrl = parse(req.url, true);

      await handle(req, res, parsedUrl);
    } catch (err) {
      console.error("Error occurred handling", req.url, err);
      res.statusCode = 500;
      res.end("internal server error");
    }
  });

  app.server.setupWebSocketHandler(server);

  server.listen(port, (err) => {
    if (err) throw err;
    console.log(`> Ready on http://${hostname}:${port}`);
  });
});
