--!strict
-- หน้าตาแมพ "หมู่บ้านนินจาในป่า": ดินอัดแน่น ไม้ หลังคากระเบื้องเขียว แสงเช้าหมอกบาง

local Theme = {}

Theme.Looks = {
	Dirt = { Color = Color3.fromRGB(128, 100, 72), Material = Enum.Material.Ground },
	Grass = { Color = Color3.fromRGB(70, 110, 55), Material = Enum.Material.Grass },
	Fence = { Color = Color3.fromRGB(100, 70, 48), Material = Enum.Material.Wood },
	FenceCap = { Color = Color3.fromRGB(80, 56, 40), Material = Enum.Material.Wood },
	Circle = { Color = Color3.fromRGB(150, 145, 135), Material = Enum.Material.Cobblestone },
	Post = { Color = Color3.fromRGB(120, 85, 55), Material = Enum.Material.Wood },
	HouseWall = { Color = Color3.fromRGB(215, 200, 170), Material = Enum.Material.Concrete },
	HouseFrame = { Color = Color3.fromRGB(90, 62, 42), Material = Enum.Material.Wood },
	Roof = { Color = Color3.fromRGB(60, 95, 80), Material = Enum.Material.Slate },
	Trunk = { Color = Color3.fromRGB(95, 68, 45), Material = Enum.Material.Wood },
	Leaves = { Color = Color3.fromRGB(55, 105, 50), Material = Enum.Material.Grass },
	Stone = { Color = Color3.fromRGB(125, 125, 120), Material = Enum.Material.Rock },
	Water = { Color = Color3.fromRGB(80, 150, 190), Material = Enum.Material.SmoothPlastic, Transparency = 0.3 },
	Bridge = { Color = Color3.fromRGB(140, 100, 65), Material = Enum.Material.WoodPlanks },
	Barrier = { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, Transparency = 1 },
	Spawn = { Color = Color3.fromRGB(160, 230, 140), Material = Enum.Material.Neon, Transparency = 0.6 },
}

Theme.Lighting = {
	ClockTime = 9.5,
	Brightness = 2.2,
	Ambient = Color3.fromRGB(80, 90, 80),
	OutdoorAmbient = Color3.fromRGB(120, 135, 120),
	Atmosphere = {
		Density = 0.4,
		Color = Color3.fromRGB(205, 225, 205),
		Decay = Color3.fromRGB(110, 140, 110),
		Haze = 1.8,
		Glare = 0,
	},
}

return Theme
