-- scripts/teleport.lua
-- Teleports the bot to a specific position.

local Players = game:GetService("Players")
local char = Players.LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if not hrp then return "No HumanoidRootPart found" end

local targetX, targetY, targetZ = 0, 10, 0 -- edit these coordinates

hrp.CFrame = CFrame.new(targetX, targetY, targetZ)

return string.format("Teleported to (%.1f, %.1f, %.1f)", targetX, targetY, targetZ)
