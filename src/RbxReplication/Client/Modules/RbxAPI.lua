local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ROOT_CLASS = "<<<ROOT>>>"
local FETCH = "https://raw.githubusercontent.com/CloneTrooper1019/Roblox-Client-Tracker/roblox/API-Dump.json"

local IGNORE_TAGS = {
	ReadOnly = true,
	Deprecated = true,
	Hidden = true,
	NotScriptable = true,
}

local module = {}

local API = nil
local classes = {}
local subclasses = {}
local members = {}
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

	for className, entryMembers in pairs(members) do
		local properties = {}
		for _, member in pairs(entryMembers) do
			if member.MemberType == "Property" then
				local writable = true
				if member.Tags then
					for _, tag in pairs(member.Tags) do
						if IGNORE_TAGS[tag] then
							writable = false
							break
						end
					end
				end

				if writable then
					properties[member.Name] = true
				end
			end
		end
		writableProperties[className] = properties
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

-- Public

function module.GetClassEntry(className)
	return classes[className]
end

function module.GetSubclasses(className)
	return subclasses[className]
end

function module.GetMembers(className)
	return members[className]
end

function module.GetWritableProperties(className)
	return writableProperties[className]
end

--

fetchAPI()
process()

return module