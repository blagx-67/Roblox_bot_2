const { WebSocketServer } = require("ws");
const { v4: uuidv4 } = require("uuid");

// In-memory bot registry
const bots = new Map(); // botId -> { ws, info, connectedAt }

function setupWebSocket(server) {
  const wss = new WebSocketServer({ server, path: "/ws" });

  wss.on("connection", (ws, req) => {
    const botId = uuidv4();
    console.log(`[WS] New connection: ${botId}`);

    ws.on("message", (raw) => {
      let msg;
      try {
        msg = JSON.parse(raw);
      } catch {
        return ws.send(JSON.stringify({ event: "error", data: "Invalid JSON" }));
      }

      switch (msg.event) {
        case "bot:register": {
          const secret = process.env.WS_SECRET;
          if (secret && msg.data?.secret !== secret) {
            ws.send(JSON.stringify({ event: "error", data: "Unauthorized" }));
            return ws.close();
          }

          bots.set(botId, {
            ws,
            info: msg.data || {},
            connectedAt: new Date().toISOString(),
            lastSeen: new Date().toISOString(),
          });

          ws.botId = botId;
          ws.send(JSON.stringify({ event: "server:registered", data: { botId } }));
          console.log(`[WS] Bot registered: ${botId} (${msg.data?.username || "unknown"})`);
          break;
        }

        case "bot:heartbeat": {
          if (bots.has(ws.botId)) {
            bots.get(ws.botId).lastSeen = new Date().toISOString();
          }
          ws.send(JSON.stringify({ event: "server:ack" }));
          break;
        }

        case "bot:result": {
          console.log(`[WS] Result from ${ws.botId}:`, msg.data);
          // Emit to any attached listeners (e.g., REST request waiting for result)
          if (ws._resultCallback) {
            ws._resultCallback(msg.data);
            ws._resultCallback = null;
          }
          break;
        }

        default:
          console.warn(`[WS] Unknown event: ${msg.event}`);
      }
    });

    ws.on("close", () => {
      if (ws.botId) {
        bots.delete(ws.botId);
        console.log(`[WS] Bot disconnected: ${ws.botId}`);
      }
    });

    ws.on("error", (err) => {
      console.error(`[WS] Error on ${botId}:`, err.message);
    });
  });

  console.log("[WS] WebSocket server ready on /ws");
  return wss;
}

function getBots() {
  const result = [];
  for (const [id, bot] of bots.entries()) {
    result.push({
      id,
      info: bot.info,
      connectedAt: bot.connectedAt,
      lastSeen: bot.lastSeen,
      status: bot.ws.readyState === 1 ? "online" : "offline",
    });
  }
  return result;
}

function getBot(id) {
  return bots.get(id) || null;
}

module.exports = { setupWebSocket, getBots, getBot };
