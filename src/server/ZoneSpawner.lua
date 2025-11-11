local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = name
        folder.Parent = parent
    end
    return folder
end

local templateStorage = ensureFolder(ServerStorage, "ZoneTemplates")

local function spawnFromTemplates(zone, baseHP)
    local enemiesFolder = zone:FindFirstChild("Enemies")
    local activeEnemies = ensureFolder(zone, "ActiveEnemies")
    local enemyStorage = ensureFolder(templateStorage, zone.Name .. "Enemies")

    if enemiesFolder then
        for _, template in ipairs(enemiesFolder:GetChildren()) do
            local clone = template:Clone()
            local body = clone:FindFirstChild("Body")
            if body then
                clone.PrimaryPart = body
            end
            local humanoid = clone:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local level = tonumber(string.match(template.Name, "%d+")) or 1
                humanoid.MaxHealth = baseHP * level
                humanoid.Health = humanoid.MaxHealth
            end
            clone.Parent = activeEnemies
            template.Parent = enemyStorage
        end
    end

    local bossesFolder = zone:FindFirstChild("Bosses")
    local activeBosses = ensureFolder(zone, "ActiveBosses")
    local bossStorage = ensureFolder(templateStorage, zone.Name .. "Bosses")

    if bossesFolder then
        for _, template in ipairs(bossesFolder:GetChildren()) do
            local clone = template:Clone()
            local body = clone:FindFirstChild("Body")
            if body then
                clone.PrimaryPart = body
            end
            clone.Parent = activeBosses
            template.Parent = bossStorage
        end
    end
end

local zones = {
    GrassField = 20,
    Forest = 50,
    CommercialCity = 100,
    SnowZone = 200,
    Desert = 400,
    Volcano = 800,
    TempleOfMasters = 1500
}

for name, hp in pairs(zones) do
    local zonesFolder = Workspace:WaitForChild("Zones")
    local zone = zonesFolder:FindFirstChild(name)
    if zone then
        spawnFromTemplates(zone, hp)
    end
end
