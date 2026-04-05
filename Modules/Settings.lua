local hub=_G.JHub; local Win=hub.Win
    local SettingsTab = Win:Tab({ Title = "Settings", Icon = "settings" })

    SettingsTab:Space({})

    local CoS = SettingsTab:Section({
        Title     = "Console",
        Desc      = "Dev console & custom console icon",
        Icon      = "monitor",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    CoS:Space({})

    CoS:Button({
        Title    = "Open Dev Console",
        Desc     = "Opens Roblox output console",
        Icon     = "terminal",
        Callback = function()
            game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
        end,
    })

    CoS:Space({})

    CoS:Toggle({
        Title    = "Console Icon",
        Desc     = "Adds a console shortcut button",
        Value    = false,
        Flag     = "ConsoleIcon",
        Callback = function(v)
            if v then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Neosq/Console/refs/heads/main/Console.txt"))()
            else
                _G.ConsoleButtonLoaded = nil
                if hub.CoreGui:FindFirstChild("ConsoleGui") then hub.CoreGui.ConsoleGui:Destroy() end
                if hub.LocalPlayer.PlayerGui:FindFirstChild("ConsoleGui") then hub.LocalPlayer.PlayerGui.ConsoleGui:Destroy() end
            end
        end,
    })

    SettingsTab:Space({})

    local CrS = SettingsTab:Section({
        Title     = "Credits",
        Desc      = "About Just A Hub",
        Icon      = "info",
        Box       = true,
        BoxBorder = true,
        Opened    = true,
    })

    CrS:Space({})

    CrS:Paragraph({
        Title = "Just A Hub",
        Desc  = "Created by Neos\nVersion: Beta 2.0.0\n\nThanks for using Just A Hub!",
    })

    CrS:Space({})

    CrS:Button({
        Title    = "Telegram: @JustNeos",
        Desc     = "Click to copy link",
        Icon     = "send",
        Callback = function()
            setclipboard("https://t.me/JustNeos")
            hub:Notify("Copied!", "Telegram link copied to clipboard", "clipboard-check")
        end,
    })

    CrS:Space({})

    CrS:Paragraph({
        Title = "WindUI Boreal",
        Desc  = "UI Library by orialdev\nFork of the original WindUI — updated to Boreal",
    })

    CrS:Space({})

    CrS:Button({
        Title    = "WindUI Creator Discord",
        Desc     = "Click to copy invite link",
        Icon     = "message-circle",
        Callback = function()
            setclipboard("https://discord.gg/ftgs-development-hub-1300692552005189632")
            hub:Notify("Copied!", "Discord invite copied to clipboard", "clipboard-check")
        end,
    })

    CrS:Space({})

    CrS:Button({
        Title    = "orialdev on GitHub",
        Desc     = "WindUI Boreal author",
        Icon     = "github",
        Callback = function()
            setclipboard("https://github.com/orialdev/WindUI-Boreal")
            hub:Notify("Copied!", "GitHub link copied to clipboard", "clipboard-check")
        end,
    })

    SettingsTab:Space({})

    hub:Notify("Settings", "Settings & Credits loaded ✓", "settings", 3)
