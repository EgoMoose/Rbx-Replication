local Shared = script.Parent
local RemotesFolder = Shared.Remotes

local Maid = require(Shared.Utility.Maid)
local Promise = require(Shared.Utility.Promise)
local RbxAPI = require(Shared.RbxAPI)

local SEND_DELAY = 0.1 -- How long to send after the property stopped changing

local replicating = {}

RemotesFolder.Pull.OnClientInvoke = function(instances)
	-- get the difference between the 
end

RemotesFolder.Push.OnClientEvent:Connect(function(instance, properties)
	if properties then
		local maid = Maid.new()

		if properties == true then
			-- replicate everything
			properties = RbxAPI.GetWritableProperties(instance.ClassName)
		end

		for _, property in pairs(properties) do
			local delaySend = Promise.resolve()

			maid:Mark(instance:GetPropertyChangedSignal(property):Connect(function()
				local value = instance[property]
				delaySend:cancel()
				delaySend = Promise.delay(SEND_DELAY):andThen(function()
					RemotesFolder.Push:FireServer(instance, property, value)
				end)
			end))
		end

		replicating[instance] = maid
	elseif replicating[instance] then
		replicating[instance]:Sweep()
		replicating[instance] = nil
	end
end)

local module = {}

return module