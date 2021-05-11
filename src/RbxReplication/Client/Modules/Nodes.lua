local RbxReplicationClient = script.Parent.Parent
local Promise = require(RbxReplicationClient.Utility.Promise)
local Maid = require(RbxReplicationClient.Utility.Maid)
local t = require(RbxReplicationClient.Utility.t)

local Remotes = nil
local REPLICATION_DELAY = 0.1

local NodeClass = {}
NodeClass.__index = NodeClass
NodeClass.ClassName = "Node"

function NodeClass.new(instance)
	local self = setmetatable({}, NodeClass)

	self._maid = Maid.new()
	self._send = Promise.resolve()
	self._pool = {}
	self._properties = {}

	self.Automatic = true
	self.Instance = instance

	return self
end

-- Private Methods

local validateProperties = t.map(t.string,t.boolean)

-- Public Methods

function NodeClass:SetReplicatedProperties(properties)
	assert(validateProperties(properties), "Properties were invalid.")

	self._properties = properties
	self._maid:Sweep()

	for property, _ in pairs(properties) do
		self._maid:Mark(self.Instance:GetPropertyChangedSignal(property):Connect(function()
			self._send:cancel()
			self._pool[property] = self.Instance[property]

			if self.Automatic then
				self._send = Promise.delay(REPLICATION_DELAY):andThen(function()
					self:Replicate()
				end)
			end
		end))
	end
end

function NodeClass:Replicate()
	Remotes.Push:FireServer(self.Instance, self._pool)
	self._pool = {}
end

function NodeClass:Destroy()
	self._maid:Sweep()
	self._send:cancel()
	self._pool = {}
end

-- Public Module

local module = {}
local nodes = {}

function module.GetNode(instance)
	if not nodes[instance] then
		nodes[instance] = NodeClass.new(instance)
	end
	return nodes[instance]
end

function module.RemoveNode(instance)
	if nodes[instance] then
		nodes[instance]:Destroy()
		nodes[instance] = nil
	end
end

function module.init()
	Remotes = require(RbxReplicationClient.Remotes)
end

return module