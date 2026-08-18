-- =========================================================
-- SWEAR // SPEAR v9.0 (Пассивный удар по лучу)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "9.0"
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

local espEnabled = false
local killAuraEnabled = false

-- =========================================================
-- МЕНЮ
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 250)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -125)
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
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 300)
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
                        local hum = p.Character:FindFirstChild("Humanoid")
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

-- 2. КИЛЛ АУРА (Пассивная / Без аима / Через Луч)
CreateToggle(90, "Kill Aura (Passive)", function(state)
    killAuraEnabled = state
    
    if state then
        task.spawn(function()
            while killAuraEnabled do
                local char = GetChar()
                local root = char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    -- 1. Пускаем луч строго из центра экрана
                    local rayOrigin = camera.CFrame.Position
                    local rayDirection = (mouse.Hit.Position - rayOrigin).Unit * 100
                    
                    -- 2. Проверяем попадание (Raycast)
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {char}
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                    
                    if result and result.Instance then
                        local hitPart = result.Instance
                        local hitParent = hitPart.Parent
                        
                        -- 3. Проверяем, что попали именно в живого врага
                        if hitParent:IsA("Model") and hitParent:FindFirstChild("Humanoid") and hitParent ~= char then
                            local targetHum = hitParent:FindFirstChild("Humanoid")
                            
                            if targetHum and targetHum.Health > 0 then
                                -- 4. Имитация Крит-зарядки (задержка + удар)
                                task.wait(0.4) -- Имитация заполнения полоски
                                mouse1click() -- Наносим критический удар
                                task.wait(0.1)
                            end
                        end
                    end
                end
                task.wait(0.05) -- Быстрая проверка, чтобы не пропустить движущегося врага
            end
        end)
    end
end)

-- Закрыть по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
