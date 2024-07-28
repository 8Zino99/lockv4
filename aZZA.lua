-- Silent Aimbot Script with Crosshair, Toggle GUI, and Adjustable Hitbox
-- Created by ChatGPT © 2024
-- This script is for educational purposes.

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

local function EnlargeHitbox(character)
    local function ApplyHitbox(part)
        if part:IsA("BasePart") then
            part.Size = part.Size + Vector3.new(5, 5, 5) -- Adjust the size increase as needed
            part.Transparency = 0.5 -- Optional: make hitbox slightly visible for debugging
        end
    end

    for _, part in pairs(character:GetChildren()) do
        ApplyHitbox(part)
    end

    character.ChildAdded:Connect(function(part)
        ApplyHitbox(part)
    end)
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
            aimlockService.release()
        end
    end)

    local SilentSizeButton = Instance.new("TextButton")
    SilentSizeButton.Name = "SilentSizeButton"
    SilentSizeButton.Parent = ScreenGui
    SilentSizeButton.Text = "Silent Size"
    SilentSizeButton.Position = UDim2.new(1, -120, 0, 70)
    SilentSizeButton.Size = UDim2.new(0, 80, 0, 40) -- Smaller button
    SilentSizeButton.AnchorPoint = Vector2.new(1, 0)
    SilentSizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    SilentSizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeButton.TextScaled = true
    SilentSizeButton.TextWrapped = true

    SilentSizeButton.MouseButton1Click:Connect(function()
        SilentSizeFrame.Visible = not SilentSizeFrame.Visible
    end)

    -- Silent Size Changer GUI
    local SilentSizeFrame = Instance.new("Frame")
    SilentSizeFrame.Name = "SilentSizeFrame"
    SilentSizeFrame.Parent = ScreenGui
    SilentSizeFrame.Size = UDim2.new(0, 200, 0, 100)
    SilentSizeFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    SilentSizeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    SilentSizeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SilentSizeFrame.Visible = false

    local SilentSizeTextBox = Instance.new("TextBox")
    SilentSizeTextBox.Name = "SilentSizeTextBox"
    SilentSizeTextBox.Parent = SilentSizeFrame
    SilentSizeTextBox.Size = UDim2.new(0, 180, 0, 40)
    SilentSizeTextBox.Position = UDim2.new(0.5, 0, 0.3, 0)
    SilentSizeTextBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SilentSizeTextBox.PlaceholderText = "Enter FOV Size"
    SilentSizeTextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeTextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    SilentSizeTextBox.TextScaled = true

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Parent = SilentSizeFrame
    SaveButton.Text = "Save"
    SaveButton.Size = UDim2.new(0, 80, 0, 30)
    SaveButton.Position = UDim2.new(0.5, 0, 0.8, 0)
    SaveButton.AnchorPoint = Vector2.new(0.5, 0.5)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextScaled = true

    SaveButton.MouseButton1Click:Connect(function()
        local newSize = tonumber(SilentSizeTextBox.Text)
        if newSize then
            Aimbot.FOVRadius = newSize
            Crosshair.Size = UDim2.new(0, newSize * 2, 0, newSize * 2)
            SilentSizeFrame.Visible = false
        end
    end)

    -- Ensure GUI persists on respawn
    LocalPlayer.CharacterAdded:Connect(function()
        wait(1)  -- Give a moment for the character to load
                ScreenGui:Destroy()
        CreateGUI()
    end)
end

CreateGUI()

--// Aimbot Functionality
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target and target.Character then
            AimAt(target)
        end
    end
end)

-- Create hitboxes for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        EnlargeHitbox(player.Character)
    end
end

-- Create hitboxes for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        EnlargeHitbox(player.Character)
    end)
end)

-- Adjust the hitbox of characters upon respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    EnlargeHitbox(character)
end)
