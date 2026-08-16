-- =========================================================
-- ANOINTING MENU v3.0 (Реальный ESP + Фиксы)
-- =========================================================

local ScriptName = "Anointing Menu"
local ScriptVersion = "3.0"
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
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================================================
-- МЕНЮ
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AnointingMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
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
-- ФУНКЦИИ
-- =========================================================

-- 1. СУПЕР СКОРОСТЬ (Исправлена)
local speedLoop = nil
CreateToggle(50, "Super Speed", function(state)
    if state then
        speedLoop = task.spawn(function()
            while true do
                local char = GetChar()
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.WalkSpeed ~= 35 then
                    hum.WalkSpeed = 35
                end
                task.wait(0.1)
            end
        end)
    else
        if speedLoop then task.cancel(speedLoop) end
        local hum = GetChar():FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

-- 2. СУПЕР ПРЫЖОК (Исправлен)
local jumpLoop = nil
CreateToggle(90, "Super Jump", function(state)
    if state then
        jumpLoop = task.spawn(function()
            while true do
                local hum = GetChar():FindFirstChild("Humanoid")
                if hum and hum.JumpPower ~= 100 then
                    hum.JumpPower = 100
                end
                task.wait(0.1)
            end
        end)
    else
        if jumpLoop then task.cancel(jumpLoop) end
        local hum = GetChar():FindFirstChild("Humanoid")
        if hum then hum.JumpPower = 50 end
    end
end)

-- =========================================================
-- РАБОЧИЙ ESP (BOXES СКВОЗЬ СТЕНЫ)
-- =========================================================
local espObjects = {}
local espLoop = nil

local function WorldToScreen(position)
    local point, onScreen = camera:WorldToViewportPoint(position)
    return point, onScreen
end

CreateToggle(130, "ESP (Wallhack)", function(state)
    if state then
        espLoop = task.spawn(function()
            while true do
                -- Очищаем старые рисованные объекты
                for _, obj in pairs(espObjects) do
                    obj:Remove()
                end
                espObjects = {}
                table.clear(espObjects)

                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                        local root = p.Character.HumanoidRootPart
                        local hum = p.Character.Humanoid
                        
                        -- Переводим 3D в 2D координаты экрана
                        local headPos, headVis = WorldToScreen(root.Position + Vector3.new(0, 2.5, 0))
                        local footPos, footVis = WorldToScreen(root.Position - Vector3.new(0, 2.5, 0))
                        
                        if headVis and footVis then
                            local height = math.abs(headPos.Y - footPos.Y)
                            local width = height / 1.5
                            
                            -- Создаем рамку
                            local box = Drawing.new("Square")
                            box.Position = Vector2.new(headPos.X - (width / 2), headPos.Y)
                            box.Size = Vector2.new(width, height)
                            box.Color = Color3.fromRGB(255, 0, 0)
                            box.Thickness = 1.5
                            box.Transparency = 0.5
                            box.Visible = true
                            table.insert(espObjects, box)
                            
                            -- Создаем линию здоровья
                            local healthBar = Drawing.new("Line")
                            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            healthBar.From = Vector2.new(headPos.X - (width / 2) - 5, headPos.Y)
                            healthBar.To = Vector2.new(headPos.X - (width / 2) - 5, headPos.Y + (height * healthPercent))
                            healthBar.Color = Color3.fromRGB(0, 255, 0)
                            healthBar.Thickness = 3
                            healthBar.Visible = true
                            table.insert(espObjects, healthBar)
                        end
                    end
                end
                task.wait()
            end
        end)
    else
        if espLoop then task.cancel(espLoop) end
        for _, obj in pairs(espObjects) do
            obj:Remove()
        end
        espObjects = {}
    end
end)

-- 3. ОСТАЛЬНЫЕ ФУНКЦИИ (Показываем в меню, но они требуют серверного доступа)
CreateToggle(170, "Infinite Jump (Broken)", function() end)
CreateToggle(210, "Noclip (Broken)", function() end)
CreateToggle(250, "Kill Aura (Broken)", function() end)

-- Закрыть меню по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
