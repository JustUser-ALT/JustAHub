local hub=_G.JHub; local Win=hub.Win
    local OtherSideTab = Win:Tab({ Title = "Other", Icon = "zap" })

    local ExtrasMulti = OtherSideTab:MultiSection({
        Title     = "Extras",
        Desc      = "Bot  •  Fun",
        Icon      = "sparkles",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    local BotTab = ExtrasMulti:Tab({ Title = "Bot", Desc = "Bot utilities", Icon = "cpu", Selected = true })
    local FunTab = ExtrasMulti:Tab({ Title = "Fun", Desc = "Fun utilities", Icon = "smile" })

    -- ── Bot Tab ────────────────────────────────────────────────────

    BotTab:Space({})

    local deleteBotEnabled = false
    local deleteBotConn    = nil

    local function dropBot(npc)
        local hrpB = npc:FindFirstChild("HumanoidRootPart")
        if not hrpB then return end
        for _, p in ipairs(npc:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
        local bv = Instance.new("BodyVelocity", hrpB)
        bv.Velocity = Vector3.new(0, -120, 0)
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        task.delay(5, function() pcall(function() bv:Destroy() end) end)
    end

    BotTab:Toggle({
        Title    = "Delete Bot",
        Desc     = "Deleting Bot — drops through floor, watches respawns",
        Value    = false,
        Flag     = "DeleteBot",
        Callback = function(v)
            deleteBotEnabled = v
            if deleteBotConn then deleteBotConn:Disconnect(); deleteBotConn = nil end
            if not v then hub:Notify("Bot", "Delete Bot disabled", "check", 2); return end
            local folder = workspace:FindFirstChild("PiggyNPC")
            if folder then
                for _, npc in ipairs(folder:GetChildren()) do
                    if npc:IsA("Model") then task.spawn(dropBot, npc) end
                end
            end
            local function watchFolder(f)
                deleteBotConn = f.ChildAdded:Connect(function(child)
                    if deleteBotEnabled and child:IsA("Model") then
                        task.wait(0.2); task.spawn(dropBot, child)
                    end
                end)
            end
            if folder then watchFolder(folder)
            else
                workspace.ChildAdded:Connect(function(child)
                    if child.Name == "PiggyNPC" then watchFolder(child) end
                end)
            end
            hub:Notify("Bot", "Delete Bot enabled", "check", 3)
        end,
    })

    BotTab:Space({})

    -- ── Fun Tab ────────────────────────────────────────────────────

    FunTab:Space({})

    FunTab:Section({
        Title = "Target Shooter",
        Desc  = "Float above target and shoot with Gun",
        Icon  = "crosshair",
    })

    FunTab:Space({})

    -- Radio-style single-select via Dropdown (Multi=false)
    local shootTarget = "Traitor"  -- default

    FunTab:Dropdown({
        Title    = "Target",
        Desc     = "Who to float above and shoot",
        Values   = { "Traitor", "Piggy", "Bot" },
        Multi    = false,
        Value    = "Traitor",
        Flag     = "ShootTarget",
        Callback = function(v) shootTarget = v end,
    })

    FunTab:Space({})

    -- Float state
    local floatConn    = nil
    local floatEnabled = false
    local floatOffset  = 8  -- studs above target

    local function stopFloat()
        floatEnabled = false
        if floatConn then floatConn:Disconnect(); floatConn = nil end
        -- Restore normal physics
        local char = hub.LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("_FloatBV")
                if bv then bv:Destroy() end
            end
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            end
        end
    end

    local function getTargetRoot()
        -- Traitor: player with Traitor BoolValue == true on character
        if shootTarget == "Traitor" then
            for _, p in pairs(hub.Players:GetPlayers()) do
                if p ~= hub.LocalPlayer and p.Character then
                    local t = p.Character:FindFirstChild("Traitor")
                    if t and t:IsA("BoolValue") and t.Value then
                        return p.Character:FindFirstChild("HumanoidRootPart"), p.Name
                    end
                end
            end
        -- Piggy: player character with Enemy BoolValue == true
        elseif shootTarget == "Piggy" then
            for _, p in pairs(hub.Players:GetPlayers()) do
                if p ~= hub.LocalPlayer and p.Character then
                    local e = p.Character:FindFirstChild("Enemy")
                    if e and e:IsA("BoolValue") and e.Value then
                        return p.Character:FindFirstChild("HumanoidRootPart"), p.Name
                    end
                end
            end
        -- Bot: first model inside workspace.PiggyNPC
        elseif shootTarget == "Bot" then
            local folder = workspace:FindFirstChild("PiggyNPC")
            if folder then
                for _, m in pairs(folder:GetChildren()) do
                    if m:IsA("Model") then
                        local root = m.PrimaryPart or m:FindFirstChild("HumanoidRootPart")
                        if root then return root, m.Name end
                    end
                end
            end
        end
        return nil, nil
    end

    local function startFloat(targetRoot)
        stopFloat()
        floatEnabled = true
        local char   = hub.LocalPlayer.Character
        if not char then return end
        local hrp    = char:FindFirstChild("HumanoidRootPart")
        if not hrp   then return end
        local hum    = char:FindFirstChild("Humanoid")

        -- Disable falling states so we hover
        if hum then
            for _, st in pairs({
                Enum.HumanoidStateType.FallingDown,
                Enum.HumanoidStateType.Freefall,
                Enum.HumanoidStateType.Jumping,
            }) do
                hum:SetStateEnabled(st, false)
            end
        end

        -- BodyVelocity keeps us at fixed height, zero velocity otherwise
        local bv = hrp:FindFirstChild("_FloatBV")
        if not bv then
            bv      = Instance.new("BodyVelocity", hrp)
            bv.Name = "_FloatBV"
        end
        bv.MaxForce = Vector3.new(0, math.huge, 0)
        bv.Velocity = Vector3.zero

        -- Every frame: stay exactly floatOffset studs above target,
        -- also drift sideways if target moves up/down (ladder/stairs)
        floatConn = hub.RunService.Heartbeat:Connect(function()
            if not floatEnabled then return end
            if not targetRoot or not targetRoot.Parent then
                stopFloat()
                hub:Notify("Float", "Target lost", "alert-circle")
                return
            end
            local targetPos = targetRoot.Position
            local wantedY   = targetPos.Y + floatOffset

            -- Keep Y fixed; follow XZ so we stay above them
            hrp.CFrame = CFrame.new(
                targetPos.X,
                wantedY,
                targetPos.Z
            ) * CFrame.Angles(0, math.atan2(-targetRoot.CFrame.LookVector.X, -targetRoot.CFrame.LookVector.Z), 0)

            bv.Velocity = Vector3.zero
        end)
    end

    local shootBtn  -- forward declare for status update

    FunTab:Button({
        Title    = "Float & Shoot",
        Desc     = "Teleport above target, float, then shoot",
        Icon     = "target",
        Callback = function()
            -- 1) Check gun in backpack
            local bp  = hub.LocalPlayer:FindFirstChild("Backpack")
            local gun = bp and bp:FindFirstChild("Gun")
            if not gun then
                hub:Notify("Error", "Gun not found in backpack", "x", 4)
                return
            end

            -- 2) Check ammo
            local ammo = gun:FindFirstChild("Ammo")
            if not ammo or not ammo:IsA("IntValue") or ammo.Value < 1 then
                hub:Notify("Error", "No ammo! Gun needs at least 1 bullet", "x", 4)
                return
            end

            -- 3) Find target
            local targetRoot, targetName = getTargetRoot()
            if not targetRoot then
                hub:Notify("Error", "Target (" .. shootTarget .. ") not found", "alert-circle", 4)
                return
            end

            hub:Notify("Float", "Floating above " .. targetName, "crosshair", 3)

            -- 4) Equip gun (move from Backpack to Character)
            local char = hub.LocalPlayer.Character
            if char then
                gun.Parent = char
            end
            task.wait(0.15)

            -- 5) Start floating above target
            startFloat(targetRoot)
            task.wait(0.3)

            -- 6) Fire via FireRemote using target's current position
            local firedGun = char and char:FindFirstChild("Gun")
            if firedGun then
                local fr = firedGun:FindFirstChild("FireRemote")
                if fr then
                    local myPos = char.HumanoidRootPart and char.HumanoidRootPart.Position or Vector3.zero
                    local tPos  = targetRoot.Position
                    local dir   = (tPos - myPos)
                    pcall(function()
                        fr:FireServer(Ray.new(
                            Vector3.new(myPos.X, myPos.Y, myPos.Z),
                            Vector3.new(dir.X, dir.Y, dir.Z)
                        ))
                    end)
                    hub:Notify("Shoot", "Shot fired at " .. targetName, "check", 3)
                else
                    hub:Notify("Error", "FireRemote not found on Gun", "x", 4)
                end
            else
                hub:Notify("Error", "Gun not equipped", "x", 4)
            end

            -- 7) Keep floating for 3 seconds then stop automatically
            task.delay(3, function()
                if floatEnabled then
                    stopFloat()
                    -- Return gun to backpack
                    local g2 = char and char:FindFirstChild("Gun")
                    if g2 then g2.Parent = hub.LocalPlayer.Backpack end
                    hub:Notify("Float", "Stopped floating", "check", 3)
                end
            end)
        end,
    })

    FunTab:Space({})

    FunTab:Button({
        Title    = "Stop Float",
        Desc     = "Cancel floating and return gun",
        Icon     = "x-circle",
        Callback = function()
            if floatEnabled then
                stopFloat()
                local char = hub.LocalPlayer.Character
                local g = char and char:FindFirstChild("Gun")
                if g then g.Parent = hub.LocalPlayer.Backpack end
                hub:Notify("Float", "Float stopped manually", "check", 3)
            else
                hub:Notify("Info", "Not currently floating", "info", 2)
            end
        end,
    })

    FunTab:Space({})

    FunTab:Slider({
        Title    = "Float Height",
        Desc     = "Studs above target head",
        Value    = { Min = 4, Max = 20, Default = 8 },
        Flag     = "FloatHeight",
        Callback = function(v) floatOffset = v end,
    })

    FunTab:Space({})

    hub:Notify("Other", "Other tab loaded", "zap", 3)
