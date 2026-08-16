-- =========================================================
-- ANOINTING MENU v2.0 (Стабильная версия на базе 1.3)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "2.0"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

-- Настройки по умолчанию
local JumpMultiplier = 3  -- Во сколько раз выше обычного прыжка
local KillAuraRadius = 15 -- Радиус убийства (метров)

-- =========================================================
-- АВТООБНОВЛЕНИЕ
-- =========================================================
local function CheckForUpdate()
    local success, result = pcall(function() return game:HttpGet(RawURL) end)
    if success then
        local newVersion = string.match(result, 'ScriptVersion%s*=%s*"([^"]+)"')
        if newVersion and newVersion ~= ScriptVersion then
            print("Обновление до v" .. newVersion)
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
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Функция для безопасного получения персонажа
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================================================
-- МЕНЮ (Визуал как в версии 1.3)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AnointingMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 290)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Anointing Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

-- Сворачивание меню по клику на заголовок
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then child.Visible = not isCollapsed end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 250, 0, 40) or UDim2.new(0, 250, 0, 290)
    end
end)

MainFrame.Draggable = true

local function CreateToggle(yPos, label, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = MainFrame
    ToggleFrame.Size = UDim2.new(0.9, 0, 0.09, 0)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    ToggleFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Text = label
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    
    local Button = Instance.new("TextButton")
    Button.Parent = ToggleFrame
    Button.Size = UDim2.new(0.3, 0, 0.8, 0)
    Button.Position = UDim2.new(0.7, 0, 0.1, 0)
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
-- ИСПРАВЛЕННЫЕ ФУНКЦИИ (ЧЕРЕЗ ФОНОВЫЕ ЦИКЛЫ)
-- =========================================================

-- 1. СУПЕР СКОРОСТЬ (Не сбрасывается при прыжках)
CreateToggle(50, "Super Speed", function(state)
    task.spawn(function()
        while state do
            local char = GetChar()
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed ~= 35 then
                hum.WalkSpeed = 35
            end
            task.wait(0.1)
        end
    end)
end)

-- 2. СУПЕР ПРЫЖОК (Не сбрасывается)
CreateToggle(90, "Super Jump", function(state)
    task.spawn(function()
        while state do
            local char = GetChar()
            local hum = char:FindFirstChild("Humanoid")
            if hum and hum.JumpPower ~= (16 * JumpMultiplier) then
                hum.JumpPower = 16 * JumpMultiplier
            end
            task.wait(0.1)
        end
    end)
end)

-- 3. ИНФИНИТИ ДЖАМП (Работает мягко)
CreateToggle(130, "Infinite Jump", function(state)
    task.spawn(function()
        while state do
            local char = GetChar()
            local hum = char:FindFirstChild("Humanoid")
            if hum and not hum.FloorMaterial then
                hum.Jump = true
            end
            task.wait()
        end
    end)
end)

-- 4. НОУКЛИП (Не сбрасывается)
CreateToggle(170, "Noclip", function(state)
    task.spawn(function()
        while state do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root.CanCollide == true then
                root.CanCollide = false
            end
            task.wait(0.1)
        end
    end)
end)

-- 5. ESP (Теперь работает на любом расстоянии)
CreateToggle(210, "ESP", function(state)
    task.spawn(function()
        while state do
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                    if not p.Character:FindFirstChild("ESP_Box") then
                        local box = Instance.new("SelectionBox")
                        box.Name = "ESP_Box"
                        box.Adornee = p.Character
                        box.Parent = p.Character
                        box.LineThickness = 0.5
                        box.Color3 = Color3.fromRGB(255, 0, 0)
                        box.Transparency = 0.5
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- 6. КИЛЛ АУРА (Оптимизирована)
CreateToggle(250, "Kill Aura", function(state)
    task.spawn(function()
        while state do
            local char = GetChar()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = p.Character.HumanoidRootPart
                        if (root.Position - targetRoot.Position).Magnitude < KillAuraRadius then
                            p.Character.Humanoid.Health = 0
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Закрыть меню по ПКМ (правая кнопка мыши)
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
