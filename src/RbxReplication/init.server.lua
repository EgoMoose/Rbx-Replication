local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local Server = script.Server
local Shared = script.Shared
local Client = script.Client

Client.Name = script.Name .. "Client"
Client.Parent = StarterPlayerScripts

Shared.Name = script.Name
Shared.Parent = ReplicatedStorage

require(Shared.RbxAPI)