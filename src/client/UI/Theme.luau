--!strict
-- ธีม UI กลาง: สี ฟอนต์ ความเร็วแอนิเมชัน (ดีไซน์ต้นฉบับ ไม่ใช้โลโก้/ฟอนต์จากอนิเมะ)

local Theme = {
	-- สไตล์แผงดำขอบแดงเข้มแบบเกมต่อสู้อาร์เคด (ดีไซน์ของเราเอง)
	Bg = Color3.fromRGB(6, 6, 10),
	Panel = Color3.fromRGB(10, 10, 14),
	PanelLight = Color3.fromRGB(26, 26, 32),
	Crimson = Color3.fromRGB(165, 24, 40),
	Text = Color3.fromRGB(245, 247, 255),
	Muted = Color3.fromRGB(150, 160, 190),
	Accent = Color3.fromRGB(255, 190, 60),
	Red = Color3.fromRGB(255, 56, 56),
	Green = Color3.fromRGB(80, 220, 110),
	Danger = Color3.fromRGB(255, 90, 90),

	FontTitle = Enum.Font.GothamBlack,
	FontPixel = Enum.Font.Arcade, -- ใช้กับตัวเลข/คำอังกฤษเท่านั้น (ไม่รองรับไทย)
	FontBold = Enum.Font.GothamBold,
	FontBody = Enum.Font.Gotham,

	-- ปุ่มต้องสูงอย่างน้อยเท่านี้ (พิกเซล) เพื่อให้นิ้วกดง่ายบนมือถือ
	MinTouch = 44,
}

Theme.Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
Theme.Page = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
Theme.Bouncy = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

return Theme
