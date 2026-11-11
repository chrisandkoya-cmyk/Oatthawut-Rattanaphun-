--!strict
-- รับปุ่มจาก PC/มือถือ แล้วส่ง "คำขอ" ให้เซิร์ฟเวอร์ (client ไม่ตัดสินอะไรเอง)
--
-- PC:  คลิกซ้าย = M1 | กด Space ค้าง + คลิก = อัปเปอร์คัต | กระโดดแล้วคลิก = ทุบลงพื้น
--      F (ค้าง) = บล็อก | Q = แดช | 1-4 = สกิล | G = อันติ
-- มือถือ: ปุ่มบนหน้าจอ (Hud.luau) เรียกฟังก์ชันของโมดูลนี้

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Net = require(ReplicatedStorage:WaitForChild("Shared").Net)

local Input = {}

local m1Remote = Net.get("M1")
local blockRemote = Net.get("Block")
local dashRemote = Net.get("Dash")
local skillRemote = Net.get("Skill")
local ultRemote = Net.get("Ultimate")

local player = Players.LocalPlayer

function Input.attack(uppercut: boolean)
	m1Remote:FireServer(uppercut)
end

function Input.block(held: boolean)
	blockRemote:FireServer(held)
end

function Input.dash()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local move = humanoid and humanoid.MoveDirection or Vector3.zero
	dashRemote:FireServer(move.X, move.Z)
end

function Input.skill(slot: number)
	skillRemote:FireServer(slot)
end

function Input.ultimate()
	ultRemote:FireServer()
end

local SKILL_KEYS: { [Enum.KeyCode]: number } = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
}

function Input.start()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Input.attack(UserInputService:IsKeyDown(Enum.KeyCode.Space))
		elseif input.KeyCode == Enum.KeyCode.F then
			Input.block(true)
		elseif input.KeyCode == Enum.KeyCode.Q then
			Input.dash()
		elseif input.KeyCode == Enum.KeyCode.G then
			Input.ultimate()
		else
			local slot = SKILL_KEYS[input.KeyCode]
			if slot then
				Input.skill(slot)
			end
		end
	end)

	-- หน้าต่างหลุดโฟกัสตอนกด F ค้าง InputEnded จะไม่มา -> ปลดบล็อกเอง
	UserInputService.WindowFocusReleased:Connect(function()
		Input.block(false)
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.F then
			Input.block(false)
		end
	end)
end

return Input
