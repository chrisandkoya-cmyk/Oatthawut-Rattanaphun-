--!strict
-- สร้างหน้าตาตัวละครจากข้อมูล (สี + ชิ้นส่วน Part ติดกับ R15) ไม่ต้องใช้โมเดล/ไฟล์ 3D ภายนอก
-- ใช้บนเซิร์ฟเวอร์ (Systems/Appearance) ชิ้นส่วนจะ replicate ให้ทุกคนเห็นเอง

local Builder = {}

export type EmitterSpec = {
	color: Color3,
	rate: number,
	size: number,
	lifetime: number,
	speed: number?,
}

-- ใช้โมเดล 3 มิติสำเร็จรูป (เช่น ผม/หมวกจาก Creator Store) แทนก้อน Part: เก็บแค่ id ของ mesh/texture
-- แล้วสร้าง Part + SpecialMesh เอง ไม่ใช้สคริปต์ใดๆ จากโมเดลต้นทาง
export type MeshSpec = {
	meshId: string, -- เช่น "rbxassetid://123"
	textureId: string?,
	scale: Vector3?, -- ค่า Scale ของ SpecialMesh
	offsetMesh: Vector3?, -- ระยะเลื่อนของ mesh ภายใน Part
}

export type PartSpec = {
	attach: string, -- ชื่อชิ้นส่วน R15 เช่น "Head", "UpperTorso", "LeftHand"
	shape: "Block" | "Ball" | "Cylinder" | "Wedge"?,
	size: Vector3,
	offset: CFrame?, -- ตำแหน่ง/การหมุนเทียบกับชิ้นส่วนที่ติด
	color: Color3,
	material: Enum.Material?,
	transparency: number?,
	emitter: EmitterSpec?,
	mesh: MeshSpec?,
}

export type Clothing = {
	shirtTemplate: string?, -- ShirtTemplate ("rbxassetid://...") ของเสื้อที่ใช้
	pantsTemplate: string?,
}

export type Look = {
	clothing: Clothing?,
	-- สีส่วนต่างๆ ของตัว R15 (ใส่เฉพาะที่ต้องการเปลี่ยน)
	colors: { [string]: Color3 },
	parts: { PartSpec },
}

local FOLDER_NAME = "Cosmetics"

local BODY_COLOR_FIELDS: { [string]: string } = {
	Head = "HeadColor3",
	UpperTorso = "TorsoColor3",
	LowerTorso = "TorsoColor3",
	LeftUpperArm = "LeftArmColor3",
	LeftLowerArm = "LeftArmColor3",
	LeftHand = "LeftArmColor3",
	RightUpperArm = "RightArmColor3",
	RightLowerArm = "RightArmColor3",
	RightHand = "RightArmColor3",
	LeftUpperLeg = "LeftLegColor3",
	LeftLowerLeg = "LeftLegColor3",
	LeftFoot = "LeftLegColor3",
	RightUpperLeg = "RightLegColor3",
	RightLowerLeg = "RightLegColor3",
	RightFoot = "RightLegColor3",
}

-- ถอดเสื้อผ้า/ผม/หมวกของอวตารผู้เล่นออก (ใช้หน้าตาของตัวละครแทน)
local function stripAvatar(character: Model)
	for _, child in character:GetChildren() do
		if
			child:IsA("Accessory")
			or child:IsA("Shirt")
			or child:IsA("Pants")
			or child:IsA("ShirtGraphic")
			or child:IsA("CharacterMesh")
		then
			child:Destroy()
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		-- ไม่ลบหน้า (Decal "face") เพื่อให้ยังมีตา/ปาก
		for _, child in head:GetChildren() do
			if child:IsA("SpecialMesh") then
				child.Scale = Vector3.one
			end
		end
	end
end

local function paintBody(character: Model, colors: { [string]: Color3 })
	local bodyColors = character:FindFirstChildOfClass("BodyColors")
	for partName, color in colors do
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			part.Color = color
		end
		local field = BODY_COLOR_FIELDS[partName]
		if bodyColors and field then
			(bodyColors :: any)[field] = color
		end
	end
end

local SHAPES: { [string]: Enum.PartType } = {
	Block = Enum.PartType.Block,
	Ball = Enum.PartType.Ball,
	Cylinder = Enum.PartType.Cylinder,
}

local function buildPart(character: Model, folder: Folder, spec: PartSpec)
	local target = character:FindFirstChild(spec.attach)
	if not (target and target:IsA("BasePart")) then
		return
	end
	local part
	if spec.shape == "Wedge" then
		part = Instance.new("WedgePart")
	else
		part = Instance.new("Part")
		part.Shape = SHAPES[spec.shape or "Block"] or Enum.PartType.Block
	end
	part.Name = spec.attach .. "_Cosmetic"
	part.Size = spec.size
	part.Color = spec.color
	part.Material = spec.material or Enum.Material.SmoothPlastic
	part.Transparency = spec.transparency or 0
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.CastShadow = false
	part.CFrame = target.CFrame * (spec.offset or CFrame.new())
	part.Parent = folder

	local meshSpec = spec.mesh
	if meshSpec then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = meshSpec.meshId
		mesh.TextureId = meshSpec.textureId or ""
		mesh.Scale = meshSpec.scale or Vector3.one
		mesh.Offset = meshSpec.offsetMesh or Vector3.zero
		mesh.Parent = part
	end

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = target
	weld.Part1 = part
	weld.Parent = part

	local emitterSpec = spec.emitter
	if emitterSpec then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(emitterSpec.color)
		emitter.LightEmission = 1
		emitter.Rate = emitterSpec.rate
		emitter.Lifetime = NumberRange.new(emitterSpec.lifetime)
		emitter.Speed = NumberRange.new(emitterSpec.speed or 2)
		emitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, emitterSpec.size),
			NumberSequenceKeypoint.new(1, 0),
		})
		emitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.2),
			NumberSequenceKeypoint.new(1, 1),
		})
		emitter.Parent = part
	end
end

-- ใส่เสื้อ/กางเกงแบบคลาสสิกจาก template (ล้างของเก่าก่อน) ใช้กับโมเดลสำเร็จรูปที่คริสเลือก
local function applyClothing(character: Model, clothing: Clothing?)
	for _, child in character:GetChildren() do
		if child:IsA("Shirt") or child:IsA("Pants") then
			child:Destroy()
		end
	end
	if not clothing then
		return
	end
	if clothing.shirtTemplate then
		local shirt = Instance.new("Shirt")
		shirt.ShirtTemplate = clothing.shirtTemplate
		shirt.Parent = character
	end
	if clothing.pantsTemplate then
		local pants = Instance.new("Pants")
		pants.PantsTemplate = clothing.pantsTemplate
		pants.Parent = character
	end
end

-- ใส่หน้าตา (เรียกซ้ำได้ จะล้างของเก่าก่อน) ใช้สลับร่างปกติ <-> ร่างอันติ
function Builder.apply(character: Model, look: Look)
	stripAvatar(character)
	paintBody(character, look.colors)

	local old = character:FindFirstChild(FOLDER_NAME)
	if old then
		old:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = FOLDER_NAME
	folder.Parent = character
	applyClothing(character, look.clothing)
	for _, spec in look.parts do
		buildPart(character, folder, spec)
	end
end

return Builder
