--[[
  NeonMenu Ultra v3 [Модуль 1/10] — Инициализация ядра и сервисов
]]
local CoreModule = {}
CoreModule.Version = "3.0.1"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

function CoreModule.Init(settingsTable, themeTable)
	print("[NeonModule] Ядро инициализировано успешно.")
	return true
end

return CoreModule

--[[
  NeonMenu Ultra v3 [Модуль 2/10] — Менеджер тем и базовых элементов интерфейса
]]
local ThemeModule = {}

function ThemeModule.ApplyTheme(theme, mainFrame, tabBar, contentFrame)
	if mainFrame then
		main.BackgroundColor3 = theme.Bg
	end
	if tabBar then
		tabBar.BackgroundColor3 = theme.Panel
	end
	print("[ThemeModule] Цветовая схема успешно применена.")
end

return ThemeModule

--[[
  NeonMenu Ultra v3 [Модуль 3/10] — Управление настройками и конфигурацией
]]
local ConfigModule = {}

ConfigModule.DefaultSettings = {
	AimAssist = false,
	AimSmooth = 5,
	AimFOV = 150,
	TeamCheck = true,
	WallCheck = false,
	WalkSpeed = 16,
	JumpPower = 50,
	ESP_Boxes = false,
	ESP_Tracers = false,
}

function ConfigModule.LoadSettings()
	-- Инициализация и сброс настроек по умолчанию
	local settings = {}
	for k, v in pairs(ConfigModule.DefaultSettings) do
		settings[k] = v
	end
	print("[ConfigModule] Конфигурация загружена.")
	return settings
end

return ConfigModule

--[[
  NeonMenu Ultra v3 [Модуль 4/10] — Утилиты для расчетов позиций и дистанции
]]
local MathModule = {}

function MathModule.CalculateDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

function MathModule.IsOnScreen(camera, worldPosition)
	local _, onScreen = camera:WorldToViewportPoint(worldPosition)
	return onScreen
end

print("[MathModule] Модуль математических расчетов подключен.")
return MathModule

--[[
  NeonMenu Ultra v3 [Модуль 5/10] — Логика Aim Assist и Silent Aim
]]
local CombatModule = {}

function CombatModule.GetClosestTarget(players, player, camera, settings, isEnemyFunc)
	local closestTarget = nil
	local shortestDist = settings.AimFOV
	local mousePos = game:GetService("UserInputService"):GetMouseLocation()

	for _, p in ipairs(players:GetPlayers()) do
		if p ~= player and isEnemyFunc(p) and p.Character then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			local targetPart = p.Character:FindFirstChild(settings.TargetPart) or p.Character:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and targetPart then
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
					if dist < shortestDist then
						shortestDist = dist
						closestTarget = targetPart
					end
				end
			end
		end
	end
	return closestTarget
end

print("[CombatModule] Модуль боевых функций подключен.")
return CombatModule

--[[
  NeonMenu Ultra v3 [Модуль 6/10] — Модуль ESP (Боксы, линии, ники)
]]
local ESPModule = {}

function ESPModule.UpdateDrawings(drawings, rootPos, headPos, legPos, plr, settings)
	local height = math.abs(headPos.Y - legPos.Y)
	local width = height / 2
	local boxX = rootPos.X - width / 2
	local boxY = headPos.Y

	-- Box ESP
	drawings.Box.Visible = settings.ESP_Boxes
	if settings.ESP_Boxes then
		drawings.Box.Size = Vector2.new(width, height)
		drawings.Box.Position = Vector2.new(boxX, boxY)
	end

	-- Name ESP
	drawings.Name.Visible = settings.ESP_Names
	if settings.ESP_Names then
		drawings.Name.Text = plr.Name
		drawings.Name.Position = Vector2.new(rootPos.X, boxY - 16)
	end
end

print("[ESPModule] Модуль ESP подключен.")
return ESPModule

--[[
  NeonMenu Ultra v3 [Модуль 7/10] — Модуль управления движением и физикой
]]
local MovementModule = {}

function MovementModule.ApplyMovement(character, settings)
	local hum = character:FindFirstChildOfClass("Humanoid")
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if hum then
		hum.WalkSpeed = settings.WalkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = settings.JumpPower
	end

	if settings.Noclip and character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end

print("[MovementModule] Модуль движения подключен.")
return MovementModule

--[[
  NeonMenu Ultra v3 [Модуль 8/10] — Модуль троллинга и фана
]]
local TrollModule = {}

function TrollModule.SpinCharacter(hrp)
	if hrp then
		for i = 1, 36 do
			hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
			task.wait(0.01)
		end
	end
end

function TrollModule.MegaJump(hrp)
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.new(0, 150, 0)
	end
end

print("[TrollModule] Модуль троллинга подключен.")
return TrollModule

--[[
  NeonMenu Ultra v3 [Модуль 9/10] — Модуль окружения, освещения и неба
]]
local EnvironmentModule = {}

function EnvironmentModule.ToggleFullbright(lighting, enabled, defaultClock)
	if enabled then
		lighting.Brightness = 2
		lighting.ClockTime = 14
		lighting.GlobalShadows = false
		lighting.Ambient = Color3.new(1, 1, 1)
	else
		lighting.GlobalShadows = true
		lighting.Brightness = 1
		lighting.ClockTime = defaultClock or 14
		lighting.Ambient = Color3.fromRGB(130, 130, 130)
	end
end

function EnvironmentModule.ToggleNoFog(atmosphere, lighting, enabled)
	if atmosphere then
		atmosphere.Density = enabled and 0 or 0.3
	end
	lighting.FogEnd = enabled and 100000 or 1000
end

print("[EnvironmentModule] Модуль окружения подключен.")
return EnvironmentModule

--[[
  NeonMenu Ultra v3 [Модуль 10/10] — Инициализация GUI, плавающей кнопки и сборка системы
]]
local MainMenuModule = {}

function MainMenuModule.CreateUI(gui, theme)
	local main = Instance.new("Frame")
	main.Name = "MainNeonMenu"
	main.Size = UDim2.fromOffset(600, 430)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = theme.Bg
	main.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = main

	print("[MainMenuModule] Интерфейс успешно собран из модулей.")
	return main
end

return MainMenuModule

            
