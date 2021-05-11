local module = {}

function module.GetOwnedProperties(instance)
	local node = module._context.Nodes.GetNodeIfExists(instance)
	if node then
		return node:GetPropertiesList()
	end
	return {}
end

function module.Replicate(instance)
	local node = module._context.Nodes.GetNodeIfExists(instance)
	if node then
		node:Replicate()
	end
end

return module