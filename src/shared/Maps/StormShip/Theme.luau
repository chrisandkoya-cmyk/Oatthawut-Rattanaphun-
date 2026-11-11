--!strict
-- หน้าตาแมพ "ดาดฟ้าเรือโจรสลัด": ไม้เปียก ทะเลมืด ท้องฟ้าพายุยามเย็น

local Theme = {}

Theme.Looks = {
	Deck = { Color = Color3.fromRGB(139, 98, 62), Material = Enum.Material.WoodPlanks },
	Sea = { Color = Color3.fromRGB(30, 70, 100), Material = Enum.Material.SmoothPlastic, Transparency = 0.15 },
	Hull = { Color = Color3.fromRGB(95, 62, 40), Material = Enum.Material.Wood },
	Rail = { Color = Color3.fromRGB(75, 48, 32), Material = Enum.Material.Wood },
	Mast = { Color = Color3.fromRGB(105, 72, 48), Material = Enum.Material.Wood },
	Sail = { Color = Color3.fromRGB(225, 215, 195), Material = Enum.Material.Fabric },
	Cabin = { Color = Color3.fromRGB(120, 82, 54), Material = Enum.Material.WoodPlanks },
	CabinRoof = { Color = Color3.fromRGB(70, 90, 100), Material = Enum.Material.Slate },
	Crate = { Color = Color3.fromRGB(160, 120, 70), Material = Enum.Material.Wood },
	Barrier = { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, Transparency = 1 },
	Spawn = { Color = Color3.fromRGB(120, 200, 255), Material = Enum.Material.Neon, Transparency = 0.6 },
}

Theme.Lighting = {
	ClockTime = 18.3,
	Brightness = 1.6,
	Ambient = Color3.fromRGB(55, 60, 75),
	OutdoorAmbient = Color3.fromRGB(95, 100, 120),
	Atmosphere = {
		Density = 0.45,
		Color = Color3.fromRGB(150, 160, 180),
		Decay = Color3.fromRGB(90, 70, 80),
		Haze = 2,
		Glare = 0,
	},
}

return Theme
