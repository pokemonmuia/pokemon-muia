// Pokémon Muia: ponte WebSocket <-> UDP davanti al server del multiplayer.
//
// Le pagine web no pol parlar in UDP, ma sì in WebSocket. Qua ogni zogador che
// se conete dal browser riceve una so "porta UDP" interna, e i messaggi (che qua
// no se lexe: i xe bytes compressi che capisse solo el server Ruby) i va e i vien
// così come i xe. Cussì el server Ruby no se acorze de la diferensa fra un
// zogador col Game.exe e uno dal browser.
//
// Fa anca partir el server Ruby (muia_server.rb) e lo fa ripartir se el casca.
const http = require("http");
const dgram = require("dgram");
const { spawn } = require("child_process");
const path = require("path");
const { WebSocketServer } = require("ws");

const PORTA_WEB = Number(process.env.PORT || 8080);
const PORTA_UDP = Number(process.env.VMS_PORT || 19457);
const MAX_ZOGADORI = Number(process.env.MAX_CONNESSIONI || 12);
const MAX_BYTE = 65536;
// Pagine autorizzade a conetarse (el browser manda sempre l'origine)
const ORIGINI = (
  process.env.ORIGINI_OK ||
  "https://pokemonmuia.github.io,http://localhost:8099,http://127.0.0.1:8099"
)
  .split(",")
  .map((s) => s.trim())
  .filter((s) => s.length > 0);

const log = (...a) => console.log(new Date().toISOString().slice(11, 19), ...a);

// ---- server Ruby -------------------------------------------------------
let ruby = null;
let fermo = false;
const avviaRuby = () => {
  ruby = spawn("ruby", [path.join(__dirname, "muia_server.rb")], {
    env: { ...process.env, VMS_PORT: String(PORTA_UDP), VMS_HOST: "127.0.0.1" },
    stdio: ["ignore", "inherit", "inherit"],
  });
  ruby.on("exit", (codice) => {
    log("server Ruby fermo, codice", codice);
    ruby = null;
    if (!fermo) {
      setTimeout(avviaRuby, 1000);
    }
  });
};
avviaRuby();

// ---- ponte -------------------------------------------------------------
const server = http.createServer((req, res) => {
  // Serve solo a "svejar" el server: la pagina ghe fa un GET prima de conetarse
  res.writeHead(200, {
    "Content-Type": "text/plain; charset=utf-8",
    "Access-Control-Allow-Origin": "*",
  });
  res.end("Server Pokémon Muia: ativo\n");
});
const wss = new WebSocketServer({
  server,
  path: "/ws",
  maxPayload: MAX_BYTE,
  verifyClient: ({ origin }) => origin === undefined || ORIGINI.includes(origin),
});

let connessi = 0;
wss.on("connection", (ws) => {
  if (connessi >= MAX_ZOGADORI) {
    ws.close(1013, "pien");
    return;
  }
  connessi++;
  const udp = dgram.createSocket("udp4");
  let ultimo = Date.now();
  udp.on("message", (msg) => {
    if (ws.readyState === ws.OPEN) {
      ws.send(msg, { binary: true });
    }
  });
  udp.on("error", (err) => log("udp:", err.message));
  ws.on("message", (msg, isBinary) => {
    ultimo = Date.now();
    if (isBinary && msg.length > 0) {
      udp.send(msg, PORTA_UDP, "127.0.0.1");
    }
  });
  // un messagio ogni 20 secondi tien viva la conession anca dietro proxy
  const batito = setInterval(() => {
    if (Date.now() - ultimo > 120000) {
      ws.terminate();
    } else if (ws.readyState === ws.OPEN) {
      ws.ping();
    }
  }, 20000);
  ws.on("pong", () => {
    ultimo = Date.now();
  });
  const chiudi = () => {
    clearInterval(batito);
    try {
      udp.close();
    } catch (err) {
      // za serà
    }
    connessi--;
  };
  ws.once("close", chiudi);
  ws.on("error", () => ws.terminate());
  log("zogador conetù (" + connessi + " in totale)");
});

server.listen(PORTA_WEB, () => log("ponte in ascolto su porta", PORTA_WEB));

const ferma = () => {
  fermo = true;
  if (ruby) {
    ruby.kill("SIGTERM");
  }
  process.exit(0);
};
process.on("SIGTERM", ferma);
process.on("SIGINT", ferma);
