repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(3)

local g = getgenv()
g.VicHop = g.VicHop or {}

local player = game:GetService("Players").LocalPlayer
local TP = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local placeId = game.PlaceId

-- Состояние храним в getgenv() — живёт пока жив executor
if g.VicHop.running == nil then g.VicHop.running = true end
g.VicHop.lastJob = g.VicHop.lastJob or game.JobId

print("=== Vic Hop v1.1 ===")
print("Place:", placeId, "| Job:", game.JobId)
print("Prev:", g.VicHop.lastJob)
print("Running:", g.VicHop.running)

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VicHopGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 140)
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
toggleBtn.BackgroundColor3 = g.VicHop.running and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 200, 80)
toggleBtn.Text = g.VicHop.running and "F6: Выключить" or "F6: Включить"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local function doHop()
    if not g.VicHop.running then return end
    g.VicHop.lastJob = game.JobId
    status.Text = "Хоп..."
    info.Text = "Хоп на новый сервер..."
    print("[VicHop] Телепорт...")
    task.wait(0.5)
    TP:Teleport(placeId)
end

local function start()
    g.VicHop.running = true
    g.VicHop.retries = 0
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

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if g.VicHop.running then stop() else start() end
    end
end)

-- Основная логика
if g.VicHop.running then
    local sameServer = (game.JobId == g.VicHop.lastJob)
    g.VicHop.lastJob = game.JobId

    if sameServer then
        -- Всё ещё на том же сервере — ждём дольше
        g.VicHop.retries = (g.VicHop.retries or 0) + 1
        local waitTime = math.min(5 + g.VicHop.retries * 10, 60)
        print("[VicHop] Тот же сервер! Жду " .. waitTime .. "с (ретрай " .. g.VicHop.retries .. ")")
        status.Text = "Тот же сервер, жду " .. waitTime .. "с..."
        for _ = 1, waitTime do
            task.wait(1)
            if not g.VicHop.running then return end
        end
        if g.VicHop.running then doHop() end
    else
        -- Новый сервер — ждём и хопаем
        g.VicHop.retries = 0
        print("[VicHop] Новый сервер! Жду 8с...")
        status.Text = "Новый сервер, жду 8с..."
        for _ = 1, 8 do
            task.wait(1)
            if not g.VicHop.running then return end
        end
        if g.VicHop.running then doHop() end
    end
else
    start()
end

print("Vic Hop v1.1 | F6 — вкл/выкл")
print("ВАЖНО: включи Auto Execute в Delta!")
print("Скрипт сам себя перезапускает после телепорта через Auto Execute")
