local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StatsModule = require(ReplicatedStorage.Shared.StatsModule)

local forms = {
    [1] = "Novice",
    [10] = "Apprentice",
    [25] = "Martial",
    [50] = "Elite",
    [100] = "Grandmaster"
}

local orderedThresholds = {}
for threshold, formName in pairs(forms) do
    table.insert(orderedThresholds, {threshold = threshold, formName = formName})
end

table.sort(orderedThresholds, function(a, b)
    return a.threshold < b.threshold
end)

local humanoidDescriptions = ServerStorage:WaitForChild("HumanoidDescriptions")

local formStats = {
    Novice = {walkSpeed = 16, jumpPower = 50, maxHealth = 100},
    Apprentice = {walkSpeed = 18, jumpPower = 55, maxHealth = 150},
    Martial = {walkSpeed = 20, jumpPower = 60, maxHealth = 250},
    Elite = {walkSpeed = 22, jumpPower = 65, maxHealth = 400},
    Grandmaster = {walkSpeed = 24, jumpPower = 70, maxHealth = 600}
}

local function applyForm(player, character, levelValue)
    local targetForm
    for _, data in ipairs(orderedThresholds) do
        if levelValue >= data.threshold then
            targetForm = data.formName
        end
    end

    if not targetForm then
        return
    end

    if player:GetAttribute("CurrentForm") == targetForm then
        return
    end

    local newForm = ServerStorage.CharacterForms:FindFirstChild(targetForm)
    if not newForm then
        return
    end

    local clone = newForm:Clone()
    clone.Name = player.Name
    local root = clone:FindFirstChild("HumanoidRootPart")
    if root then
        clone.PrimaryPart = root
    end

    local cf
    if character.PrimaryPart then
        cf = character.PrimaryPart.CFrame
    end

    character:Destroy()
    clone.Parent = workspace

    if clone.PrimaryPart and cf then
        clone:SetPrimaryPartCFrame(cf)
    end

    local humanoid = clone:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local description = humanoidDescriptions:FindFirstChild(targetForm)
        if description then
            humanoid:ApplyDescription(description)
        end

        local stats = formStats[targetForm]
        if stats then
            humanoid.WalkSpeed = stats.walkSpeed
            humanoid.JumpPower = stats.jumpPower
            humanoid.MaxHealth = stats.maxHealth
            humanoid.Health = humanoid.MaxHealth
        end
    end

    player.Character = clone
    player:SetAttribute("CurrentForm", targetForm)
end

Players.PlayerAdded:Connect(function(player)
    player:SetAttribute("CurrentForm", nil)
    StatsModule.Setup(player)

    player.CharacterAdded:Connect(function(character)
        local leaderstats = player:WaitForChild("leaderstats")
        local level = leaderstats:WaitForChild("Level")

        applyForm(player, character, level.Value)

        level.Changed:Connect(function()
            if player.Character then
                applyForm(player, player.Character, level.Value)
            end
        end)
    end)
end)
