local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = script.Parent.Parent
local Client = ReplicatedStorage:WaitForChild(Server.Name)

return {
	Server = Server,
	Client = Client,
}