-- =========================================================
-- SWEAR // SPEAR v5.1 (Слайдер Аим + Криты + Фильтр стен)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "5.1"
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
-- ПЕРЕМЕННЫЕ И НАСТРОЙКИ
-- =========================================================
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function GetChar()
    return player.Character or player.CharacterAdded:Wait()
end

local aimEnabled = false
local aimFov = 120 -- Стандартное значение (будет меняться слайдером)
local godModeEnabled = false
local killAuraEnabled = false
local espEnabled = false

-- =========================================================
-- МЕНЮ (С ПРОКРУТКОЙ И ПЕРЕТАСКИВАНИЕМ)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -210)
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
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 550)
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

-- Функция для создания Слайдера (Ползунка)
local function CreateSlider(yPos, label, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = ScrollingFrame
    Frame.Size = UDim2.new(0.95, 0, 0.08, 0)
    Frame.Position = UDim2.new(0.025, 0, 0, yPos)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Text = label .. " (" .. default .. ")"
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextScaled = true
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Parent = Frame
    SliderBtn.Size = UDim2.new(0.4, 0, 0.8, 0)
    SliderBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
    SliderBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SliderBtn.Text = ""
    SliderBtn.TextColor3 = Color3.new(1, 1, 1)

    local dragging = false
    SliderBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    SliderBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((i.Position.X - SliderBtn.AbsolutePosition.X) / SliderBtn.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            Label.Text = label .. " (" .. val .. ")"
            callback(val)
        end
    end)
end

-- =========================================================
-- ФУНКЦИИ
-- =========================================================

-- 1. ESP (С ХП-барами)
local espObjs = {}
CreateToggle(50, "ESP (With HP)", function(state)
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
                            -- Полоска ХП
                            if hum then
                                local hpLine = Drawing.new("Line")
                                local percent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                                hpLine.From = Vector2.new(head.X - wd/2, head.Y - 5)
                                hpLine.To = Vector2.new(head.X - wd/2 + (wd * percent), head.Y - 5)
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

-- 2. БЕССМЕРТИЕ (Исправленное)
CreateToggle(90, "God Mode", function(state)
    godModeEnabled = state
    task.spawn(function()
        while godModeEnabled do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
            task.wait(0.1)
        end
    end)
end)

-- 3. СЛАЙДЕР НАСТРОЙКИ АИМА
CreateSlider(130, "Aim Range", 30, 300, 120, function(val)
    aimFov = val
end)

-- 4. АИМБОТ (Плавный, с защитой от детекта)
CreateToggle(170, "Aimbot", function(state)
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
                        -- Защита: не аимить, если враг слишком близко (чтобы не спалиться)
                        if dist < closestDist and dist > 50 then
                            closestDist = dist
                            closestPart = target
                        end
                    end
                end
            end
            if closestPart then
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, closestPart.Position), 0.2)
            end
        end
    end
end)

-- 5. КИЛЛ АУРА (С фильтром стен + Криты)
CreateToggle(210, "Kill Aura (Crits)", function(state)
    killAuraEnabled = state
    task.spawn(function()
        while killAuraEnabled do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = p.Character.HumanoidRootPart
                        local dist = (root.Position - targetRoot.Position).Magnitude
                        
                        -- Проверка на стену (Raycast)
                        local ray = Ray.new(root.Position, (targetRoot.Position - root.Position).Unit * dist)
                        local hit, pos = workspace:FindPartOnRay(ray, char)
                        
                        -- Если нет стены между вами и врагом
                        if not hit or hit:IsDescendantOf(p.Character) then
                            if dist < 10 then
                                -- Наводимся на врага
                                camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
                                task.wait(0.02)
                                -- Эмуляция КРИТИЧЕСКОГО удара (3 клика за раз)
                                for i = 1, 3 do
                                    mouse1click()
                                end
                                task.wait(0.05)
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Закрыть по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
