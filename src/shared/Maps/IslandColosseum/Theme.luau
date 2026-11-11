--!strict
-- หน้าตาแมพ "โคลอสเซียมเกาะเขตร้อน": หินอ่อนสีครีม ทรายขาว ทะเลใส ต้นปาล์ม แสงบ่ายจ้า

local Theme = {}

Theme.Looks = {
	Sand = { Color = Color3.fromRGB(226, 208, 164), Material = Enum.Material.Sand },
	Ring = { Color = Color3.fromRGB(190, 168, 125), Material = Enum.Material.Sand },
	Marble = { Color = Color3.fromRGB(232, 226, 212), Material = Enum.Material.Marble },
	Stone = { Color = Color3.fromRGB(196, 184, 160), Material = Enum.Material.Limestone },
	StoneDark = { Color = Color3.fromRGB(150, 138, 118), Material = Enum.Material.Limestone },
	TopWall = { Color = Color3.fromRGB(170, 120, 90), Material = Enum.Material.Brick },
	Gate = { Color = Color3.fromRGB(70, 55, 45), Material = Enum.Material.Wood },
	Column = { Color = Color3.fromRGB(240, 235, 222), Material = Enum.Material.Marble },
	Wood = { Color = Color3.fromRGB(125, 86, 55), Material = Enum.Material.WoodPlanks },
	Island = { Color = Color3.fromRGB(240, 225, 185), Material = Enum.Material.Sand },
	Sea = { Color = Color3.fromRGB(40, 150, 190), Material = Enum.Material.SmoothPlastic, Transparency = 0.2 },
	Trunk = { Color = Color3.fromRGB(120, 90, 60), Material = Enum.Material.Wood },
	Leaf = { Color = Color3.fromRGB(50, 140, 70), Material = Enum.Material.Grass },
	Barrier = { Color = Color3.new(1, 1, 1), Material = Enum.Material.SmoothPlastic, Transparency = 1 },
	Spawn = { Color = Color3.fromRGB(255, 215, 110), Material = Enum.Material.Neon, Transparency = 0.6 },
}

Theme.Lighting = {
	ClockTime = 14,
	Brightness = 3,
	Ambient = Color3.fromRGB(100, 100, 105),
	OutdoorAmbient = Color3.fromRGB(150, 150, 150),
	Atmosphere = {
		Density = 0.25,
		Color = Color3.fromRGB(190, 215, 235),
		Decay = Color3.fromRGB(120, 150, 170),
		Haze = 1,
		Glare = 0.2,
	},
}

return Theme
