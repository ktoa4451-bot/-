-- =========================================================
-- ANOINTING MENU v2.0 (Стабильная версия + Небо)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "2.0"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

local JumpMultiplier = 3
local KillAuraRadius = 15

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
-- БАЗОВЫЕ ПЕРЕМЕННЫЕ
-- =========================================================
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Функция безопасного получения персонажа
local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================================================
-- ФУНКЦИЯ СОЗДАНИЯ GUI (ГЛАВНОЕ МЕНЮ)
-- =========================================================
local function CreateMenu()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.CoreGui
    ScreenGui.Name = "AnointingMain"
    ScreenGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.Size = UDim2.new(0, 250, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.Text = "Anointing Main"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextScaled = true

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
    -- ОСНОВНЫЕ ФУНКЦИИ (С ФОНОВЫМИ ЦИКЛАМИ)
    -- =========================================================

    -- 1. СУПЕР СПИД (Исправлен, держит скорость постоянно)
    CreateToggle(50, "Super Speed", function(state)
        task.spawn(function()
            while state do
                local char = GetChar()
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = 35 end
                task.wait(0.1)
            end
        end)
    end)

    -- 2. СУПЕР ПРЫЖОК (Исправлен)
    CreateToggle(90, "Super Jump", function(state)
        task.spawn(function()
            while state do
                local char = GetChar()
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.JumpPower = 16 * JumpMultiplier end
                task.wait(0.1)
            end
        end)
    end)

    -- 3. ИНФИНИТИ ДЖАМП (Исправлен, работает мягко)
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

    -- 4. НОУКЛИП (Исправлен, не сбрасывается)
    CreateToggle(170, "Noclip", function(state)
        task.spawn(function()
            while state do
                local char = GetChar()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then root.CanCollide = false end
                task.wait(0.2)
            end
        end)
    end)

    -- 5. ESP (Теперь работает на любом расстоянии)
    CreateToggle(210, "ESP", function(state)
        task.spawn(function()
            while state do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
                        local hl = p.Character:FindFirstChild("ESP_Line")
                        if not hl then
                            local line = Instance.new("SelectionBox")
                            line.Name = "ESP_Line"
                            line.Adornee = p.Character
                            line.Parent = p.Character
                            line.LineThickness = 0.5
                            line.Color3 = Color3.fromRGB(255, 0, 0)
                            line.Transparency = 0.5
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end)

    -- 6. КИЛЛ АУРА
    CreateToggle(250, "Kill Aura", function(state)
        task.spawn(function()
            while state do
                local char = GetChar()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < KillAuraRadius then
                                p.Character.Humanoid.Health = 0
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)

    -- 7. КНОПКА ОТКРЫТИЯ МЕНЮ НЕБА
    local SkyBtn = Instance.new("TextButton")
    SkyBtn.Parent = MainFrame
    SkyBtn.Size = UDim2.new(0.9, 0, 0.09, 0)
    SkyBtn.Position = UDim2.new(0.05, 0, 0, 290)
    SkyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    SkyBtn.Text = "🌄 Open Sky & Fog"
    SkyBtn.TextColor3 = Color3.new(1, 1, 1)
    SkyBtn.MouseButton1Click:Connect(CreateSkyMenu)

    return ScreenGui
end

-- =========================================================
-- МЕНЮ НЕБА И ТУМАНА
-- =========================================================
local function CreateSkyMenu()
    local SkyGui = Instance.new("ScreenGui")
    SkyGui.Parent = game.CoreGui
    SkyGui.Name = "AnointingSky"
    SkyGui.IgnoreGuiInset = true

    local SkyFrame = Instance.new("Frame")
    SkyFrame.Parent = SkyGui
    SkyFrame.Size = UDim2.new(0, 300, 0, 250)
    SkyFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    SkyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SkyFrame.BorderSizePixel = 0

    local Title = Instance.new("TextLabel")
    Title.Parent = SkyFrame
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.Text = "☁️ Sky & Fog Options"
    Title.TextColor3 = Color3.new(1, 1, 1)

    local function CreateSlider(yPos, label, min, max, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = SkyFrame
        Frame.Size = UDim2.new(0.9, 0, 0.1, 0)
        Frame.Position = UDim2.new(0.05, 0, 0, yPos)
        Frame.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel")
        Label.Parent = Frame
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Text = label
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Slider = Instance.new("TextButton")
        Slider.Parent = Frame
        Slider.Size = UDim2.new(0.4, 0, 0.8, 0)
        Slider.Position = UDim2.new(0.5, 0, 0.1, 0)
        Slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        Slider.Text = "0"
        Slider.TextColor3 = Color3.new(1, 1, 1)

        local dragging = false
        Slider.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        Slider.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local pos = math.clamp((i.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                Slider.Text = tostring(val)
                callback(val)
            end
        end)
    end

    -- Настройки
    CreateSlider(45, "Sky Color (R)", 0, 255, function(v)
        Lighting:FindFirstChild("Sky"):Destroy()
        local sky = Instance.new("Sky")
        sky.SkyColor = Color3.fromRGB(v, 0, 0)
        sky.Parent = Lighting
    end)

    CreateSlider(95, "Sky Color (G)", 0, 255, function(v)
        local sky = Lighting:FindFirstChild("Sky")
        if sky then sky.SkyColor = Color3.fromRGB(sky.SkyColor.R * 255, v, 0) end
    end)

    CreateSlider(145, "Fog Density", 0, 1, function(v)
        Lighting.FogColor = Color3.new(0.5, 0.5, 0.5)
        Lighting.FogEnd = 500 * (1 - v)
    end)

    -- Закрыть меню неба
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = SkyFrame
    CloseBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
    CloseBtn.Position = UDim2.new(0.05, 0, 0, 200)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    CloseBtn.Text = "Close Sky Menu"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.MouseButton1Click:Connect(function()
        SkyGui:Destroy()
    end)
end

-- =========================================================
-- ЗАПУСК
-- =========================================================
CreateMenu()
