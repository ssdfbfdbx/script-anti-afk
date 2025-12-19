-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--------------------------------------------------
-- GUI SETUP
--------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "AntiAFK_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN WINDOW
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.fromOffset(280, 170)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(22,22,28)
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.Active = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

-- OUTLINE
local stroke = Instance.new("UIStroke")
stroke.Parent = main
stroke.Color = Color3.fromRGB(0,200,255)
stroke.Thickness = 1.5
stroke.Transparency = 1

--------------------------------------------------
-- TOP BAR
--------------------------------------------------
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,36)
top.BackgroundColor3 = Color3.fromRGB(18,18,22)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.fromOffset(12,0)
title.BackgroundTransparency = 1
title.Text = "ANTI AFK - by sosohess"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(0,200,255)
title.TextTransparency = 1

local close = Instance.new("TextButton", top)
close.Size = UDim2.fromOffset(26,26)
close.Position = UDim2.fromOffset(246,5)
close.Text = "✕"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(200,70,70)
close.TextTransparency = 1
Instance.new("UICorner", close)

--------------------------------------------------
-- CONTENT
--------------------------------------------------
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.fromOffset(240,42)
toggle.Position = UDim2.fromOffset(20,52)
toggle.Text = "ANTI AFK : OFF"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 15
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(170,60,60)
toggle.TextTransparency = 1
Instance.new("UICorner", toggle)

local stats = Instance.new("TextLabel", main)
stats.Size = UDim2.fromOffset(240,48)
stats.Position = UDim2.fromOffset(20,104)
stats.BackgroundColor3 = Color3.fromRGB(30,30,36)
stats.TextColor3 = Color3.fromRGB(220,220,220)
stats.Font = Enum.Font.Gotham
stats.TextSize = 13
stats.Text = "Temps : 0s\nSauts : 0"
stats.TextTransparency = 1
Instance.new("UICorner", stats)

--------------------------------------------------
-- STARTUP ANIMATION (100% SAFE)
--------------------------------------------------
main.Size = UDim2.fromOffset(240, 140)

TweenService:Create(main, TweenInfo.new(
	0.45,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
), {
	Size = UDim2.fromOffset(280, 170),
	BackgroundTransparency = 0
}):Play()

TweenService:Create(stroke, TweenInfo.new(0.4), {
	Transparency = 0.15
}):Play()

task.delay(0.15, function()
	for _,v in ipairs(main:GetDescendants()) do
		if v:IsA("TextLabel") or v:IsA("TextButton") then
			TweenService:Create(v, TweenInfo.new(0.25), {
				TextTransparency = 0
			}):Play()
		end
	end
end)

--------------------------------------------------
-- DRAG SYSTEM (FIABLE)
--------------------------------------------------
local dragging = false
local dragStart, startPos

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--------------------------------------------------
-- ANTI AFK LOGIC
--------------------------------------------------
local enabled = false
local startTime = 0
local jumpCount = 0
local lastJump = 0
local jumpCooldown = 3
local angle = 0

local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

toggle.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		startTime = tick()
		jumpCount = 0
		toggle.Text = "ANTI AFK : ON"
		toggle.BackgroundColor3 = Color3.fromRGB(60,190,120)
	else
		toggle.Text = "ANTI AFK : OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(170,60,60)
	end
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

RunService.RenderStepped:Connect(function(dt)
	if not enabled then return end

	angle += dt
	root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, angle, 0)
	humanoid:Move(Vector3.new(math.sin(angle),0,math.cos(angle)), true)

	if tick() - lastJump >= jumpCooldown then
		humanoid.Jump = true
		jumpCount += 1
		lastJump = tick()
	end

	stats.Text =
		"Temps : "..math.floor(tick() - startTime).."s\n"..
		"Sauts : "..jumpCount
end)
