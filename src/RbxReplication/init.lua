local Players = game:GetService("Players")

local Utility = script.Utility
local t = require(Utility.t)

local module = {}
local replicators = {}

-- Class

local ReplicatorClass = {}
ReplicatorClass.__index = ReplicatorClass
ReplicatorClass.ClassName = "Replicator"

function ReplicatorClass.new(instance)
	local self = setmetatable({}, ReplicatorClass)

	self._properties = {}

	self.Instance = instance

	return self
end

-- Private Methods

local validateProperties = t.map(
	t.string,
	t.union(t.boolean, t.callback)
)

local function defaultValidate(instance, property, value)
	return true, value
end

-- Public Methods

function ReplicatorClass:SetOwner(owner, properties)
	if properties == "All" then
		properties = module._context.RbxAPI.GetWritableProperties(self.Instance.ClassName)
	end

	assert(validateProperties(properties), "Properties failed to validate.")

	local changed = {}
	for property, validate in pairs(properties) do
		local prev = self._properties[property]
		if prev and prev.owner then
			changed[prev.owner] = true
		end

		if owner then
			changed[owner] = true
		end

		self._properties[property] = {
			owner = owner,
			validate = t.callback(validate) and validate or defaultValidate,
		}
	end

	for player, _ in pairs(changed) do
		local send = {}
		local count = 0
		for property, data in pairs(self._properties) do
			if data.owner == player then
				count = count + 1
				send[count] = module._context.RbxAPI.GetPropertyIndex(property)
			end
		end

		module._context.Remotes.Push:FireClient(player, self.Instance, send)
	end
end

function ReplicatorClass:_push(player, pool)
	assert(player and player:IsA("Player"), "Player must be a valid player object.")

	for property, value in pairs(pool) do
		local data = self._properties[property]
		if data.owner == player then
			local success, transform = data.validate(self.Instance, property, value)
			if success then
				self.Instance[property] = transform
			end
		end
	end
end

function ReplicatorClass:_removeOwner(player)
	for property, data in pairs(self._properties) do
		if data.owner == player then
			self._properties[property] = nil
		end
	end
end

-- Private Module

local function init()
	Players.PlayerRemoving:Connect(function(player)
		for _, replicator in pairs(replicators) do
			replicator:_removeOwner(player)
		end
	end)
end

-- Public Module

function module.GetReplicator(instance)
	if not replicators[instance] then
		replicators[instance] = ReplicatorClass.new(instance)
	end
	return replicators[instance]
end

function module.IsReady(yield)
	return module._context.IsReady(yield)
end

init()
return module