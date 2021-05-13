# Rbx-Replication
A custom replication system for Roblox.

This is very much still a work in progress.

https://www.youtube.com/watch?v=LOoK2XZ2JTg

The purpose of this library is to provide an easy way to replicate properties of instances to the server. It does so by using the familiar concept of NetworkOwnership.

With this module an object called a `replicator` can be retrieved on the server for any instance. This object can then be used to give ownership of properties to certain clients.

```Lua
-- server

local RbxReplication = require(...)
local PartReplicator = RbxReplication.GetReplicator(workspace.Part)

-- This method allows you to set control of non-physics based properties
PartReplicator:SetPropertiesOwnership(SomePlayer, "All")
-- Return ownership to the server
PartReplicator:SetPropertiesOwnership(nil, "All")

-- Alternatively you can define only specific properties
PartReplicator:SetPropertiesOwnership(SomePlayer, {
	Color = true,
	Name = true,
})

-- You can also define validation and transformations (for sanity checks)
-- Note: SomePlayer still owns Color and Name properties
PartReplicator:SetPropertiesOwnership(SomePlayer, {
	Size = function(instance, property, value)
		-- return two things
		-- 1. If the value should be replicated
		-- 2. The transformed value
		return true, Vector3.new(
			math.min(value.X, 10),
			math.min(value.Y, 10),
			math.min(value.Z, 10)
		)
	end,
})

-- Multiple players can own different properties in the same instance
PartReplicator:SetPropertiesOwnership(OtherPlayer, {
	Material = true,
})

-- This method allows you control of physics based properties (CFrame & Velocities)
-- Physics ownership can only be owned by one player at any given time
-- Network ownership will be set if the part is unanchored
-- This method only works for BaseParts
PartReplicator:SetPhysicsOwnership(SomePlayer)
```