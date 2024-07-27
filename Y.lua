-- Silent Aimbot Script with Crosshair, Toggle GUI, Player ESP, Health Display, and Auto-Fire Functionality
-- Created by z-a © 2024

--// Cache
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

--// Aimbot Settings
local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "Head",
    LockedTarget = nil,
    Smoothness = 0.1
}

--// Auto-Fire Settings
local AutoFire = {
    Enabled = false,
    FireRate = 0.1 -- Time in seconds between shots
}

--// aimlockService
local aimlockService = {}
local aimlockTarget

function aimlockService.acquire(target)
    aimlockTarget = target
end

function aimlockService.release()
    aimlockTarget = nil
end

--// Utility Functions
local function GetDistanceFromCursor(pos)
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
end

local function GetClosestTarget()
    local closestTarget, closestDist = nil, Aimbot.FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.LockPart) then
            local targetPos = player.Character[Aimbot.LockPart].Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

            if onScreen then
                local dist = GetDistanceFromCursor(screenPos)
                if dist < closestDist then
                    closestDist = dist
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

local function AimAt(target)
    if not target or not target.Character then return end

    aimlockService.acquire(target)
    local targetPosition = target.Character[Aimbot.LockPart].Position
    local direction = (targetPosition - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction * 1000)

    -- Implement smooth aiming
    if Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(Aimbot.Smoothness, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        local tween = TweenService:Create(Camera, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
    end
end

local function AutoFireFunction()
    if AutoFire.Enabled and aimlockService.acquire then
        local target = aimlockService.acquire
        if target and target.Character then
            local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                -- Simulate shooting
                humanoid:TakeDamage(10) -- Adjust damage as needed
            end
        end
    end
end

--// GUI Creation Function
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local Crosshair = Instance.new("Frame")
    Crosshair.Name = "Crosshair"
    Crosshair.Parent = ScreenGui
    Crosshair.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Crosshair.Size = UDim2.new(0, Aimbot.FOVRadius * 2, 0, Aimbot.FOVRadius * 2)
    Crosshair.Position = UDim2.new(0.5, -Aimbot.FOVRadius, 0.5, -Aimbot.FOVRadius)
    Crosshair.BackgroundTransparency = 1
    Crosshair.BorderSizePixel = 0

    local Circle = Instance.new("UICorner")
    Circle.Parent = Crosshair
    Circle.CornerRadius = UDim.new(1, 0)

    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Crosshair
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.Text = "Aimbot: OFF"
    ToggleButton.Position = UDim2.new(1, -120, 0, 20)
    ToggleButton.Size = UDim2.new(0, 80, 0, 40) -- Smaller button
    ToggleButton.AnchorPoint = Vector2.new(1, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextScaled = true
    ToggleButton.TextWrapped = true

    ToggleButton.MouseButton1Click:Connect(function()
        Aimbot.Enabled = not Aimbot.Enabled
        if Aimbot.Enabled then
            ToggleButton.Text = "Aimbot: ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            ToggleButton.Text = "Aimbot: OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            aimlockService.release()
        end
    end)

    local AutoFireButton = Instance.new("TextButton")
    AutoFireButton.Name = "AutoFireButton"
    AutoFireButton.Parent = ScreenGui
    AutoFireButton.Text = "Auto-Fire: OFF"
    AutoFireButton.Position = UDim2.new(1, -120, 0, 70)
    AutoFireButton.Size = UDim2.new(0, 80, 0, 40) -- Smaller button
    AutoFireButton.AnchorPoint = Vector2.new(1, 0)
    AutoFireButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    AutoFireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoFireButton.TextScaled = true
    AutoFireButton.TextWrapped = true

    AutoFireButton.MouseButton1Click:Connect(function()
        AutoFire.Enabled = not AutoFire.Enabled
        if AutoFire.Enabled then
            AutoFireButton.Text = "Auto-Fire: ON"
            AutoFireButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            AutoFireButton.Text = "Auto-Fire: OFF"
            AutoFireButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)

    -- Ensure GUI persists on respawn
    LocalPlayer.CharacterAdded:Connect(function()
        ScreenGui:Destroy()
        CreateGUI()
    end)
end

CreateGUI()

--// ESP Functionality
local function CreateESP(player)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = player.Character:GetExtentsSize()
    Box.Adornee = player.Character.PrimaryPart
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Color3 = Color3.fromRGB(0, 255, 255)
    Box.Transparency = 0.5
    Box.Parent = player.Character

    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(0, 50, 0, 25) -- Smaller Billboard
    Billboard.Adornee = player.Character.PrimaryPart
    Billboard.AlwaysOnTop = true
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.Parent = player.Character

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true
    TextLabel.Text = player.Name
    TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    TextLabel.TextStrokeTransparency = 0.5
    TextLabel.Parent = Billboard

    player.CharacterAdded:Connect(function()
        Box:Destroy()
        Billboard:Destroy()
        CreateESP(player)
    end)
end

-- Create ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
    end
end

-- Create ESP for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        CreateESP(player)
    end)
end)

-- Aimbot and Auto-Fire functionality
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end

    -- Automatically handle auto-fire
    AutoFireFunction()
end)
