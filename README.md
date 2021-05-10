# Rbx-Replication
 A custom replication system for Roblox

```Lua
-- server

local RbxReplication = require(...)
local PartReplicator = RbxReplication.GetReplicator(workspace.Part)

PartReplicator:SetReplicatedProperties({
	["Size"] = true,
	["Color"] = true,
})

PartReplicator:SetNetworkOwner(game.Players.EgoMoose)
```