-- Silent Aimbot Script with Crosshair, Toggle GUI, Player ESP, Health Display, Auto-Fire Functionality, and FOV Size Adjustment
-- Created by z © 2024

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

local function ResizeHitbox(character, sizeMultiplier)
    for _, partName in pairs({"Head", "Torso", "LeftLeg", "RightLeg", "LeftArm", "RightArm"}) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Size = part.Size * sizeMultiplier
            part.Massless = true
            part.CanCollide = false
        end
    end
end

--// GUI Creation Function
local function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Visible = false

    local ToggleMainFrame = Instance.new("TextButton")
    ToggleMainFrame.Name = "ToggleMainFrame"
    ToggleMainFrame.Parent = ScreenGui
    ToggleMainFrame.Text = "Menu"
    ToggleMainFrame.Position = UDim2.new(1, -120, 0, 20)
    ToggleMainFrame.Size = UDim2.new(0, 80, 0, 40)
    ToggleMainFrame.AnchorPoint = Vector2.new(1, 0)
    ToggleMainFrame.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    ToggleMainFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleMainFrame.TextScaled = true
    ToggleMainFrame.TextWrapped = true

    ToggleMainFrame.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.Text = "Silent Aimbot Menu"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.TextWrapped = true

    local TabsFrame = Instance.new("Frame")
    TabsFrame.Name = "TabsFrame"
    TabsFrame.Parent = MainFrame
    TabsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabsFrame.Size = UDim2.new(1, 0, 0, 40)
    TabsFrame.Position = UDim2.new(0, 0, 0, 40)

    local TabsListLayout = Instance.new("UIListLayout")
    TabsListLayout.Parent = TabsFrame
    TabsListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ContentFrame.Size = UDim2.new(1, 0, 1, -80)
    ContentFrame.Position = UDim2.new(0, 0, 0, 80)

    local AimbotTab = Instance.new("TextButton")
    AimbotTab.Name = "AimbotTab"
    AimbotTab.Parent = TabsFrame
    AimbotTab.Text = "Aimbot"
    AimbotTab.Size = UDim2.new(0, 100, 1, 0)
    AimbotTab.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    AimbotTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotTab.TextScaled = true
    AimbotTab.TextWrapped = true

    local AimbotContent = Instance.new("Frame")
    AimbotContent.Name = "AimbotContent"
    AimbotContent.Parent = ContentFrame
    AimbotContent.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    AimbotContent.Size = UDim2.new(1, 0, 1, 0)
    AimbotContent.Visible = true

    local SilentSizeLabel = Instance.new("TextLabel")
    SilentSizeLabel.Name = "SilentSizeLabel"
    SilentSizeLabel.Parent = AimbotContent
    SilentSizeLabel.Text = "Silent FOV Size:"
    SilentSizeLabel.Size = UDim2.new(0, 100, 0, 40)
    SilentSizeLabel.Position = UDim2.new(0, 10, 0, 10)
    SilentSizeLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SilentSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeLabel.TextScaled = true
    SilentSizeLabel.TextWrapped = true

    local SilentSizeInput = Instance.new("TextBox")
    SilentSizeInput.Name = "SilentSizeInput"
    SilentSizeInput.Parent = AimbotContent
    SilentSizeInput.Size = UDim2.new(0, 100, 0, 40)
    SilentSizeInput.Position = UDim2.new(0, 120, 0, 10)
        SilentSizeInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SilentSizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    SilentSizeInput.TextScaled = true
    SilentSizeInput.TextWrapped = true
    SilentSizeInput.PlaceholderText = tostring(Aimbot.FOVRadius)

    local SaveButton = Instance.new("TextButton")
    SaveButton.Name = "SaveButton"
    SaveButton.Parent = AimbotContent
    SaveButton.Text = "Save"
    SaveButton.Size = UDim2.new(0, 80, 0, 40)
    SaveButton.Position = UDim2.new(0, 230, 0, 10)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.TextScaled = true
    SaveButton.TextWrapped = true

    SaveButton.MouseButton1Click:Connect(function()
        local newSize = tonumber(SilentSizeInput.Text)
        if newSize then
            Aimbot.FOVRadius = newSize
            Crosshair.Size = UDim2.new(0, Aimbot.FOVRadius * 2, 0, Aimbot.FOVRadius * 2)
            Crosshair.Position = UDim2.new(0.5, -Aimbot.FOVRadius, 0.5, -Aimbot.FOVRadius)
        end
    end)

    -- Tabs Functionality
    AimbotTab.MouseButton1Click:Connect(function()
        AimbotContent.Visible = true
    end)

    -- Add other tabs as needed and their corresponding content frames
    -- Ensure the other content frames are not visible when AimbotContent is visible
    -- Example:
    -- AnotherTab.MouseButton1Click:Connect(function()
    --     AimbotContent.Visible = false
    --     AnotherContent.Visible = true
    -- end)

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
    Box.ZIndex = 5
    Box.Transparency = 0.5
    Box.Color3 = Color3.new(1, 0, 0)
    Box.Parent = player.Character.PrimaryPart

    local function OnCharacterAdded(character)
        Box.Adornee = character.PrimaryPart
    end

    player.CharacterAdded:Connect(OnCharacterAdded)
end

local function SetupESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                CreateESP(player)
            end)
        end
    end)
end

SetupESP()

--// Main Loop
RunService.RenderStepped:Connect(function()
    if Aimbot.Enabled then
        local target = GetClosestTarget()
        AimAt(target)
    end

    if AutoFire.Enabled then
        AutoFireFunction()
    end
end)
