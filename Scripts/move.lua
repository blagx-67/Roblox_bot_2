-- scripts/move.lua
-- Moves the bot's character in the specified direction.
-- Args (via server:command): direction = "forward" | "back" | "left" | "right", distance = number

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local char = lp and lp.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local humanoid = char and char:FindFirstChild("Humanoid")

if not hrp or not humanoid then
    return "No character found"
end

local distance = 10 -- default studs
local cf = hrp.CFrame

hrp.CFrame = cf * CFrame.new(0, 0, -distance) -- move forward
return "Moved forward " .. distance .. " studs"
