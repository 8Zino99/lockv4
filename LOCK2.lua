-- Created by Z-aq

local function CreateGUI()
    local Library = {}
    local UI = Instance.new("ScreenGui", game.CoreGui)
    UI.Name = "CustomAimbotUI"

    function Library:CreateWindow(config)
        local Window = Instance.new("Frame")
        Window.Size = UDim2.new(0.3, 0, 0.5, 0)
        Window.Position = UDim2.new(0.35, 0, 0.25, 0)
        Window.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Window.BorderSizePixel = 0
        Window.Parent = UI

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 0.1, 0)
        Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Text = config.Name or "Window"
        Title.Parent = Window

        local Tabs = Instance.new("Frame")
        Tabs.Size = UDim2.new(1, 0, 0.9, 0)
        Tabs.Position = UDim2.new(0, 0, 0.1, 0)
        Tabs.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Tabs.Parent = Window

        function Library:CreateTab(tabConfig)
            local Tab = Instance.new("Frame")
            Tab.Size = UDim2.new(1, 0, 1, 0)
            Tab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Tab.Visible = false
            Tab.Parent = Tabs

            local TabButton = Instance.new("TextButton")
            TabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
            TabButton.Position = UDim2.new(0, 0, 0, 0)
            TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.Text = tabConfig.Name or "Tab"
            TabButton.Parent = Window

            TabButton.MouseButton1Click:Connect(function()
                for _, child in pairs(Tabs:GetChildren()) do
                    child.Visible = false
                end
                Tab.Visible = true
            end)

            function Library:CreateSection(sectionConfig)
                local Section = Instance.new("Frame")
                Section.Size = UDim2.new(1, 0, 1, 0)
                Section.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Section.Parent = Tab

                local Title = Instance.new("TextLabel")
                Title.Size = UDim2.new(1, 0, 0.1, 0)
                Title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.Text = sectionConfig.Name or "Section"
                Title.Parent = Section

                function Library:AddToggle(toggleConfig)
                    local Toggle = Instance.new("TextButton")
                    Toggle.Size = UDim2.new(1, 0, 0.1, 0)
                    Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Toggle.Text = toggleConfig.Name or "Toggle"
                    Toggle.Parent = Section

                    local ToggleValue = toggleConfig.Value or false

                    Toggle.MouseButton1Click:Connect(function()
                        ToggleValue = not ToggleValue
                        Toggle.Text = (ToggleValue and "✓ " or "✗ ") .. (toggleConfig.Name or "Toggle")
                        if toggleConfig.Callback then
                            toggleConfig.Callback(ToggleValue)
                        end
                    end)

                    Toggle.Text = (ToggleValue and "✓ " or "✗ ") .. (toggleConfig.Name or "Toggle")
                end

                function Library:AddSlider(sliderConfig)
                    local Slider = Instance.new("Frame")
                    Slider.Size = UDim2.new(1, 0, 0.1, 0)
                    Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    Slider.Parent = Section

                    local Title = Instance.new("TextLabel")
                    Title.Size = UDim2.new(0.6, 0, 1, 0)
                    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    Title.Text = sliderConfig.Name or "Slider"
                    Title.Parent = Slider

                    local SliderBar = Instance.new("Frame")
                    SliderBar.Size = UDim2.new(0.8, 0, 0.5, 0)
                    SliderBar.Position = UDim2.new(0.2, 0, 0.5, 0)
                    SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    SliderBar.Parent = Slider

                    local Handle = Instance.new("Frame")
                    Handle.Size = UDim2.new(0.05, 0, 1, 0)
                    Handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Handle.Parent = SliderBar

                    local SliderValue = Instance.new("TextLabel")
                    SliderValue.Size = UDim2.new(0.4, 0, 0.5, 0)
                    SliderValue.Position = UDim2.new(0.6, 0, 0.5, 0)
                    SliderValue.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    SliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
                    SliderValue.Text = tostring(sliderConfig.Value or 0)
                    SliderValue.Parent = Slider

                    local dragging = false
                    local minValue = sliderConfig.Min or 0
                    local maxValue = sliderConfig.Max or 100

                    Handle.MouseButton1Down:Connect(function()
                        dragging = true
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mouseX = input.Position.X
                            local sliderStart = SliderBar.AbsolutePosition.X
                            local sliderWidth = SliderBar.AbsoluteSize.X
                            local newValue = math.clamp(((mouseX - sliderStart) / sliderWidth), 0, 1) * (maxValue - minValue) + minValue
                            Handle.Position = UDim2.new(newValue / (maxValue - minValue), 0, 0, 0)
                            SliderValue.Text = tostring(math.floor(newValue))
                            if sliderConfig.Callback then
                                sliderConfig.Callback(newValue)
                            end
                        end
                    end)
                end
            end
        end

        return Library
    end

    return Library
end

-- Initialize
local getgenv = getgenv
if getgenv().Aimbot then return end
getgenv().Aimbot = { Settings = {}, FOVSettings = {}, Functions = {} }

local Aimbot = getgenv().Aimbot
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Initialize Settings
Aimbot.Settings = {
    Enabled = true,
    Toggle = false,
    LockPart = "Head",
    TriggerKey = Enum.KeyCode.MouseButton2,
    Sensitivity = 0.5,
    TeamCheck = false,
    WallCheck = true,
    AliveCheck = true,
    ThirdPerson = false,
    ThirdPersonSensitivity = 3,
}

Aimbot.FOVSettings = {
    Enabled = true,
    Visible = true,
    Amount = 90,
    Transparency = 0.5,
    Sides = 60,
    Thickness = 1,
    Filled = false,
    Color = Color3.fromRGB(255, 255, 255),
    LockedColor = Color3.fromRGB(255, 70, 70),
}

-- GUI Setup
local Library = CreateGUI()
local MainFrame = Library:CreateWindow({
    Name = "Custom Aimbot"
})

-- Settings Tab
local SettingsTab = MainFrame:CreateTab({ Name = "Settings" })
local Values = SettingsTab:CreateSection({ Name = "Values" })
local Checks = SettingsTab:CreateSection({ Name = "Checks" })
local ThirdPerson = SettingsTab:CreateSection({ Name = "Third Person" })

-- Values Section
Values:AddToggle({
    Name = "Enabled",
    Value = Aimbot.Settings.Enabled,
    Callback = function(New)
        Aimbot.Settings.Enabled = New
    end
})

Values:AddSlider({
    Name = "Sensitivity",
    Value = Aimbot.Settings.Sensitivity,
    Min = 0.1,
    Max = 10,
    Callback = function(New)
        Aimbot.Settings.Sensitivity = New
    end
})

Values:AddToggle({
    Name = "Lock Part",
    Value = Aimbot.Settings.LockPart,
    Callback = function(New)
        Aimbot.Settings.LockPart = New
    end
})

Values:AddToggle({
    Name = "Trigger Key",
    Value = Aimbot.Settings.TriggerKey.Name,
    Callback = function(New)
        Aimbot.Settings.TriggerKey = Enum.KeyCode[New]
    end
})

-- Checks Section
Checks:AddToggle({
    Name = "Team Check",
    Value = Aimbot.Settings.TeamCheck,
    Callback = function(New)
        Aimbot.Settings.TeamCheck = New
    end
})

Checks:AddToggle({
    Name = "Wall Check",
    Value = Aimbot.Settings.WallCheck,
    Callback = function(New)
        Aimbot.Settings.WallCheck = New
    end
})

Checks:AddToggle({
    Name = "Alive Check",
    Value = Aimbot.Settings.AliveCheck,
    Callback = function(New)
        Aimbot.Settings.AliveCheck = New
    end
})

-- Third Person Section
ThirdPerson:AddToggle({
    Name = "Enable Third Person",
    Value = Aimbot.Settings.ThirdPerson,
    Callback = function(New)
        Aimbot.Settings.ThirdPerson = New
    end
})

ThirdPerson:AddSlider({
    Name = "Third Person Sensitivity",
    Value = Aimbot.Settings.ThirdPersonSensitivity,
    Min = 0.1,
    Max = 10,
    Callback = function(New)
        Aimbot.Settings.ThirdPersonSensitivity = New
    end
})

-- Aimbot Logic
local function GetClosestPlayer()
    local closestPlayer, closestDistance = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Aimbot.Settings.LockPart) and player.Character:FindFirstChildOfClass("Humanoid") then
            if Aimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            if Aimbot.Settings.AliveCheck and player.Character.Humanoid.Health <= 0 then continue end
            if Aimbot.Settings.WallCheck and #Camera:GetPartsObscuringTarget({player.Character[Aimbot.Settings.LockPart].Position}, player.Character:GetDescendants()) > 0 then continue end

            local screenPoint = Camera:WorldToViewportPoint(player.Character[Aimbot.Settings.LockPart].Position)
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
            if distance < closestDistance and distance < Aimbot.FOVSettings.Amount then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    return closestPlayer
end

local function AimbotFunction()
    if not Aimbot.Settings.Enabled then return end
    local player = GetClosestPlayer()
    if player then
        local targetPosition = Camera:WorldToViewportPoint(player.Character[Aimbot.Settings.LockPart].Position)
        local mousePosition = UserInputService:GetMouseLocation()
        local aimDirection = (Vector2.new(targetPosition.X, targetPosition.Y) - mousePosition).unit
        local newMousePosition = mousePosition + (aimDirection * Aimbot.Settings.Sensitivity)
        UserInputService:SetMouseLocation(Vector2.new(newMousePosition.X, newMousePosition.Y))
    end
end

-- Smoothness and Aiming Adjustment
RunService.RenderStepped:Connect(function()
    if Aimbot.Settings.Toggle then
        AimbotFunction()
    end
end)

-- Detect if the user is typing to prevent aimbot activation
UserInputService.TextBoxFocused:Connect(function()
    Aimbot.Typing = true
end)

UserInputService.TextBoxFocusReleased:Connect(function()
    Aimbot.Typing = false
end)

-- GUI Management
RunService.Heartbeat:Connect(function()
    if Aimbot.FOVSettings.Visible then
        -- Draw the FOV circle
        local fovCircle = Instance.new("Frame")
        fovCircle.Size = UDim2.new(0, Aimbot.FOVSettings.Amount * 2, 0, Aimbot.FOVSettings.Amount * 2)
        fovCircle.Position = UDim2.new(0.5, -Aimbot.FOVSettings.Amount, 0.5, -Aimbot.FOVSettings.Amount)
        fovCircle.BackgroundColor3 = Aimbot.FOVSettings.Color
        fovCircle.BackgroundTransparency = Aimbot.FOVSettings.Transparency
        fovCircle.BorderSizePixel = Aimbot.FOVSettings.Thickness
        fovCircle.BorderColor3 = Aimbot.FOVSettings.Color
        fovCircle.Visible = Aimbot.FOVSettings.Visible
        fovCircle.Parent = UI
    end
end)
