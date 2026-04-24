# 🤖 Roblox Bot Controller

A full-stack framework for deploying, managing, and executing scripts on Roblox bots via a central control server.

## 📁 Project Structure

```
roblox-bot-controller/
├── server/           # Node.js control server (Express + WebSocket)
│   ├── index.js      # Main server entry point
│   ├── routes/       # REST API routes
│   └── ws.js         # WebSocket handler
├── bot-client/       # Lua scripts injected into Roblox clients
│   ├── main.lua      # Bot bootstrap / heartbeat
│   └── executor.lua  # Remote script execution handler
├── scripts/          # Pre-built Lua scripts to push to bots
│   ├── move.lua
│   ├── chat.lua
│   └── teleport.lua
├── dashboard/        # Web dashboard (HTML/JS)
│   └── index.html
└── .github/workflows/
    └── deploy.yml
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Fill in your values
```

### 3. Start the Control Server

```bash
npm start
```

The server runs on `http://localhost:3000` by default.

### 4. Connect a Bot Client

Inject `bot-client/main.lua` into your Roblox session. The bot will automatically connect to the control server via WebSocket.

## 🔌 API Reference

### REST Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/bots` | List all connected bots |
| `POST` | `/api/bots/:id/execute` | Execute a Lua script on a bot |
| `POST` | `/api/bots/:id/command` | Send a command to a bot |
| `DELETE` | `/api/bots/:id` | Disconnect a bot |
| `GET` | `/api/scripts` | List available scripts |

### WebSocket Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `bot:register` | Client → Server | Bot identifies itself |
| `bot:heartbeat` | Client → Server | Keep-alive ping |
| `bot:result` | Client → Server | Script execution result |
| `server:execute` | Server → Client | Execute a Lua script |
| `server:command` | Server → Client | Send a named command |

## 📜 Example: Execute a Script

```bash
curl -X POST http://localhost:3000/api/bots/BOT_ID/execute \
  -H "Content-Type: application/json" \
  -d '{"script": "print(game.Players.LocalPlayer.Name)"}'
```

## 🖥️ Dashboard

Open `dashboard/index.html` or visit `http://localhost:3000/dashboard` to manage bots via a browser UI.

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `WS_SECRET` | — | Shared secret for bot auth |
| `MAX_BOTS` | `50` | Max simultaneous bots |

## 📦 Dependencies

- `express` — REST API server
- `ws` — WebSocket server
- `uuid` — Bot ID generation
- `dotenv` — Environment config

## 📄 License

MIT
