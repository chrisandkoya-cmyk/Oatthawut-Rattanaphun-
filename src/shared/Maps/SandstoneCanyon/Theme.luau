--!strict
-- หน้าตาแมพ "หุบเขาหินแตก": ทรายอุ่น หินแดง แสงกลางวันจ้า

local Theme = {}

Theme.Looks = {
	Sand = { Color = Color3.fromRGB(214, 184, 130), Material = Enum.Material.Sand },
	OuterSand = { Color = Color3.fromRGB(196, 164, 112), Material = Enum.Material.Sand },
	Cliff = { Color = Color3.fromRGB(176, 108, 74), Material = Enum.Material.Sandstone },
	CliffCap = { Color = Color3.fromRGB(150, 88, 60), Material = Enum.Material.Rock },
	Rock = { Color = Color3.fromRGB(160, 96, 66), Material = Enum.Material.Sandstone },
	RockDark = { Color = Color3.fromRGB(110, 78, 62), Material = Enum.Material.Slate },
	Mesa = { Color = Color3.fromRGB(190, 130, 90), Material = Enum.Material.Sandstone },
	Barrier = { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, Transparency = 1 },
	Spawn = { Color = Color3.fromRGB(255, 200, 90), Material = Enum.Material.Neon, Transparency = 0.6 },
}

Theme.Lighting = {
	ClockTime = 13,
	Brightness = 3,
	Ambient = Color3.fromRGB(95, 80, 70),
	OutdoorAmbient = Color3.fromRGB(150, 130, 110),
	Atmosphere = {
		Density = 0.25,
		Color = Color3.fromRGB(235, 205, 165),
		Decay = Color3.fromRGB(150, 110, 80),
		Haze = 1.5,
		Glare = 0.3,
	},
}

return Theme
