--!strict
-- สร้างแมพจากข้อมูล Layout + Theme ลงใน Workspace (ฝั่งเซิร์ฟเวอร์)
-- ทุกชิ้นเป็น Anchored และใช้ Part พื้นฐานเท่านั้น ไม่โหลด asset ภายนอก

local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local MapBuilder = {}

local SHAPES: { [string]: string } = {
	Block = "Part",
	Cylinder = "Part",
	Wedge = "WedgePart",
}

local function applyLook(part: BasePart, look: any)
	part.Color = look.Color
	part.Material = look.Material
	part.Transparency = look.Transparency or 0
end

local function getFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function applyLighting(lighting: any)
	Lighting.ClockTime = lighting.ClockTime
	Lighting.Brightness = lighting.Brightness
	Lighting.Ambient = lighting.Ambient
	Lighting.OutdoorAmbient = lighting.OutdoorAmbient

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = lighting.Atmosphere.Density
	atmosphere.Color = lighting.Atmosphere.Color
	atmosphere.Decay = lighting.Atmosphere.Decay
	atmosphere.Haze = lighting.Atmosphere.Haze
	atmosphere.Glare = lighting.Atmosphere.Glare
	atmosphere.Parent = Lighting
end

-- map: โมดูลแมพ เช่น require(ReplicatedStorage.Shared.Maps.TempleCourtyard)
-- คืนค่าโมเดลแมพที่สร้างแล้ว (ถ้ามีแมพเดิมชื่อเดียวกันจะลบก่อน)
function MapBuilder.Build(map: any): Model
	local layout = map.Layout
	local theme = map.Theme

	local old = Workspace:FindFirstChild("Map")
	if old then
		old:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "Map"
	model:SetAttribute("MapId", map.Id)
	model:SetAttribute("BoundsMin", layout.Bounds.Min)
	model:SetAttribute("BoundsMax", layout.Bounds.Max)
	if layout.BoundsRadius then
		model:SetAttribute("BoundsRadius", layout.BoundsRadius)
	end

	for _, spec in layout.Parts do
		local look = theme.Looks[spec.Look]
		assert(look, `ไม่พบ Look "{spec.Look}" ใน Theme ของ {spec.Name}`)

		local part = Instance.new(SHAPES[spec.Shape]) :: BasePart
		if spec.Shape == "Cylinder" then
			(part :: Part).Shape = Enum.PartType.Cylinder
		end
		part.Name = spec.Name
		part.Size = spec.Size
		part.CFrame = spec.CFrame
		part.Anchored = true
		part.CanCollide = if spec.CanCollide == nil then true else spec.CanCollide
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		applyLook(part, look)

		if spec.Group == "Barriers" then
			-- กำแพงล่องหน: ชนตัวละครได้ แต่ไม่บังกล้อง ไม่ทำเงา และไม่โดน raycast ของสกิล
			part.CastShadow = false
			part.CanQuery = false
			part.CanTouch = false
		end

		for _, tag in spec.Tags or {} do
			CollectionService:AddTag(part, tag)
		end

		part.Parent = getFolder(model, spec.Group)
	end

	local spawnFolder = getFolder(model, "Spawns")
	local spawnLook = theme.Looks.Spawn
	for i, cf in layout.Spawns do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Spawn" .. i
		spawn.Size = Vector3.new(6, 1, 6)
		spawn.CFrame = cf
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Duration = 3 -- ForceField กันโดนตีตอนเพิ่งเกิด 3 วินาที
		spawn.CanCollide = false
		spawn.TopSurface = Enum.SurfaceType.Smooth
		applyLook(spawn, spawnLook)
		spawn.Parent = spawnFolder
	end

	applyLighting(theme.Lighting)

	model.Parent = Workspace
	return model
end

return MapBuilder
