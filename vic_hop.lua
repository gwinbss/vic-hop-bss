-- Vic Hop v1.1 — Bee Swarm Simulator
-- Server Hop: автоматический переход между серверами

repeat wait() until game:IsLoaded()

local VicHop = {}
VicHop.running = true
VicHop.interval = 5 -- секунд между серверами

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local placeId = game.PlaceId

function VicHop:getServers()
    local success, result = pcall(function()
        return TeleportService:GetTeleportAsync(placeId, player, {
            MaxPlayers = 50,
            IgnorePlayerIds = {player.UserId}
        })
    end)
    if success then
        return result
    end
    return nil
end

function VicHop:hop()
    local servers = self:getServers()
    if not servers or #servers == 0 then
        warn("[VicHop] Нет доступных серверов")
        return
    end
    -- Выбираем случайный сервер
    local target = servers[math.random(1, #servers)]
    print("[VicHop] Переход на сервер:", target.Id or "unknown")
    TeleportService:TeleportToPlaceInstance(placeId, target.Id, player)
end

function VicHop:start()
    print("[VicHop] Запуск Server Hop...")
    self.running = true
    while self.running do
        wait(self.interval)
        if self.running then
            self:hop()
        end
    end
end

function VicHop:stop()
    print("[VicHop] Server Hop остановлен")
    self.running = false
end

-- Автостарт
spawn(function()
    VicHop:start()
end)

-- Отключаем по нажатию F6
player:GetMouse().KeyDown:Connect(function(key)
    if key:lower() == "f6" then
        if VicHop.running then
            VicHop:stop()
        else
            VicHop:start()
        end
    end
end)

print("[VicHop] Vic Hop v1.1 загружен | F6 — вкл/выкл")
