repeat task.wait() until game:IsLoaded()
task.wait(3)

local BSS_PLACE = 1537690962
local BOUNCE_PLACE = 4924922222 -- Brookhaven (для сброса привязки)

local g = getgenv()
g.VicHop = g.VicHop or {}
if g.VicHop.running == nil then g.VicHop.running = true end

local TP = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local placeId = game.PlaceId
local player = game:GetService("Players").LocalPlayer

print("=== Vic Hop v1.1 ===")
print("Place:", placeId, "Job:", game.JobId)

-- GUI (только в BSS)
if placeId == BSS_PLACE and player then
    local gui = Instance.new("ScreenGui")
    gui.Name = "VicHopGUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 200, 0, 70)
    f.Position = UDim2.new(0, 10, 0, 10)
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true
    f.Parent = gui

    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 0, 25)
    t.BackgroundTransparency = 1
    t.Text = "Vic Hop v1.1"
    t.TextColor3 = Color3.fromRGB(255, 200, 50)
    t.Font = Enum.Font.SourceSansBold
    t.TextSize = 16

    local s = Instance.new("TextLabel", f)
    s.Name = "Status"
    s.Size = UDim2.new(1, 0, 0, 20)
    s.Position = UDim2.new(0, 0, 0, 25)
    s.BackgroundTransparency = 1
    s.Text = "Статус: Работаю..."
    s.TextColor3 = Color3.fromRGB(100, 255, 100)
    s.Font = Enum.Font.SourceSans
    s.TextSize = 13

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1, -20, 0, 18)
    b.Position = UDim2.new(0, 10, 0, 48)
    b.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    b.Text = "F6: Выкл"
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    b.MouseButton1Click:Connect(function()
        g.VicHop.running = not g.VicHop.running
        b.Text = g.VicHop.running and "F6: Выкл" or "F6: Вкл"
        b.BackgroundColor3 = g.VicHop.running and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 200, 80)
        s.Text = g.VicHop.running and "Статус: Работаю..." or "Статус: Остановлен"
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F6 then
            g.VicHop.running = not g.VicHop.running
            b.Text = g.VicHop.running and "F6: Выкл" or "F6: Вкл"
            b.BackgroundColor3 = g.VicHop.running and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 200, 80)
            s.Text = g.VicHop.running and "Статус: Работаю..." or "Статус: Остановлен"
        end
    end)
end

-- Логика хопа
if not g.VicHop.running then print("[VicHop] Выключен"); return end

if placeId == BSS_PLACE then
    -- В BSS: ждём и уходим в bounce-игру
    print("[VicHop] BSS: жду 8с...")
    for _ = 1, 8 do
        task.wait(1)
        if not g.VicHop.running then return end
    end
    if g.VicHop.running then
        print("[VicHop] BSS -> Bounce (" .. BOUNCE_PLACE .. ")")
        TP:Teleport(BOUNCE_PLACE)
    end
else
    -- В bounce-игре (или любой другой): сразу возвращаемся в BSS
    print("[VicHop] Bounce -> BSS")
    task.wait(0.5)
    TP:Teleport(BSS_PLACE)
end

print("Vic Hop v1.1 | Включи Auto Execute в Delta!")
print("BSS -> Brookhaven -> BSS (новый сервер) -> ...")
