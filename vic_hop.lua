--[[
  Vic Hop v1.1 — Bee Swarm Simulator
  Server hop: перебор серверов в поисках Vicious Bee
]]

local Players = game:GetService("Players")
local TS = game:GetService("TeleportService")
local Http = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local GAME_ID = 1537690962
local BOSS_NAME = "Vicious Bee"
local CHECK_INTERVAL = 3

local player = Players.LocalPlayer
local checked = {}

local function notify(title, text, duration)
    duration = duration or 5
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

-- Поиск Vicious Bee на сервере
local function hasBoss()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == BOSS_NAME then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
    end
    return false
end

-- Получение списка серверов
local function getServers(cursor)
    local url = "https://games.roblox.com/v1/games/" .. GAME_ID .. "/servers/Public?limit=100"
    if cursor then url = url .. "&cursor=" .. cursor end
    local ok, res = pcall(Http.GetAsync, Http, url)
    if ok then
        return Http:JSONDecode(res)
    end
    return nil
end

-- Основной цикл
notify("Vic Hop", "Начинаю поиск Vicious Bee...", 3)
print("[Vic Hop] Поиск Vicious Bee...")

if hasBoss() then
    notify("Vic Hop", "Vicious Bee уже на этом сервере!", 5)
    print("[Vic Hop] Vicious Bee найден на текущем сервере!")
    return
end

while true do
    local data = getServers()
    if not data or not data.data then
        warn("[Vic Hop] Не удалось получить список серверов")
        wait(CHECK_INTERVAL)
        continue
    end

    print("[Vic Hop] Получено серверов:", #data.data)

    for _, sv in ipairs(data.data) do
        if checked[sv.id] then continue end
        checked[sv.id] = true

        if sv.playing >= sv.maxPlayers then continue end

        print("[Vic Hop] Телепорт на сервер:", sv.id)
        notify("Vic Hop", "Перехожу на сервер " .. sv.id, 2)
        TS:TeleportToPlaceInstance(GAME_ID, sv.id, player)
        return
    end

    wait(CHECK_INTERVAL)
end
