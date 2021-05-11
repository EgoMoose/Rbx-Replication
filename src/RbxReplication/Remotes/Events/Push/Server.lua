return function(player, context, compressed)
	local decompressed = {}
	for _, pool in pairs(compressed.pools) do
		local newPool = {}
		local instance = pool.instance

		for propertyIndex, valueIndex in pairs(pool.pool) do
			local property = context.RbxAPI.GetIndexProperty(tonumber(propertyIndex))
			local value = compressed.values[valueIndex]

			newPool[property] = value
		end

		decompressed[instance] = newPool
	end

	for instance, pool in pairs(decompressed) do
		local replicator = context.RbxReplication.GetReplicator(instance)
		replicator:_push(player, pool)
	end
end