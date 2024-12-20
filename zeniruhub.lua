local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

if _G.ScriptRunning then
    _G.ToggleConnection:Disconnect()
    _G.ScriptRunning = false
end

_G.ScriptRunning = true

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local teleportPlayer = false
local toggle = false
local mobsFolder = Workspace:WaitForChild("Mobs")
local damageRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DamageMob")

local selectedMobLevel = 1
local removePlayerLevelRestriction = false

local playerLevel = tonumber(player:WaitForChild("leaderstats"):WaitForChild("Level").Value)

local function getMobLevel(mob)
    local mobNameText = mob:FindFirstChild("BillboardGui")
        and mob.BillboardGui:FindFirstChild("Canvas")
        and mob.BillboardGui.Canvas:FindFirstChild("MobName")
        and mob.BillboardGui.Canvas.MobName.Text

    if mobNameText then
        local startIndex, endIndex = mobNameText:find("%[%d+%]")
        if startIndex and endIndex then
            local levelString = mobNameText:sub(startIndex + 1, endIndex - 1)
            return tonumber(levelString)
        end
    end
    return nil
end

local function isMobAlive(mob)
    local health = mob:FindFirstChild("Health") and mob.Health.Value
    return health and health > 0
end

local function findNextTarget()
    for _, mob in pairs(mobsFolder:GetChildren()) do
        local mobLevel = getMobLevel(mob)
        if mobLevel and mobLevel >= selectedMobLevel and (removePlayerLevelRestriction or mobLevel <= playerLevel) and isMobAlive(mob) then
            return mob
        end
    end
    return nil
end

local currentPlatform = nil

local function createPlatform(position)
    if currentPlatform then
        currentPlatform:Destroy()
    end

    local platform = Instance.new("Part")
    platform.Size = Vector3.new(3, 1, 3)
    platform.Position = position + Vector3.new(0, -0.5, 0)
    platform.Anchored = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright yellow")
    platform.Parent = Workspace

    currentPlatform = platform

    return platform
end

local function teleportToMob(mob)
    if teleportPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local mobPosition = mob:FindFirstChild("HumanoidRootPart") and mob.HumanoidRootPart.Position
        if mobPosition then
            local targetPosition = mobPosition + Vector3.new(0, 15, 0)
            rootPart.CFrame = CFrame.new(targetPosition)
            createPlatform(targetPosition)
        end
    end
end

local function attackMob(mob)
    teleportToMob(mob)
    while isMobAlive(mob) and toggle do
        damageRemote:InvokeServer(mob)
        task.wait(0.1)
    end
end

local function mainLoop()
    while toggle do
        local targetMob = findNextTarget()
        if targetMob then
            attackMob(targetMob)
        else
            task.wait(0.1)
        end
    end
end

local Window = OrionLib:MakeWindow({
    Name = "zeniru hub",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "ZeniruHubConfig"
})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Enable Script",
    Default = false,
    Callback = function(Value)
        toggle = Value
        if toggle then
            OrionLib:MakeNotification({
                Name = "Script Enabled",
                Content = "The script is now running.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
            task.spawn(function() mainLoop() end)
        else
            OrionLib:MakeNotification({
                Name = "Script Disabled",
                Content = "The script has been stopped.",
                Image = "rbxassetid://4483345998",
                Time = 5
            })
        end
    end
})

MainTab:AddToggle({
    Name = "Teleport to Enemy",
    Default = false,
    Callback = function(Value)
        teleportPlayer = Value
    end
})

MainTab:AddSlider({
    Name = "Select Mob Level",
    Min = 1,
    Max = 100,
    Default = 1,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(Value)
        selectedMobLevel = Value
    end
})

MainTab:AddToggle({
    Name = "remove moblevel < playerlevel",
    Default = false,
    Callback = function(Value)
        removePlayerLevelRestriction = Value
    end
})

local MiscTab = Window:MakeTab({
    Name = "Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddButton({
    Name = "Load Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        OrionLib:MakeNotification({
            Name = "Infinite Yield Loaded",
            Content = "Infinite Yield script has been successfully loaded.",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

OrionLib:Init()
