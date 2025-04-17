-- Aimbot, Fly, FOV, e Interface Móvel com design bonito e sem suavização (teleporte direto)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local AimbotEnabled = false
local FlyEnabled = false
local FOVEnabled = false
local AimbotPart = "Head"  -- Default: Head
local FOVRadius = 100  -- Default FOV radius
local FOVCircle = nil
local TargetPlayer = nil
local FlySpeed = 50 -- Velocidade do voo
local BodyVelocity = Instance.new("BodyVelocity")

-- Função para desenhar FOV
local function DrawFOV()
    if FOVCircle then
        FOVCircle:Remove()
    end
    FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVCircle.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
    FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    FOVCircle.BackgroundTransparency = 0.5
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Parent = game.CoreGui
end

-- Função de Aimbot Teleportado (sem suavização)
local function TeleportAimbot(targetPosition)
    Camera.CFrame = CFrame.new(targetPosition)  -- Teleporta diretamente para o alvo
end

-- Função para encontrar o melhor alvo
local function FindTarget()
    local closestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = player.Character:FindFirstChild(AimbotPart)
            if target then
                local distance = (Camera.CFrame.Position - target.Position).Magnitude
                if distance < closestDistance and distance <= FOVRadius then
                    closestDistance = distance
                    TargetPlayer = player
                end
            end
        end
    end
end

-- Função do Aimbot
local function Aimbot()
    if AimbotEnabled and TargetPlayer and TargetPlayer.Character then
        local target = TargetPlayer.Character:FindFirstChild(AimbotPart)
        if target then
            TeleportAimbot(target.Position)  -- Teleporta diretamente para o alvo
        end
    end
end

-- Função de Fly
local function Fly()
    if FlyEnabled then
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
            if not bodyVelocity then
                bodyVelocity = BodyVelocity:Clone()
                bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyVelocity.Velocity = Vector3.new(0, FlySpeed, 0)
                bodyVelocity.Parent = character.HumanoidRootPart
            end
        end
    else
        -- Remover BodyVelocity quando desativar o Fly
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
            if bodyVelocity then
                bodyVelocity:Destroy()
            end
        end
    end
end

-- Interface Gráfica (GUI) e Botões
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- Função para criar botões com estilo bonito
local function CreateButton(text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = position
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Vermelho
    button.BorderSizePixel = 2
    button.BorderColor3 = Color3.fromRGB(255, 255, 255)
    button.Parent = ScreenGui
    button.MouseButton1Click:Connect(callback)
end

-- Botão de Aimbot
CreateButton("Toggle Aimbot", UDim2.new(0.5, -100, 0.7, 0), function()
    AimbotEnabled = not AimbotEnabled
    CreateButton("Toggle Aimbot", UDim2.new(0.5, -100, 0.7, 0), function() end).Text = AimbotEnabled and "Aimbot ON" or "Aimbot OFF"
end)

-- Botão de Fly
CreateButton("Toggle Fly", UDim2.new(0.5, -100, 0.8, 0), function()
    FlyEnabled = not FlyEnabled
    CreateButton("Toggle Fly", UDim2.new(0.5, -100, 0.8, 0), function() end).Text = FlyEnabled and "Fly ON" or "Fly OFF"
end)

-- Botão de FOV
CreateButton("Toggle FOV", UDim2.new(0.5, -100, 0.9, 0), function()
    FOVEnabled = not FOVEnabled
    if FOVEnabled then
        DrawFOV()
    else
        if FOVCircle then
            FOVCircle:Remove()
        end
    end
    CreateButton("Toggle FOV", UDim2.new(0.5, -100, 0.9, 0), function() end).Text = FOVEnabled and "FOV ON" or "FOV OFF"
end)

-- Botão para escolher a parte do corpo
CreateButton("Select Aimbot Part", UDim2.new(0.5, -100, 1, 0), function()
    local parts = {"Head", "Torso", "Closest Part"}
    local partIndex = table.find(parts, AimbotPart) or 1
    partIndex = partIndex % #parts + 1
    AimbotPart = parts[partIndex]
    CreateButton("Select Aimbot Part", UDim2.new(0.5, -100, 1, 0), function() end).Text = "Aim at: " .. AimbotPart
end)

-- Tornar a interface móvel
local dragSpeed = 0.2
local dragging, dragInput, dragStart, startPos = nil, nil, nil, nil

ScreenGui.Draggable = true
ScreenGui.Active = true
ScreenGui.Selectable = true

ScreenGui.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ScreenGui.Position
        input.Changed:Connect(function()
            if not input.UserInputState == Enum.UserInputState.Change then return end
            if dragging then
                local delta = input.Position - dragStart
                ScreenGui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
end)

ScreenGui.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Loop para encontrar o alvo e ativar aimbot e fly
while true do
    wait(0.1)
    if FOVEnabled then
        FindTarget()
    end
    Aimbot()
    Fly()
end
