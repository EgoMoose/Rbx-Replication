local Paths = require(script:FindFirstAncestor("RbxReplication").Modules.Paths)
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
local RbxReplication = nil

function module.Register(rbxReplication)
	RbxReplication = rbxReplication
end

module.ClaimOwnership = createRemote({
	Type = "RemoteEvent",
	Name = "ClaimOwnership",
	Callback = function(remote, player)
		
	end,
})

module.Push = createRemote({
	Type = "RemoteEvent",
	Name = "Push",
	Callback = function(remote, player, instance, pool)
		local owner = RbxReplication.GetOwner(instance)
		if owner == player then
			for property, value in pairs(pool) do
				instance[property] = value
			end
		end
	end,
})

return module