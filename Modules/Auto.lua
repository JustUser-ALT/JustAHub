local hub      = _G.JHub
local Win      = hub.Win
local RS       = game:GetService("RunService")
local RStor    = game:GetService("ReplicatedStorage")
local PGui     = hub.LocalPlayer:WaitForChild("PlayerGui")

local AutoSideTab = Win:Tab({ Title = "Auto", Icon = "play-circle" })

local AutoMulti = AutoSideTab:MultiSection({
    Title     = "Automation",
    Desc      = "Chapters  •  Skins",
    Icon      = "cpu",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local ChapTab  = AutoMulti:Tab({ Title = "Chapters", Desc = "Auto chapter completion", Icon = "map",   Selected = true })
local SkinsTab = AutoMulti:Tab({ Title = "Skins",    Desc = "Skin farming utilities",  Icon = "shirt" })

-- ─ Shared helpers ────────────────────────────────────────────────────

local function hrp()
    local c = hub.LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Noclip toggle during teleports so barriers don't push the player
local noclipConn = nil
local function noclipOn()
    if noclipConn then return end
    noclipConn = RS.Stepped:Connect(function()
        local c = hub.LocalPlayer.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end
local function noclipOff()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    local c = hub.LocalPlayer.Character
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

-- Returns true if a position is too close to any threat (Piggy player / PiggyNPC bot)
local THREAT_RADIUS = 12
local function isThreatNearby(pos)
    -- Check Piggy player
    for _, p in pairs(hub.Players:GetPlayers()) do
        if p ~= hub.LocalPlayer and p.Character then
            local e = p.Character:FindFirstChild("Enemy")
            if e and e:IsA("BoolValue") and e.Value then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r and (r.Position - pos).Magnitude < THREAT_RADIUS then return true end
            end
        end
    end
    -- Check bots
    local folder = workspace:FindFirstChild("PiggyNPC")
    if folder then
        for _, m in pairs(folder:GetChildren()) do
            if m:IsA("Model") then
                local r = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
                if r and (r.Position - pos).Magnitude < THREAT_RADIUS then return true end
            end
        end
    end
    return false
end

-- Safe TP: noclip + float + threat check
-- Returns false if destination is too dangerous to approach
local function safeTP(partOrCF, avoidThreats)
    local cf = (typeof(partOrCF) == "CFrame") and partOrCF or partOrCF.CFrame
    local dest = cf.Position
    if avoidThreats and isThreatNearby(dest) then return false end
    local h = hrp(); if not h then return false end
    noclipOn()
    h.CFrame = cf * CFrame.new(0, 7, 2)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end)
    task.wait(0.15)
    h.CFrame = cf * CFrame.new(0, 3, 1.5)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end)
    task.wait(0.15)
    noclipOff()
    return true
end

local function fireCD(part)
    local function on(o)
        if not o or not o.Parent then return false end
        local cd = o:FindFirstChildOfClass("ClickDetector")
        if cd and cd.MaxActivationDistance > 0 then
            for _ = 1, 4 do pcall(fireclickdetector, cd); task.wait(0.08) end; return true
        end
    end
    if on(part) then return end
    for _, d in ipairs(part:GetDescendants()) do
        if d:IsA("ClickDetector") and d.MaxActivationDistance > 0 then
            for _ = 1, 4 do pcall(fireclickdetector, d); task.wait(0.08) end; return
        end
    end
    on(part.Parent)
end

local function vipCmd(...)
    local a = {...}
    pcall(function() RStor:WaitForChild("Remotes"):WaitForChild("VIPCommandEvent"):FireServer(unpack(a)) end)
end
local function newVote(...)
    local a = {...}
    pcall(function() RStor:WaitForChild("Remotes"):WaitForChild("NewVote"):FireServer(unpack(a)) end)
end

-- ─ Chapter helpers ────────────────────────────────────────────────────

-- Check if item is in backpack OR already equipped
local function hasItem(name)
    local b = hub.LocalPlayer:FindFirstChild("Backpack")
    local c = hub.LocalPlayer.Character
    return (b and b:FindFirstChild(name) ~= nil)
        or (c and c:FindFirstChild(name) ~= nil)
end

-- Find StringValue with given value anywhere near a part
local function svMatch(part, tool)
    for _, ch in ipairs(part:GetChildren()) do
        if ch:IsA("StringValue") and ch.Value == tool then return true end
    end
    local par = part.Parent
    if par then
        for _, ch in ipairs(par:GetChildren()) do
            if ch:IsA("StringValue") and ch.Value == tool then return true end
        end
    end
    return false
end

-- Find all clickable parts that require the given tool (StringValue primary, colorFB fallback)
local function findLocks(tool, colorFB, sizeFB)
    local results, seen = {}, {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if seen[o] then continue end
        if not (o:IsA("BasePart") or o:IsA("UnionOperation") or o:IsA("MeshPart")) then continue end
        local cd = o:FindFirstChildOfClass("ClickDetector")
        if not cd or cd.MaxActivationDistance <= 0 then continue end
        local ok = svMatch(o, tool)
        if not ok and colorFB then
            local c = o.Color
            ok = (c.R-colorFB.R)^2+(c.G-colorFB.G)^2+(c.B-colorFB.B)^2 < 0.06
            if ok and sizeFB then ok = (o.Size - sizeFB).Magnitude < 0.5 end
        end
        if ok then seen[o] = true; table.insert(results, o) end
    end
    return results
end

-- Use a tool on N matching locks. NO equip needed — just click.
-- Returns true when all locks are activated.
local function useTool(tool, count, colorFB, sizeFB, timeout)
    count   = count or 1
    timeout = timeout or 20
    if not hasItem(tool) then return false end
    local done, used, t = 0, {}, tick()
    while done < count and tick()-t < timeout do
        local locks = findLocks(tool, colorFB, sizeFB)
        for _, lock in ipairs(locks) do
            if done >= count then break end
            if not used[lock] then
                if safeTP(lock, true) then
                    fireCD(lock); task.wait(0.5)
                    used[lock] = true; done = done + 1
                end
            end
        end
        if done < count then task.wait(0.4) end
    end
    return done >= count
end

-- Collect a named item from the world (by Name on the object)
local function collectItem(name, timeout)
    timeout = timeout or 20
    if hasItem(name) then return true end
    local t = tick()
    while tick()-t < timeout do
        for _, o in ipairs(workspace:GetDescendants()) do
            if o.Name == name then
                local cd = o:FindFirstChildOfClass("ClickDetector")
                         or o:FindFirstChildOfClass("ProximityPrompt")
                if cd then
                    if safeTP(o, true) then
                        fireCD(o); task.wait(0.6)
                        if hasItem(name) then return true end
                    end
                end
            end
        end
        task.wait(0.5)
    end
    return hasItem(name)
end

-- ─ Exit watcher ──────────────────────────────────────────────────────
-- Watches for a TouchTransmitter part matching color+minSize.
-- When found, immediately TPs and fires it.

local exitWatchConn = nil
local function watchExit(color, minSz, onDone)
    if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
    local fired = false
    exitWatchConn = RS.Heartbeat:Connect(function()
        if fired then return end
        for _, o in ipairs(workspace:GetDescendants()) do
            if not (o:IsA("BasePart") or o:IsA("UnionOperation")) then continue end
            if not o:FindFirstChildOfClass("TouchTransmitter") then continue end
            local c = o.Color
            local cd = (c.R-color.R)^2+(c.G-color.G)^2+(c.B-color.B)^2 < 0.05
            local sd = not minSz or (o.Size.X >= minSz.X and o.Size.Y >= minSz.Y)
            if cd and sd then
                fired = true
                if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
                task.wait(0.2)
                local h = hrp(); if not h then return end
                noclipOn()
                h.CFrame = o.CFrame * CFrame.new(0, 2, 1)
                for _ = 1, 80 do
                    if not o.Parent then break end
                    pcall(firetouchinterest, h, o, 0); task.wait(0.04)
                    pcall(firetouchinterest, h, o, 1); task.wait(0.02)
                end
                noclipOff()
                hub:Notify("Auto", "Exit reached!", "check", 3)
                if onDone then onDone() end
                return
            end
        end
    end)
end

local function stopExitWatcher()
    if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
end

-- ─ Chapter definitions ───────────────────────────────────────────────

local CHAPTERS = {
    House = {
        mapName   = "House",
        exitColor = Color3.fromRGB(248, 248, 248),
        exitMinSz = Vector3.new(6, 8, 1),
        run = function(running)
            -- Tools: Hammer, Wrench, KeyCode — in ANY order, all must succeed
            local tools = {"Hammer", "Wrench", "KeyCode"}
            for _, tool in ipairs(tools) do
                if not running() then return end
                hub:Notify("House", "Collecting "..tool.."...", "package", 2)
                if collectItem(tool) then
                    useTool(tool, 1)
                else
                    hub:Notify("House", "Could not find "..tool, "alert-circle", 3)
                end
                task.wait(0.3)
            end
            -- Gears
            for _, tool in ipairs({"GreenGear", "RedGear"}) do
                if not running() then return end
                hub:Notify("House", "Collecting "..tool.."...", "package", 2)
                if collectItem(tool) then useTool(tool, 1) end
                task.wait(0.3)
            end
            -- WhiteKey spawns later
            if not running() then return end
            hub:Notify("House", "Waiting for White Key...", "clock", 3)
            if collectItem("WhiteKey", 90) then
                useTool("WhiteKey", 1)
            else
                hub:Notify("House", "White Key timed out", "x", 3)
            end
        end,
    },
}

-- ─ State ─────────────────────────────────────────────────────────────
local selectedChapter = "House"
local selectedMode    = "Bot"
local chapRunning     = false
local autoPlayOn      = false
local autoEscapeOn    = false

-- ─ Auto Play ─────────────────────────────────────────────────────────
local LOBBY_STATES = { IDLE=1, PLAY_MENU=2, VOTING=3, RESULTS=4 }

local function getLobbyState()
    local ok, Main = pcall(function() return PGui:WaitForChild("MainMenu", 2) end)
    if not ok or not Main then return nil end
    local play = Main:FindFirstChild("PlayMenu")
    if not play or not play.Visible then return LOBBY_STATES.IDLE end
    local vote = play:FindFirstChild("VotingMenu")
    if not vote or not vote.Visible then return LOBBY_STATES.PLAY_MENU end
    local results = vote:FindFirstChild("ResultsMenu")
    if results and results.Visible then return LOBBY_STATES.RESULTS end
    local modeVote = vote:FindFirstChild("ModeVoting")
    if modeVote and modeVote.Visible then return LOBBY_STATES.VOTING end
    return LOBBY_STATES.PLAY_MENU
end

local function clickPlayButton()
    pcall(function()
        local btn = PGui.MainMenu.MainScreen.CenterFrame.CenterButtons.Play
        -- Works on both PC and mobile
        local veh = btn.MouseButton1Click
        veh:Fire()
    end)
end

local function runAutoPlayLoop()
    while autoPlayOn do
        local state = getLobbyState()
        if state == nil then
            task.wait(2); continue
        end
        if state == LOBBY_STATES.IDLE then
            clickPlayButton()
            task.wait(2)
        elseif state == LOBBY_STATES.PLAY_MENU then
            clickPlayButton()
            task.wait(1.5)
        elseif state == LOBBY_STATES.RESULTS then
            vipCmd("SkipTimer", true)
            task.wait(1.5)
        elseif state == LOBBY_STATES.VOTING then
            vipCmd("SetMap", selectedChapter)
            task.wait(0.3)
            vipCmd("SetMode", selectedMode)
            task.wait(0.3)
            vipCmd("SkipTimer", true)
            task.wait(0.3)
            -- Fallback votes (no VIP)
            newVote("Map",    selectedChapter)
            newVote("Piggy",  selectedMode)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end

-- ─ Chapters UI ───────────────────────────────────────────────────────

ChapTab:Space({})

ChapTab:Dropdown({
    Title    = "Chapter",
    Desc     = "Select which chapter to run",
    Values   = { "House" },
    Multi    = false,
    Value    = "House",
    Flag     = "SelectedChapter",
    Callback = function(v)
        selectedChapter = v
        if autoEscapeOn then
            stopExitWatcher()
            local ch = CHAPTERS[v]
            if ch then watchExit(ch.exitColor, ch.exitMinSz) end
        end
    end,
})

ChapTab:Space({})

ChapTab:Dropdown({
    Title    = "Mode",
    Desc     = "Game mode to vote for",
    Values   = { "Bot", "Player", "PlayerBot", "Swarm", "Infection", "Traitor", "Tag" },
    Multi    = false,
    Value    = "Bot",
    Flag     = "SelectedMode",
    Callback = function(v) selectedMode = v end,
})

ChapTab:Space({})

ChapTab:Toggle({
    Title    = "Auto Play",
    Desc     = "Auto-selects map/mode and skips timers in lobby",
    Value    = false,
    Flag     = "AutoPlay",
    Callback = function(v)
        autoPlayOn = v
        if v then
            task.spawn(runAutoPlayLoop)
            hub:Notify("Auto", "Auto Play on  •  "..selectedChapter, "play", 3)
        else
            hub:Notify("Auto", "Auto Play stopped", "square", 2)
        end
    end,
})

ChapTab:Space({})

ChapTab:Toggle({
    Title    = "Auto Escape",
    Desc     = "Watches for exit block and teleports to it instantly",
    Value    = false,
    Flag     = "AutoEscape",
    Callback = function(v)
        autoEscapeOn = v
        if v then
            local ch = CHAPTERS[selectedChapter]
            if ch then
                watchExit(ch.exitColor, ch.exitMinSz)
                hub:Notify("Auto", "Watching for exit — "..selectedChapter, "map-pin", 3)
            end
        else
            stopExitWatcher()
            hub:Notify("Auto", "Exit watcher stopped", "square", 2)
        end
    end,
})

ChapTab:Space({})

-- Toggle (not button) so it can be stopped
ChapTab:Toggle({
    Title    = "Run Chapter",
    Desc     = "Toggle ON to start, OFF to stop",
    Value    = false,
    Flag     = "RunChapter",
    Callback = function(v)
        chapRunning = v
        if not v then
            stopExitWatcher()
            hub:Notify("Auto", "Chapter stopped", "square", 2)
            return
        end
        local ch = CHAPTERS[selectedChapter]
        if not ch then hub:Notify("Auto", "Chapter not found", "x", 3); return end
        -- Start exit watcher alongside the sequence
        watchExit(ch.exitColor, ch.exitMinSz, function()
            chapRunning = false
        end)
        hub:Notify("Auto", "Starting "..selectedChapter.."...", "play", 3)
        task.spawn(function()
            pcall(ch.run, function() return chapRunning end)
            chapRunning = false
            hub:Notify("Auto", selectedChapter.." done", "check", 4)
        end)
    end,
})

-- ─ Skins Tab ─────────────────────────────────────────────────────────
SkinsTab:Space({})

SkinsTab:Paragraph({
    Title = "Skins",
    Desc  = "Skin automation coming soon.",
})

hub:Notify("Auto", "Auto tab loaded", "play-circle", 3)
