local Client = script.Parent
local RemotesFolder = Client.Remotes

RemotesFolder.Pull.OnClientInvoke = function(player, instances)
	print(instances)
end

local module = {}

return module