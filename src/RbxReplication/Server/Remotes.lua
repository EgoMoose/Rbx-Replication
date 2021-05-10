local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = script.Parent.Parent
local Shared = ReplicatedStorage:WaitForChild(Core.Name .. "Shared")
local RemotesFolder = Shared.Remotes

local function createRemote(options)
	local remote = Instance.new(options.Type)

	local function onInvoke(player, ...)
		options.Callback(remote, player, ...)
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

createRemote({
	Type = "RemoteFunction",
	Name = "Pull",
	Parent = RemotesFolder,
	Callback = function(remote, player)

	end,
})

return true