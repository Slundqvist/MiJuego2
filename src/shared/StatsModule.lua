local StatsModule = {}

function StatsModule.Setup(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local Level = Instance.new("IntValue")
    Level.Name = "Level"
    Level.Value = 1
    Level.Parent = leaderstats

    local XP = Instance.new("IntValue")
    XP.Name = "XP"
    XP.Value = 0
    XP.Parent = leaderstats
end

return StatsModule
