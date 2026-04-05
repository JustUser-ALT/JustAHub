local hub     = _G.JHub
local Win     = hub.Win
local CoreGui = hub.CoreGui

local ITEM_FINDER_URL = "https://raw.githubusercontent.com/JustUser-ALT/JustAHub/main/ItemFinder.lua"

local FinderSideTab = Win:Tab({ Title = "Finder", Icon = "search" })

local FinderMulti = FinderSideTab:MultiSection({
    Title     = "Tools",
    Desc      = "Item Finder  •  Blueprints",
    Icon      = "package",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local ItemTab = FinderMulti:Tab({ Title = "Items",      Desc = "Find & collect items",      Icon = "box",      Selected = true })
local BpTab   = FinderMulti:Tab({ Title = "Blueprints", Desc = "Auto-collect blueprint desks", Icon = "map" })

local ifLoaded = false

ItemTab:Space({})

ItemTab:Toggle({
    Title    = "Item Finder GUI",
    Desc     = "Show / hide the Item Finder window",
    Value    = false,
    Flag     = "ItemFinderGUI",
    Callback = function(v)
        if not ifLoaded then
            pcall(function() loadstring(game:HttpGet(ITEM_FINDER_URL))() end)
            ifLoaded = true
            task.wait(0.3)
        end
        if _G.ItemFinderShow then _G.ItemFinderShow(v) end
    end,
})

ItemTab:Space({})

local BP_COLOR = Color3.fromRGB(13, 105, 172)
local BP_SIZE  = Vector3.new(1.66, 0.48, 0.34)
local BP_MESH  = "60791940"

local function findBlueprintDesks()
    local desks = {}
    for _, d in ipairs(workspace:GetDescendants()) do
        if not(d:IsA("BasePart") or d:IsA("MeshPart") or d:IsA("UnionOperation")) then continue end
        local cd = d:FindFirstChildOfClass("ClickDetector"); if not cd then continue end
        local cDiff = math.abs(d.Color.R-BP_COLOR.R)+math.abs(d.Color.G-BP_COLOR.G)+math.abs(d.Color.B-BP_COLOR.B)
        if cDiff > 0.05 then continue end
        if (d.Size - BP_SIZE).Magnitude > 0.3 then continue end
        local sm = d:FindFirstChildOfClass("SpecialMesh")
        if not sm or not tostring(sm.MeshId):find(BP_MESH) then continue end
        table.insert(desks, { part=d, cd=cd })
    end
    return desks
end

local function bpSafeTP(part)
    local h = hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not h then return end
    h.CFrame = part.CFrame * CFrame.new(0, 6, 2)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end); task.wait(0.15)
    h.CFrame = part.CFrame * CFrame.new(0, 3, 1.5)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end); task.wait(0.15)
end

local bpRunning = false

BpTab:Space({})

BpTab:Toggle({
    Title    = "Auto Blueprints",
    Desc     = "Cycle through all blueprint desks continuously",
    Value    = false,
    Flag     = "AutoBlueprints",
    Callback = function(v)
        bpRunning = v
        if not v then hub:Notify("Blueprints", "Stopped", "check", 2); return end
        task.spawn(function()
            while bpRunning do
                local h = hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if h then
                    local origCF = h.CFrame
                    for _, desk in ipairs(findBlueprintDesks()) do
                        if not bpRunning then break end
                        bpSafeTP(desk.part); pcall(fireclickdetector, desk.cd); task.wait(0.35)
                    end
                    local h2 = hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if h2 then h2.CFrame = origCF * CFrame.new(0,4,0); pcall(function() h2.AssemblyLinearVelocity=Vector3.zero end) end
                end
                task.wait(2)
            end
        end)
        hub:Notify("Blueprints", "Auto Blueprints started", "map", 3)
    end,
})

BpTab:Space({})

BpTab:Button({
    Title    = "Collect Once",
    Desc     = "Single pass through all blueprint desks",
    Icon     = "map",
    Callback = function()
        local h = hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local origCF = h.CFrame
        local desks = findBlueprintDesks()
        if #desks == 0 then hub:Notify("Blueprints", "No desks found", "info", 3); return end
        task.spawn(function()
            for _, desk in ipairs(desks) do bpSafeTP(desk.part); pcall(fireclickdetector, desk.cd); task.wait(0.35) end
            local h2 = hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if h2 then h2.CFrame = origCF * CFrame.new(0,4,0); pcall(function() h2.AssemblyLinearVelocity=Vector3.zero end) end
            hub:Notify("Blueprints", "Done! ("..#desks.." desks)", "check", 3)
        end)
    end,
})

hub:Notify("Finder", "Finder tab loaded", "search", 3)
