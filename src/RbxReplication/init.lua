local Paths = require(script.Modules.Paths)
local RbxAPI = require(Paths.Client.Modules.RbxAPI)
local Remotes = require(Paths.Server.Modules.Remotes)
local t = require(Paths.Client.Utility.t)

local ReplicatorClass = {}
ReplicatorClass.__index = ReplicatorClass
ReplicatorClass.ClassName = "Replicator"

function ReplicatorClass.new(instance)
	local self = setmetatable({}, ReplicatorClass)

	self._properties = true

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
			self._properties
		)
	end
end

function ReplicatorClass:SetReplicatedProperties(properties)
	if properties == "All" then
		properties = true
	else
		assert(validateProperties(properties), "Properties failed validation.")
	end

	self._properties = properties

	if self.Owner then
		Remotes.ClaimOwnership:FireClient(
			self.Owner, 
			self.Instance, 
			self._properties
		)
	end
end

-- Public Module

local module = {}
local replicators = {}

function module.GetReplicator(instance)
	if not replicators[instance] then
		replicators[instance] = ReplicatorClass.new(instance)
	end
	return replicators[instance]
end

function module.GetOwner(instance)
	if replicators[instance] then
		return replicators[instance].Owner
	end
end

Remotes.Register(module)

return module