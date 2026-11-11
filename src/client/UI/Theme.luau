--!strict
-- ธีม UI กลาง: สี ฟอนต์ ความเร็วแอนิเมชัน (ดีไซน์ต้นฉบับ ไม่ใช้โลโก้/ฟอนต์จากอนิเมะ)

local Theme = {
	Bg = Color3.fromRGB(10, 12, 24),
	Panel = Color3.fromRGB(22, 26, 46),
	PanelLight = Color3.fromRGB(34, 40, 68),
	Text = Color3.fromRGB(245, 247, 255),
	Muted = Color3.fromRGB(150, 160, 190),
	Accent = Color3.fromRGB(255, 190, 60),
	Red = Color3.fromRGB(255, 56, 56),
	Green = Color3.fromRGB(80, 220, 110),
	Danger = Color3.fromRGB(255, 90, 90),

	FontTitle = Enum.Font.GothamBlack,
	FontBold = Enum.Font.GothamBold,
	FontBody = Enum.Font.Gotham,

	-- ปุ่มต้องสูงอย่างน้อยเท่านี้ (พิกเซล) เพื่อให้นิ้วกดง่ายบนมือถือ
	MinTouch = 44,
}

Theme.Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
Theme.Page = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
Theme.Bouncy = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

return Theme
