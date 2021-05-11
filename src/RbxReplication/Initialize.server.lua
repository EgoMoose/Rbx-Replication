local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local context = {}

local ServerCore = script.Parent
local RemotesFolder = ServerCore.Remotes
local ClientModule = ServerCore.ClientModule
local ClientInitialize = ClientModule.Initialize

-- create the remotes

local function createRemote(options)
	local remote = Instance.new(options.Type)

	local function onInvoke(player, ...)
		options.Callback(player, context, ...)
	end

	if options.Type == "RemoteFunction" then
		remote.OnServerInvoke = onInvoke
	else
		remote.OnServerEvent:Connect(onInvoke)
	end

	remote.Name = options.Name
	remote.Parent = options.Parent

	return remote
end

local newRemotes = Instance.new("Folder")
newRemotes.Name = "Remotes"
newRemotes.Parent = ClientModule

for _, folder in pairs(RemotesFolder:GetChildren()) do
	for _, group in pairs(folder:GetChildren()) do
		local remote = createRemote({
			Name = group.Name,
			Type = "Remote" .. folder.Name:sub(1, -2),
			Callback = require(group.Server),
			Parent = newRemotes,
		})

		group.Client.Parent = remote
	end
end

-- Parent and rename
ServerCore.Utility:Clone().Parent = ClientModule

ClientModule.Name = ServerCore.Name
ClientInitialize.Name = ServerCore.Name

ClientModule.Parent = ReplicatedStorage
ClientInitialize.Parent = StarterPlayerScripts

-- Update context
context.RbxAPI = require(ClientModule.RbxAPI)
context.RbxReplication = require(ServerCore)
context.Remotes = newRemotes

for _, module in pairs(context) do
	if type(module) == "table" then
		module._context = context
	end
end