--[[
  NeonMenu Ultra v4.0 [Animated & Custom Models Edition] — Часть 1/3
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Защита от крашей (Anti-Crash & Anti-267)
local function safeCall(func, ...)
	local success, err = pcall(func, ...)
	if not success then return nil end
	return err
end

-- Защищенный контейнер GUI для экзекутора
local guiParent = safeCall(function() return gethui() end) or player:WaitForChild("PlayerGui")

local Theme = {
	Bg = Color3.fromRGB(10, 10, 15),
	Panel = Color3.fromRGB(16, 16, 24),
	Item = Color3.fromRGB(22, 22, 35),
	Accent = Color3.fromRGB(139, 92, 246), -- Неоновый фиолетовый
	Accent2 = Color3.fromRGB(34, 211, 238), -- Неоновый голубой
	Text = Color3.fromRGB(240, 240, 255),
	Muted = Color3.fromRGB(120, 120, 150),
}

local function tween(obj, props, t, style)
	safeCall(function()
		TweenService:Create(obj, TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end)
end

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do safeCall(function() o[k] = v end) end
	if parent then o.Parent = parent end
	return o
end

local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end

-- Глобальные настройки чит-меню
local Settings = {
	SilentAim = false,
	AimFOV = 100,
	WallCheck = true,
	ESP_Chams = false,
	HitboxExpander = false,
	Noclip = false,
	InfiniteJump = false,
	BunnyHop = false,
	AntiVoid = true,
}

-- 🔍 Умный сканер для кастомных моделей шутеров
local function getCustomRoot(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") 
		or char:FindFirstChild("RootPart") 
		or char:FindFirstChild("Torso") 
		or char:FindFirstChild("UpperTorso") 
		or char:FindFirstChild("MainPart")
end

local function getCustomHead(char)
	if not char then return nil end
	local head = char:FindFirstChild("Head") or char:FindFirstChild("Helmet") or char:FindFirstChild("FacePart")
	if not head then
		local maxY = -math.huge
		for _, p in ipairs(char:GetChildren()) do
			if p:IsA("BasePart") and p.Position.Y > maxY then
				maxY = p.Position.Y
				head = p
			end
		end
	end
	return head
end

--[[
  NeonMenu Ultra v4.0 — Часть 2/3 (Анимированный интерфейс)
]]

local gui = make("ScreenGui", {
	Name = "NeonUltraAnimated", 
	ResetOnSpawn = false, 
	IgnoreGuiInset = true, 
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, guiParent)

local main = make("Frame", {
	Size = UDim2.fromOffset(600, 420), 
	Position = UDim2.fromScale(0.5, 0.5), 
	AnchorPoint = Vector2.new(0.5, 0.5), 
	BackgroundColor3 = Theme.Bg,
	BackgroundTransparency = 0.05
}, gui)
corner(main, 16)
make("UIStroke", {Color = Theme.Accent, Thickness = 2, Transparency = 0.3}, main)

-- Шапка
local header = make("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1}, main)
make("TextLabel", {
	Text = "⚡ NEON ULTRA v4.0 [CUSTOM SHOTGUN EDITION]", 
	Font = Enum.Font.GothamBold, 
	TextSize = 13, 
	TextColor3 = Theme.Text, 
	BackgroundTransparency = 1, 
	Position = UDim2.fromOffset(18, 0), 
	Size = UDim2.new(0.7, 0, 1, 0), 
	TextXAlignment = Enum.TextXAlignment.Left
}, header)

local closeBtn = make("TextButton", {
	Text = "×", 
	Font = Enum.Font.GothamBold, 
	TextSize = 22, 
	TextColor3 = Theme.Muted, 
	BackgroundTransparency = 1, 
	Size = UDim2.fromOffset(40, 40), 
	Position = UDim2.new(1, -45, 0, 2),
	AutoButtonColor = false
}, header)

closeBtn.MouseEnter:Connect(function() tween(closeBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.15) end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, {TextColor3 = Theme.Muted}, 0.15) end)

-- Перетаскивание окна
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

-- Боковая панель вкладок
local tabBar = make("Frame", {Size = UDim2.new(0, 140, 1, -55), Position = UDim2.fromOffset(12, 50), BackgroundColor3 = Theme.Panel}, main)
corner(tabBar, 12)
make("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, tabBar)
make("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, tabBar)

local content = make("Frame", {Size = UDim2.new(1, -168, 1, -55), Position = UDim2.fromOffset(156, 50), BackgroundTransparency = 1}, main)
local pages, tabButtons = {}, {}

local function selectTab(name)
	for n, page in pairs(pages) do 
		page.Visible = (n == name)
		if n == name then
			page.Position = UDim2.fromOffset(0, 10)
			page.BackgroundTransparency = 1
			tween(page, {Position = UDim2.fromOffset(0, 0)}, 0.25, Enum.EasingStyle.Back)
		end
	end
	for n, b in pairs(tabButtons) do
		local active = (n == name)
		tween(b, {
			BackgroundColor3 = active and Theme.Accent or Theme.Item,
			TextColor3 = active and Color3.new(1, 1, 1) + Color3.fromRGB(20,20,20) or Theme.Muted
		}, 0.2)
	end
end

local function addTab(name, order)
	local b = make("TextButton", {Text = name, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Theme.Muted, BackgroundColor3 = Theme.Item, Size = UDim2.new(1, 0, 0, 34), LayoutOrder = order, AutoButtonColor = false}, tabBar)
	corner(b, 8)
	
	b.MouseEnter:Connect(function() if tabButtons[name].BackgroundColor3 ~= Theme.Accent then tween(b, {TextColor3 = Theme.Text}, 0.15) end end)
	b.MouseLeave:Connect(function() if tabButtons[name].BackgroundColor3 ~= Theme.Accent then tween(b, {TextColor3 = Theme.Muted}, 0.15) end end)

	local page = make("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false}, content)
	make("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
	
	pages[name], tabButtons[name] = page, b
	b.MouseButton1Click:Connect(function() selectTab(name) end)
	return page
end

local function section(page, text)
	make("TextLabel", {Text = text:upper(), Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Theme.Accent2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), TextXAlignment = Enum.TextXAlignment.Left}, page)
end

-- Плавный анимированный тоггл
local function toggle(page, text, default, cb)
	local state = default
	local row = make("TextButton", {Text = "", BackgroundColor3 = Theme.Item, Size = UDim2.new(1, 0, 0, 36), AutoButtonColor = false}, page)
	corner(row, 8)
	
	row.MouseEnter:Connect(function() tween(row, {BackgroundColor3 = Color3.fromRGB(28, 28, 45)}, 0.15) end)
	row.MouseLeave:Connect(function() tween(row, {BackgroundColor3 = Theme.Item}, 0.15) end)

	make("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Theme.Text, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -70, 1, 0), TextXAlignment = Enum.TextXAlignment.Left}, row)
	
	local track = make("Frame", {Size = UDim2.fromOffset(40, 20), Position = UDim2.new(1, -48, 0.5, -10), BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(40, 40, 60)}, row)
	corner(track, 10)
	
	local knob = make("Frame", {Size = UDim2.fromOffset(16, 16), Position = state and UDim2.fromOffset(21, 2) or UDim2.fromOffset(3, 2), BackgroundColor3 = Color3.new(1, 1, 1)}, track)
	corner(knob, 8)
	
	row.MouseButton1Click:Connect(function()
		state = not state
		tween(track, {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(40, 40, 60)}, 0.2)
		tween(knob, {Position = state and UDim2.fromOffset(21, 2) or UDim2.fromOffset(3, 2)}, 0.2, Enum.EasingStyle.Back)
		safeCall(cb, state)
	end)
	safeCall(cb, state)
end

-- Создаем вкладки
local combatTab = addTab("Бой", 1)
local espTab = addTab("Визуал", 2)
local moveTab = addTab("Движение", 3)

section(combatTab, "Наводка")
toggle(combatTab, "Silent Aim Assist", false, function(v) Settings.SilentAim = v end)
toggle(combatTab, "WallCheck (Проверка стен)", true, function(v) Settings.WallCheck = v end)

section(espTab, "Подсветка игроков")
toggle(espTab, "Chams (Сквозь стены)", false, function(v) Settings.ESP_Chams = v end)
toggle(espTab, "Увеличение хитбоксов", false, function(v) Settings.HitboxExpander = v end)

section(moveTab, "Физика и Мувмент")
toggle(moveTab, "Noclip (Ходьба сквозь стены)", false, function(v) Settings.Noclip = v end)
toggle(moveTab, "Infinite Jump (Бесконечный прыжок)", false, function(v) Settings.InfiniteJump = v end)
toggle(moveTab, "BunnyHop (Авто-распрыжка)", false, function(v) Settings.BunnyHop = v end)

selectTab("Бой")

--[[
  NeonMenu Ultra v4.0 — Часть 3/3 (Логика читов под кастомные игры)
]]

local function isEnemy(plr)
	if not player.Team or not plr.Team then return true end
	return player.Team ~= plr.Team
end

-- Safe Chams с учетом кастомных частей тела
RunService.RenderStepped:Connect(function()
	safeCall(function()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local char = plr.Character
				local head = getCustomHead(char)
				local enemy = isEnemy(plr)

				local hl = char:FindFirstChild("CustomChams")
				if Settings.ESP_Chams and enemy and head then
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "CustomChams"
						hl.FillTransparency = 0.45
						hl.FillColor = Color3.fromRGB(255, 40, 40)
						hl.OutlineColor = Theme.Accent2
						hl.Parent = char
					end
				elseif hl then
					hl:Destroy()
				end

				-- Расширение хитбоксов для кастомных моделей
				if Settings.HitboxExpander and enemy then
					local root = getCustomRoot(char)
					if root then
						root.Size = Vector3.new(4, 4, 4)
						root.Transparency = 0.8
						root.CanCollide = false
					end
				end
			end
		end
	end)
end)

-- Бесконечный прыжок и BunnyHop
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
		local hum = char:FindFirstChildOfClass("Humanoid")

		-- Noclip для кастомных ригов
		if Settings.Noclip then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end

		-- BunnyHop симуляция
		if Settings.BunnyHop and hum then
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end)

-- Скрытие меню на RightShift
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
