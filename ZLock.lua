-- made by z-aq


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
    Smoothness = 0.1,
    HitboxSizeMultiplier = 2
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

local function AimAt(target)
    if not target or not target.Character then return end

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

local function UpdateHitboxSize(character)
    if not character or not character:FindFirstChild(Aimbot.LockPart) then return end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Size = part.Size * Aimbot.HitboxSizeMultiplier
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
    SilentSizeButton.Size = UDim2.new(0, 80, 0, 40) -- Smaller button
    SilentSizeButton.AnchorPoint = Vector2.new(1, 0)
    SilentSizeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
    SilentSizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeButton.TextScaled = true
    SilentSizeButton.TextWrapped = true

    SilentSizeButton.MouseButton1Click:Connect(function()
        local inputBox = Instance.new("TextBox")
        inputBox.Size = UDim2.new(0, 200, 0, 50)
        inputBox.Position = UDim2.new(0.5, -100, 0.5, -25)
        inputBox.AnchorPoint = Vector2.new(0.5, 0.5)
        inputBox.Text = tostring(Aimbot.FOVRadius)
        inputBox.Parent = ScreenGui

        local saveButton = Instance.new("TextButton")
        saveButton.Text = "Save"
        saveButton.Size = UDim2.new(0, 100, 0, 50)
        saveButton.Position = UDim2.new(0.5, -50, 0.6, 0)
        saveButton.AnchorPoint = Vector2.new(0.5, 0)
        saveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        saveButton.Parent = ScreenGui

        saveButton.MouseButton1Click:Connect(function()
            local new = tonumber(inputBox.Text)
            if new then
                Aimbot.FOVRadius = new
                Crosshair.Size = UDim2.new(0, new * 2, 0, new * 2)
                Crosshair.Position = UDim2.new(0.5, -new, 0.5, -new)
            end
            inputBox:Destroy()
            saveButton:Destroy()
        end)
    end)

    -- Ensure GUI persists on respawn
    LocalPlayer.CharacterAdded:Connect(function(character)
        CreateGUI()
        UpdateHitboxSize(character)
    end)
end

CreateGUI()

-- Ensure hitbox size for all current players
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        UpdateHitboxSize(player.Character)
    end
end

-- Update hitbox size for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        UpdateHitboxSize(character)
    end)
end)

-- Aimbot functionality
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
        end
    end
end)
