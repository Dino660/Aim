local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

_G.AimLockEnabled = false -- AimLock desactivado al inicio
local lockedTarget = nil -- Variable para almacenar el objetivo bloqueado

-- Crear UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 100, 0, 50)
AimButton.Position = UDim2.new(0.9, 0, 0.9, 0) -- Abajo a la derecha
AimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.Text = "Aim OFF"
AimButton.Parent = ScreenGui

-- Variable para controlar si el botón está siendo arrastrado
local dragging = false
local dragStart = nil
local startPos = nil

-- Función para permitir arrastrar el botón
AimButton.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = AimButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - dragStart
        AimButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Cambia el color y el texto del botón según el estado
local function updateButton()
    if _G.AimLockEnabled then
        AimButton.Text = "Aim ON"
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Verde cuando está activo
    else
        AimButton.Text = "Aim OFF"
        AimButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Rojo cuando está apagado
    end
end

-- Función para encontrar el jugador más cercano
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local playerCharacter = localPlayer.Character
    local playerPosition = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart") and playerCharacter.HumanoidRootPart.Position

    if not playerPosition then return nil end

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= localPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local otherPosition = otherPlayer.Character.HumanoidRootPart.Position
            local distance = (playerPosition - otherPosition).Magnitude
            
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = otherPlayer
            end
        end
    end

    return closestPlayer
end

-- Función para hacer que la cámara siga al enemigo
local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = target.Character.HumanoidRootPart.Position

        -- Ajustar la cámara para que siempre mire al objetivo
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
    end
end

-- Conectar el botón para activar/desactivar el AimLock
AimButton.MouseButton1Click:Connect(function()
    _G.AimLockEnabled = not _G.AimLockEnabled
    updateButton()
    if not _G.AimLockEnabled then
        lockedTarget = nil  -- Si desactivamos AimLock, se desbloquea el objetivo
    end
end)

-- Mantener el AimLock activado y la cámara siguiéndolo
RunService.RenderStepped:Connect(function()
    if _G.AimLockEnabled then
        -- Si no hay un objetivo bloqueado, buscar el más cercano
        if not lockedTarget then
            lockedTarget = getClosestPlayer()
        end

        if lockedTarget then
            aimAt(lockedTarget)
        end
    end
end)

updateButton() -- Actualizar botón al iniciar
