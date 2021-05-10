local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild(script.Name .. "Shared")

local module = {}

function module.SetOwner(player, instances)
	Shared.Remotes.Pull:InvokeClient(player, instances)
end

return module