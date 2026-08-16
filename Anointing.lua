-- =========================================================
-- ANOINTING MENU (Автообновление v1.0)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "1.0"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

-- =========================================================
-- СИСТЕМА АВТООБНОВЛЕНИЯ
-- =========================================================
local function CheckForUpdate()
    local success, result = pcall(function()
        return game:HttpGet(RawURL)
    end)
    
    if success then
        -- Ищем версию в загруженном коде. (Ищем строку ScriptVersion = "...")
        local newVersion = string.match(result, 'ScriptVersion%s*=%s*"([^"]+)"')
        if newVersion and newVersion ~= ScriptVersion then
            print("Найдено обновление! Версия " .. newVersion .. ". Загружаем...")
            loadstring(result)() -- Запускаем новую версию
            return true
        end
    end
    return false
end

-- Проверяем обновление перед запуском
if CheckForUpdate() then return end

-- =========================================================
-- ОСНОВНОЕ МЕНЮ
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AnointingMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 330)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -165)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Anointing Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- Функция создания переключателей
local function CreateToggle(yPos, label, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = MainFrame
    ToggleFrame.Size = UDim2.new(0.9, 0, 0.09, 0)
    ToggleFrame.Position = UDim2.new(0.05, 0, 0, yPos)
    ToggleFrame.BackgroundTransparency = 1

    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 0, 0, 0)
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

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- =========================================================
-- ФУНКЦИИ МЕНЮ
-- =========================================================

-- 1. СУПЕР СКОРОСТЬ (Speed)
CreateToggle(50, "Super Speed", function(state)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = state and 100 or 16
    end
end)

-- 2. СУПЕР ПРЫЖОК (Значение 15)
CreateToggle(90, "Super Jump (x15)", function(state)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = state and 15 or 50
    end
end)

-- 3. ИНФИНИТИ ДЖАМП (Отдельная кнопка)
CreateToggle(130, "Infinite Jump", function(state)
    if state then
        task.spawn(function()
            while state do
                local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.Jump = true 
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- 4. АВТОКЛИКЕР (Для телефонов / Мобильный)
CreateToggle(170, "Auto Clicker (Mobile)", function(state)
    task.spawn(function()
        while state do
            if player.Character then
                -- Безопасная эмуляция тапа для сенсорных экранов
                local args = { 
                    [1] = Vector2.new(mouse.X, mouse.Y), 
                    [2] = true 
                }
                game:GetService("Players").LocalPlayer:GetMouse()._MouseButton1Down:Fire(unpack(args))
            end
            task.wait(0.05)
        end
    end)
end)

-- 5. ESP (Wallhack)
CreateToggle(210, "ESP (Wallhack)", function(state)
    task.spawn(function()
        while state do
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if not p.Character:FindFirstChild("ESP_Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"
                        hl.Parent = p.Character
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                    end
                end
            end
            task.wait(0.5)
        end
        -- Очистка при выключении
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_Highlight") then
                p.Character.ESP_Highlight:Destroy()
            end
        end
    end)
end)

-- =========================================================
-- УПРАВЛЕНИЕ МЕНЮ (Закрытие/Открытие)
-- =========================================================
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
