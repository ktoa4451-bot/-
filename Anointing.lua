-- =========================================================
-- SWEAR // SPEAR v4.0 (Красивое меню + Боевые фиксы)
-- =========================================================

local ScriptName = "swear // spear"
local ScriptVersion = "4.0"
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

-- НАСТРОЙКИ АИМА
local aimFov = 90 -- Ширина зоны захвата
local aimEnabled = false

-- =========================================================
-- КОМПАКТНОЕ МЕНЮ (Дизайн взят из вашей ссылки)
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SwearSpearMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 240, 0, 340)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "swear // spear"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local function CreateToggle(yPos, label, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Parent = MainFrame
    ToggleFrame.Size = UDim2.new(0.95, 0, 0.08, 0)
    ToggleFrame.Position = UDim2.new(0.025, 0, 0, yPos)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

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
-- ПОЧИНЕННЫЕ ФУНКЦИИ
-- =========================================================

-- 1. СКОРОСТЬ И ПРЫЖОК (Теперь не сбрасываются)
CreateToggle(50, "Super Speed", function(state)
    task.spawn(function()
        while state do
            local h = GetChar():FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 35 end
            task.wait(0.1)
        end
    end)
end)

CreateToggle(90, "Super Jump", function(state)
    task.spawn(function()
        while state do
            local h = GetChar():FindFirstChild("Humanoid")
            if h then h.JumpPower = 100 end
            task.wait(0.1)
        end
    end)
end)

-- 2. ИНФИНИТИ ДЖАМП (Через невидимую платформу)
local infLoop = nil
CreateToggle(130, "Infinite Jump", function(state)
    if state then
        infLoop = task.spawn(function()
            while true do
                local char = GetChar()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root and not char.Humanoid.FloorMaterial then
                    local plat = Instance.new("Part")
                    plat.Anchored = true
                    plat.CanCollide = true
                    plat.Transparency = 1
                    plat.Size = Vector3.new(4, 0.1, 4)
                    plat.Position = root.Position - Vector3.new(0, 3, 0)
                    plat.Parent = workspace
                    task.delay(0.2, function() plat:Destroy() end)
                end
                task.wait(0.1)
            end
        end)
    else
        if infLoop then task.cancel(infLoop) end
    end
end)

-- 3. НОУКЛИП (Исправлен)
local noclipLoop = nil
CreateToggle(170, "Noclip", function(state)
    if state then
        noclipLoop = task.spawn(function()
            while true do
                local root = GetChar():FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame + root.CFrame.LookVector * 0.1
                end
                task.wait(0.05)
            end
        end)
    else
        if noclipLoop then task.cancel(noclipLoop) end
    end
end)

-- 4. ESP (Работает сквозь стены)
local espObjs = {}
CreateToggle(210, "ESP", function(state)
    task.spawn(function()
        while state do
            for _, v in pairs(espObjs) do v:Remove() end
            table.clear(espObjs)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = p.Character.HumanoidRootPart
                    local h = p.Character.Humanoid
                    local head, vis = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0))
                    local foot, _ = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                    if vis then
                        local ht = math.abs(head.Y - foot.Y)
                        local wd = ht / 1.5
                        local box = Drawing.new("Square")
                        box.Position = Vector2.new(head.X - wd/2, head.Y)
                        box.Size = Vector2.new(wd, ht)
                        box.Color = Color3.fromRGB(255, 0, 0)
                        box.Thickness = 1.5
                        box.Visible = true
                        table.insert(espObjs, box)
                    end
                end
            end
            task.wait()
        end
    end)
end)

-- 5. КИЛЛ АУРА (Убивает врагов в радиусе)
CreateToggle(250, "Kill Aura", function(state)
    task.spawn(function()
        while state do
            local root = GetChar():FindFirstChild("HumanoidRootPart")
            if root then
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 15 then
                            p.Character.Humanoid.Health = 0
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- 6. БЕССМЕРТИЕ (Вечная жизнь)
CreateToggle(290, "God Mode", function(state)
    task.spawn(function()
        while state do
            local h = GetChar():FindFirstChild("Humanoid")
            if h then
                h.MaxHealth = math.huge
                h.Health = math.huge
            end
            task.wait(0.1)
        end
    end)
end)

-- 7. НАСТРАИВАЕМЫЙ АИМ (Аимбот)
CreateToggle(330, "Aimbot", function(state)
    aimEnabled = state
end)

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local char = GetChar()
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        local closestPart = nil
        local closestDist = aimFov
        
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = p.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
                if onScreen then
                    local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = targetRoot
                    end
                end
            end
        end
        
        if closestPart then
            camera.CFrame = CFrame.new(camera.CFrame.Position, closestPart.Position)
        end
    end
end)

-- Переключение меню по ПКМ
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
