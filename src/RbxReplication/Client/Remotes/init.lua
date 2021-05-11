local RbxReplicationClient = script.Parent
local RemotesFolder = RbxReplicationClient.Remotes
local RbxAPI = require(RbxReplicationClient.Modules.RbxAPI)
local Nodes = require(RbxReplicationClient.Modules.Nodes)

local module = {}

module.ClaimOwnership = RemotesFolder:WaitForChild("ClaimOwnership")
module.Push = RemotesFolder:WaitForChild("Push")

module.ClaimOwnership.OnClientEvent:Connect(function(instance, properties)
	assert(instance, "Cannot claim ownership of part that is non-existing for client.")

	if properties then
		if properties == true then
			properties = RbxAPI.GetWritableProperties(instance.ClassName)
		end

		local node = Nodes.GetNode(instance)
		node:SetReplicatedProperties(properties)
	else
		Nodes.RemoveNode(instance)
	end
end)

return module