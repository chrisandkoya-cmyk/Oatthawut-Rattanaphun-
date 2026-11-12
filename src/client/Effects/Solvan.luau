--!strict
-- เอฟเฟกต์ของโซลวาน: ฟ้าอมเขียว/ขาว (ทำเองด้วย Part ไม่ใช้ภาพหรือเสียงจากอนิเมะ)
-- คีย์ตรงกับ ctx.fx(...) ใน server/Characters/Solvan และคีย์ M1 ของระบบต่อสู้

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Types)
local Lib = require(script.Parent.Lib)

local CYAN = Color3.fromRGB(63, 200, 224)
local WHITE = Color3.fromRGB(235, 250, 255)

type Handler = (root: BasePart, payload: Types.FxPayload) -> ()

local effects: { [string]: Handler } = {
	M1_1 = function(root)
		Lib.slash(root, CYAN, 4, 10)
	end,
	M1_2 = function(root)
		Lib.slash(root, CYAN, 4, -10)
	end,
	M1_3 = function(root)
		Lib.slash(root, WHITE, 5, 40)
	end,
	M1_4 = function(root)
		Lib.slash(root, CYAN, 6, 0)
		Lib.burst(root.Position + root.CFrame.LookVector * 4, CYAN, 8, 14)
	end,
	M1_Uppercut = function(root)
		local front = root.Position + root.CFrame.LookVector * 3
		Lib.beam(front - Vector3.new(0, 2, 0), front + Vector3.new(0, 9, 0), WHITE, 1.2, 0.3)
		Lib.burst(front, CYAN, 10, 16)
	end,
	M1_Air = function(root)
		local ground = root.Position - Vector3.new(0, 3, 0)
		Lib.ring(ground, CYAN, 7, 0.35)
		Lib.burst(ground, WHITE, 10, 14)
	end,
	UltStart = function(root)
		-- แปลงร่าง: วงแหวนสองชั้นที่พื้น + ลำแสงพุ่งขึ้นฟ้า + ประกาย
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Lib.ring(ground, CYAN, 14, 0.7)
		Lib.groundBurst(ground, CYAN, 1.2)
		Lib.ring(ground, WHITE, 9, 0.5)
		Lib.beam(ground, ground + Vector3.new(0, 14, 0), CYAN, 1.6, 0.4, nil, 0.7) -- เสาแสงบางและโปร่ง จางเร็ว ไม่บังตัวละครตอนแปลงร่าง
		Lib.burst(root.Position, WHITE, 30, 30, 0.9)
	end,
	Dash = function(root)
		Lib.afterimage(root.Position, CYAN, 0.3)
		Lib.burst(root.Position, CYAN, 5, 8)
	end,

	Skill1 = function(root)
		-- ง้างพลังที่มือ: ลูกแสงใหญ่ขึ้นเร็วๆ ก่อนยิง
		Lib.orb(root.Position + root.CFrame.LookVector * 2.5, CYAN, 1, 4.5, 0.4)
		Lib.ring(
			root.Position + root.CFrame.LookVector * 2.5,
			WHITE,
			4,
			0.35,
			root.CFrame * CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.rad(90), 0)
		)
	end,
	Skill1Shot = function(root)
		local muzzle = root.Position + root.CFrame.LookVector * 3
		Lib.orb(muzzle, WHITE, 3, 0.6, 0.25)
		Lib.beam(muzzle, muzzle + root.CFrame.LookVector * 12, CYAN, 1.6, 0.3)
		Lib.burst(muzzle, CYAN, 8, 16, 0.4)
	end,
	Skill2 = function(root)
		-- พุ่งดาวหาง: ลำแสงหางยาวด้านหลัง
		local back = root.Position - root.CFrame.LookVector * 20
		Lib.beam(back, root.Position, CYAN, 4.5, 0.8)
		Lib.beam(back, root.Position, WHITE, 2, 0.8)
		Lib.burst(root.Position, WHITE, 14, 18)
	end,
	Skill2Hit = function(root)
		Lib.burst(root.Position + root.CFrame.LookVector * 4, CYAN, 14, 20)
		Lib.ring(
			root.Position + root.CFrame.LookVector * 4,
			WHITE,
			5,
			0.3,
			root.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(90), 0)
		)
	end,
	Skill3 = function(root)
		local palm = root.Position + root.CFrame.LookVector * 4
		Lib.beam(palm - Vector3.new(0, 3, 0), palm + Vector3.new(0, 10, 0), CYAN, 2.2, 0.8, nil, 0.45)
		Lib.ring(palm - Vector3.new(0, 2.5, 0), WHITE, 5, 0.5)
	end,
	Skill3Hit = function(root)
		Lib.burst(root.Position + root.CFrame.LookVector * 4 + Vector3.new(0, 4, 0), WHITE, 14, 18)
	end,
	Skill4Charge = function(root)
		-- ลูกแสงชาร์จที่มือ ค่อยๆ ใหญ่ขึ้น 1 วินาที
		Lib.orb(root.Position + root.CFrame.LookVector * 2.5, CYAN, 0.5, 3.5, 1.0, root)
	end,
	Skill4 = function(root)
		-- ลำแสงสองสายไขว้ ยาว 60 สตัด
		local origin = root.Position + root.CFrame.LookVector * 2
		local forward = root.CFrame.LookVector
		local right = root.CFrame.RightVector
		Lib.beam(origin + right * 3, origin + forward * 60 - right * 1, CYAN, 7, 1.3)
		Lib.beam(origin - right * 3, origin + forward * 60 + right * 1, WHITE, 5, 1.3)
		Lib.beam(origin, origin + forward * 60, WHITE, 2.5, 1.5)
		Lib.rayBurst(origin, origin + forward * 60, CYAN, 1)
		Lib.ring(origin, CYAN, 8, 0.6, root.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(90), 0))
		Lib.burst(origin, WHITE, 16, 20)
	end,

	Ult1 = function(root)
		Lib.burst(root.Position + root.CFrame.LookVector * 2.5, WHITE, 14, 16)
		Lib.ring(root.Position, CYAN, 6, 0.4)
	end,
	Ult2 = function(_root, payload)
		-- เงาหลอกที่จุดเดิมก่อนวาร์ป
		local position = payload.position
		if position then
			Lib.afterimage(position, CYAN, 1.5)
			Lib.burst(position, CYAN, 10, 12)
		end
	end,
	Ult2In = function(root)
		Lib.burst(root.Position, WHITE, 10, 12)
	end,
	Ult3Charge = function(root)
		Lib.orb(root.Position, CYAN, 8, 1, 0.3, root)
	end,
	Ult3 = function(root)
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Lib.ring(ground, WHITE, 12, 0.5)
		Lib.ring(ground, CYAN, 9, 0.35)
		Lib.groundBurst(ground, CYAN, 1)
		Lib.burst(root.Position, WHITE, 24, 26)
	end,
	Ult4Charge = function(root)
		Lib.orb(root.Position + root.CFrame.LookVector * 3, CYAN, 1, 6, 0.7, root)
	end,
	Ult4 = function(root)
		-- ลำแสงใหญ่กว้าง 8 สตัด ยิง 2 วินาที
		local origin = root.Position + root.CFrame.LookVector * 3
		local forward = root.CFrame.LookVector
		Lib.beam(origin, origin + forward * 70, CYAN, 8, 2.0)
		Lib.beam(origin, origin + forward * 70, WHITE, 4, 2.0)
		Lib.rayBurst(origin, origin + forward * 70, CYAN, 1.4)
		Lib.burst(origin, WHITE, 24, 28)
	end,
}

return effects
