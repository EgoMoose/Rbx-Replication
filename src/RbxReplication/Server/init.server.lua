local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local Core = script.Parent
local Server = Core.Server
local Shared = Core.Shared
local Client = Core.Client

Client.Name = Core.Name .. "Client"
Client.Parent = StarterPlayerScripts

Shared.Name = Core.Name .. "Shared"
Shared.Parent = ReplicatedStorage

require(Server.Remotes)
require(Shared.RbxAPI)