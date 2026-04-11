local hub = _G.JHub
local Win = hub.Win
local RS  = game:GetService("RunService")
local RStorage = game:GetService("ReplicatedStorage")
local PGui = hub.LocalPlayer:WaitForChild("PlayerGui")

local AutoSideTab = Win:Tab({ Title = "Auto", Icon = "play-circle" })

local AutoMulti = AutoSideTab:MultiSection({
    Title     = "Automation",
    Desc      = "Chapters  •  Skins",
    Icon      = "cpu",
    Box       = true,
    BoxBorder = true,
    Opened    = true,
})

local ChapTab  = AutoMulti:Tab({ Title = "Chapters", Desc = "Auto chapter completion", Icon = "map",    Selected = true })
local SkinsTab = AutoMulti:Tab({ Title = "Skins",    Desc = "Skin farming utilities",  Icon = "shirt" })

-- ─ Shared helpers ────────────────────────────────────────────────────
local function hrp()
    local c = hub.LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function safeTP(part)
    local h = hrp(); if not h then return end
    local cf = (typeof(part) == "CFrame") and part or part.CFrame
    h.CFrame = cf * CFrame.new(0, 7, 2)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end); task.wait(0.12)
    h.CFrame = cf * CFrame.new(0, 3, 1.5)
    pcall(function() h.AssemblyLinearVelocity = Vector3.zero end); task.wait(0.12)
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
    local args = {...}
    pcall(function()
        RStorage:WaitForChild("Remotes"):WaitForChild("VIPCommandEvent"):FireServer(unpack(args))
    end)
end

local function voteMap(mapName)
    pcall(function()
        RStorage:WaitForChild("Remotes"):WaitForChild("NewVote"):FireServer("Map", mapName)
    end)
end

-- ─ Item finder helpers (shared with Chapter Engine pattern) ──────────
local function svMatch(part, tool)
    for _, c in ipairs(part:GetChildren()) do
        if c:IsA("StringValue") and c.Value == tool then return true end
    end
    local par = part.Parent
    if par then
        for _, c in ipairs(par:GetChildren()) do
            if c:IsA("StringValue") and c.Value == tool then return true end
        end
    end
    return false
end

local function findInteractives(tool, colorFB)
    local results, seen = {}, {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if seen[o] then continue end
        if not(o:IsA("BasePart") or o:IsA("UnionOperation") or o:IsA("MeshPart")) then continue end
        local cd = o:FindFirstChildOfClass("ClickDetector")
        if not cd or cd.MaxActivationDistance <= 0 then continue end
        local ok = svMatch(o, tool)
        if not ok and colorFB then
            local c = o.Color
            ok = (c.R-colorFB.R)^2+(c.G-colorFB.G)^2+(c.B-colorFB.B)^2 < 0.06
        end
        if ok then seen[o] = true; table.insert(results, o) end
    end
    return results
end

local function collectItem(name, timeout)
    timeout = timeout or 15
    local function inInv()
        local b = hub.LocalPlayer:FindFirstChild("Backpack"); local c = hub.LocalPlayer.Character
        return (b and b:FindFirstChild(name)) or (c and c:FindFirstChild(name))
    end
    if inInv() then return true end
    local t = tick()
    while tick()-t < timeout do
        for _, o in ipairs(workspace:GetDescendants()) do
            if o.Name == name then
                local cd = o:FindFirstChildOfClass("ClickDetector") or o:FindFirstChildOfClass("ProximityPrompt")
                if cd then safeTP(o); fireCD(o); task.wait(0.6); if inInv() then return true end end
            end
        end
        task.wait(0.4)
    end
    return inInv()
end

local function useItem(tool, count, colorFB, timeout)
    count = count or 1; timeout = timeout or 18
    -- equip
    local c = hub.LocalPlayer.Character
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if hum and not c:FindFirstChild(tool) then
        local b = hub.LocalPlayer:FindFirstChild("Backpack")
        local t = b and b:FindFirstChild(tool)
        if t and t:IsA("Tool") then hum:EquipTool(t); task.wait(0.3) end
    end
    local done, used, t = 0, {}, tick()
    while done < count and tick()-t < timeout do
        local parts = findInteractives(tool, colorFB)
        for _, part in ipairs(parts) do
            if done >= count then break end
            if not used[part] then
                safeTP(part); fireCD(part); task.wait(0.5)
                used[part] = true; done = done + 1
            end
        end
        if done < count then task.wait(0.4) end
    end
    return done >= count
end

-- ─ Exit watcher ──────────────────────────────────────────────────────
local exitWatchConn = nil
local function watchExit(color, minSz)
    if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
    local fired = false
    exitWatchConn = RS.Heartbeat:Connect(function()
        if fired then return end
        for _, o in ipairs(workspace:GetDescendants()) do
            if (o:IsA("BasePart") or o:IsA("UnionOperation")) and o:FindFirstChildOfClass("TouchTransmitter") then
                local c = o.Color
                local cd = (c.R-color.R)^2+(c.G-color.G)^2+(c.B-color.B)^2 < 0.05
                local sd = minSz and (o.Size.X >= minSz.X and o.Size.Y >= minSz.Y) or true
                if cd and sd then
                    fired = true
                    if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
                    task.wait(0.2)
                    local h = hrp(); if not h then return end
                    h.CFrame = o.CFrame * CFrame.new(0, 2, 1)
                    for _ = 1, 80 do
                        if not o.Parent then break end
                        pcall(firetouchinterest, h, o, 0); task.wait(0.04)
                        pcall(firetouchinterest, h, o, 1); task.wait(0.02)
                    end
                    hub:Notify("Auto", "Exit triggered!", "check", 3)
                    return
                end
            end
        end
    end)
end

-- ─ Chapter definitions ───────────────────────────────────────────────
local CHAPTERS = {
    House = {
        mapName = "House",
        exitColor = Color3.fromRGB(248, 248, 248),
        exitMinSize = Vector3.new(6, 8, 1),
        run = function()
            -- Hammer, Wrench, KeyCode in any order
            collectItem("Hammer");  useItem("Hammer")
            collectItem("Wrench");  useItem("Wrench")
            collectItem("KeyCode"); useItem("KeyCode")
            -- GreenGear + RedGear
            collectItem("GreenGear"); useItem("GreenGear")
            collectItem("RedGear");   useItem("RedGear")
            -- WhiteKey spawns after gears — wait for it
            hub:Notify("House", "Waiting for White Key...", "clock", 3)
            collectItem("WhiteKey", 60)
            useItem("WhiteKey")
        end,
    },
}

-- ─ State ─────────────────────────────────────────────────────────────
local selectedChapter = "House"
local autoEscapeOn    = false
local autoPlayOn      = false
local autoPlayConn    = nil

-- ─ Auto Escape (exit watcher toggle) ─────────────────────────────────
local function startAutoEscape()
    local ch = CHAPTERS[selectedChapter]
    if not ch then return end
    watchExit(ch.exitColor, ch.exitMinSize)
    hub:Notify("Auto", "Exit watcher active for "..selectedChapter, "map-pin", 3)
end

local function stopAutoEscape()
    if exitWatchConn then exitWatchConn:Disconnect(); exitWatchConn = nil end
end

-- ─ Auto Play loop ─────────────────────────────────────────────────────
local function runAutoPlay()
    while autoPlayOn do
        local Main     = PGui:FindFirstChild("MainMenu")
        if not Main then task.wait(1); continue end

        local PlayMenu = Main:FindFirstChild("PlayMenu")
        local VoteMenu = PlayMenu and PlayMenu:FindFirstChild("VotingMenu")

        -- Wait for VotingMenu to become visible
        if not VoteMenu or not VoteMenu.Visible then
            -- Click Play button to open play menu
            pcall(function()
                local playBtn = Main.MainScreen.CenterFrame.CenterButtons.Play
                playBtn.MouseButton1Click:Fire()
            end)
            task.wait(2); continue
        end

        -- Results phase: skip timer
        local Results = VoteMenu:FindFirstChild("ResultsMenu")
        if Results and Results.Visible then
            vipCmd("SkipTimer", true)
            task.wait(1); continue
        end

        -- Voting phase
        local ModeVote = VoteMenu:FindFirstChild("ModeVoting")
        if ModeVote and ModeVote.Visible then
            vipCmd("SetMap", selectedChapter)
            task.wait(0.3)
            vipCmd("SkipTimer", true)
            task.wait(1); continue
        end

        -- Fallback: just vote
        voteMap(selectedChapter)
        task.wait(2)
    end
end

-- ─ Chapters UI ───────────────────────────────────────────────────────
ChapTab:Space({})

ChapTab:Dropdown({
    Title    = "Chapter",
    Desc     = "Select chapter to auto-complete",
    Values   = { "House" },
    Multi    = false,
    Value    = "House",
    Flag     = "SelectedChapter",
    Callback = function(v)
        selectedChapter = v
        if autoEscapeOn then stopAutoEscape(); startAutoEscape() end
    end,
})

ChapTab:Space({})

ChapTab:Toggle({
    Title    = "Auto Play",
    Desc     = "Auto-selects map and skips timers in lobby",
    Value    = false,
    Flag     = "AutoPlay",
    Callback = function(v)
        autoPlayOn = v
        if v then
            task.spawn(runAutoPlay)
            hub:Notify("Auto", "Auto Play enabled for "..selectedChapter, "play", 3)
        else
            hub:Notify("Auto", "Auto Play stopped", "square", 2)
        end
    end,
})

ChapTab:Space({})

ChapTab:Toggle({
    Title    = "Auto Escape",
    Desc     = "Watches for exit block and teleports to it",
    Value    = false,
    Flag     = "AutoEscape",
    Callback = function(v)
        autoEscapeOn = v
        if v then startAutoEscape()
        else      stopAutoEscape() end
    end,
})

ChapTab:Space({})

ChapTab:Button({
    Title    = "Run Chapter",
    Desc     = "Runs the full selected chapter sequence",
    Icon     = "play",
    Callback = function()
        local ch = CHAPTERS[selectedChapter]
        if not ch then hub:Notify("Auto", "Chapter not found", "x", 3); return end
        if autoEscapeOn then startAutoEscape() end
        hub:Notify("Auto", "Starting "..selectedChapter.."...", "play", 3)
        task.spawn(function()
            pcall(ch.run)
            hub:Notify("Auto", selectedChapter.." sequence done", "check", 4)
        end)
    end,
})

-- ─ Skins UI ──────────────────────────────────────────────────────────
SkinsTab:Space({})

SkinsTab:Paragraph({
    Title = "Skins",
    Desc  = "Skin automation will be added here.\nSkin scripts require individual setup.",
})

hub:Notify("Auto", "Auto tab loaded", "play-circle", 3)
