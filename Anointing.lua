-- =========================================================
-- SWEAR // SPEAR v4.5 (Anti-Cheat Bypass)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "4.5"
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

local aimEnabled = false
local aimFov = 120

-- =========================================================
-- МЕНЮ (С ПРОКРУТКОЙ, ЧТОБЫ НИЧЕГО НЕ ВЫЛЕТАЛО)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 250, 0, 370)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -185)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "swear // spear"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true

-- Прокручиваемый блок (чтобы кнопки не вылетали)
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 450) -- Высота скролла
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
-- ФУНКЦИИ (Античит-Байпас)
-- =========================================================

-- 1. СУПЕР СКОРОСТЬ (Фикс)
CreateToggle(50, "Super Speed", function(state)
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed ~= 35 then hum.WalkSpeed = 35 end
            task.wait(0.05)
        end
    end)
end)

-- 2. СУПЕР ПРЫЖОК (Микро-телепорт вверх вместо JumpPower)
CreateToggle(90, "Super Jump (Velocity)", function(state)
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                root.Velocity = Vector3.new(root.Velocity.X, 35, root.Velocity.Z)
            end
            task.wait(0.05)
        end
    end)
end)

-- 3. ИНФИНИТИ ДЖАМП (Агрессивный подъём)
CreateToggle(130, "Infinite Jump", function(state)
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root and not GetChar().Humanoid.FloorMaterial then
                root.Velocity = Vector3.new(root.Velocity.X, 40, root.Velocity.Z)
            end
            task.wait(0.05)
        end
    end)
end)

-- 4. НОУКЛИП (Сверх-быстрое обновление коллизии)
CreateToggle(170, "Noclip", function(state)
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root and root.CanCollide then root.CanCollide = false end
            task.wait(0.02)
        end
    end)
end)

-- 5. ESP (Боксы сквозь стены)
local espObjs = {}
CreateToggle(210, "ESP", function(state)
    if state then
        task.spawn(function()
            while true do
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

-- 6. КИЛЛ АУРА (Эмуляция удара мышкой)
CreateToggle(250, "Kill Aura (Spam Click)", function(state)
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 15 then
                            mouse1click()
                        end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- 7. БЕССМЕРТИЕ (Сброс здоровья)
CreateToggle(290, "God Mode", function(state)
    task.spawn(function()
        while state do
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum and hum.Health < 100 then hum.Health = 100 end
            task.wait(0.05)
        end
    end)
end)

-- 8. НАСТРАИВАЕМЫЙ АИМ (Вращение тела)
CreateToggle(330, "Aimbot (Body)", function(state)
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
                root.CFrame = CFrame.lookAt(root.Position, closestPart.Position)
            end
        end
    end
end)

-- Закрыть по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
