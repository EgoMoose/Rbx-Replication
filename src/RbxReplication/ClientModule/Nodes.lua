local ClientCore = script.Parent
local RemoteFolder = ClientCore.Remotes

local t = require(ClientCore.Utility.t)
local Maid = require(ClientCore.Utility.Maid)
local Signal = require(ClientCore.Utility.Signal)
local Promise = require(ClientCore.Utility.Promise)
local RbxAPI = require(ClientCore.RbxAPI)

local POOLING_DELAY = 0.1
local poolingUpdate = Signal.new()

-- Class

local NodeClass = {}
NodeClass.__index = NodeClass
NodeClass.ClassName = "Node"

function NodeClass.new(instance)
	local self = setmetatable({}, NodeClass)

	self._maid = Maid.new()
	self._pool = {}
	self._properties = {}

	self.Automatic = true
	self.Instance = instance

	return self
end

-- Private Methods

local validateProperties = t.map(
	t.string,
	t.boolean
)

local function compress(nodes)
	local pools = {}
	local values = {}
	local valuesArray = {}

	local count = 0
	for i, node in pairs(nodes) do
		local compressedPool = {}
		for property, value in pairs(node._pool) do
			local index = RbxAPI.GetPropertyIndex(property)
			local lookup = (typeof(value) == "Instance") and value or tostring(value)

			if not values[lookup] then
				count = count + 1
				values[lookup] = count
				valuesArray[count] = value
			end

			compressedPool[index] = values[lookup]
		end

		pools[i] = {
			instance = node.Instance,
			pool = compressedPool,
		}
	end

	return {
		pools = pools,
		values = valuesArray,
	}
end

-- Public Methods

function NodeClass:SetReplicatedProperties(properties)
	assert(validateProperties(properties), "Properties failed validation.")

	self._maid:Sweep()
	self._properties = properties

	for property, _ in pairs(self._properties) do
		self._pool[property] = self.Instance[property]
		self._maid:Mark(self.Instance:GetPropertyChangedSignal(property):Connect(function()
			self._pool[property] = self.Instance[property]
			if self.Automatic then
				poolingUpdate:Fire()
			end
		end))
	end

	if self.Automatic and next(self._pool) then
		poolingUpdate:Fire()
	end
end

function NodeClass:Replicate()
	if next(self._pool) then
		local compressed = compress({self})
		RemoteFolder.Push:FireServer(compressed)
		self._pool = {}
	end
end

function NodeClass:GetPropertiesList()
	local list = {}
	for property, _ in pairs(self._properties) do
		table.insert(list, property)
	end
	return list
end

function NodeClass:Destroy()
	self._maid:Sweep()
	self._pool = {}
end

-- Module

local module = {}
local nodes = {}

-- Private

local function init()
	local sending = Promise.resolve()

	poolingUpdate:Connect(function()
		sending:cancel()
		sending = Promise.delay(POOLING_DELAY):andThen(function()
			local nodesToSend = {}
			for _, node in pairs(nodes) do
				if node.Automatic and next(node._pool) then
					table.insert(nodesToSend, node)
				end
			end

			if next(nodesToSend) then
				local compressed = compress(nodesToSend)
				RemoteFolder.Push:FireServer(compressed)

				for _, node in ipairs(nodesToSend) do
					node._pool = {}
				end
			end
		end)
	end)
end

-- Public

function module.GetNode(instance)
	if not nodes[instance] then
		nodes[instance] = NodeClass.new(instance)
	end
	return nodes[instance]
end

function module.GetNodeIfExists(instance)
	return nodes[instance]
end

function module.RemoveNode(instance)
	if nodes[instance] then
		nodes[instance]:Destroy()
		nodes[instance] = nil
	end
end

init()
return module