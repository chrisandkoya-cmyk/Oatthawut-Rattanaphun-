--!strict
-- จุดเดียวที่สร้าง/หา RemoteEvent ทั้งหมด
-- เซิร์ฟเวอร์สร้าง remote, client แค่รอ (client สร้าง remote เองไม่ได้)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

export type RemoteName =
	-- client -> server
	"M1"
	| "Block"
	| "Dash"
	| "Skill"
	| "Ultimate"
	| "SelectCharacter"
	| "Respawn"
	-- server -> client
	| "Fx"
	| "ApplyVelocity"

local NAMES: { RemoteName } = {
	"M1",
	"Block",
	"Dash",
	"Skill",
	"Ultimate",
	"SelectCharacter",
	"Respawn",
	"Fx",
	"ApplyVelocity",
}

local FOLDER_NAME = "Remotes"

local Net = {}

local folder: Folder? = nil

local function getFolder(): Folder
	if folder then
		return folder
	end
	if RunService:IsServer() then
		local existing = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
		local created: Folder
		if existing and existing:IsA("Folder") then
			created = existing
		else
			created = Instance.new("Folder")
			created.Name = FOLDER_NAME
			created.Parent = ReplicatedStorage
		end
		for _, name in NAMES do
			if not created:FindFirstChild(name) then
				local remote = Instance.new("RemoteEvent")
				remote.Name = name
				remote.Parent = created
			end
		end
		folder = created
		return created
	else
		local found = ReplicatedStorage:WaitForChild(FOLDER_NAME) :: Folder
		folder = found
		return found
	end
end

function Net.get(name: RemoteName): RemoteEvent
	local f = getFolder()
	if RunService:IsServer() then
		return f:FindFirstChild(name) :: RemoteEvent
	end
	return f:WaitForChild(name) :: RemoteEvent
end

return Net
