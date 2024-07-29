-- made by z-aq-messilt
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Aimbot = {
    Enabled = false,
    FOVRadius = 100,
    LockPart = "Head",
    LockedTarget = nil,
    Smoothness = 0.1,
    SilentRadius = 50,
    AutoFire = false
}

local function GetDistanceFromCursor(pos)
    local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (Vector2.new(pos.X, pos.Y) - centerPos).Magnitude
end

local function GetClosestTarget()
    local closestTarget, closestDist = nil, Aimbot.SilentRadius

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
    local newCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)

    if Aimbot.Smoothness > 0 then
        local tweenInfo = TweenInfo.new(Aimbot.Smoothness, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(Camera, tweenInfo, { CFrame = newCFrame })
        tween:Play()
    else
        Camera.CFrame = newCFrame
    end
end

local function AutoFire(target)
    if not target or not target.Character then return end

    local gun = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if gun then
        -- Assuming gun is a tool with a Fire method
        gun:Activate()
    end
end

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

    local SilentInput = Instance.new("TextBox")
    SilentInput.Parent = SilentSizeButton
    SilentInput.Size = UDim2.new(1, -10, 0, 20)
    SilentInput.Position = UDim2.new(0, 5, 0, 10)
    SilentInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SilentInput.Text = "Enter Size"

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Parent = SilentSizeButton
    SaveButton.Text = "Save"
    SaveButton.Size = UDim2.new(1, 0, 0.5, 0)
    SaveButton.Position = UDim2.new(0, 0, 0.5, 0)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextScaled = true
    SaveButton.TextWrapped = true

    SaveButton.MouseButton1Click:Connect(function()
        local newSize = tonumber(SilentInput.Text)
        if newSize then
            Aimbot.SilentRadius = newSize
            Crosshair.Size = UDim2.new(0, Aimbot.SilentRadius * 2, 0, Aimbot.SilentRadius * 2)
        end
    end)

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = SilentSizeButton
    CloseButton.Text = "Close"
    CloseButton.Size = UDim2.new(1, 0, 0.5, 0)
    CloseButton.Position = UDim2.new(0, 0, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextScaled = true
    CloseButton.TextWrapped = true

    CloseButton.MouseButton1Click:Connect(function()
        SilentSizeButton.Visible = false
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        ScreenGui:Destroy()
        CreateGUI()
    end)
end

CreateGUI()

local function UpdateHitboxSize(character)
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character:FindFirstChild("Humanoid")
        local hitbox = character:FindFirstChild("Hitbox")
        if not hitbox then
            hitbox = Instance.new("Part")
            hitbox.Name = "Hitbox"
            hitbox.Size = humanoid.HipWidth * Vector3.new(1.5, 2.5, 1.5)
            hitbox.Transparency = 1
            hitbox.Anchored = true
            hitbox.CanCollide = false
            hitbox.Parent = character
        end
        hitbox.Size = humanoid.HipWidth * Vector3.new(1.5, 2.5, 1.5)
        hitbox.CFrame = character.PrimaryPart.CFrame
    end
end

RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        if target then
            AimAt(target)
            if Aimbot.AutoFire then
                AutoFire(target)
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        UpdateHitboxSize(character)
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(character)

    CreateGUI()


    UpdateHitboxSize(character)
end)


Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        UpdateHitboxSize(character)
    end)
end)


for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        UpdateHitboxSize(player.Character)
    end
end
   
