local RbxReplicationClient = script.Parent
local RemotesFolder = RbxReplicationClient.Remotes
local RbxAPI = require(RbxReplicationClient.RbxAPI)

local module = {}

RemotesFolder:WaitForChild("ClaimOwnership").OnClientEvent:Connect(function(instance, properties)
	assert(instance, "Cannot claim ownership of part that is non-existing for client.")

	if properties then
		if properties == true then
			properties = RbxAPI.GetWritableProperties(instance.ClassName)
		end

		print(instance, properties)
		-- replicate the properties for instance
	else
		-- stop replicating the properties for instance
	end
end)

return module