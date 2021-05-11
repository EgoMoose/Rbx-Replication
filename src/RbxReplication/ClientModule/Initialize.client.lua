local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local context = {}

local ClientCore = ReplicatedStorage:WaitForChild(script.Name)
local RemotesFolder = ClientCore.Remotes

-- create the remotes

for _, remote in pairs(RemotesFolder:GetChildren()) do
	local callback = require(remote.Client)
	if remote.ClassName == "RemoteFunction" then
		remote.OnClientInvoke = function(...)
			callback(Players.LocalPlayer, context, ...)
		end
	elseif remote.ClassName == "RemoteEvent" then
		remote.OnClientEvent:Connect(function(...)
			callback(Players.LocalPlayer, context, ...)
		end)
	end	
end

context.RbxAPI = require(ClientCore.RbxAPI)
context.Nodes = require(ClientCore.Nodes)
context.RbxReplication = require(ClientCore)

for _, module in pairs(context) do
	if type(module) == "table" then
		module._context = context
	end
end