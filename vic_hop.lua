--[[
  Vic Hop v1.1 — Bee Swarm Simulator
  Server hop: перебор серверов в поисках Vicious Bee
  При нахождении босса — скрипт останавливается.
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local GAME_ID = 1537690962 -- Bee Swarm Simulator
local BOSS_NAME = "Vicious Bee"
local CHECK_INTERVAL = 3
local MAX_PLAYERS_CHECK = 50

local player = Players.LocalPlayer
local checkedServers = {}

-- Проверка: есть ли Vicious Bee на текущем сервере
local function findBoss()
    for _, obj in workspace:GetDescendants() do
        if obj:IsA("Model") and obj.Name == BOSS_NAME then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
    end
    return false
end

-- Получение списка публичных серверов
local function fetchServers(cursor)
    local url = "https://games.roblox.com/v1/games/"
        .. GAME_ID
        .. "/servers/Public?limit=100"
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local ok, res = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if ok then
        return HttpService:JSONDecode(res)
    end
    return nil
end

-- Функция server hop
local function startHop()
    print("[Vic Hop] Поиск Vicious Bee...")

    -- Сначала проверим текущий сервер
    if findBoss() then
        print("[Vic Hop] Vicious Bee найден на текущем сервере!")
        return
    end

    while true do
        local data = fetchServers()
        if not data or not data.data then
            warn("[Vic Hop] Ошибка получения списка серверов")
            task.wait(CHECK_INTERVAL)
            continue
        end

        for _, server in ipairs(data.data) do
            if checkedServers[server.id] then
                continue
            end
            checkedServers[server.id] = true

            if server.playing >= server.maxPlayers then
                continue -- сервер полный, пропускаем
            end

            print("[Vic Hop] Телепорт на сервер:", server.id)

            TeleportService:TeleportToPlaceInstance(
                GAME_ID,
                server.id,
                player
            )
            return -- после телепорта скрипт на этом сервере завершится
        end

        task.wait(CHECK_INTERVAL)
    end
end

startHop()
