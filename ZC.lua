--  Aimbot Script for Da Hood
-- Created by z-aq © 2024


--// Cache
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Aimbot Settings
local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "Head",
    Smoothness = 0.1,
    HitboxScale = Vector3.new(5, 5, 5),
    BulletDrop = true,  -- Toggle bullet drop simulation
    BulletSpeed = 5000, -- Speed of the bullets
    Gravity = 196.2,    -- Gravity for bullet drop calculation (similar to Roblox default)
}

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

local function CalculateBulletDrop(startPos, endPos, distance)
    if not Aimbot.BulletDrop then return end

    local time = distance / Aimbot.BulletSpeed
    local drop = 0.5 * Aimbot.Gravity * time^2
    return endPos - Vector3.new(0, drop, 0)
end

local function AimAt(target)
    if not target or not target.Character then return end

    local targetPos = target.Character[Aimbot.LockPart].Position
    local distance = (targetPos - Camera.CFrame.Position).Magnitude
    local adjustedTargetPos = Aimbot.BulletDrop and CalculateBulletDrop(Camera.CFrame.Position, targetPos, distance) or targetPos
    local direction = (adjustedTargetPos - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + direction * 1000)

    -- Implement smooth aiming
    if Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(Aimbot.Smoothness, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, adjustedTargetPos)
        local tween = TweenService:Create(Camera, tweenInfo, { CFrame = targetCFrame })
        tween:Play()
    end
end

local function EnlargeHitbox(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Size = part.Size + Aimbot.HitboxScale -- Increase hitbox size
            part.Transparency = 0.5 -- Optional: Make the hitbox visible
        end
    end
end

--// GUI Creation Function
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
        end
    end)

    local SilentSizeButton = Instance.new("TextButton")
    SilentSizeButton.Name = "SilentSizeButton"
    SilentSizeButton.Parent = ScreenGui
    SilentSizeButton.Text = "Change Silent Size"
    SilentSizeButton.Position = UDim2.new(1, -120, 0, 70)
    SilentSizeButton.Size = UDim2.new(0, 150, 0, 40) -- Smaller button
    SilentSizeButton.AnchorPoint = Vector2.new(1, 0)
    SilentSizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    SilentSizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeButton.TextScaled = true
    SilentSizeButton.TextWrapped = true

    local SilentSizeFrame = Instance.new("Frame")
    SilentSizeFrame.Name = "SilentSizeFrame"
    SilentSizeFrame.Parent = ScreenGui
    SilentSizeFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    SilentSizeFrame.Size = UDim2.new(0, 200, 0, 100)
    SilentSizeFrame.Visible = false
    SilentSizeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SilentSizeFrame.BorderSizePixel = 0

    local SilentSizeInput = Instance.new("TextBox")
    SilentSizeInput.Name = "SilentSizeInput"
    SilentSizeInput.Parent = SilentSizeFrame
    SilentSizeInput.Position = UDim2.new(0.5, -50, 0.3, 0)
    SilentSizeInput.Size = UDim2.new(0, 100, 0, 40)
    SilentSizeInput.Text = tostring(Aimbot.FOVRadius)
    SilentSizeInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeInput.TextScaled = true

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Parent = SilentSizeFrame
    SaveButton.Text = "Save"
    SaveButton.Position = UDim2.new(0.5, -50, 0.7, 0)
    SaveButton.Size = UDim2.new(0, 100, 0, 40)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextScaled = true

    SilentSizeButton.MouseButton1Click:Connect(function()
        SilentSizeFrame.Visible = not SilentSizeFrame.Visible
    end)

    SaveButton.MouseButton1Click:Connect(function()
        local newSize = tonumber(SilentSizeInput.Text)
        if newSize then
            Aimbot.FOVRadius = newSize
            Crosshair.Size = UDim2.new(0, newSize * 2, 0, newSize * 2)
            Crosshair.Position = UDim2.new(0.5, -newSize, 0.5, -newSize)
        end
        SilentSizeFrame.Visible = false
    end)

       -- Ensure GUI persists on respawn
    LocalPlayer.CharacterAdded:Connect(function()
        if not ScreenGui.Parent then
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
end

--// Main Execution Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end
end)

--// Event Handlers for Player Character Updates
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        EnlargeHitbox(character)
    end)
end)

-- Create GUI
CreateGUI()
