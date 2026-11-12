--!strict
-- เอฟเฟกต์ของโซลวาน: ฟ้าอมเขียว/ขาว (ทำเองด้วย Part ไม่ใช้ภาพหรือเสียงจากอนิเมะ)
-- คีย์ตรงกับ ctx.fx(...) ใน server/Characters/Solvan และคีย์ M1 ของระบบต่อสู้

local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared").Types)
local Lib = require(script.Parent.Lib)
local Recipes = require(script.Parent.Recipes)
local Juice = require(script.Parent.Juice)

local CYAN = Color3.fromRGB(63, 200, 224)
local WHITE = Color3.fromRGB(235, 250, 255)
local RED = Color3.fromRGB(255, 56, 40)

-- พุ่งประชิด: ภาพค้าง + เส้นสปีด + ลำแสงหางด้านหลัง
local function dashFx(root: BasePart, color: Color3, big: boolean)
	local back = root.Position - root.CFrame.LookVector * (if big then 24 else 20)
	Lib.beam(back, root.Position, color, big and 5.5 or 4.5, 0.7)
	Lib.beam(back, root.Position, WHITE, 2, 0.7)
	Recipes.dash(root, color)
	Lib.burst(root.Position, WHITE, 14, 18)
end

-- โดนเป้า: วาบขาว + วงกระแทก
local function hitFx(root: BasePart, color: Color3, size: number)
	local at = root.Position + root.CFrame.LookVector * 4
	Lib.impact(at, color, size)
	Lib.ring(at, WHITE, 4 + size * 1.5, 0.3, root.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(90), 0))
end

-- หมัดคอมโบ: side = 1/-1 ซ้ายขวา, 0 = หมัดสุดท้าย (ใหญ่ ตรงกลาง)
local function punchFx(root: BasePart, color: Color3, side: number, finisher: boolean)
	local fist = root.Position + root.CFrame.LookVector * 3.5 + root.CFrame.RightVector * side * 1.2
	Recipes.slash(root, color, finisher and 8 or 4.5, side * 12)
	Lib.afterimage(root.Position - root.CFrame.LookVector * 1.2, color, 0.2)
	Lib.burst(fist, color, finisher and 14 or 6, finisher and 20 or 12)
	if finisher then
		Lib.impact(fist, WHITE, 1.8)
		Juice.speedLines(root, color, 10, 14)
	end
end

-- คาเมฮาเมฮา: ลำแสงหลายชั้น + วงเกลียว + แรงถีบสะเทือน
local function kameFx(root: BasePart, color: Color3, length: number, width: number)
	local origin = root.Position + root.CFrame.LookVector * 2
	Lib.beam(origin, origin + root.CFrame.LookVector * length, color, width * 1.5, 1.3)
	Recipes.kiBeam(root, color, length, width, 1.4, true)
	Lib.ring(origin, color, width * 2, 0.6, root.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(0, math.rad(90), 0))
	Lib.burst(origin, WHITE, 18, 22)
end

type Handler = (root: BasePart, payload: Types.FxPayload) -> ()

local effects: { [string]: Handler } = {
	M1_1 = function(root)
		Recipes.slash(root, CYAN, 4.5, 10)
	end,
	M1_2 = function(root)
		Recipes.slash(root, CYAN, 4.5, -10)
	end,
	M1_3 = function(root)
		Recipes.slash(root, WHITE, 6, 40)
	end,
	M1_4 = function(root)
		Recipes.slash(root, CYAN, 7.5, 0)
		Lib.impact(root.Position + root.CFrame.LookVector * 4, CYAN, 1.3)
		Lib.burst(root.Position + root.CFrame.LookVector * 4, CYAN, 8, 14)
	end,
	M1_Uppercut = function(root)
		local front = root.Position + root.CFrame.LookVector * 3
		Lib.beam(front - Vector3.new(0, 2, 0), front + Vector3.new(0, 11, 0), WHITE, 1.6, 0.35)
		Lib.impact(front + Vector3.new(0, 1, 0), CYAN, 1.2)
		Lib.burst(front, CYAN, 10, 16)
	end,
	M1_Air = function(root)
		local ground = root.Position - Vector3.new(0, 3, 0)
		Recipes.slam(ground, CYAN, 10)
	end,
	UltStart = function(root)
		-- แปลงร่าง: วงแหวนสองชั้นที่พื้น + ลำแสงพุ่งขึ้นฟ้า + ประกาย
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Recipes.converge(root.Position, CYAN, 30, 14, 0.5)
		Recipes.slam(ground, CYAN, 18)
		Lib.beam(ground, ground + Vector3.new(0, 18, 0), CYAN, 2, 0.5, nil, 0.7) -- เสาแสงบางและโปร่ง จางเร็ว ไม่บังตัวละครตอนแปลงร่าง
		Lib.burst(root.Position, WHITE, 30, 30, 0.9)
		Recipes.aura(root, CYAN, 6)
	end,
	Dash = function(root)
		Recipes.dash(root, CYAN)
	end,

	-- ไคโอเคน: ตัวแดง ท่าไหนที่ยิงตอนบัพติดจะใช้คีย์ ...Kai (สีแดง/ใหญ่ขึ้น)
	Skill1 = function(root)
		dashFx(root, CYAN, false)
	end,
	Skill1Kai = function(root)
		dashFx(root, RED, true)
	end,
	Skill1Hit = function(root)
		hitFx(root, CYAN, 1.8)
	end,
	Skill1HitKai = function(root)
		hitFx(root, RED, 2.4)
	end,

	Skill2 = function() end,
	Skill2Punch1 = function(root)
		punchFx(root, CYAN, 1, false)
	end,
	Skill2Punch2 = function(root)
		punchFx(root, CYAN, -1, false)
	end,
	Skill2Punch4 = function(root)
		punchFx(root, WHITE, 0, true)
	end,
	Skill2PunchKai1 = function(root)
		punchFx(root, RED, 1, false)
	end,
	Skill2PunchKai2 = function(root)
		punchFx(root, RED, -1, false)
	end,
	Skill2PunchKai4 = function(root)
		punchFx(root, RED, 0, true)
	end,
	Skill2Connect = function(root)
		hitFx(root, CYAN, 1.2)
	end,
	Skill2ConnectKai = function(root)
		hitFx(root, RED, 1.7)
	end,

	-- คาเมฮาเมฮา: ชาร์จลูกแสงที่มือสองข้าง 1 วินาที แล้วยิงลำใหญ่
	Skill3Charge = function(root)
		Recipes.charge(root, CYAN, 1.0, 4.5)
	end,
	Skill3ChargeKai = function(root)
		Recipes.charge(root, RED, 1.0, 5.5)
		Recipes.aura(root, RED, 1.2)
	end,
	Skill3 = function(root)
		kameFx(root, CYAN, 60, 4)
	end,
	Skill3Kai = function(root)
		kameFx(root, RED, 72, 6)
	end,

	-- ไคโอเคน: รวมพลังแล้วตัวแดงวาบ ออร่าแดงค้างตลอดบัพ 10 วินาที
	Skill4 = function(root)
		Recipes.converge(root.Position, RED, 22, 10, 0.4)
		Lib.ring(root.Position - Vector3.new(0, 2.5, 0), RED, 7, 0.5)
	end,
	Skill4Aura = function(root)
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Recipes.slam(ground, RED, 16)
		Lib.burst(root.Position, WHITE, 20, 26, 0.8)
		Lib.beam(ground, ground + Vector3.new(0, 16, 0), RED, 2.4, 0.5, nil, 0.6)
		Recipes.aura(root, RED, 10)
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
		Recipes.charge(root, CYAN, 0.3, 5)
	end,
	Ult3 = function(root)
		local ground = root.Position - Vector3.new(0, 2.5, 0)
		Recipes.slam(ground, CYAN, 16)
		Lib.burst(root.Position, WHITE, 24, 26)
	end,
	Ult4Charge = function(root)
		Recipes.charge(root, CYAN, 0.7, 7)
	end,
	Ult4 = function(root)
		-- ลำแสงใหญ่กว้าง 8 สตัด ยิง 2 วินาที
		local origin = root.Position + root.CFrame.LookVector * 3
		local forward = root.CFrame.LookVector
		Lib.beam(origin, origin + forward * 70, CYAN, 8, 2.0)
		Lib.beam(origin, origin + forward * 70, WHITE, 4, 2.0)
		Recipes.kiBeam(root, CYAN, 70, 7, 2.0, true)
		Lib.burst(origin, WHITE, 24, 28)
	end,
}

return effects
