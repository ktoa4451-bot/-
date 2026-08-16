-- =========================================================
-- ANOINTING MENU (Автообновление v1.2)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "1.2"
local RawURL = "https://raw.githubusercontent.com/ktoa4451-bot/-/main/Anointing.lua"

-- =========================================================
-- СИСТЕМА АВТООБНОВЛЕНИЯ
-- =========================================================
local function CheckForUpdate()
    local success, result = pcall(function()
        return game:HttpGet(RawURL)
    end)
    
    if success then
        local newVersion = string.match(result, 'ScriptVersion%s*=%s*"([^"]+)"')
        if newVersion and newVersion ~= ScriptVersion then
            print("Найдено обновление! Версия " .. newVersion .. ". Загружаем...")
            loadstring(result)()
            return true
        end
    end
    return false
end

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

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Anointing Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- СВОРАЧИВАНИЕ МЕНЮ ПО КЛИКУ НА ЗАГОЛОВОК
local isCollapsed = false
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isCollapsed = not isCollapsed
        for _, child in pairs(MainFrame:GetChildren()) do
            if child ~= Title then
                child.Visible = not isCollapsed
            end
        end
        MainFrame.Size = isCollapsed and UDim2.new(0, 260, 0, 40) or UDim2.new(0, 260, 0, 330)
    end
end)

-- Перетаскивание
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

-- 1. СУПЕР СКОРОСТЬ (Снижена до 35)
CreateToggle(50, "Super Speed", function(state)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = state and 35 or 16
    end
end)

-- 2. СУПЕР ПРЫЖОК (Умножение на 15. Название чистое)
CreateToggle(90, "Super Jump", function(state)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = state and (16 * 15) or 50
    end
end)

-- 3. ИНФИНИТИ ДЖАМП (Исправленный)
CreateToggle(130, "Infinite Jump", function(state)
    if state then
        task.spawn(function()
            while state do
                local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                if hum and hum.PlatformStand == false then
                    hum.Jump = true 
                end
                task.wait()
            end
        end)
    end
end)

-- 4. НОУКЛИП (Noclip)
CreateToggle(170, "Noclip", function(state)
    local char = player.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CanCollide = not state
        end
    end
end)

-- 5. ESP (Просто ESP, без Wallhack)
CreateToggle(210, "ESP", function(state)
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
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_Highlight") then
                p.Character.ESP_Highlight:Destroy()
            end
        end
    end)
end)

-- 6. АВТО-УДАР (Triggerbot. Бьет, когда крестик красный / наведен на врага)
CreateToggle(250, "Auto Attack (Trigger)", function(state)
    if state then
        task.spawn(function()
            while state do
                local target = mouse.Target
                if target then
                    local parent = target.Parent
                    if parent:IsA("Model") and parent:FindFirstChild("Humanoid") and parent ~= player.Character then
                        -- Эмулируем нажатие мыши для автоатаки
                        mouse1click()
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end)

-- Закрытие меню по ПКМ (правая кнопка мыши)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
