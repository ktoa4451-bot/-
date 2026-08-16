-- =========================================================
-- ANOINTING MENU v1.3 (Исправленный)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "1.3"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

-- Настройки по умолчанию (можно менять)
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
            print("Найдено обновление v" .. newVersion)
            loadstring(result)()
            return true
        end
    end
    return false
end

if CheckForUpdate() then return end

-- =========================================================
-- МЕНЮ
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

-- Сворачивание по клику на заголовок
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

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- =========================================================
-- ФУНКЦИИ МЕНЮ
-- =========================================================

-- 1. СУПЕР СКОРОСТЬ
CreateToggle(50, "Super Speed", function(state)
    humanoid.WalkSpeed = state and 35 or 16
end)

-- 2. СУПЕР ПРЫЖОК (Снижен до 3x)
CreateToggle(90, "Super Jump", function(state)
    humanoid.JumpPower = state and (16 * JumpMultiplier) or 50
end)

-- 3. ИНФИНИТИ ДЖАМП (Полностью переписан, мягкий)
local infJumpLoop = nil
CreateToggle(130, "Infinite Jump", function(state)
    if state then
        infJumpLoop = task.spawn(function()
            while state do
                local currentChar = player.Character
                if currentChar and currentChar:FindFirstChild("Humanoid") and currentChar:FindFirstChild("HumanoidRootPart") then
                    local hum = currentChar.Humanoid
                    if not hum.FloorMaterial then
                        hum.Jump = true
                    end
                end
                task.wait(0.01)
            end
        end)
    else
        if infJumpLoop then task.cancel(infJumpLoop) end
    end
end)

-- 4. НОУКЛИП (Исправлен)
CreateToggle(170, "Noclip", function(state)
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CanCollide = not state
    end
end)

-- 5. ESP (Стабильный, без вылетов через 10 минут)
local espLoop = nil
CreateToggle(210, "ESP", function(state)
    if state then
        espLoop = task.spawn(function()
            while state do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        if not p.Character:FindFirstChild("ESP_HL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "ESP_HL"
                            hl.Parent = p.Character
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                        end
                    end
                end
                task.wait(0.8)
            end
        end)
    else
        if espLoop then task.cancel(espLoop) end
        -- Очистка
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_HL") then
                p.Character.ESP_HL:Destroy()
            end
        end
    end
end)

-- 6. КИЛЛ АУРА (Вместо авто-атаки)
CreateToggle(250, "Kill Aura", function(state)
    if state then
        task.spawn(function()
            while state do
                local currentChar = player.Character
                if currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
                    local rootPos = currentChar.HumanoidRootPart.Position
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                            local targetRoot = p.Character.HumanoidRootPart
                            local dist = (rootPos - targetRoot.Position).Magnitude
                            if dist < KillAuraRadius then
                                -- Эмуляция удара (в простых играх сработает)
                                p.Character.Humanoid.Health = 0
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- Закрыть меню по ПКМ
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
