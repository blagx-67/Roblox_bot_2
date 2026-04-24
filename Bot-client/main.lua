-- ============================================================
-- Roblox Bot Client - main.lua
-- Connects to the control server and handles incoming events.
-- Inject this script via your preferred executor.
-- ============================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ┌─────────────────────────────────────────┐
-- │  CONFIG — edit these values             │
-- └─────────────────────────────────────────┘
local CONFIG = {
    SERVER_URL = "ws://localhost:3000/ws",  -- Control server WebSocket URL
    SECRET     = "change_this_to_a_strong_secret", -- Must match server WS_SECRET
    HEARTBEAT_INTERVAL = 15, -- seconds
}

-- ┌─────────────────────────────────────────┐
-- │  State                                  │
-- └─────────────────────────────────────────┘
local ws = nil
local connected = false
local botId = nil

-- ┌─────────────────────────────────────────┐
-- │  Helpers                                │
-- └─────────────────────────────────────────┘
local function send(event, data)
    if not ws then return end
    local ok, err = pcall(function()
        ws:Send(HttpService:JSONEncode({ event = event, data = data }))
    end)
    if not ok then
        warn("[BotClient] Send error:", err)
    end
end

local function safeExec(script)
    local fn, err = loadstring(script)
    if not fn then
        return false, "Compile error: " .. tostring(err)
    end
    local ok, result = pcall(fn)
    if not ok then
        return false, "Runtime error: " .. tostring(result)
    end
    return true, tostring(result or "")
end

-- ┌─────────────────────────────────────────┐
-- │  Event Handlers                         │
-- └─────────────────────────────────────────┘
local handlers = {}

handlers["server:registered"] = function(data)
    botId = data.botId
    print("[BotClient] Registered! Bot ID:", botId)
    connected = true
end

handlers["server:execute"] = function(data)
    local script = data.script
    if not script then return end
    print("[BotClient] Executing script...")
    local ok, result = safeExec(script)
    send("bot:result", { success = ok, output = result })
end

handlers["server:command"] = function(data)
    local cmd = data.command
    local args = data.args or {}
    print("[BotClient] Command received:", cmd)

    -- Built-in commands
    if cmd == "ping" then
        send("bot:result", { success = true, output = "pong" })

    elseif cmd == "getPosition" then
        local lp = Players.LocalPlayer
        local char = lp and lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            send("bot:result", {
                success = true,
                output = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
            })
        else
            send("bot:result", { success = false, output = "Character not found" })
        end

    elseif cmd == "chat" then
        if args.message then
            game:GetService("Chat"):Chat(
                Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head"),
                args.message, Enum.ChatColor.White
            )
            send("bot:result", { success = true, output = "Chatted: " .. args.message })
        end

    elseif cmd == "teleport" then
        local char = Players.LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and args.x and args.y and args.z then
            hrp.CFrame = CFrame.new(args.x, args.y, args.z)
            send("bot:result", { success = true, output = "Teleported" })
        else
            send("bot:result", { success = false, output = "Invalid args or no character" })
        end

    else
        send("bot:result", { success = false, output = "Unknown command: " .. cmd })
    end
end

handlers["server:disconnect"] = function()
    print("[BotClient] Disconnected by server.")
    connected = false
    if ws then ws:Close() end
end

handlers["server:ack"] = function() end -- heartbeat ack, no-op

handlers["error"] = function(data)
    warn("[BotClient] Server error:", data)
end

-- ┌─────────────────────────────────────────┐
-- │  Connection                             │
-- └─────────────────────────────────────────┘
local function connect()
    print("[BotClient] Connecting to", CONFIG.SERVER_URL)

    ws = game:GetService("HttpService"):WebSocketConnect(CONFIG.SERVER_URL)

    ws.OnMessage:Connect(function(raw)
        local ok, msg = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok or not msg.event then return end
        local handler = handlers[msg.event]
        if handler then
            pcall(handler, msg.data)
        else
            warn("[BotClient] Unhandled event:", msg.event)
        end
    end)

    ws.OnClose:Connect(function()
        print("[BotClient] Connection closed. Reconnecting in 5s...")
        connected = false
        task.wait(5)
        connect()
    end)

    -- Register with the server
    task.wait(0.5)
    send("bot:register", {
        secret   = CONFIG.SECRET,
        username = Players.LocalPlayer and Players.LocalPlayer.Name or "unknown",
        userId   = Players.LocalPlayer and Players.LocalPlayer.UserId or 0,
        gameId   = game.PlaceId,
    })
end

-- ┌─────────────────────────────────────────┐
-- │  Heartbeat Loop                         │
-- └─────────────────────────────────────────┘
task.spawn(function()
    while true do
        task.wait(CONFIG.HEARTBEAT_INTERVAL)
        if connected then
            send("bot:heartbeat", {})
        end
    end
end)

-- Start
connect()
