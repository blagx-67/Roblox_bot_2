-- scripts/chat.lua
-- Makes the bot send a chat message.

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local message = "Hello from the bot!"

game:GetService("Chat"):Chat(
    lp.Character and lp.Character:FindFirstChild("Head"),
    message,
    Enum.ChatColor.White
)

return "Sent: " .. message
