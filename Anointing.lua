-- [[ ОСНОВНОЕ МЕНЮ ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "DeltaMenu"
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 260, 0, 380)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Delta Cheat Menu"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

-- [[ ФУНКЦИЯ СОЗДАНИЯ ТУМБЛЕРА ]]
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

-- [[ ПЕРЕМЕННЫЕ СОСТОЯНИЯ ]]
local config = {
    speed = false,
    jump = false,
    infJump = false,
    hitbox = false,
    autoShoot = false,
    clicker = false,
    esp = false
}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- [[ 1. УВЕЛИЧЕНИЕ ХИТБОКСОВ ]]
CreateToggle(50, "Hitbox Expander", function(state)
    config.hitbox = state
    task.spawn(function()
        while config.hitbox do
            local char = player.Character
            if char then
                -- Растягиваем главную часть тела (торс) и голову
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                if root then root.Size = Vector3.new(8, 8, 8) end -- Делаем огромным
                if head then head.Size = Vector3.new(5, 5, 5) end 
            end
            task.wait(0.5)
        end
        -- Сброс размера при выключении
        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            if root then root.Size = Vector3.new(2, 2, 1) end
            if head then head.Size = Vector3.new(1, 1, 1) end
        end
    end)
end)

-- [[ 2. СУПЕР СКОРОСТЬ ]]
CreateToggle(100, "Super Speed", function(state)
    config.speed = state
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = state and 100 or 16
    end
end)

-- [[ 3. СУПЕР ПРЫЖОК И ИНФИНИТИ ДЖАМП ]]
CreateToggle(150, "Super Jump / Infinite", function(state)
    config.jump = state
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = state and 150 or 50
    end
    
    if state then
        -- Включаем бесконечные прыжки (Inf Jump)
        config.infJump = true
        task.spawn(function()
            while config.infJump do
                local hum = player.Character and player.Character:FindFirstChild("Humanoid")
                if hum then
                    hum.Jump = true -- Принудительно заставляем прыгать
                end
                task.wait(0.1)
            end
        end)
    else
        config.infJump = false
    end
end)

-- [[ 4. АВТОКЛИКЕР ]]
CreateToggle(200, "Auto Clicker", function(state)
    config.clicker = state
    task.spawn(function()
        while config.clicker do
            if player.Character then
                -- Эмуляция клика мышкой
                mouse1click() -- Встроенная функция для эмуляции
            end
            task.wait(0.05) -- Скорость кликов
        end
    end)
end)

-- [[ 5. СТРЕЛЬБА ПО ПРИЦЕЛУ (АВТО-АТАКА) ]]
CreateToggle(250, "Trigger Bot (Hitbox)", function(state)
    config.autoShoot = state
end)

-- Логика Триггер-Бота: Если прицел на враге -> бьем
mouse.Move:Connect(function()
    if config.autoShoot and player.Character then
        local target = mouse.Target
        if target then
            -- Проверяем, что цель - это часть тела другого игрока
            local parentModel = target.Parent
            if parentModel:IsA("Model") and parentModel:FindFirstChild("Humanoid") and parentModel ~= player.Character then
                mouse1click() -- Наносим удар
            end
        end
    end
end)

-- [[ 6. ОБЫЧНЫЙ ESP ]]
CreateToggle(300, "ESP (Wallhack)", function(state)
    config.esp = state
    task.spawn(function()
        while config.esp do
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if not p.Character:FindFirstChild("ESP_Highlight") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ESP_Highlight"
                        hl.Parent = p.Character
                        hl.FillColor = Color3.fromRGB(255, 0, 0) -- Красный цвет врага
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                    end
                end
            end
            task.wait(0.5)
        end
        -- Удаляем при выключении
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ESP_Highlight") then
                p.Character.ESP_Highlight:Destroy()
            end
        end
    end)
end)

-- [[ Опционально: Скрыть меню по клавише RightControl ]]
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
