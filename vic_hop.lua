repeat task.wait() until game:IsLoaded()
task.wait(2)

local BSS = 1537690962
local BOUNCE = 4924922222 -- Brookhaven

local g = getgenv()
g.VicHop = g.VicHop or {}
if g.VicHop.running == nil then g.VicHop.running = true end

local player = game:GetService("Players").LocalPlayer
local TP = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local q = queue_on_teleport or syn.queue_on_teleport
local placeId = game.PlaceId
local inBSS = (placeId == BSS)
local inBounce = (placeId == BOUNCE)

print("=== Vic Hop v1.1 ===")
print("Place:", placeId, "Job:", game.JobId)
print("queue_on_teleport:", q ~= nil)

-- GUI в BSS
if inBSS and player then
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

    Instance.new("TextLabel", f).Size = UDim2.new(1, 0, 0, 25)
    Instance.new("TextLabel", f).BackgroundTransparency = 1
    Instance.new("TextLabel", f).Text = "Vic Hop v1.1"
    Instance.new("TextLabel", f).TextColor3 = Color3.fromRGB(255, 200, 50)
    Instance.new("TextLabel", f).Font = Enum.Font.SourceSansBold
    Instance.new("TextLabel", f).TextSize = 16

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

    local function ui(v)
        b.Text = v and "F6: Выкл" or "F6: Вкл"
        b.BackgroundColor3 = v and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 200, 80)
        s.Text = v and "Статус: Работаю..." or "Статус: Остановлен"
    end
    ui(g.VicHop.running)

    b.MouseButton1Click:Connect(function()
        g.VicHop.running = not g.VicHop.running
        ui(g.VicHop.running)
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.F6 then
            g.VicHop.running = not g.VicHop.running
            ui(g.VicHop.running)
        end
    end)
end

-- Логика
if not g.VicHop.running then print("[VicHop] Выключен"); return end

if inBSS then
    -- В BSS: ждём и хопаем
    print("[VicHop] BSS: жду 8с и хоп...")
    for _ = 1, 8 do
        task.wait(1)
        if not g.VicHop.running then return end
    end
    if g.VicHop.running then
        -- queue_on_teleport: после телепорта в BOUNCE сразу вернись в BSS
        if q then
            local backCode = "repeat task.wait()until game:IsLoaded() task.wait(1) game:GetService('TeleportService'):Teleport(" .. BSS .. ")"
            q(backCode)
        end
        task.wait(0.5)
        TP:Teleport(BOUNCE)
    end
elseif inBounce then
    -- В Brookhaven: сразу телепорт обратно в BSS (на другой сервер)
    print("[VicHop] Brookhaven -> BSS")
    task.wait(0.3)
    TP:Teleport(BSS)
else
    print("[VicHop] Другая игра, пропускаю")
end

print("Vic Hop v1.1 | Введи скрипт в BSS")
