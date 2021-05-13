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

-- Multiple players can own different properties in the same part
PartReplicator:SetPropertiesOwnership(OtherPlayer, {
	Material = true,
})

-- This method allows you control of physics based properties (CFrame & Velocities)
-- Physics ownership can only be owned by one player at any given time
-- Network ownership will be set if the part is unanchored
PartReplicator:SetPhysicsOwnership(SomePlayer)
```

## Known Issues

One known issue is in relation to physics ownership. Since `NetworkOwnership` already allows control of `BasePart`'s physics replication then it is unnecessary to replicate these properties in those cases. However, when a part is anchored these properties still need to be replicated since an anchored part cannot have NetworkOwnership. This is currently what `RbxReplication` does.

The main issue with the above approach is that in certain cases an unanchored part cannot have its `NetworkOwnership` set. For example, when the `BasePart` instance is welded to an anchored part. The solution in that case would be to replicate the physics properties anyways. However, there is no efficient way to signal when a part is not anchored, but can or cannot set its `NetworkOwnership`. As a result it is possible to get a network ownership error when a player has control of physics ownership.