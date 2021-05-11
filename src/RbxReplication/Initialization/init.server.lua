local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local Core = script.Parent
local Client = Core.Client

Client.Name = Core.Name
Client.Parent = ReplicatedStorage

local clientMain = script.main
clientMain.Name = Core.Name
clientMain.Parent = StarterPlayerScripts

-- Startup server
require(Core)