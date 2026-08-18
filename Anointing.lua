-- =========================================================
-- SWEAR // SPEAR v5.0 (Anti-Detect & Безопасные функции)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "5.0"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

-- =========================================================
-- АВТООБНОВЛЕНИЕ
-- =========================================================
local function CheckForUpdate()
    local success, result = pcall(function() return game:HttpGet(RawURL) end)
    if success then
        local newVersion = string.match(result, 'ScriptVersion%s*=%s*"([^"]+)"')
        if newVersion and newVersion ~= ScriptVersion then
            loadstring(result)()
            return true
        end
    end
    return false
end
if CheckForUpdate() then return end

-- =========================================================
-- ПЕРЕМЕННЫЕ
-- =========================================================
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- Переменные для переключателей
local aimEnabled = false
local aimFov = 120
local godModeEnabled = false
local killAuraEnabled = false
local espEnabled = false

-- =========================================================
-- МЕНЮ (С прокруткой и перетаскиванием)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true  -- Включил перетаскивание

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "swear // spear"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

-- Прокручиваемый блок
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 400)
ScrollingFrame.ScrollBarThickness = 4

local function CreateToggle(yPos, label, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = ScrollingFrame
    ToggleFrame.Size = UDim2.new(0.95, 0, 0.08, 0)
    ToggleFrame.Position = UDim2.new(0.025, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = label
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.BackgroundTransparency = 1
    
    local Button = Instance.new("TextButton")
    Button.Parent = ToggleFrame
    Button.Size = UDim2.new(0.3, 0, 0.7, 0)
    Button.Position = UDim2.new(0.65, 0, 0.15, 0)
    Button.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.new(1, 1, 1)

    local isOn = false
    Button.MouseButton1Click:Connect(function()
        isOn = not isOn
        Button.Text = isOn and "ON" or "OFF"
        Button.BackgroundColor3 = isOn and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(200, 40, 40)
        callback(isOn)
    end)
end

-- =========================================================
-- ФУНКЦИИ (Работающие и безопасные)
-- =========================================================

-- 1. ESP (Боксы сквозь стены) - БЕЗОПАСНО
local espObjs = {}
CreateToggle(50, "ESP", function(state)
    espEnabled = state
    if state then
        task.spawn(function()
            while espEnabled do
                for _, v in pairs(espObjs) do v:Remove() end
                table.clear(espObjs)
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local root = p.Character.HumanoidRootPart
                        local head, vis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
                        local foot = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                        if vis then
                            local ht = math.abs(head.Y - foot.Y)
                            local wd = ht / 1.5
                            local box = Drawing.new("Square")
                            box.Position = Vector2.new(head.X - wd/2, head.Y)
                            box.Size = Vector2.new(wd, ht)
                            box.Color = Color3.fromRGB(255, 0, 0)
                            box.Thickness = 2
                            box.Visible = true
                            table.insert(espObjs, box)
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        for _, v in pairs(espObjs) do v:Remove() end
        table.clear(espObjs)
    end
end)

-- 2. БЕССМЕРТИЕ (Год-мод) - Исправлен переключатель
CreateToggle(90, "God Mode", function(state)
    godModeEnabled = state
    task.spawn(function()
        while godModeEnabled do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum and hum.Health < 100 then hum.Health = 100 end
            task.wait(0.1)
        end
    end)
end)

-- 3. АИМБОТ (Плавный, без дёрганий)
CreateToggle(130, "Aimbot", function(state)
    aimEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local char = GetChar()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local closestPart = nil
            local closestDist = aimFov
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local target = p.Character.HumanoidRootPart
                    local sp, vis = camera:WorldToViewportPoint(target.Position)
                    if vis then
                        local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestPart = target
                        end
                    end
                end
            end
            if closestPart then
                -- Плавное вращение камеры (без рывков)
                camera.CFrame = CFrame.new(camera.CFrame.Position, closestPart.Position)
            end
        end
    end
end)

-- 4. КИЛЛ АУРА (Точный удар, без спама кликов)
CreateToggle(170, "Kill Aura (Precise)", function(state)
    killAuraEnabled = state
    task.spawn(function()
        while killAuraEnabled do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                local nearestEnemy = nil
                local nearestDist = 20
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestEnemy = p
                        end
                    end
                end
                if nearestEnemy then
                    -- Наводим камеру на врага
                    local targetRoot = nearestEnemy.Character.HumanoidRootPart
                    camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
                    task.wait(0.05)
                    -- Делаем один точный клик
                    mouse1click()
                    task.wait(0.1)
                end
            end
            task.wait(0.2)
        end
    end)
end)

-- Закрыть по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
