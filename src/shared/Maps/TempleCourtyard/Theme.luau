--!strict
-- หน้าตาของแมพ "ลานวัดร้าง" (สี/วัสดุ/แสง) แยกออกจาก Layout
-- อยากเปลี่ยนโทนสีหรือวัสดุ แก้ไฟล์นี้ไฟล์เดียว ไม่ต้องแตะตำแหน่งชิ้นส่วน

export type Look = {
	Color: Color3,
	Material: Enum.Material,
	Transparency: number?,
}

local Theme = {}

Theme.Looks = {
	Floor = { Color = Color3.fromRGB(150, 140, 125), Material = Enum.Material.Slate },
	FloorTrim = { Color = Color3.fromRGB(110, 100, 90), Material = Enum.Material.Cobblestone },
	Grass = { Color = Color3.fromRGB(86, 120, 64), Material = Enum.Material.Grass },
	Wall = { Color = Color3.fromRGB(120, 108, 96), Material = Enum.Material.Brick },
	WallCap = { Color = Color3.fromRGB(95, 85, 76), Material = Enum.Material.Slate },
	Pillar = { Color = Color3.fromRGB(185, 172, 150), Material = Enum.Material.Limestone },
	Platform = { Color = Color3.fromRGB(135, 125, 110), Material = Enum.Material.Cobblestone },
	Dais = { Color = Color3.fromRGB(170, 160, 140), Material = Enum.Material.Marble },
	Statue = { Color = Color3.fromRGB(105, 120, 110), Material = Enum.Material.Rock },
	Rubble = { Color = Color3.fromRGB(125, 115, 102), Material = Enum.Material.Rock },
	Wood = { Color = Color3.fromRGB(110, 70, 45), Material = Enum.Material.WoodPlanks },
	Roof = { Color = Color3.fromRGB(150, 60, 45), Material = Enum.Material.Slate },
	Barrier = { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, Transparency = 1 },
	Spawn = { Color = Color3.fromRGB(200, 170, 90), Material = Enum.Material.Neon, Transparency = 0.6 },
} :: { [string]: Look }

-- แสงยามบ่ายแก่ โทนอุ่น
Theme.Lighting = {
	ClockTime = 16.2,
	Brightness = 2.5,
	Ambient = Color3.fromRGB(70, 65, 60),
	OutdoorAmbient = Color3.fromRGB(130, 120, 110),
	FogEnd = 1500,
	Atmosphere = {
		Density = 0.3,
		Color = Color3.fromRGB(220, 195, 165),
		Decay = Color3.fromRGB(120, 95, 80),
		Haze = 1.2,
		Glare = 0.2,
	},
}

return Theme
