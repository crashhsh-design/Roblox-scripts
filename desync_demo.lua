-- Cliente: simulación de desync con sliders de control
local enemy = workspace:WaitForChild("Enemy")

-- Crear clon del enemigo
local fakeEnemy = enemy:Clone()
fakeEnemy.Name = "FakeEnemy"
fakeEnemy.BrickColor = BrickColor.new("Bright red")
fakeEnemy.Parent = workspace

-- Variables de control
local desyncEnabled = false
local lagChance = 0.2
local lagDuration = 2
local lagging = false
local lagEndTime = 0

-- Crear UI
local player = game.Players.LocalPlayer
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- Botón de encendido
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 200, 0, 50)
ToggleButton.Position = UDim2.new(0.5, -100, 0.8, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleButton.Text = "Desync: OFF"
ToggleButton.TextScaled = true

-- Slider de probabilidad
local ChanceLabel = Instance.new("TextLabel", ScreenGui)
ChanceLabel.Size = UDim2.new(0, 200, 0, 30)
ChanceLabel.Position = UDim2.new(0.5, -100, 0.65, 0)
ChanceLabel.BackgroundTransparency = 1
ChanceLabel.TextScaled = true
ChanceLabel.Text = "LagChance: " .. tostring(lagChance)

local ChanceSlider = Instance.new("TextButton", ScreenGui)
ChanceSlider.Size = UDim2.new(0, 200, 0, 20)
ChanceSlider.Position = UDim2.new(0.5, -100, 0.7, 0)
ChanceSlider.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
ChanceSlider.Text = ""

local ChanceKnob = Instance.new("Frame", ChanceSlider)
ChanceKnob.Size = UDim2.new(0, 20, 1, 0)
ChanceKnob.BackgroundColor3 = Color3.fromRGB(255, 100, 100)

-- Slider de duración
local DurationLabel = Instance.new("TextLabel", ScreenGui)
DurationLabel.Size = UDim2.new(0, 200, 0, 30)
DurationLabel.Position = UDim2.new(0.5, -100, 0.55, 0)
DurationLabel.BackgroundTransparency = 1
DurationLabel.TextScaled = true
DurationLabel.Text = "LagDuration: " .. tostring(lagDuration)

local DurationSlider = Instance.new("TextButton", ScreenGui)
DurationSlider.Size = UDim2.new(0, 200, 0, 20)
DurationSlider.Position = UDim2.new(0.5, -100, 0.6, 0)
DurationSlider.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
DurationSlider.Text = ""

local DurationKnob = Instance.new("Frame", DurationSlider)
DurationKnob.Size = UDim2.new(0, 20, 1, 0)
DurationKnob.BackgroundColor3 = Color3.fromRGB(100, 255, 100)

-- Toggle ON/OFF
ToggleButton.MouseButton1Click:Connect(function()
    desyncEnabled = not desyncEnabled
    if desyncEnabled then
        ToggleButton.Text = "Desync: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    else
        ToggleButton.Text = "Desync: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        fakeEnemy.Position = enemy.Position
        lagging = false
    end
end)

-- Función para mover knobs
local UserInputService = game:GetService("UserInputService")

local function makeSlider(slider, knob, label, min, max, callback)
    local dragging = false

    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation().X
            local sliderPos = slider.AbsolutePosition.X
            local sliderSize = slider.AbsoluteSize.X
            local relative = math.clamp((mouse - sliderPos) / sliderSize, 0, 1)
            knob.Position = UDim2.new(relative, -10, 0, 0)
            local value = min + (max - min) * relative
            callback(value, label)
        end
    end)
end

-- Slider para duración (0.5 a 5 segundos)
makeSlider(DurationSlider, DurationKnob, DurationLabel, 0.5, 5, function(value, label)
    lagDuration = math.floor(value * 10) / 10
    label.Text = "LagDuration: " .. tostring(lagDuration)
end)

-- Slider para probabilidad (0 a 1.0)
makeSlider(ChanceSlider, ChanceKnob, ChanceLabel, 0, 1, function(value, label)
    lagChance = math.floor(value * 100) / 100
    label.Text = "LagChance: " .. tostring(lagChance)
end)

-- Simulación del desync
game:GetService("RunService").RenderStepped:Connect(function(dt)
    if not desyncEnabled then
        fakeEnemy.Position = enemy.Position
        return
    end

    if not lagging then
        if math.random() < lagChance * dt then
            lagging = true
            lagEndTime = tick() + lagDuration
        else
            fakeEnemy.Position = enemy.Position
        end
    else
        if tick() >= lagEndTime then
            lagging = false
            fakeEnemy.Position = enemy.Position
        end
    end
end)
