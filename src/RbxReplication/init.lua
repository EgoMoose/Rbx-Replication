local Paths = require(script.Paths)
local RbxAPI = require(Paths.Client.RbxAPI)
local ReplicatorClass = require(Paths.Server.Classes.Replicator)

local replicators = {}

local module = {}

function module.GetReplicator(instance)
	if replicators[instance] then
		return replicators[instance]
	end

	local replicator = ReplicatorClass.new(instance)
	replicators[instance] = replicator
	return replicator
end

return module