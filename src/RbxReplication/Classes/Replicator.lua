local Paths = require(script:FindFirstAncestor("RbxReplication").Paths)
local Remotes = require(Paths.Server.Services.Remotes)
local t = require(Paths.Client.Utility.t)

local ReplicatorClass = {}
ReplicatorClass.__index = ReplicatorClass
ReplicatorClass.ClassName = "Replicator"

function ReplicatorClass.new(instance)
	local self = setmetatable({}, ReplicatorClass)

	self._replicatedProperties = true

	self.Instance = instance
	self.Owner = nil

	return self
end

-- Private

local validateProperties = t.map(
	t.string, 
	t.union(t.boolean, t.callback)
)

-- Public

function ReplicatorClass:SetNetworkOwner(player)
	if self.Owner then
		Remotes.ClaimOwnership:FireClient(
			self.Owner,
			self.Instance,
			false
		)
	end

	self.Owner = player

	if self.Owner then
		Remotes.ClaimOwnership:FireClient(
			self.Owner,
			self.Instance,
			self._replicatedProperties
		)
	end
end

function ReplicatorClass:SetReplicatedProperties(properties)
	if properties == "All" then
		properties = true
	else
		assert(validateProperties(properties), "Properties failed validation.")
	end

	self._replicatedProperties = properties

	if self.Owner then
		Remotes.ClaimOwnership:FireClient(
			self.Owner, 
			self.Instance, 
			self._replicatedProperties
		)
	end
end

--

return ReplicatorClass