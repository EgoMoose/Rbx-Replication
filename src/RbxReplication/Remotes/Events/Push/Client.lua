return function(player, context, instance, properties)
	local newProperties = {}
	for _, index in pairs(properties) do
		local property = context.RbxAPI.GetIndexProperty(index)
		newProperties[property] = true
	end

	local node = context.Nodes.GetNode(instance)
	if node then
		if next(newProperties) then
			node:SetReplicatedProperties(newProperties)
		else
			context.Nodes.RemoveNode(instance)
		end
	end
end