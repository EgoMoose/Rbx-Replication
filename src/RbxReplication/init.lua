local Players = game:GetService("Players")

local t = require(script.Utility.t)

local PHYSICS_PROPERTIES = {
	["CFrame"] = true,
	["Position"] = true,
	["Rotation"] = true,
	["Orientation"] = true,
	["Velocity"] = true,
	["RotVelocity"] = true,
	["AssemblyLinearVelocity"] = true,
	["AssemblyAngularVelocity"] = true,
}

local module = {}
local replicators = {}

-- Class

local ReplicatorClass = {}
ReplicatorClass.__index = ReplicatorClass
ReplicatorClass.ClassName = "Replicator"

function ReplicatorClass.new(instance)
	local self = setmetatable({}, ReplicatorClass)

	self._properties = {}
	self._physicsOwner = nil
	self._isBasePart = instance:IsA("BasePart")

	self.Instance = instance

	self:_initPhysicsOwnership()

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

function ReplicatorClass:_initPhysicsOwnership()
	if not self._isBasePart then
		return
	end

	self.Instance:GetPropertyChangedSignal("Anchored"):Connect(function()
		if not self.Instance.Anchored and self._physicsOwner then
			self.Instance:SetNetworkOwner(self._physicsOwner)
		end
	end)
end

function ReplicatorClass:_push(player, pool)
	assert(player and player:IsA("Player"), "Player must be a valid player object.")

	for property, value in pairs(pool) do
		local data = nil

		if PHYSICS_PROPERTIES[property] then
			data = {
				owner = self._physicsOwner,
				validate = defaultValidate,
			}
		else
			data = self._properties[property]
		end

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

-- Public Methods

function ReplicatorClass:SetPropertiesOwnership(owner, properties)
	local isAll = (properties == "All")
	local isBasePart = self._isBasePart

	if isAll then
		properties = module._context.RbxAPI.GetWritableProperties(self.Instance.ClassName)
	end

	assert(validateProperties(properties), "Properties failed to validate.")

	local changed = {}
	for property, validate in pairs(properties) do
		if isBasePart and PHYSICS_PROPERTIES[property] then
			assert(isAll, "Cannot set property ownership of a physics controlled property. Use :SetPhysicsOwnership() instead.")
			continue
		end

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

function ReplicatorClass:SetPhysicsOwnership(owner, validation)
	assert(self._isBasePart, "Cannot set network owner of non BasePart.")

	local prevOwner = self._physicsOwner

	if prevOwner == owner then
		return
	elseif prevOwner then
		module._context.Remotes.SetPhysicsOwner:FireClient(prevOwner, self.Instance, false)
	end

	self._physicsOwner = owner

	if self._physicsOwner then
		module._context.Remotes.SetPhysicsOwner:FireClient(self._physicsOwner, self.Instance, true)
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