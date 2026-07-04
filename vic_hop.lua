-- Vic Hop v1.1 — Bee Swarm Simulator
-- Server Hop: автоматический переход между серверами
-- Вставь этот скрипт в Delta Executor

repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

local VicHop = {}
VicHop.running = true
VicHop.interval = 5
VicHop.placeId = game.PlaceId
VicHop.player = game:GetService("Players").LocalPlayer

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

function VicHop:getServers()
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100", self.placeId)

    local success, result = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync(url))
    end)

    if success and result and result.data then
        local servers = {}
        for _, v in ipairs(result.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        return servers
    end
    return nil
end

function VicHop:hop()
    local servers = self:getServers()
    if not servers or #servers == 0 then
        warn("[VicHop] Нет доступных серверов")
        return
    end

    local target = servers[math.random(1, #servers)]
    print("[VicHop] Переход на сервер:", target)
    TeleportService:TeleportToPlaceInstance(self.placeId, target, self.player)
end

function VicHop:start()
    if self.running then return end
    print("[VicHop] Запуск Server Hop...")
    self.running = true
    while self.running do
        self:hop()
        for _ = 1, self.interval do
            task.wait(1)
            if not self.running then break end
        end
    end
end

function VicHop:stop()
    print("[VicHop] Server Hop остановлен")
    self.running = false
end

spawn(function()
    task.wait(1)
    VicHop:start()
end)

VicHop.player:GetMouse().KeyDown:Connect(function(key)
    if key:lower() == "f6" then
        if VicHop.running then
            VicHop:stop()
        else
            VicHop:start()
        end
    end
end)

print([[

  Vic Hop v1.1 загружен!
  Server Hop запущен автоматически
  F6 — вкл/выкл
]])
