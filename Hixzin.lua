-- Mini Cena de Entrada
local function ShowIntroScreen()
    -- Criando a interface de entrada
    local introGui = Instance.new("ScreenGui")
    introGui.Parent = game.CoreGui

    -- Criando a tela de fundo
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.Parent = introGui

    -- Criando o texto de boas-vindas
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Size = UDim2.new(0, 400, 0, 50)
    welcomeText.Position = UDim2.new(0.5, -200, 0.5, -25)
    welcomeText.Text = "Bem-vindo ao Aimbot!"
    welcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcomeText.BackgroundTransparency = 1
    welcomeText.TextSize = 30
    welcomeText.Parent = introGui

    -- Criando o logo ou título, se quiser
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 300, 0, 50)
    logoText.Position = UDim2.new(0.5, -150, 0.6, 0)
    logoText.Text = "Hixzin Aimbot"
    logoText.TextColor3 = Color3.fromRGB(255, 0, 0)
    logoText.BackgroundTransparency = 1
    logoText.TextSize = 35
    logoText.Parent = introGui

    -- Criando a animação de desaparecimento (Delay antes de desaparecer)
    wait(3) -- Exibe por 3 segundos

    -- Remover a tela de entrada
    introGui:Destroy()
end

-- Chama a cena de entrada quando o script é iniciado
ShowIntroScreen()

-- Aimbot, Fly, FOV, e Interface Móvel com design bonito e movimentação suave para o Aimbot

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
    FOVCircle.BackgroundTransparency = 0.5  -- Transparência de 50%
    FOVCircle.BorderSizePixel = 0
    FOVCircle.Parent = game.CoreGui
end

-- Função de Aimbot Suavizado
local function SmoothAimbot(targetPosition)
    local currentPosition = Camera.CFrame.Position
    local direction = (targetPosition - currentPosition).unit
    local newPosition = currentPosition + direction * 5  -- Ajuste a distância de cada movimento
    Camera.CFrame = CFrame.new(newPosition, targetPosition)  -- Movimenta suavemente em direção ao alvo
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

-- Função de Aimbot
local function Aimbot()
    if AimbotEnabled and TargetPlayer and TargetPlayer.Character then
        local target = TargetPlayer.Character:FindFirstChild(AimbotPart)
        if target then
            SmoothAimbot(target.Position)  -- Movimenta suavemente em direção ao alvo
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
    return button
end

-- Função para atualizar o texto do botão
local function UpdateButtonText(button, isEnabled)
    button.Text = isEnabled and "Desligar" or "Ligar"
end

-- Botão de Aimbot
local aimbotButton = CreateButton("Aimbot: OFF", UDim2.new(0.5, -100, 0.7, 0), function()
    AimbotEnabled = not AimbotEnabled
    UpdateButtonText(aimbotButton, AimbotEnabled)
end)

-- Botão de Fly
local flyButton = CreateButton("Fly: OFF", UDim2.new(0.5, -100, 0.8, 0), function()
    FlyEnabled = not FlyEnabled
    UpdateButtonText(flyButton, FlyEnabled)
end)

-- Botão de FOV
local fovButton = CreateButton("FOV: OFF", UDim2.new(0.5, -100, 0.9, 0), function()
    FOVEnabled = not FOVEnabled
    if FOVEnabled then
        DrawFOV()
    else
        if FOVCircle then
            FOVCircle:Remove()
        end
    end
    UpdateButtonText(fovButton, FOVEnabled)
end)

-- Função de maximizar/minimizar
local isMenuVisible = true
local maximizeButton = CreateButton("Minimizar", UDim2.new(0.5, -100, 0.6, 0), function()
    isMenuVisible = not isMenuVisible
    if isMenuVisible then
        ScreenGui.Enabled = true
        maximizeButton.Text = "Minimizar"
    else
        ScreenGui.Enabled = false
        maximizeButton.Text = "Maximizar"
    end
end)

-- Tornar a interface móvel e ajustar a transparência
local dragSpeed = 0.2
local dragging, dragInput, dragStart, startPos = nil, nil, nil, nil

ScreenGui.Draggable = true
ScreenGui.Active = true
ScreenGui.Selectable = true

ScreenGui.BackgroundTransparency = 0.7  -- 70% Transparente

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
