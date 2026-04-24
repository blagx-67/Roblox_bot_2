require("dotenv").config();
const express = require("express");
const http = require("http");
const path = require("path");
const { setupWebSocket } = require("./ws");
const botsRouter = require("./routes/bots");
const scriptsRouter = require("./routes/scripts");

const app = express();
const server = http.createServer(app);

const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, "../dashboard")));

// Routes
app.use("/api/bots", botsRouter);
app.use("/api/scripts", scriptsRouter);

app.get("/dashboard", (req, res) => {
  res.sendFile(path.join(__dirname, "../dashboard/index.html"));
});

app.get("/", (req, res) => {
  res.json({ status: "online", message: "Roblox Bot Controller" });
});

// WebSocket
setupWebSocket(server);

server.listen(PORT, () => {
  console.log(`[Server] Control server running on http://localhost:${PORT}`);
  console.log(`[Server] Dashboard: http://localhost:${PORT}/dashboard`);
});
