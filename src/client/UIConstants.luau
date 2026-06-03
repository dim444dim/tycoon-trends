local UIConstants = {}

UIConstants.Animation = {
	Fast = 0.15,
	Standard = 0.25,
	Slow = 0.40,
}

UIConstants.Colors = {
	Background = Color3.fromRGB(18, 18, 30),
	Foreground = Color3.fromRGB(30, 30, 45),
	PrimaryText = Color3.fromRGB(255, 255, 255),
	SecondaryText = Color3.fromRGB(200, 200, 200),
	AccentGreen = Color3.fromRGB(100, 255, 100),
	AccentRed = Color3.fromRGB(255, 100, 100),
	AccentBlue = Color3.fromRGB(100, 150, 255),
	AccentGold = Color3.fromRGB(255, 200, 100),
}

UIConstants.Layout = {
	CashPanelPosition = UDim2.new(0, 20, 0, 20),
	CashPanelSize = UDim2.new(0, 300, 0, 80),
	ShopButtonPosition = UDim2.new(0.5, -50, 1, -60),
	ShopButtonSize = UDim2.new(0, 100, 0, 40),
}

UIConstants.SessionProgressBarCap = 50000

return UIConstants
