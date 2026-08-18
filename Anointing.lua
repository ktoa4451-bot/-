-- =========================================================
-- SWEAR // SPEAR v5.2 (Без Аима, Kill Aura без лагов)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "5.2"
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

local godModeEnabled = false
local killAuraEnabled = false
local espEnabled = false

-- =========================================================
-- МЕНЮ
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 350)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "swear // spear"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

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
-- ФУНКЦИИ
-- =========================================================

-- 1. ESP (Сбоку)
local espObjs = {}
CreateToggle(50, "ESP (HP Left)", function(state)
    espEnabled = state
    if state then
        task.spawn(function()
            while espEnabled do
                for _, v in pairs(espObjs) do v:Remove() end
                table.clear(espObjs)
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local root = p.Character.HumanoidRootPart
                        local hum = p.Character:FindFirstChild("Humanoid")
                        local head, vis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
                        local foot = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                        if vis then
                            local ht = math.abs(head.Y - foot.Y)
                            local wd = ht / 1.5
                            -- Рамка
                            local box = Drawing.new("Square")
                            box.Position = Vector2.new(head.X - wd/2, head.Y)
                            box.Size = Vector2.new(wd, ht)
                            box.Color = Color3.fromRGB(255, 0, 0)
                            box.Thickness = 2
                            box.Visible = true
                            table.insert(espObjs, box)
                            
                            -- Полоска ХП СЛЕВА
                            if hum then
                                local hpLine = Drawing.new("Line")
                                local percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                hpLine.From = Vector2.new(head.X - wd/2 - 8, head.Y)
                                hpLine.To = Vector2.new(head.X - wd/2 - 8, head.Y + (ht * percent))
                                hpLine.Color = Color3.fromRGB(0, 255, 0)
                                hpLine.Thickness = 3
                                hpLine.Visible = true
                                table.insert(espObjs, hpLine)
                            end
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

-- 2. БЕССМЕРТИЕ (Починенное)
CreateToggle(90, "God Mode", function(state)
    godModeEnabled = state
    task.spawn(function()
        while godModeEnabled do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = 9999
                hum.Health = 9999
            end
            task.wait(0.05)
        end
    end)
end)

-- 3. КИЛЛ АУРА (Без спама кликов. Сбрасывает врага в воздух)
CreateToggle(130, "Kill Aura (Fall)", function(state)
    killAuraEnabled = state
    task.spawn(function()
        while killAuraEnabled do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = p.Character.HumanoidRootPart
                        local dist = (root.Position - targetRoot.Position).Magnitude
                        
                        if dist < 12 then
                            -- Подбрасываем врага вверх и отключаем ему коллизию
                            targetRoot.Velocity = Vector3.new(0, 50, 0)
                            targetRoot.CanCollide = false
                            task.wait(0.1)
                            targetRoot.CanCollide = true
                            
                            -- Альтернативный урон, если игра не убивает падением
                            local hum = p.Character:FindFirstChild("Humanoid")
                            if hum and hum.Health > 0 then
                                hum.Health = 0
                            end
                        end
                    end
                end
            end
            task.wait(0.15)
        end
    end)
end)

-- Закрыть по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
