-- Vic Hop v1.1 — Bee Swarm Simulator
-- Для Delta Executor

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
task.wait(2)

local player = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local placeId = game.PlaceId

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VicHopGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 80)
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

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 22)
toggleBtn.Position = UDim2.new(0, 10, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
toggleBtn.Text = "F6: Выключить"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

-- Server hop logic
local running = true

local function getServers()
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"
        local req = request or syn.request or http_request
        if req then
            local resp = req({Url = url, Method = "GET"})
            if resp and resp.StatusCode == 200 then
                return game:GetService("HttpService"):JSONDecode(resp.Body)
            end
        end
        return nil
    end)
    if success and result and result.data then
        local servers = {}
        for _, v in ipairs(result.data) do
            if v.playing and v.maxPlayers and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        return servers
    end
    return {}
end

local function hop()
    local servers = getServers()
    if #servers == 0 then
        status.Text = "Нет серверов"
        return
    end
    local target = servers[math.random(1, #servers)]
    status.Text = "Хоп на " .. target:sub(1, 8) .. "..."
    task.wait(0.5)
    TeleportService:TeleportToPlaceInstance(placeId, target, player)
end

local function start()
    running = true
    status.Text = "Статус: Работаю..."
    toggleBtn.Text = "F6: Выключить"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    while running do
        hop()
        for _ = 1, 5 do
            task.wait(1)
            if not running then break end
        end
    end
end

local function stop()
    running = false
    status.Text = "Статус: Остановлен"
    toggleBtn.Text = "F6: Включить"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
end

toggleBtn.MouseButton1Click:Connect(function()
    if running then stop() else spawn(start) end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if running then stop() else spawn(start) end
    end
end)

spawn(start)

print("Vic Hop v1.1 загружен! F6 — вкл/выкл | GUI в левом верхнем углу")
