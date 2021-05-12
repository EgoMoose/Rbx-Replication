local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ROOT_CLASS = "<<<ROOT>>>"
local FETCH = "https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json"

local IGNORE_TAGS = {
	ReadOnly = true,
	NotScriptable = true,
}

local module = {}
local loaded = false
local loadedSignal = Instance.new("BindableEvent")

local API = nil
local classes = {}
local subclasses = {}
local members = {}
local propertyIndices = {}
local indicesProperty = {}
local writableProperties = {}

-- Private

local function process()
	assert(API, "No API available.")

	for _, entry in pairs(API.Classes) do
		classes[entry.Name] = entry

		if not subclasses[entry.Superclass] then
			subclasses[entry.Superclass] = {}
		end

		subclasses[entry.Superclass][entry.Name] = true
	end

	for _, entry in pairs(classes) do
		local entries = {}
		local entryMembers = {}

		local currentEntry = entry
		while currentEntry and currentEntry.Superclass ~= ROOT_CLASS do
			table.insert(entries, currentEntry)
			currentEntry = classes[currentEntry.Superclass]
		end

		table.insert(entries, currentEntry)

		for _, cousin in pairs(entries) do
			for _, member in pairs(cousin.Members) do
				table.insert(entryMembers, member)
			end
		end

		members[entry.Name] = entryMembers
	end

	local existing = {}
	for className, entryMembers in pairs(members) do
		local properties = {}
		for _, member in pairs(entryMembers) do
			if member.MemberType == "Property" then
				local writable = true

				if member.Security.Write ~= "None" then
					writable = false
				end

				if writable and member.Tags then
					for _, tag in pairs(member.Tags) do
						if IGNORE_TAGS[tag] then
							writable = false
							break
						end
					end
				end

				if writable then
					existing[member.Name] = true
					properties[member.Name] = true
				end
			end
		end
		writableProperties[className] = properties
	end

	local count = 0
	for property, _ in pairs(existing) do
		count = count + 1
		indicesProperty[count] = property
		propertyIndices[property] = count
	end
end

local function fetchAPI()
	local dump = nil

	if not script:GetAttribute("Fetched") and RunService:IsServer() then
		for _ = 1, 3 do
			local success, err = pcall(function()
				dump = HttpService:GetAsync(FETCH)
			end)

			if success then
				break
			else
				warn(err)
				warn("Retrying fetch API request.")
			end
		end

		if not dump then
			error("Could not fetch API.")
		end

		local K200 = 200000 - 1
		local n = math.ceil(#dump / K200)		
		for i = 1, n do
			local str = Instance.new("StringValue")
			str.Name = i
			str.Value = dump:sub(1 + K200 * (i - 1), K200 * i)
			str.Parent = script
		end

		script:SetAttribute("Fetched", true)
	else
		while not script:GetAttribute("Fetched") do
			script:GetAttributeChangedSignal("Fetched"):Wait()
		end

		dump = ""
		
		local children = script:GetChildren()
		for i = 1, #children do
			local str = script:FindFirstChild(i)
			dump = dump .. str.Value
		end

		if RunService:IsClient() then
			script:ClearAllChildren()
		end
	end

	API = HttpService:JSONDecode(dump)
end

local function waitForReady()
	while not loaded do
		loadedSignal.Event:Wait()
	end
end

-- Public

function module.GetClassEntry(className)
	waitForReady()
	return classes[className]
end

function module.GetSubclasses(className)
	waitForReady()
	return subclasses[className]
end

function module.GetMembers(className)
	waitForReady()
	return members[className]
end

function module.GetWritableProperties(className)
	waitForReady()
	return writableProperties[className]
end

function module.GetIndexProperty(index)
	waitForReady()
	return indicesProperty[index]
end

function module.GetPropertyIndex(property)
	waitForReady()
	return propertyIndices[property]
end

function module.IsLoaded(yield)
	if yield then
		waitForReady()
	end
	return loaded
end

--

coroutine.wrap(function()
	fetchAPI()
	process()
	loaded = true
	loadedSignal:Fire()
end)()

return module