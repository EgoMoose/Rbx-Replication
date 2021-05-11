return function(player, context, instance, isPhysicsOwner)
	local node = context.Nodes.GetNode(instance)
	if node then
		node:_setPhysicsOwner(isPhysicsOwner)
	end
end