local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild(script.Name .. "Shared")

local owners = {}

local module = {}

function module.SetOwner(player, instance, properties)
	owners[instance] = player
	Shared.Remotes.Push:FireClient(player, instance, properties)
end

function module.GetOwner(instance)
	return owners[instance]
end

return module