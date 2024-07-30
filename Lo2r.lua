-- Created by z-aa

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Aimbot Settings
local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "Head",
    LockedTarget = nil,
    Smoothness = 0.01, -- Reduced smoothness for more immediate aiming
    HitboxSize = 10,
    AutoFire = false
}

-- Utility Functions
local function GetDistanceFromCursor(pos)
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
end

local function GetClosestTargetInSilentZone()
    local closestTarget, closestDist = nil, Aimbot.FOVRadius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.LockPart) then
            local targetPos = player.Character[Aimbot.LockPart].Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

            if onScreen then
                local dist = GetDistanceFromCursor(screenPos)
                if dist <= Aimbot.FOVRadius then
                    -- Target is within the Silent Zone
                    closestDist = dist
                    closestTarget = player
                end
            end
        end
    end

    return closestTarget
end

local function PredictTargetPosition(target)
    local targetPos = target.Character[Aimbot.LockPart].Position
    local velocity = target.Character:FindFirstChild("HumanoidRootPart").Velocity
    local predictedPosition = targetPos + (velocity * 0.5) -- Adjust factor as needed
    return predictedPosition
end

local function AimAt(target)
    if not target or not target.Character then return end

    local targetPosition = PredictTargetPosition(target)
    local direction = (targetPosition - Camera.CFrame.Position).Unit
    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)

    -- Directly set CFrame for immediate aiming
    Camera.CFrame = targetCFrame
end

local function UpdateHitboxSize(character)
    if character and character:FindFirstChild(Aimbot.LockPart) then
        local hitbox = character:FindFirstChild("Hitbox") or Instance.new("Part")
        hitbox.Size = Vector3.new(Aimbot.HitboxSize, Aimbot.HitboxSize, Aimbot.HitboxSize)
        hitbox.Transparency = 1
        hitbox.CanCollide = false
        hitbox.Anchored = true
        hitbox.Parent = character
    end
end

-- GUI Creation Function
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
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
    ToggleButton.Size = UDim2.new(0, 80, 0, 40)
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
        end
    end)

    local SilentSizeButton = Instance.new("TextButton")
    SilentSizeButton.Name = "SilentSizeButton"
    SilentSizeButton.Parent = ScreenGui
    SilentSizeButton.Text = "Silent Size"
    SilentSizeButton.Position = UDim2.new(1, -120, 0, 70)
    SilentSizeButton.Size = UDim2.new(0, 80, 0, 40)
    SilentSizeButton.AnchorPoint = Vector2.new(1, 0)
    SilentSizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    SilentSizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeButton.TextScaled = true
    SilentSizeButton.TextWrapped = true

    SilentSizeButton.MouseButton1Click:Connect(function()
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0, 200, 0, 50)
        input.Position = UDim2.new(0.5, -100, 0.5, -25)
        input.PlaceholderText = "Enter new size"
        input.Parent = ScreenGui

        local saveButton = Instance.new("TextButton")
        saveButton.Size = UDim2.new(0, 100, 0, 50)
        saveButton.Position = UDim2.new(0.5, -50, 0.5, 30)
        saveButton.Text = "Save"
        saveButton.Parent = ScreenGui

        saveButton.MouseButton1Click:Connect(function()
            local newSize = tonumber(input.Text)
            if newSize then
                Aimbot.FOVRadius = newSize
                Crosshair.Size = UDim2.new(0, Aimbot.FOVRadius * 2, 0, Aimbot.FOVRadius * 2)
            end
            input:Destroy()
            saveButton:Destroy()
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1)
        CreateGUI()
        UpdateHitboxSize(character)
    end)
end

CreateGUI()

-- Main Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTargetInSilentZone()
        if target then
            AimAt(target)
            if Aimbot.AutoFire then
                -- Implement AutoFire logic if necessary
                -- Example: fire at target
            end
        end
    end
end)

-- Ensure GUI persists on respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    CreateGUI()
    UpdateHitboxSize(character)
end)
