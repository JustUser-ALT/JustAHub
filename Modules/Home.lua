local hub=_G.JHub; local Win=hub.Win; local CoreGui=hub.CoreGui

    local HomeTab = Win:Tab({ Title = "Home", Icon = "home" })

    local function pad(n) return n < 10 and "0" .. n or tostring(n) end
    local function getTime()
        local t = DateTime.now():ToLocalTime()
        return string.format(
            "%s:%s:%s  •  %s/%s/%s",
            pad(t.Hour), pad(t.Minute), pad(t.Second),
            pad(t.Day), pad(t.Month), t.Year
        )
    end

    HomeTab:Space({})

    local clockBtn = HomeTab:Button({
        Title    = getTime(),
        Desc     = "Local time",
        Icon     = "clock",
        Callback = function() end,
    })

    task.spawn(function()
        while task.wait(1) do
            pcall(function() clockBtn:SetTitle(getTime()) end)
        end
    end)

    HomeTab:Space({})

    local M = HomeTab:MultiSection({
        Title     = "Features",
        Desc      = "Player  •  Visual",
        Icon      = "layout-dashboard",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    local PlayerTab = M:Tab({ Title = "Player", Desc = "Movement & teleport", Icon = "user", Selected = true })
    local VisualTab = M:Tab({ Title = "Visual",  Desc = "ESP & lighting",      Icon = "eye" })

    hub.HomeMultiSection = M
    hub.HomePlayerTab    = PlayerTab
    hub.HomeVisualTab    = VisualTab

    local enabledFeatures = {}

    PlayerTab:Space({})

    PlayerTab:Dropdown({
        Title    = "Active Features",
        Desc     = "Choose which features to enable",
        Values   = { "Fly", "WalkSpeed", "JumpPower" },
        Multi    = true,
        Value    = {},
        Flag     = "ActiveFeatures",
        Callback = function(selected)
            enabledFeatures = selected
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Slider({
        Title    = "Fly Speed",
        Desc     = "Speed when flying",
        Value    = { Min = 1, Max = 200, Default = 50 },
        Flag     = "FlySpeed",
        Callback = function(v)
            hub.FlySpeed = v
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Slider({
        Title    = "Walk Speed",
        Desc     = "Character walk speed",
        Value    = { Min = 16, Max = 500, Default = 16 },
        Flag     = "WalkSpeed",
        Callback = function(v)
            hub.WalkSpeed = v
            if table.find(enabledFeatures, "WalkSpeed") then
                local char = hub.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = v
                end
            end
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Slider({
        Title    = "Jump Power",
        Desc     = "Character jump power",
        Value    = { Min = 50, Max = 500, Default = 50 },
        Flag     = "JumpPower",
        Callback = function(v)
            hub.JumpPower = v
            if table.find(enabledFeatures, "JumpPower") then
                local char = hub.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.UseJumpPower = true
                    char.Humanoid.JumpPower = v
                end
            end
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Toggle({
        Title    = "Enable Selected Features",
        Desc     = "Activates features chosen above",
        Value    = false,
        Flag     = "EnableSelected",
        Callback = function(v)
            if table.find(enabledFeatures, "Fly") then
                if v then
                    if hub._actFly then hub._actFly() end
                else
                    if hub._deactFly then hub._deactFly() end
                end
            end
            local char = hub.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if table.find(enabledFeatures, "WalkSpeed") then
                    char.Humanoid.WalkSpeed = v and hub.WalkSpeed or hub.OriginalWalkSpeed
                end
                if table.find(enabledFeatures, "JumpPower") then
                    char.Humanoid.UseJumpPower = v
                    char.Humanoid.JumpPower = v and hub.JumpPower or 50
                end
            end
        end,
    })

    PlayerTab:Space({})

    local actFly, deactFly = nil, nil
    do
        local flyDir = Vector3.new()
        local states = {
            Enum.HumanoidStateType.Climbing,         Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Flying,           Enum.HumanoidStateType.Freefall,
            Enum.HumanoidStateType.GettingUp,        Enum.HumanoidStateType.Jumping,
            Enum.HumanoidStateType.Landed,           Enum.HumanoidStateType.Physics,
            Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.Running,          Enum.HumanoidStateType.RunningNoPhysics,
            Enum.HumanoidStateType.Seated,           Enum.HumanoidStateType.StrafingNoPhysics,
            Enum.HumanoidStateType.Swimming,
        }

        function actFly()
            if hub.Flags.FlyEnabled then return end
            hub.Flags.FlyEnabled = true
            local char = hub.LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end

            local root = char.HumanoidRootPart
            local bodyVelocity = Instance.new("BodyVelocity", root)
            bodyVelocity.Velocity = Vector3.new()
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

            local inputConn = nil
            inputConn = hub.UserInput.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.KeyCode == Enum.KeyCode.W then flyDir = flyDir + root.CFrame.LookVector end
                if input.KeyCode == Enum.KeyCode.A then flyDir = flyDir - root.CFrame.RightVector end
                if input.KeyCode == Enum.KeyCode.S then flyDir = flyDir - root.CFrame.LookVector end
                if input.KeyCode == Enum.KeyCode.D then flyDir = flyDir + root.CFrame.RightVector end
                if input.KeyCode == Enum.KeyCode.Space then flyDir = flyDir + Vector3.new(0, 1, 0) end
                if input.KeyCode == Enum.KeyCode.LeftControl then flyDir = flyDir - Vector3.new(0, 1, 0) end
            end)

            local heartbeatConn = nil
            heartbeatConn = hub.RunService.Heartbeat:Connect(function()
                if not hub.Flags.FlyEnabled or not root or not root.Parent then
                    if inputConn then inputConn:Disconnect() end
                    if heartbeatConn then heartbeatConn:Disconnect() end
                    if bodyVelocity then bodyVelocity:Destroy() end
                    return
                end
                flyDir = flyDir.Magnitude > 0 and (flyDir.Unit * hub.FlySpeed) or Vector3.new()
                bodyVelocity.Velocity = flyDir
            end)
        end

        function deactFly()
            hub.Flags.FlyEnabled = false
            local char = hub.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local bv = char.HumanoidRootPart:FindFirstChild("BodyVelocity")
                if bv then bv:Destroy() end
                for _, st in pairs(states) do
                    char.Humanoid:SetStateEnabled(st, true)
                end
            end
        end
    end

    hub._actFly = actFly
    hub._deactFly = deactFly

    hub.LocalPlayer.CharacterAdded:Connect(function(c)
        deactFly()
        task.wait(0.5)
        local h = c:FindFirstChild("Humanoid")
        if h then hub.OriginalWalkSpeed = h.WalkSpeed end
    end)
    if hub.LocalPlayer.Character and hub.LocalPlayer.Character:FindFirstChild("Humanoid") then
        hub.OriginalWalkSpeed = hub.LocalPlayer.Character.Humanoid.WalkSpeed
    end

    PlayerTab:Space({})

    local selP = ""
    local function getOtherPlayers()
        local l = {}
        for _, p in pairs(hub.Players:GetPlayers()) do
            if p ~= hub.LocalPlayer then table.insert(l, p.Name) end
        end
        return l
    end

    PlayerTab:Dropdown({
        Title    = "Select Player",
        Desc     = "Pick a player to teleport to",
        Values   = getOtherPlayers(),
        Multi    = false,
        Value    = "",
        Flag     = "SelectedPlayer",
        Callback = function(v) selP = v end,
    })

    PlayerTab:Space({})

    PlayerTab:Button({
        Title    = "Teleport to Player",
        Desc     = "TP to selected player",
        Icon     = "map-pin",
        Callback = function()
            if selP == "" then
                hub:Notify("Error", "Please select a player first", "alert-circle")
                return
            end
            local t = hub.Players:FindFirstChild(selP)
            if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                local myChar = hub.LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    myChar.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    hub:Notify("Teleported!", "Teleported to " .. selP, "check")
                end
            else
                hub:Notify("Error", "Player not found or has no character", "x")
            end
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Button({
        Title    = "Copy Current Position",
        Desc     = "Copies XYZ to clipboard",
        Icon     = "copy",
        Callback = function()
            local char = hub.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos = char.HumanoidRootPart.Position
                setclipboard(string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z))
                hub:Notify("Copied!", "Position copied to clipboard", "clipboard-check")
            end
        end,
    })

    PlayerTab:Space({})

    PlayerTab:Button({
        Title    = "Teleport to CFrame",
        Desc     = "Use CFrame from injector",
        Icon     = "map-pin",
        Callback = function()
            hub:Notify("Info", "Use executor to run teleportion CFrame", "info")
        end,
    })

    -- ── ESP logic ────────────────────────────────────────────────────

    local espEnabled      = false
    local espObjects      = {}
    local espConnections  = {}
    local espTypes        = {}
    local espShowNames    = true
    local espShowDistance = true
    local espFillOpacity  = 0.55

    local espColors = {
        Players = Color3.fromRGB(80,  160, 255),
        Piggy   = Color3.fromRGB(255,  50,  80),
        Traitor = Color3.fromRGB(255, 200,   0),
        Bots    = Color3.fromRGB(255, 130,  40),
        NPC     = Color3.fromRGB(100, 220, 100),
    }

    -- playerCharSet: immediately updated so NPC scanner never mis-identifies a player char
    local playerCharSet = {}
    local function rebuildCharSet()
        playerCharSet = {}
        for _, p in pairs(hub.Players:GetPlayers()) do
            if p.Character then playerCharSet[p.Character] = true end
        end
    end
    local function isPlayerChar(m) return playerCharSet[m] == true end
    for _, p in pairs(hub.Players:GetPlayers()) do
        if p.Character then playerCharSet[p.Character] = true end
        p.CharacterAdded:Connect(function(c) playerCharSet[c] = true end)
    end
    hub.Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function(c) playerCharSet[c] = true end)
    end)

    -- Role checks via BoolValue on the character
    local function boolVal(char, name)
        local v = char and char:FindFirstChild(name)
        return v and v:IsA("BoolValue") and v.Value
    end
    local function isPiggy(p)   return boolVal(p.Character, "Enemy")   end
    local function isTraitor(p) return boolVal(p.Character, "Traitor") end

    -- Bot: inside PiggyNPC folder
    local function isBot(model)
        return model.Parent and model.Parent.Name == "PiggyNPC"
    end

    -- NPC: has NPCScript + Enemy, NOT a player char, NOT a bot
    local function isRealNPC(model)
        return model:FindFirstChild("NPCScript") ~= nil
            and model:FindFirstChild("Enemy") ~= nil
            and not isPlayerChar(model)
            and not isBot(model)
    end

    local function getBots()
        local bots = {}
        local f = workspace:FindFirstChild("PiggyNPC")
        if f then for _, b in pairs(f:GetChildren()) do if b:IsA("Model") then table.insert(bots, b) end end end
        return bots
    end
    local function getNPCs()
        local out = {}; rebuildCharSet()
        for _, d in pairs(workspace:GetDescendants()) do
            if d:IsA("Model") and d:FindFirstChildWhichIsA("Humanoid") and isRealNPC(d) then
                table.insert(out, d)
            end
        end
        return out
    end

    local function getDist(root)
        local mc = hub.LocalPlayer.Character; if not mc then return "" end
        local mr = mc:FindFirstChild("HumanoidRootPart")
        if not mr or not root or not root.Parent then return "" end
        return string.format(" [%dm]", math.floor((mr.Position - root.Position).Magnitude))
    end

    -- buildESP: Highlight parented INSIDE the model (not CoreGui) so Roblox
    -- renders it as part of that model's scene graph — this is the approach
    -- that gives full-body coverage including accessories and sub-models.
    -- DepthMode is Occluded (default) so it correctly depth-tests with walls;
    -- AlwaysOnTop is handled by billboard only.
    local function buildESP(adorneeModel, root, color, labelText)
        local hl = Instance.new("Highlight")
        hl.Name                = "ESP_HL"
        hl.Adornee             = adorneeModel
        hl.FillColor           = color
        hl.FillTransparency    = espFillOpacity
        hl.OutlineColor        = color
        hl.OutlineTransparency = 0
        hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent              = adorneeModel   -- inside model = full-body coverage

        local bb = Instance.new("BillboardGui")
        bb.Name        = "ESP_Label"
        bb.Adornee     = root
        bb.Size        = UDim2.new(0, 130, 0, 20)
        bb.StudsOffset = Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 600
        bb.Parent      = CoreGui

        local lbl = Instance.new("TextLabel", bb)
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3             = color
        lbl.TextStrokeColor3       = Color3.new(0, 0, 0)
        lbl.TextStrokeTransparency = 0
        lbl.TextScaled             = true
        lbl.Font                   = Enum.Font.GothamBold
        lbl.Text                   = labelText

        -- Auto-cleanup when model is removed
        local ancConn; ancConn = adorneeModel.AncestryChanged:Connect(function(_, par)
            if par == nil then
                pcall(function() hl:Destroy() end)
                pcall(function() bb:Destroy() end)
                if ancConn then ancConn:Disconnect() end
            end
        end)
        table.insert(espConnections, ancConn)

        return { highlight = hl, billboard = bb, label = lbl, baseName = labelText, root = root }
    end

    local function removeESP(target)
        if espObjects[target] then
            pcall(function() espObjects[target].highlight:Destroy() end)
            pcall(function() espObjects[target].billboard:Destroy() end)
            espObjects[target] = nil
        end
    end

    local distConn = nil
    local function startDistLoop()
        if distConn then return end
        distConn = hub.RunService.Heartbeat:Connect(function()
            for _, esp in pairs(espObjects) do
                if esp.label and esp.label.Parent and esp.root and esp.root.Parent then
                    esp.label.Text = (espShowNames and esp.baseName or "")
                                  .. (espShowDistance and getDist(esp.root) or "")
                end
            end
        end)
    end
    local function stopDistLoop()
        if distConn then distConn:Disconnect(); distConn = nil end
    end

    local function getRoot(char)
        return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    end

    -- Single function that resolves which ESP category a player falls into
    local function resolvePlayerESP(player)
        if player == hub.LocalPlayer or not player.Character then return end
        local isPig = isPiggy(player)
        local isTrt = isTraitor(player)
        if isPig and table.find(espTypes, "Piggy") then
            local root = getRoot(player.Character); if not root then return end
            espObjects[player] = buildESP(player.Character, root, espColors.Piggy, player.Name)
        elseif isTrt and table.find(espTypes, "Traitor") then
            local root = getRoot(player.Character); if not root then return end
            espObjects[player] = buildESP(player.Character, root, espColors.Traitor, player.Name)
        elseif not isPig and not isTrt and table.find(espTypes, "Players") then
            local root = getRoot(player.Character); if not root then return end
            espObjects[player] = buildESP(player.Character, root, espColors.Players, player.Name)
        end
    end

    -- On respawn: register in charSet immediately, wait 1.5s for role BoolValues,
    -- then re-apply ESP with correct color
    local function refreshPlayerESP(player)
        if player.Character then playerCharSet[player.Character] = true end
        removeESP(player)
        if not espEnabled then return end
        task.wait(1.5)
        if not espEnabled then return end
        resolvePlayerESP(player)
    end

    -- Watch Enemy/Traitor BoolValue changes so color updates mid-round
    local function watchRoleChanges(player)
        local function onChanged()
            if not espEnabled then return end
            removeESP(player); resolvePlayerESP(player)
        end
        local char = player.Character; if not char then return end
        for _, vname in ipairs({ "Enemy", "Traitor" }) do
            local bv = char:FindFirstChild(vname)
            if bv and bv:IsA("BoolValue") then
                table.insert(espConnections, bv.Changed:Connect(onChanged))
            end
            table.insert(espConnections, char.ChildAdded:Connect(function(child)
                if child.Name == vname and child:IsA("BoolValue") then
                    table.insert(espConnections, child.Changed:Connect(onChanged))
                end
            end))
        end
    end

    local function createBotESP(bot)
        if not bot or not bot.Parent then return end
        if not table.find(espTypes, "Bots") then return end
        local root = bot.PrimaryPart or bot:FindFirstChild("HumanoidRootPart")
        if not root then return end
        espObjects[bot] = buildESP(bot, root, espColors.Bots, bot.Name)
    end

    local function createNPCESP(npc)
        if not npc or not npc.Parent or not isRealNPC(npc) then return end
        local root = npc.PrimaryPart or npc:FindFirstChild("HumanoidRootPart")
        if not root then return end
        espObjects[npc] = buildESP(npc, root, espColors.NPC, npc.Name)
    end

    local function toggleESP(v)
        espEnabled = v
        stopDistLoop()
        for target in pairs(espObjects) do removeESP(target) end
        for _, conn in pairs(espConnections) do pcall(function() conn:Disconnect() end) end
        espConnections = {}
        if not v then return end

        startDistLoop()
        rebuildCharSet()

        -- Players / Piggy / Traitor
        for _, plr in hub.Players:GetPlayers() do
            if plr ~= hub.LocalPlayer then
                task.spawn(resolvePlayerESP, plr)
                task.spawn(watchRoleChanges, plr)
            end
        end
        table.insert(espConnections, hub.Players.PlayerAdded:Connect(function(plr)
            table.insert(espConnections, plr.CharacterAdded:Connect(function()
                task.spawn(refreshPlayerESP, plr)
                task.spawn(watchRoleChanges, plr)
            end))
        end))
        for _, plr in hub.Players:GetPlayers() do
            table.insert(espConnections, plr.CharacterAdded:Connect(function()
                task.spawn(refreshPlayerESP, plr)
                task.spawn(watchRoleChanges, plr)
            end))
        end

        -- Bots (PiggyNPC folder)
        if table.find(espTypes, "Bots") then
            for _, bot in pairs(getBots()) do task.spawn(createBotESP, bot) end
            local function watchPiggyNPC(folder)
                table.insert(espConnections, folder.ChildAdded:Connect(function(child)
                    task.wait(0.3)
                    if espEnabled and child:IsA("Model") and not espObjects[child] then
                        task.spawn(createBotESP, child)
                    end
                end))
            end
            local npcFolder = workspace:FindFirstChild("PiggyNPC")
            if npcFolder then watchPiggyNPC(npcFolder)
            else
                table.insert(espConnections, workspace.ChildAdded:Connect(function(child)
                    if child.Name == "PiggyNPC" then watchPiggyNPC(child) end
                end))
            end
        end

        -- NPC
        if table.find(espTypes, "NPC") then
            for _, npc in pairs(getNPCs()) do task.spawn(createNPCESP, npc) end
            table.insert(espConnections, workspace.DescendantAdded:Connect(function(desc)
                if not espEnabled or not desc:IsA("Model") then return end
                task.wait(0.5)
                if isRealNPC(desc) and not espObjects[desc] then
                    task.spawn(createNPCESP, desc)
                end
            end))
        end
    end

    -- ── ESP section UI ───────────────────────────────────────────────

    local EspS = VisualTab:Section({
        Title     = "ESP",
        Desc      = "Highlight silhouettes through walls",
        Icon      = "scan-eye",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    EspS:Space({})

    EspS:Dropdown({
        Title    = "ESP Targets",
        Desc     = "Select one or more target types",
        Values   = { "Players", "Piggy", "Traitor", "Bots", "NPC" },
        Multi    = true,
        Value    = {},
        Flag     = "ESPTargets",
        Callback = function(selected)
            espTypes = selected
            if espEnabled then toggleESP(false); task.wait(0.1); toggleESP(true) end
        end,
    })

    EspS:Space({})

    EspS:Slider({
        Title    = "Fill Opacity",
        Desc     = "0 = outline only  |  100 = solid fill",
        Value    = { Min = 0, Max = 100, Default = 45 },
        Flag     = "ESPFill",
        Callback = function(v)
            espFillOpacity = 1 - (v / 100)
            for _, esp in pairs(espObjects) do
                pcall(function() esp.highlight.FillTransparency = espFillOpacity end)
            end
        end,
    })

    EspS:Space({})

    EspS:Toggle({
        Title    = "Show Names",
        Desc     = "Display name label above head",
        Value    = true,
        Flag     = "ESPNames",
        Callback = function(v) espShowNames = v end,
    })

    EspS:Space({})

    EspS:Toggle({
        Title    = "Show Distance",
        Desc     = "Display distance in metres",
        Value    = true,
        Flag     = "ESPDist",
        Callback = function(v) espShowDistance = v end,
    })

    EspS:Space({})

    EspS:Toggle({
        Title    = "Enable ESP",
        Desc     = "Toggle highlight ESP on/off",
        Value    = false,
        Flag     = "ESPEnabled",
        Callback = toggleESP,
    })

    -- ── Visuals section UI ───────────────────────────────────────────

    local VisS = VisualTab:Section({
        Title     = "Visuals",
        Desc      = "Lighting & camera tweaks",
        Icon      = "sun",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    local lightingBackup = { saved = false }
    local function backupLighting()
        if not lightingBackup.saved then
            lightingBackup = {
                FogEnd         = hub.Lighting.FogEnd,
                FogStart       = hub.Lighting.FogStart,
                Brightness     = hub.Lighting.Brightness,
                Ambient        = hub.Lighting.Ambient,
                OutdoorAmbient = hub.Lighting.OutdoorAmbient,
                ClockTime      = hub.Lighting.ClockTime,
                saved          = true,
            }
        end
    end

    VisS:Space({})

    VisS:Toggle({
        Title    = "Full Bright",
        Desc     = "Maximises in-game brightness",
        Value    = false,
        Flag     = "FullBright",
        Callback = function(v)
            if v then
                backupLighting()
                hub.Lighting.Brightness     = 2
                hub.Lighting.Ambient        = Color3.new(1, 1, 1)
                hub.Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
                hub.Lighting.ClockTime      = 14
                for _, e in hub.Lighting:GetDescendants() do
                    if e:IsA("BloomEffect") or e:IsA("BlurEffect")
                    or e:IsA("ColorCorrectionEffect") or e:IsA("SunRaysEffect") then
                        e.Enabled = false
                    end
                end
            else
                if lightingBackup.saved then
                    hub.Lighting.Brightness     = lightingBackup.Brightness
                    hub.Lighting.Ambient        = lightingBackup.Ambient
                    hub.Lighting.OutdoorAmbient = lightingBackup.OutdoorAmbient
                    hub.Lighting.ClockTime      = lightingBackup.ClockTime
                end
            end
        end,
    })

    VisS:Space({})

    VisS:Toggle({
        Title    = "No Fog",
        Desc     = "Removes all fog & atmosphere",
        Value    = false,
        Flag     = "NoFog",
        Callback = function(v)
            if v then
                backupLighting()
                hub.Lighting.FogEnd   = math.huge
                hub.Lighting.FogStart = math.huge
                for _, atm in hub.Lighting:GetDescendants() do
                    if atm:IsA("Atmosphere") then atm.Density = 0; atm.Haze = 0 end
                end
            else
                if lightingBackup.saved then
                    hub.Lighting.FogEnd   = lightingBackup.FogEnd
                    hub.Lighting.FogStart = lightingBackup.FogStart
                end
            end
        end,
    })

    VisS:Space({})

    VisS:Slider({
        Title    = "Max Zoom Distance",
        Desc     = "Camera max zoom out",
        Value    = { Min = 1, Max = 9999, Default = hub.MaxZoom },
        Flag     = "MaxZoom",
        Callback = function(v)
            hub.MaxZoom = v
            hub.LocalPlayer.CameraMaxZoomDistance = v
        end,
    })

    hub:Notify("Home", "Home tab loaded ✓", "check", 3)
