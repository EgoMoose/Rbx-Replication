local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moduleName = script.Name:sub(1, -#("Client") - 1)

require(ReplicatedStorage:WaitForChild(moduleName))