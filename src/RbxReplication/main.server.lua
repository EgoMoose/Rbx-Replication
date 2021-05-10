local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local Core = script.Parent
local Client = Core.Client

Client.Name = Core.Name
Client.Parent = ReplicatedStorage

local clientMain = Client.main
clientMain.Name = Core.Name
clientMain.Parent = StarterPlayerScripts

-- Startup server
require(script.Parent)