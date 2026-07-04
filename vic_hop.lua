repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(2)

local player = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local placeId = game.PlaceId
local q = queue_on_teleport or syn.queue_on_teleport

local g = getgenv()
g.VicHop = g.VicHop or {}
g.VicHop.lastJob = g.VicHop.lastJob or game.JobId
g.VicHop.running = g.VicHop.running
if g.VicHop.running == nil then g.VicHop.running = true end

print("=== Vic Hop v1.1 ===")
print("Place:", placeId, "| Job:", game.JobId)
print("Last Job:", g.VicHop.lastJob)
print("Running:", g.VicHop.running)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VicHopGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 130)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Vic Hop v1.1"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, 0, 0, 25)
status.Position = UDim2.new(0, 0, 0, 25)
status.BackgroundTransparency = 1
status.Text = "Статус: Работаю..."
status.TextColor3 = Color3.fromRGB(100, 255, 100)
status.Font = Enum.Font.SourceSans
status.TextSize = 14
status.Parent = frame

local info = Instance.new("TextLabel")
info.Name = "Info"
info.Size = UDim2.new(1, 0, 0, 40)
info.Position = UDim2.new(0, 0, 0, 48)
info.BackgroundTransparency = 1
info.Text = "Job: " .. game.JobId:sub(1, 14)
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.Font = Enum.Font.SourceSans
info.TextSize = 12
info.TextWrapped = true
info.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 22)
toggleBtn.Position = UDim2.new(0, 10, 0, 95)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = g.VicHop.running and "F6: Выключить" or "F6: Включить"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

-- Код для queue_on_teleport (самодостаточный)
local hopCode = [[
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(2)
local g = getgenv()
g.VicHop = g.VicHop or {}
local q = queue_on_teleport or syn.queue_on_teleport
local cur = game.JobId
local prev = g.VicHop.lastJob or cur
g.VicHop.lastJob = cur

if g.VicHop.running == false then print("VicHop: остановлен"); return end

if cur == prev then
    print("VicHop: тот же сервер, хоплю через 2с...")
    task.wait(2)
end

if q then q(getgenv().VicHop.hopCode) end
task.wait(0.5)
game:GetService("TeleportService"):Teleport(game.PlaceId)
]]

g.VicHop.hopCode = hopCode

local function doHop()
    if not g.VicHop.running then return end
    g.VicHop.lastJob = game.JobId
    status.Text = "Хоп..."
    info.Text = "Хоп на новый сервер..."
    print("[VicHop] Хоп...")

    if q then
        print("[VicHop] Ставлю queue_on_teleport")
        q(hopCode)
    else
        print("[VicHop] queue_on_teleport нет, хоп без продолжения")
    end

    task.wait(0.5)
    TeleportService:Teleport(placeId)
end

local function start()
    g.VicHop.running = true
    status.Text = "Статус: Работаю..."
    toggleBtn.Text = "F6: Выключить"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    print("=== Server Hop запущен ===")
    doHop()
end

local function stop()
    g.VicHop.running = false
    status.Text = "Статус: Остановлен"
    toggleBtn.Text = "F6: Включить"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
    print("=== Server Hop остановлен ===")
end

toggleBtn.MouseButton1Click:Connect(function()
    if g.VicHop.running then stop() else start() end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if g.VicHop.running then stop() else start() end
    end
end)

-- Автозапуск при новом сервере
if g.VicHop.running then
    if game.JobId ~= g.VicHop.lastJob then
        print("[VicHop] Новый сервер, жду 5с перед следующим хопом...")
        info.Text = "Новый сервер, жду 5с"
        task.wait(5)
    end
    if g.VicHop.running then doHop() end
else
    start()
end

print("Vic Hop v1.1 | F6 — вкл/выкл")
