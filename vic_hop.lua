--[[
  Vic Hop v1.1 — Bee Swarm Simulator
  Delta Executor compatible
]]

local player = game:GetService("Players").LocalPlayer
local TS = game:GetService("TeleportService")
local GAME_ID = 1537690962
local BOSS_NAMES = {"Vicious Bee", "ViciousBee"}
local CHECKED = {}

-- Создаём GUI для вывода статуса
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "VicHopGui"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 50)
frame.Position = UDim2.new(0.5, -150, 0, 50)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
local txt = Instance.new("TextLabel", frame)
txt.Size = UDim2.new(1, 0, 1, 0)
txt.BackgroundTransparency = 1
txt.TextColor3 = Color3.new(1, 1, 1)
txt.TextScaled = true
txt.Font = Enum.Font.SourceSansBold
txt.Text = "Vic Hop: запуск..."

local function log(msg)
    txt.Text = msg
    print("[Vic Hop]", msg)
end

-- Поиск босса
local function hasBoss()
    for _, name_ in ipairs(BOSS_NAMES) do
        for _, obj in workspace:GetDescendants() do
            if obj:IsA("Model") and obj.Name == name_ then
                local hum = obj:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- HTTP-запрос (подходит для Delta и большинства мобильных экзекуторов)
local function httpGet(url)
    -- Пробуем разные методы HTTP
    local methods = {
        function()
            return game:GetService("HttpService"):GetAsync(url)
        end,
        function()
            return syn and syn.request and syn.request({Url=url, Method="GET"}).Body
        end,
        function()
            return request and request({Url=url, Method="GET"}).Body
        end,
        function()
            return http and http.request and http.request("GET", url)
        end
    }
    for _, method in ipairs(methods) do
        local ok, res = pcall(method)
        if ok and res then
            return res
        end
    end
    return nil
end

-- Получение списка серверов
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. GAME_ID .. "/servers/Public?limit=100"
    if cursor then url = url .. "&cursor=" .. cursor end
    local data = httpGet(url)
    if data then
        return game:GetService("HttpService"):JSONDecode(data)
    end
    return nil
end

-- Старт
log("Поиск Vicious Bee...")

if hasBoss() then
    log("Vicious Bee уже на этом сервере!")
    return
end

while true do
    local data = getServers()
    if not data or not data.data then
        log("Ошибка: не получен список серверов")
        wait(3)
        continue
    end

    log("Серверов: " .. #data.data)

    for _, sv in ipairs(data.data) do
        if CHECKED[sv.id] then continue end
        CHECKED[sv.id] = true
        if sv.playing >= sv.maxPlayers then continue end

        log("Хоп на " .. sv.id)
        TS:TeleportToPlaceInstance(GAME_ID, sv.id, player)
        return
    end

    wait(3)
end
