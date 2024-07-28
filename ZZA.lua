-- Silent Aimbot Script with Crosshair, Toggle GUI, Player ESP, and Hitbox Enlargement
-- Created by zin-aa © 2024


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

-- Function to enlarge hitboxes of characters
local function EnlargeHitbox(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Size = part.Size * 1.5 -- Only slightly increase the size
            part.Transparency = 0.5
        end
    end
end

-- Function to create ESP
local function CreateESP(player)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = player.Character:GetExtentsSize()
    Box.Adornee = player.Character.PrimaryPart
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Color3 = Color3.fromRGB(0, 255, 255)
    Box.Transparency = 0.5
    Box.Parent = player.Character

    player.CharacterAdded:Connect(function()
        Box:Destroy()
        CreateESP(player)
    end)
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

    local SilentSizeFrame = Instance.new("Frame")
    SilentSizeFrame.Name = "SilentSizeFrame"
    SilentSizeFrame.Parent = ScreenGui
    SilentSizeFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
    SilentSizeFrame.Size = UDim2.new(0, 200, 0, 100)
    SilentSizeFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SilentSizeFrame.Visible = false

    local SilentSizeBox = Instance.new("TextBox")
    SilentSizeBox.Name = "SilentSizeBox"
    SilentSizeBox.Parent = SilentSizeFrame
    SilentSizeBox.Position = UDim2.new(0.1, 0, 0.2, 0)
    SilentSizeBox.Size = UDim2.new(0.8, 0, 0.3, 0)
    SilentSizeBox.Text = tostring(Aimbot.FOVRadius)
    SilentSizeBox.TextScaled = true
    SilentSizeBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Parent = SilentSizeFrame
    SaveButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    SaveButton.Size = UDim2.new(0.8, 0, 0.3, 0)
    SaveButton.Text = "Save"
    SaveButton.TextScaled = true
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

    SaveButton.MouseButton1Click:Connect(function()
        local new = tonumber(SilentSizeBox.Text)
        if new then
            Aimbot.FOVRadius = new
            Crosshair.Size = UDim2.new(0, new * 2, 0, new * 2)
            Crosshair.Position = UDim2.new(0.5, -new, 0.5, -new)
        end
        SilentSizeFrame.Visible = false
    end)

    local OpenSilentSizeButton = Instance.new("TextButton")
    OpenSilentSizeButton.Name = "OpenSilentSizeButton"
    OpenSilentSizeButton.Parent = ScreenGui
    OpenSilentSizeButton.Text = "Silent Size"
    OpenSilentSizeButton.Position = UDim2.new(1, -120, 0, 70)
    OpenSilentSizeButton.Size = UDim2.new(0, 80, 0, 40) -- Smaller button
    OpenSilentSizeButton.AnchorPoint = Vector2.new(1, 0)
    OpenSilentSizeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    OpenSilentSizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    OpenSilentSizeButton.TextScaled = true
    OpenSilentSizeButton.TextWrapped = true

    OpenSilentSizeButton.MouseButton1Click:Connect(function()
        SilentSizeFrame.Visible = not SilentSizeFrame.Visible
    end)

    -- Ensure GUI persists on respawn
    LocalPlayer.CharacterAdded:Connect(function()
                wait(1)  -- Give a moment for the character to load
        ScreenGui:Destroy()
        CreateGUI()
    end)
end

CreateGUI()

--// ESP and Hitbox Enlargement for Existing Players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer and player.Character then
        CreateESP(player)
        EnlargeHitbox(player.Character)
    end
end

--// ESP and Hitbox Enlargement for New Players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        CreateESP(player)
        EnlargeHitbox(character)
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
