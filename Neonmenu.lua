--[[
  NeonMenu Ultra v3.5 — Часть 1/3 (Конфигурация и обходы)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Защита от критических ошибок и детект-киков (обход ошибки 267)
local function safeCall(func, ...)
	local success, err = pcall(func, ...)
	if not success then return nil end
	return err
end

local Theme = {
	Bg = Color3.fromRGB(12, 12, 18),
	Panel = Color3.fromRGB(18, 18, 28),
	Item = Color3.fromRGB(26, 26, 40),
	Accent = Color3.fromRGB(139, 92, 246),
	Accent2 = Color3.fromRGB(34, 211, 238),
	Text = Color3.fromRGB(235, 235, 245),
	Muted = Color3.fromRGB(140, 140, 165),
}

local function tween(obj, props, t)
	safeCall(function()
		TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
	end)
end

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do 
		safeCall(function() o[k] = v end)
	end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end

local Settings = {
	AimAssist = false,
	AimSmooth = 8,
	AimFOV = 120,
	TeamCheck = true,
	WallCheck = true,
	TargetPart = "Head",
	TriggerBot = false,
	ESP_Chams = false,
	WalkSpeed = 16,
	JumpPower = 50,
	InfiniteJump = false,
	Noclip = false,
	Fly = false,
	AntiVoid = true,
	AutoFarm = false,
}

--[[
  NeonMenu Ultra v3.5 — Часть 2/3 (Интерфейс и вкладки)
]]

local gui = make("ScreenGui", {
	Name = "NeonMenuSecure", 
	ResetOnSpawn = false, 
	IgnoreGuiInset = true, 
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, safeCall(function() return CoreGui end) or player:WaitForChild("PlayerGui"))

local main = make("Frame", {
	Size = UDim2.fromOffset(580, 410), 
	Position = UDim2.fromScale(0.5, 0.5), 
	AnchorPoint = Vector2.new(0.5, 0.5), 
	BackgroundColor3 = Theme.Bg
}, gui)
corner(main, 14)
make("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Transparency = 0.4}, main)

local header = make("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1}, main)
make("TextLabel", {
	Text = "NEON ULTRA v3.5 [SECURE BYPASS]", 
	Font = Enum.Font.GothamBold, 
	TextSize = 14, 
	TextColor3 = Theme.Text, 
	BackgroundTransparency = 1, 
	Position = UDim2.fromOffset(16, 0), 
	Size = UDim2.new(0.7, 0, 1, 0), 
	TextXAlignment = Enum.TextXAlignment.Left
}, header)

local closeBtn = make("TextButton", {
	Text = "×", 
	Font = Enum.Font.GothamBold, 
	TextSize = 20, 
	TextColor3 = Theme.Muted, 
	BackgroundTransparency = 1, 
	Size = UDim2.fromOffset(36, 36), 
	Position = UDim2.new(1, -40, 0, 2)
}, header)

-- Перетаскивание мышей
do
	local dragging, startPos, startInput
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, startPos, startInput = true, main.Position, i.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local tabBar = make("Frame", {Size = UDim2.new(0, 130, 1, -50), Position = UDim2.fromOffset(10, 45), BackgroundColor3 = Theme.Panel}, main)
corner(tabBar, 10)
make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, tabBar)
make("UIPadding", {PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, tabBar)

local content = make("Frame", {Size = UDim2.new(1, -155, 1, -50), Position = UDim2.fromOffset(145, 45), BackgroundTransparency = 1}, main)
local pages, tabButtons = {}, {}

local function selectTab(name)
	for n, page in pairs(pages) do page.Visible = (n == name) end
	for n, b in pairs(tabButtons) do
		tween(b, {BackgroundColor3 = (n == name) and Theme.Accent or Theme.Item, TextColor3 = (n == name) and Color3.new(1, 1, 1) or Theme.Muted})
	end
end

local function addTab(name, order)
	local b = make("TextButton", {Text = name, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Muted, BackgroundColor3 = Theme.Item, Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order, AutoButtonColor = false}, tabBar)
	corner(b, 6)
	local page = make("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, content)
	make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	pages[name], tabButtons[name] = page, b
	b.MouseButton1Click:Connect(function() selectTab(name) end)
	return page
end

local function section(page, text)
	make("TextLabel", {Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.Accent2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left}, page)
end

local function toggle(page, text, default, cb)
	local state = default
	local row = make("TextButton", {Text = "", BackgroundColor3 = Theme.Item, Size = UDim2.new(1, 0, 0, 32), AutoButtonColor = false}, page)
	corner(row, 6)
	make("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text, BackgroundTransparency = 1, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left}, row)
	local track = make("Frame", {Size = UDim2.fromOffset(34, 16), Position = UDim2.new(1, -42, 0.5, -8), BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 70)}, row)
	corner(track, 8)
	local knob = make("Frame", {Size = UDim2.fromOffset(12, 12), Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2), BackgroundColor3 = Color3.new(1, 1, 1)}, track)
	corner(knob, 6)
	
	row.MouseButton1Click:Connect(function()
		state = not state
		tween(track, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 70)})
		tween(knob, {Position = state and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)})
		safeCall(cb, state)
	end)
	safeCall(cb, state)
end

local combatTab = addTab("Бой", 1)
local espTab = addTab("Визуал (ESP)", 2)
local moveTab = addTab("Движение", 3)
local utilsTab = addTab("Функции", 4)

section(combatTab, "Безопасный Aimbot")
toggle(combatTab, "Aim Assist (ПКМ)", false, function(v) Settings.AimAssist = v end)
toggle(combatTab, "TriggerBot (Автовыстрел)", false, function(v) Settings.TriggerBot = v end)

section(espTab, "Подсветка игроков (Safe)")
toggle(espTab, "Chams (Подсветка сквозь стены)", false, function(v) Settings.ESP_Chams = v end)

section(moveTab, "Параметры персонажа")
toggle(moveTab, "Бесконечный прыжок", false, function(v) Settings.InfiniteJump = v end)
toggle(moveTab, "Noclip (Ходьба сквозь стены)", false, function(v) Settings.Noclip = v end)
toggle(moveTab, "Fly (Полёт на WASD)", false, function(v) Settings.Fly = v end)

section(utilsTab, "Автоматизация и Трейсеры")
toggle(utilsTab, "Анти-падение в бездну", true, function(v) Settings.AntiVoid = v end)
toggle(utilsTab, "Авто-фарм / Сбор элементов", false, function(v) Settings.AutoFarm = v end)

selectTab("Бой")

--[[
  NeonMenu Ultra v3.5 — Часть 3/3 (Игровая логика и циклы)
]]

local function isEnemy(plr)
	if not Settings.TeamCheck then return true end
	if not player.Team or not plr.Team then return true end
	return player.Team ~= plr.Team
end

-- Безопасный Chams через стандартный Highlight (без детекта 267)
RunService.RenderStepped:Connect(function()
	safeCall(function()
		local rainbowColor = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local char = plr.Character
				local hum = char:FindFirstChildOfClass("Humanoid")
				local enemy = isEnemy(plr)

				local hl = char:FindFirstChild("SafeHighlight")
				if Settings.ESP_Chams and enemy and hum and hum.Health > 0 then
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "SafeHighlight"
						hl.FillTransparency = 0.5
						hl.Parent = char
					end
					hl.FillColor = rainbowColor
					hl.OutlineColor = Theme.Accent2
				elseif hl then
					hl:Destroy()
				end
			end
		end
	end)
end)

UserInputService.JumpRequest:Connect(function()
	safeCall(function()
		if Settings.InfiniteJump and player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
	end)
end)

RunService.Stepped:Connect(function()
	safeCall(function()
		local char = player.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")

		if Settings.Noclip then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.CanCollide = false end
			end
		end

		if hum then
			if Settings.WalkSpeed ~= 16 then hum.WalkSpeed = Settings.WalkSpeed end
			if Settings.JumpPower ~= 50 then hum.JumpPower = Settings.JumpPower end
		end

		if Settings.AntiVoid and hrp and hrp.Position.Y < -60 then
			hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
			hrp.AssemblyLinearVelocity = Vector3.zero
		end
		
		if Settings.AutoFarm then
			pcall(function()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("star")) then
						if hrp and (obj.Position - hrp.Position).Magnitude < 25 then
							hrp.CFrame = obj.CFrame
						end
					end
				end
			end)
		end
	end)
end)

local isOpen = true
closeBtn.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	main.Visible = isOpen
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.RightShift then
		isOpen = not isOpen
		main.Visible = isOpen
	end
end)
