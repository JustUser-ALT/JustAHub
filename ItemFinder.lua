
local Players,CoreGui,RS = game:GetService("Players"),game:GetService("CoreGui"),game:GetService("RunService")
local Player = Players.LocalPlayer

local ITEMS = {
    Hammer={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(0.9,0.3,2.7)},
    BlueKey={Color=Color3.new(0,1,1),Size=Vector3.new(0.7,1.6,0.15)},
    Ammo={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(1.55,1.2,0.9)},
    GreenKey={Color=Color3.new(0,1,0),Size=Vector3.new(0.7,1.6,0.15)},
    PurpleKey={Color=Color3.new(0.7059,0,0.7059),Size=Vector3.new(0.7,1.6,0.15)},
    Wrench={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(0.4,0.6,2.1)},
    Gun={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(0.15,1.25,0.9)},
    GreenGear={Color=Color3.new(0,0.6667,0),Size=Vector3.new(1.3,1.25,0.2)},
    OrangeKey={Color=Color3.new(1,0.3922,0),Size=Vector3.new(0.7,1.6,0.15)},
    WhiteKey={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(0.7,1.6,0.15)},
    KeyCode={Color=Color3.new(0.9725,0.9725,0.9725),Size=Vector3.new(0.85,0.15,1.5)},
    Plank={Color=Color3.fromRGB(150,70,20),Size=Vector3.new(0.9,0.3,2.7)},
    RedGear={Color=Color3.new(1,0.3137,0),Size=Vector3.new(1.3,1.25,0.2)},
    RedKey={Color=Color3.new(1,0,0),Size=Vector3.new(0.7,1.6,0.15)},
    YellowKey={Color=Color3.fromRGB(212,175,55),Size=Vector3.new(0.7,1.6,0.15)},
    Gas={Color=Color3.fromRGB(255,89,89),Size=Vector3.new(1.674,1.579,0.45)},
    Battery={Color=Color3.new(0,0,0),Size=Vector3.new(0.5,1.58,0.5)},
    Bone={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(0.3,3.05,0.7)},
    GreenEgg={Color=Color3.fromRGB(52,142,64),Size=Vector3.new(0.9,1.4,0.8)},
    RedEgg={Color=Color3.fromRGB(196,40,28),Size=Vector3.new(0.9,1.4,0.8)},
    EmptyVial={Color=Color3.fromRGB(160,132,79),Size=Vector3.new(1.55,0.425,0.425)},
    GreenVial={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(1.55,0.425,0.425)},
    PinkVial={Color=Color3.fromRGB(255,0,191),Size=Vector3.new(1.55,0.425,0.425)},
    Carrot={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(0.3,2.6,0.7),MeshId="rbxassetid://741743576"},
    RedKeycard={Color=Color3.fromRGB(255,255,255),Size=Vector3.new(0.825,1.65,0.15),Rotation=Vector3.new(90,0,0),ParticleColor=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,1,0)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))})},
    BlueKeycard={Color=Color3.fromRGB(17,17,17),Size=Vector3.new(0.825,1.65,0.15),Rotation=Vector3.new(90,0,-30),ParticleColor=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,1)),ColorSequenceKeypoint.new(1,Color3.new(1,0,1))})},
    GreenKeycard={Color=Color3.fromRGB(17,17,17),Size=Vector3.new(0.825,1.65,0.15),Rotation=Vector3.new(90,0,90),ParticleColor=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,0,1)),ColorSequenceKeypoint.new(1,Color3.new(0,1,0))})},
    OrangeKeycard={Color=Color3.fromRGB(255,255,255),Size=Vector3.new(0.825,1.65,0.15),Rotation=Vector3.new(90,0,45),ParticleColor=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(0,1,0.333)),ColorSequenceKeypoint.new(1,Color3.new(1,1,0.333))})},
    LitTorch={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(1,2.2,0.85)},
    Torch={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(1,2.2,0.85)},
    Book={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(1.05,0.5,1.35)},
    Coin={Color=Color3.fromRGB(245,205,48),Size=Vector3.new(1.05,1.025,0.225)},
    Crossbow={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(1.725,0.5,2.35)},
    Mallet={Color=Color3.fromRGB(245,205,48),Size=Vector3.new(2.4,0.6,0.625)},
    WaterGun={Color=Color3.fromRGB(163,162,165),Size=Vector3.new(0.25,0.7,1.4)},
    FakePhoto={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.5,0.1,0.6)},
    FireExtinguisher={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(0.55,1.55,0.5)},
    Grass={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(0.55,1.3,0.65),MeshId="rbxassetid://577111754"},
    TNT={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(0.55,0.6,1.75)},
    Mirror={Color=Color3.fromRGB(175,221,255),Size=Vector3.new(0.15,1.65,1.05)},
    Crowbar={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(0.5,0.1,1.7)},
    Chip={Color=Color3.fromRGB(91,154,76),Size=Vector3.new(0.637,0.068,0.579),MeshId="rbxassetid://17848548940"},
    Apple={Color=Color3.fromRGB(163,162,165),Size=Vector3.new(0.792,0.95,0.792),MeshId="rbxassetid://16190555"},
    Photo={Color=Color3.fromRGB(243,243,243),Size=Vector3.new(1.215,0.101,1.35)},
    Shell={Color=Color3.fromRGB(159,161,159),Size=Vector3.new(0.5,1.58,0.5),MeshId="rbxassetid://991156270"},
    GlitchKey={Size=Vector3.new(1.606,0.104,0.495),MeshId="rbxassetid://17848542337"},
    ToyDino={Color=Color3.new(0,0,0),Size=Vector3.new(0.425,0.905,1.3)},
    ToyRobot={Color=Color3.new(0,0,0),Size=Vector3.new(0.975,0.38,1.3)},
    Mop={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(0.35,0.3,2.05),MeshId="http://www.roblox.com/asset/?id=36365830"},
    Scissors={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(1.05,1.4,0.15),MeshId="http://www.roblox.com/asset/?id=6550055"},
    Screwdriver={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(2,0.45,0.4),MeshId="http://www.roblox.com/asset/?id=70265804"},
    Ladder={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(0.95,0.676,0.122)},
    Remote={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(1,0.25,0.9),MeshId="rbxassetid://81616133"},
    SmokeGrenade={Color=Color3.new(0,0,0),Size=Vector3.new(0.5,1.58,0.5),MeshId="http://www.roblox.com/asset/?id=88794862"},
    Blowtorch={Color=Color3.fromRGB(17,17,17),Size=Vector3.new(1.332,0.833,0.469)},
    ElevatorKey={Color=Color3.fromRGB(91,93,105),Size=Vector3.new(0.45,1.6,0.15),MeshId="rbxassetid://456878024"},
    Gears={Color=Color3.fromRGB(159,161,172),Size=Vector3.new(1.3,1.25,0.2),MeshId="rbxassetid://524706126"},
    Axe={Color=Color3.fromRGB(163,162,165),Size=Vector3.new(0.3,2,0.75),MeshId="http://www.roblox.com/asset?id=145815658"},
    Shovel={Color=Color3.fromRGB(105,102,92),Size=Vector3.new(0.5,2,0.2),MeshId="rbxassetid://1448137661"},
    WoodenSword={Color=Color3.fromRGB(163,162,165),Size=Vector3.new(1,0.5,3),MeshId="http://www.roblox.com/asset/?id=12130075"},
    GrappleHook={Color=Color3.new(0,0,0),Size=Vector3.new(0.25,1,1.75),MeshId="http://www.roblox.com/asset/?id=30308256"},
    Candle={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.9,1.2,0.9),MeshId="rbxassetid://1949604058"},
    Rope={Color=Color3.fromRGB(124,92,70),Size=Vector3.new(1,1,0.35),MeshId="http://www.roblox.com/asset/?id=16606212"},
    RustySword={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(2.4,0.495,0.496)},
    Pie={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(1,1,0.3),MeshId="http://www.roblox.com/asset/?id=18417911"},
    Spray={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(0.7,1.6,0.7),MeshId="http://www.roblox.com/asset/?id=79146128"},
    Weights={Color=Color3.fromRGB(99,95,98),Size=Vector3.new(1.4,0.6,0.6),MeshId="http://www.roblox.com/asset/?id=122333663"},
    GreenPotion={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(0.9,1.2,0.9),Material=Enum.Material.Glass},
    RedPotion={Color=Color3.fromRGB(255,0,0),Size=Vector3.new(0.9,1.2,0.9),Material=Enum.Material.Glass},
    PurplePotion={Color=Color3.fromRGB(140,91,159),Size=Vector3.new(1.2,0.9,0.9),Material=Enum.Material.Glass},
    EmptyBacket={Color=Color3.fromRGB(0,255,255),Size=Vector3.new(0.7,0.779,0.15)},
    Heart={Color=Color3.fromRGB(218,43,46),Size=Vector3.new(1.304,1.179,0.322),MeshId="rbxassetid://126620494244800"},
    FilledBucket={Color=Color3.fromRGB(0,255,255),Size=Vector3.new(0.7,0.779,0.15)},
    BlueWire={Color=Color3.fromRGB(0,0,255),Size=Vector3.new(0.25,2,0.25),MeshId="rbxassetid://6830387841"},
    GreenWire={Color=Color3.fromRGB(0,255,0),Size=Vector3.new(0.25,2,0.25),MeshId="rbxassetid://6830387841"},
    RedWire={Color=Color3.fromRGB(255,0,0),Size=Vector3.new(0.25,2,0.25),MeshId="rbxassetid://6830387841"},
    YellowWire={Color=Color3.fromRGB(255,255,0),Size=Vector3.new(0.25,2,0.25),MeshId="rbxassetid://6830387841"},
    MilitaryKnife={Color=Color3.fromRGB(255,255,0),Size=Vector3.new(0.25,3,0.5),MeshId="http://www.roblox.com/asset/?id=121944778"},
    DayBucket={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.5,0.5,0.5),MeshId="http://www.roblox.com/asset/?id=15952512",TextureId="http://www.roblox.com/asset/?id=11322789612"},
    NightBucket={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.5,0.5,0.5),MeshId="http://www.roblox.com/asset/?id=15952512",TextureId="http://www.roblox.com/asset/?id=11322790908"},
    SunsetBucket={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.5,0.5,0.5),MeshId="http://www.roblox.com/asset/?id=15952512",TextureId="http://www.roblox.com/asset/?id=11322790307"},
    NewBlueKey={Color=Color3.fromRGB(0,255,255),Size=Vector3.new(0.5,1.5,0.15),MeshId="rbxassetid://456878024"},
    NewBook={Color=Color3.fromRGB(202,191,163),Size=Vector3.new(1.05,0.5,1.35),MeshId="http://www.roblox.com/asset/?id=1136139",TextureId="rbxassetid://9644371"},
    NewRedKey={Color=Color3.fromRGB(255,0,0),Size=Vector3.new(0.5,1.5,0.15),MeshId="rbxassetid://456878024"},
    NewRemote={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(1,0.25,0.9),MeshId="rbxassetid://81616133",TextureId="http://www.roblox.com/asset/?id=81616111"},
    NewWhiteKey={Color=Color3.fromRGB(248,248,248),Size=Vector3.new(0.5,1.5,0.15),MeshId="rbxassetid://456878024"},
    NewBlackKey={Color=Color3.fromRGB(17,17,17),Size=Vector3.new(0.5,1.5,0.15),MeshId="rbxassetid://456878024"},
}

local function mk(c,p,r) local i=Instance.new(c) for k,v in pairs(p) do i[k]=v end if r then i.Parent=r end return i end
local function rnd(n,p) return mk("UICorner",{CornerRadius=UDim.new(0,n)},p) end
local function str(c,t,p) return mk("UIStroke",{Color=c,Thickness=t},p) end

local C={
    bg =Color3.fromRGB(11,9,17),  pan=Color3.fromRGB(20,16,30),
    row=Color3.fromRGB(28,22,42), acc=Color3.fromRGB(108,52,168),
    aL =Color3.fromRGB(142,76,208),sel=Color3.fromRGB(70,28,118),
    txt=Color3.fromRGB(218,208,238),mut=Color3.fromRGB(130,115,155),
    grn=Color3.fromRGB(58,182,98), red=Color3.fromRGB(182,52,52),
    bdr=Color3.fromRGB(46,36,68),
}


local function getIcon(name,obj)
    local p=ITEMS[name]; local mid=p and p.MeshId
    if not mid then
        local s=obj and obj:FindFirstChildOfClass("SpecialMesh")
        mid=s and s.MeshId~="" and s.MeshId or nil
    end
    if mid then
        local id=tostring(mid):match("%d+")
        if id then return "rbxthumb://type=Asset&id="..id.."&w=150&h=150" end
    end
    if obj then
        for _,ch in ipairs(obj:GetChildren()) do
            if ch:IsA("SpecialMesh") or ch:IsA("MeshPart") then
                local id=(ch.MeshId or ""):match("%d+")
                if id and id~="" then return "rbxthumb://type=Asset&id="..id.."&w=150&h=150" end
            end
        end
    end
    return ""
end

local function cmpCS(s1,s2)
    if not s1 or not s2 or #s1.Keypoints~=#s2.Keypoints then return false end
    for i,k in ipairs(s1.Keypoints) do
        local k2=s2.Keypoints[i]
        if (k.Value.R-k2.Value.R)^2+(k.Value.G-k2.Value.G)^2+(k.Value.B-k2.Value.B)^2>0.01 then return false end
    end; return true
end

local function ident(obj)
    if not(obj:IsA("BasePart") or obj:IsA("UnionOperation") or obj:IsA("MeshPart")) then return end
    for name,p in pairs(ITEMS) do
        local cd=p.Color and ((obj.Color.R-p.Color.R)^2+(obj.Color.G-p.Color.G)^2+(obj.Color.B-p.Color.B)^2) or 0
        local sd=(obj.Size-p.Size).Magnitude
        local gG,rG=name=="GreenGear",name=="RedGear"
        local mm=not p.Material or obj.Material==p.Material
        if (not p.Color or cd<(gG and 0.5 or rG and 0.2 or 0.1)) and sd<(gG and 0.5 or rG and 0.2 or p.MeshId and 0.01 or 0.1) and mm then
            if p.MeshId then
                local m=obj:IsA("MeshPart") and obj or obj:FindFirstChildOfClass("SpecialMesh")
                if m and m.MeshId==p.MeshId then
                    if not p.TextureId then return name end
                    local tid=obj:IsA("MeshPart") and obj.TextureID or (m and m.TextureId or "")
                    if tid==p.TextureId then return name end
                end
            elseif p.ParticleColor then
                local pe=obj:FindFirstChildOfClass("ParticleEmitter")
                if pe and cmpCS(pe.Color,p.ParticleColor) then
                    if not p.Rotation then return name end
                    local rot=obj.Rotation
                    if (rot.X-p.Rotation.X)^2+(rot.Y-p.Rotation.Y)^2+(rot.Z-p.Rotation.Z)^2<0.1 then return name end
                end
            else return name end
        end
    end
end

local function findItems()
    local out={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("UnionOperation") or obj:IsA("MeshPart") then
            local ok=false
            for _,c in ipairs(obj:GetDescendants()) do
                if (c:IsA("ProximityPrompt") and c.Enabled) or (c:IsA("ClickDetector") and c.MaxActivationDistance>0) then ok=true; break end
            end
            if ok then local n=ident(obj); if n then table.insert(out,{Obj=obj,Name=n}) end end
        end
    end
    return out
end

local function collect(item)
    local char=Player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not item.Obj or not item.Obj.Parent then return false end
    local orig=hrp.CFrame
    hrp.CFrame=item.Obj.CFrame*CFrame.new(0,4,0)
    pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)
    task.wait(0.15)
    local function fire(obj)
        if not obj or not obj.Parent then return end
        local function tryPrompts(o)
            local p=o:FindFirstChildOfClass("ProximityPrompt")
            if p and p.Enabled then for _=1,6 do pcall(fireproximityprompt,p); task.wait(0.04) end; return true end
            for _,d in ipairs(o:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then for _=1,6 do pcall(fireproximityprompt,d); task.wait(0.04) end; return true end
            end
        end
        local function tryClicks(o)
            local cd=o:FindFirstChildOfClass("ClickDetector"); if cd then pcall(fireclickdetector,cd); return true end
            for _,d in ipairs(o:GetDescendants()) do if d:IsA("ClickDetector") then pcall(fireclickdetector,d); return true end end
        end
        if not tryPrompts(obj) then tryClicks(obj) end
    end
    fire(item.Obj)
    if item.Obj and item.Obj.Parent then fire(item.Obj.Parent) end
    if item.Obj and item.Obj.Parent and item.Obj.Parent.Parent then fire(item.Obj.Parent.Parent) end
    task.wait(0.35)
    local op=orig.Position+Vector3.new(0,5,0)
    hrp.CFrame=CFrame.new(op,op+orig.LookVector)
    task.wait(0.08)
    pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero; hrp.AssemblyAngularVelocity=Vector3.zero end)
    local bp=Player:FindFirstChild("Backpack"); return bp and bp:FindFirstChild(item.Name)~=nil
end

local espObjs,espNames={},true
local function mkESP(obj,name)
    local p=ITEMS[name]
    local col=(p and p.Color) or Color3.fromRGB(142,76,208)
    local hl=mk("Highlight",{FillColor=col,OutlineColor=Color3.fromRGB(255,255,255),FillTransparency=0.45,OutlineTransparency=0,Adornee=obj,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop},CoreGui)
    local bb=mk("BillboardGui",{Size=UDim2.new(0,110,0,24),StudsOffset=Vector3.new(0,2.5,0),AlwaysOnTop=true,Enabled=espNames,Adornee=obj},CoreGui)
    mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=col,TextStrokeTransparency=0,TextScaled=true,Font=Enum.Font.GothamBold,Parent=bb})
    return {hl=hl,bb=bb}
end
local function rmESP(obj)
    if espObjs[obj] then
        pcall(function() espObjs[obj].hl:Destroy(); espObjs[obj].bb:Destroy() end)
        espObjs[obj]=nil
    end
end
RS.Heartbeat:Connect(function()
    for obj in pairs(espObjs) do
        if not obj or not obj.Parent then rmESP(obj) end
    end
end)

if CoreGui:FindFirstChild("ItemFinderGUI") then CoreGui.ItemFinderGUI:Destroy() end
local sg=mk("ScreenGui",{Name="ItemFinderGUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},CoreGui)

local tog=mk("TextButton",{Text="Item Finder",Size=UDim2.new(0,126,0,36),Position=UDim2.new(0,10,0,10),BackgroundColor3=C.acc,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=14,BorderSizePixel=0,AutoButtonColor=false},sg)
rnd(18,tog); str(C.aL,1.5,tog)

local win=mk("Frame",{Size=UDim2.new(0,310,0,450),Position=UDim2.new(0.5,-155,0.5,-225),BackgroundColor3=C.bg,BorderSizePixel=0,Visible=false},sg)
rnd(16,win); str(C.acc,1.5,win)

local title=mk("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.pan,BorderSizePixel=0},win)
rnd(16,title); str(C.acc,1,title)
mk("Frame",{Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.pan,BorderSizePixel=0,ZIndex=0},title)
mk("TextLabel",{Text="Item Finder",Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=17,TextXAlignment=Enum.TextXAlignment.Left},title)
local xBtn=mk("TextButton",{Text="x",Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-38,0.5,-15),BackgroundColor3=C.red,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=16,BorderSizePixel=0,AutoButtonColor=false},title)
rnd(8,xBtn)

do
    local drag,ds,sp=false,nil,nil
    local function startDrag(i)
        local abs=xBtn.AbsolutePosition; local sz=xBtn.AbsoluteSize
        local over=i.Position.X>=abs.X and i.Position.X<=abs.X+sz.X and i.Position.Y>=abs.Y and i.Position.Y<=abs.Y+sz.Y
        if not over then drag=true; ds=i.Position; sp=win.Position end
    end
    title.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then startDrag(i) end end)
    title.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds; win.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
    title.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
end

local tabBar=mk("Frame",{Size=UDim2.new(1,-16,0,36),Position=UDim2.new(0,8,0,52),BackgroundColor3=C.pan,BorderSizePixel=0},win)
rnd(10,tabBar); str(C.bdr,1,tabBar)
local tFinder=mk("TextButton",{Text="Finder",Size=UDim2.new(0.5,-3,1,-4),Position=UDim2.new(0,2,0,2),BackgroundColor3=C.acc,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0,AutoButtonColor=false},tabBar)
rnd(8,tFinder)
local tESP=mk("TextButton",{Text="Item ESP",Size=UDim2.new(0.5,-3,1,-4),Position=UDim2.new(0.5,1,0,2),BackgroundColor3=C.pan,TextColor3=C.mut,Font=Enum.Font.GothamBold,TextSize=13,BorderSizePixel=0,AutoButtonColor=false},tabBar)
rnd(8,tESP)

local countLbl=mk("TextLabel",{Text="0 items",Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,8,0,93),BackgroundTransparency=1,TextColor3=C.mut,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right},win)

local scroll=mk("ScrollingFrame",{Size=UDim2.new(1,-16,1,-162),Position=UDim2.new(0,8,0,115),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=C.acc,BorderSizePixel=0},win)
mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

local bot=mk("Frame",{Size=UDim2.new(1,-16,0,44),Position=UDim2.new(0,8,1,-52),BackgroundColor3=C.pan,BorderSizePixel=0},win)
rnd(10,bot); str(C.bdr,1,bot)
local namesBtn=mk("TextButton",{Text="Names: ON",Size=UDim2.new(0.5,-5,1,-8),Position=UDim2.new(0,4,0,4),BackgroundColor3=C.grn,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false,Visible=false},bot)
rnd(8,namesBtn)
local espAllBtn=mk("TextButton",{Text="ESP All",Size=UDim2.new(0.5,-5,1,-8),Position=UDim2.new(0.5,1,0,4),BackgroundColor3=C.acc,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false,Visible=false},bot)
rnd(8,espAllBtn); str(C.aL,1,espAllBtn)
local botInfo=mk("TextLabel",{Text="Tap TP to teleport  •  Get to collect",Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,TextColor3=C.mut,Font=Enum.Font.Gotham,TextSize=12},bot)

local curTab,items,espState="Finder",{},{}
local refresh -- forward declare

local function makeRow(item)
    local p=ITEMS[item.Name]
    local row=mk("Frame",{Size=UDim2.new(1,0,0,46),BackgroundColor3=C.row,BorderSizePixel=0},scroll)
    rnd(10,row); str(C.bdr,1,row)

    local itemColor=(p and p.Color) or C.mut
    local iconBg=mk("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,5,0.5,-18),BackgroundColor3=C.pan,BorderSizePixel=0},row)
    rnd(8,iconBg)
    local icon=getIcon(item.Name,item.Obj)
    if icon~="" then
        mk("ImageLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image=icon,ImageColor3=itemColor,ScaleType=Enum.ScaleType.Fit},iconBg)
    else
        local sq=mk("Frame",{Size=UDim2.new(0.65,0,0.65,0),Position=UDim2.new(0.175,0,0.175,0),BackgroundColor3=itemColor,BorderSizePixel=0},iconBg)
        rnd(4,sq)
    end

    local nameLbl=mk("TextLabel",{Text=item.Name,Size=UDim2.new(1,-106,1,0),Position=UDim2.new(0,47,0,0),BackgroundTransparency=1,TextColor3=C.txt,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},row)

    if curTab=="Finder" then
        local tpB=mk("TextButton",{Text="TP",Size=UDim2.new(0,38,0,30),Position=UDim2.new(1,-84,0.5,-15),BackgroundColor3=C.pan,TextColor3=C.mut,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},row)
        rnd(8,tpB); str(C.acc,1,tpB)
        local getB=mk("TextButton",{Text="Get",Size=UDim2.new(0,38,0,30),Position=UDim2.new(1,-42,0.5,-15),BackgroundColor3=C.acc,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},row)
        rnd(8,getB); str(C.aL,1,getB)

        tpB.MouseButton1Click:Connect(function()
            local hrp=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and item.Obj and item.Obj.Parent then
                hrp.CFrame=item.Obj.CFrame*CFrame.new(0,5,0)
                pcall(function() hrp.AssemblyLinearVelocity=Vector3.zero end)
            end
        end)
        getB.MouseButton1Click:Connect(function()
            getB.Text="..."; getB.BackgroundColor3=C.mut
            task.spawn(function()
                collect(item); task.wait(0.5)
                if win.Visible then refresh() end
            end)
        end)
    else
        local on=espState[item.Name]
        local espB=mk("TextButton",{Text=on and "ON" or "OFF",Size=UDim2.new(0,52,0,30),Position=UDim2.new(1,-60,0.5,-15),BackgroundColor3=on and C.grn or C.red,TextColor3=C.txt,Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},row)
        rnd(8,espB)
        espB.MouseButton1Click:Connect(function()
            espState[item.Name]=not espState[item.Name]; local s=espState[item.Name]
            espB.Text=s and "ON" or "OFF"; espB.BackgroundColor3=s and C.grn or C.red
            if s then if not espObjs[item.Obj] then espObjs[item.Obj]=mkESP(item.Obj,item.Name) end
            else rmESP(item.Obj) end
        end)
    end
end

refresh=function()
    scroll:ClearAllChildren()
    mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},scroll)
    mk("UIPadding",{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2)},scroll)
    items=findItems()
    countLbl.Text=#items.." items found"
    for _,item in ipairs(items) do makeRow(item) end
    scroll.CanvasSize=UDim2.new(0,0,0,#items*50+8)
    for _,item in ipairs(items) do
        if espState[item.Name] and not espObjs[item.Obj] then
            espObjs[item.Obj]=mkESP(item.Obj,item.Name)
        end
    end
end

local function setTab(t)
    curTab=t
    tFinder.BackgroundColor3=t=="Finder" and C.acc or C.pan; tFinder.TextColor3=t=="Finder" and C.txt or C.mut
    tESP.BackgroundColor3=t=="ESP" and C.acc or C.pan; tESP.TextColor3=t=="ESP" and C.txt or C.mut
    namesBtn.Visible=t=="ESP"; espAllBtn.Visible=t=="ESP"; botInfo.Visible=t=="Finder"
    refresh()
end

tog.MouseButton1Click:Connect(function() win.Visible=not win.Visible; if win.Visible then refresh() end end)
xBtn.MouseButton1Click:Connect(function() win.Visible=false end)
tFinder.MouseButton1Click:Connect(function() setTab("Finder") end)
tESP.MouseButton1Click:Connect(function() setTab("ESP") end)

namesBtn.MouseButton1Click:Connect(function()
    espNames=not espNames; namesBtn.Text="Names: "..(espNames and "ON" or "OFF")
    namesBtn.BackgroundColor3=espNames and C.grn or C.red
    for _,e in pairs(espObjs) do e.bb.Enabled=espNames end
end)

espAllBtn.MouseButton1Click:Connect(function()
    local allOn=true; for _,it in ipairs(items) do if not espState[it.Name] then allOn=false; break end end
    for _,it in ipairs(items) do
        espState[it.Name]=not allOn
        if not allOn then if not espObjs[it.Obj] then espObjs[it.Obj]=mkESP(it.Obj,it.Name) end
        else rmESP(it.Obj) end
    end
    espAllBtn.Text=allOn and "ESP All" or "ESP None"
    refresh()
end)

task.spawn(function()
    while true do task.wait(3); if win.Visible then refresh() end end
end)

_G.ItemFinderShow=function(v) win.Visible=v end