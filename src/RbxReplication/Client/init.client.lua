local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild(script.Name:sub(1, -#("Client") - 1) .. "Shared")

local RbxAPI = require(Shared.RbxAPI)
local Remotes = require(Shared.Remotes)
