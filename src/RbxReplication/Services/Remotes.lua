local Paths = require(script:FindFirstAncestor("RbxReplication").Paths)
local RemotesFolder = Paths.Client.Remotes

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
	remote.Parent = RemotesFolder

	return remote
end

local module = {}

module.ClaimOwnership = createRemote({
	Type = "RemoteEvent",
	Name = "ClaimOwnership",
	Callback = function(remote, player)
		
	end,
})


return module