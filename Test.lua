-- Test muy simple
local p = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", p:WaitForChild("PlayerGui"))

local label = Instance.new("TextLabel", gui)
label.Size = UDim2.new(0.5, 0, 0.1, 0)
label.Position = UDim2.new(0.25, 0, 0.1, 0)
label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
label.TextColor3 = Color3.fromRGB(0, 255, 0)
label.TextScaled = true
label.Text = "✅ Script cargado correctamente"
