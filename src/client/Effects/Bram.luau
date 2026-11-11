--!strict
-- เอฟเฟกต์ของแบรม: ส้มทอง/ม่วง แขนยืดวาดเป็นแท่งสีผิว (ทำเองด้วย Part ไม่ใช้ภาพหรือเสียงจากอนิเมะ)
-- คีย์ตรงกับ ctx.fx(...) ใน server/Characters/Bram และคีย์ M1 ของระบบต่อสู้

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Types)
local Lib = require(script.Parent.Lib)

local SKIN = Color3.fromRGB(201, 142, 98)
local GLOW = Color3.fromRGB(255, 154, 46)
local PURPLE = Color3.fromRGB(150, 110, 235)

type Handler = (root: BasePart, payload: Types.FxPayload) -> ()

local effects: { [string]: Handler } = {
	M1_1 = function(root)
		Lib.slash(root, PURPLE, 3.5, 10)
	end,
	M1_2 = function(root)
		Lib.slash(root, PURPLE, 3.5, -10)
	end,
	M1_3 = function(root)
		Lib.slash(root, GLOW, 6, 60)
	end,
	M1_4 = function(root)
		Lib.stretchArm(root, 1, 7, SKIN, 0.45)
		Lib.burst(root.Position + root.CFrame.LookVector * 7, GLOW, 8, 14)
	end,
	M1_Uppercut = function(root)
		local front = root.Position + root.CFrame.LookVector * 3
		Lib.beam(
			front - Vector3.new(0, 2, 0),
			front + Vector3.new(0, 9, 0),
			SKIN,
			1.2,
			0.3,
			Enum.Material.SmoothPlastic
		)
		Lib.burst(front, GLOW, 8, 14)
	end,
	M1_Air = function(root)
		local ground = root.Position - Vector3.new(0, 3, 0)
		Lib.ring(ground, GLOW, 7, 0.35)
		Lib.burst(ground, PURPLE, 10, 14)
	end,
	UltStart = function(root)
		-- แปลงร่าง: วงแหวนสองชั้นที่พื้น + ลำแสงพุ่งขึ้นฟ้า + ประกาย
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Lib.ring(ground, GLOW, 14, 0.7)
		Lib.ring(ground, PURPLE, 9, 0.5)
		Lib.beam(ground, ground + Vector3.new(0, 14, 0), GLOW, 1.6, 0.4, nil, 0.7) -- เสาแสงบางและโปร่ง จางเร็ว ไม่บังตัวละครตอนแปลงร่าง
		Lib.burst(root.Position, PURPLE, 30, 30, 0.9)
	end,
	Dash = function(root)
		Lib.afterimage(root.Position, PURPLE, 0.3)
		Lib.burst(root.Position, PURPLE, 5, 8)
	end,

	Skill1Charge = function(root)
		Lib.stretchArm(root, 1, -3, SKIN, 0.25) -- ดึงแขนไปข้างหลัง
	end,
	Skill1 = function(root)
		Lib.stretchArm(root, 1, 30, SKIN, 0.7)
		Lib.burst(root.Position + root.CFrame.LookVector * 30, GLOW, 10, 16)
	end,
	Skill2 = function(root)
		Lib.stretchArm(root, 1, 25, SKIN, 0.9)
	end,
	Skill2Hit = function(root)
		Lib.burst(root.Position + root.CFrame.LookVector * 4, PURPLE, 12, 16)
	end,
	Skill3 = function(root)
		-- แขนยืดหมุนรอบตัว 2 รอบ ด้วยการสร้างแขนหลายทิศ
		for i = 0, 11 do
			task.delay(i * 0.12, function()
				if root.Parent then
					Lib.stretchArm(root, 1, 10, SKIN, 0.2, i * 60)
					Lib.ring(root.Position - Vector3.new(0, 2.5, 0), PURPLE, 5 + (i % 3) * 2, 0.3)
				end
			end)
		end
	end,
	Skill4Anchor = function(root)
		Lib.stretchArm(root, 1, 20, SKIN, 0.8)
	end,
	Skill4 = function(root)
		Lib.beam(
			root.Position - root.CFrame.LookVector * 2,
			root.Position + root.CFrame.LookVector * 18,
			GLOW,
			1.5,
			0.3
		)
		Lib.burst(root.Position, GLOW, 8, 12)
	end,

	Ult1 = function(root)
		Lib.stretchArm(root, math.random() > 0.5 and 1 or -1, 20, SKIN, 0.12)
		Lib.burst(root.Position + root.CFrame.LookVector * 18, GLOW, 3, 10, 0.2)
	end,
	Ult2 = function(root)
		Lib.beam(
			root.Position - Vector3.new(0, 2.5, 0),
			root.Position + root.CFrame.LookVector * 35 - Vector3.new(0, 2.5, 0),
			GLOW,
			2,
			0.4
		)
		Lib.burst(root.Position - Vector3.new(0, 2.5, 0), GLOW, 12, 14)
	end,
	Ult3Charge = function(root)
		Lib.beam(root.Position, root.Position + Vector3.new(0, 14, 0), GLOW, 1.5, 0.5)
	end,
	Ult3 = function(root, payload)
		-- เซิร์ฟเวอร์ส่งตำแหน่งพื้นที่ค้อนทุบมาให้ (ตอนนั้นตัวยังลอยอยู่)
		local ground = payload.position or (root.Position - Vector3.new(0, 2.5, 0))
		Lib.ring(ground, GLOW, 14, 0.5)
		Lib.ring(ground, PURPLE, 9, 0.35)
		Lib.burst(ground + Vector3.new(0, 2, 0), GLOW, 22, 24)
	end,
	Ult4Charge = function(root)
		Lib.orb(root.Position, GLOW, 8, 2, 1.0, root)
	end,
	Ult4 = function(root)
		-- หมัดยักษ์: แขนยืดอ้วน 40 สตัด
		Lib.stretchArm(root, 1, 40, SKIN, 1.0)
		Lib.beam(root.Position, root.Position + root.CFrame.LookVector * 40, GLOW, 6, 0.5)
		Lib.burst(root.Position + root.CFrame.LookVector * 40, GLOW, 26, 30)
	end,
}

return effects
