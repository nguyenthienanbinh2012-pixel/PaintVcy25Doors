local Obsidian = nil
local urls = {
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua",
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.luau",
    "https://gitlab.com/upio/obsidian/-/raw/main/Library.lua"
}
for _, url in ipairs(urls) do
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 1000 then
        local ok2, lib = pcall(function() return loadstring(res)() end)
        if ok2 and type(lib) == "table" then
            Obsidian = lib
            break
        end
    end
end

if not Obsidian then
    error("Không thể tải Obsidian từ bất kỳ nguồn nào! Kiểm tra mạng hoặc Executor.")
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Window = Obsidian:CreateWindow({
    Title = "PaintCrack1.5",
    SubTitle = "PaintVcyCrack",
    TabWidth = 150,
    Size = UDim2.new(0, 700, 0, 390),
    Center = true,
    AutoShow = true,
    MenuFadeTime = 0.10
})

local Tabs = {
    Info = Window:AddTab("Info", "user-check"),
    Function = Window:AddTab("Function", "user"),
    Visual = Window:AddTab("Visual", "eye"),
    Misc = Window:AddTab("Misc", "door"),
    Anti = Window:AddTab("Anti", "skull"),
    Settings = Window:AddTab("Settings", "cog"),
    }
local InfoGroup = Tabs.Info:AddLeftGroupbox("Player & Area Info")
local playerInfoLabel = InfoGroup:AddLabel("Player: " .. LocalPlayer.Name)
local floorInfoLabel = InfoGroup:AddLabel("Status: Crack Xcode Ho Tro Doors")
local loadedLabel = InfoGroup:AddLabel("<font color='#32FF64'><b>PaintVcy1.2 Loaded Successfully!</b></font>", true)

local noteGroup = Tabs.Info:AddRightGroupbox("Changelog")
noteGroup:AddLabel("<font color='#FF3232'><b>PaintV1.5 Fix + Add</b></font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Add Fly</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Add Axial Velocity</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Add Third Person</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Fix Book Esp[Floors1]</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Fix Bug Lag</font>", true)
noteGroup:AddLabel("<font color='#32FF64'>Thời điểm Fix + Add: 18/10/2026</font>", true)
local checkGroup = Tabs.Info:AddRightGroupbox("Check System")

local checkPlayerLabel = checkGroup:AddLabel("<font color='#32FF64'>Check Player: Đang quét...</font>", true)
local checkRoomLabel = checkGroup:AddLabel("<font color='#32FF64'>Check Room: Đang quét...</font>", true)
local checkEntityLabel = checkGroup:AddLabel("<font color='#32FF64'>Check Entity: Không có Entity</font>", true)
local checkAntiCheatLabel = checkGroup:AddLabel("<font color='#32FF64'><b>Check Anti Cheat: 0% (Ping: 0ms)</b></font>", true)

checkGroup:AddButton("Check Player", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            checkPlayerLabel:SetText(string.format("<font color='#32FF64'>Check Player: HP %d | Speed %d | Ping %dms</font>", math.floor(hum.Health), math.floor(hum.WalkSpeed), ping))
        end
    end
end)

checkGroup:AddButton("Check Room", function()
    local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
    local inGame = LocalPlayer:GetAttribute("InGame")
    checkRoomLabel:SetText(string.format("<font color='#32FF64'>Check Room: Room %s | Status: %s</font>", tostring(currentRoom or "Lobby"), tostring(inGame or "Sảnh")))
end)

local activeEntityName = nil
local entityTimeout = 0

local function onEntityDetected(inst)
    if not inst or not inst.Parent then return end
    local char = LocalPlayer.Character
    if char and inst:IsDescendantOf(char) then return end
    
    local hum = inst:FindFirstChildOfClass("Humanoid")
    local isEntity = false
    
    if hum and inst.Name ~= LocalPlayer.Name then
        isEntity = true
    elseif inst:FindFirstChild("Hitbox") or inst:FindFirstChild("EntityHitbox") then
        isEntity = true
    end

    if isEntity then
        activeEntityName = inst.Name
        entityTimeout = tick() + 4
        checkEntityLabel:SetText("<font color='#FF3232'><b>Check Entity: " .. tostring(inst.Name):upper() .. " ĐANG XUẤT HIỆN!</b></font>")
    end
end

Workspace.ChildAdded:Connect(function(inst) task.defer(function() onEntityDetected(inst) end) end)
Workspace.DescendantAdded:Connect(function(inst)
    if inst:IsA("Model") or inst:IsA("BasePart") then
        task.defer(function() onEntityDetected(inst) end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if activeEntityName and tick() > entityTimeout then
            activeEntityName = nil
            checkEntityLabel:SetText("<font color='#32FF64'>Check Entity: Không có Entity</font>")
        end
        
        pcall(function()
            local riskScore = 0
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            if ping > 250 then riskScore = riskScore + 50
            elseif ping > 150 then riskScore = riskScore + 30
            elseif ping > 80 then riskScore = riskScore + 10 end
            
            if hrp and hum then
                if hrp.AssemblyLinearVelocity.Magnitude > 50 then riskScore = riskScore + 30 end
                if hum.WalkSpeed > 30 then riskScore = riskScore + 15 end
                if hum.PlatformStand or char:FindFirstChild("PaintFlyAttachment") then riskScore = riskScore + 20 end
                
                if not _G.LastCheckPos then _G.LastCheckPos = hrp.Position end
                if (hrp.Position - _G.LastCheckPos).Magnitude > 50 then riskScore = riskScore + 40 end
                _G.LastCheckPos = hrp.Position
            end
            
            riskScore = math.clamp(riskScore, 0, 100)
            
            if riskScore > 60 then
                checkAntiCheatLabel:SetText(string.format("<font color='#FF0000'><b>Check Anti Cheat: %d%% (Ping: %dms)</b></font>", riskScore, ping))
            elseif riskScore > 30 then
                checkAntiCheatLabel:SetText(string.format("<font color='#FFAA00'><b>Check Anti Cheat: %d%% (Ping: %dms)</b></font>", riskScore, ping))
            else
                checkAntiCheatLabel:SetText(string.format("<font color='#32FF64'><b>Check Anti Cheat: %d%% (Ping: %dms)</b></font>", riskScore, ping))
            end
        end)
    end
end)

local FuncLeft = Tabs.Function:AddLeftGroupbox("Movement")
local FuncRight = Tabs.Function:AddRightGroupbox("Exploits")
local VisualLeft = Tabs.Visual:AddLeftGroupbox("Visual")
local VisualRight = Tabs.Visual:AddRightGroupbox("Lighting & Lag")
local MiscLeft = Tabs.Misc:AddLeftGroupbox("Stealth")
local MiscRight = Tabs.Misc:AddRightGroupbox("Utility & Auto")
local AntiLeft = Tabs.Anti:AddLeftGroupbox("Anti Entity")
local AntiRight = Tabs.Anti:AddRightGroupbox("Anti Trap")
local antiEyesActive = false
local antiDupeActive = false
local antiEyesConn = nil
local oldNamecall = nil

local function isEyesOrLook(name)
    local n = tostring(name or ""):lower()
    return n:find("eyes", 1, true) or n:find("lookman", 1, true) or n:find("look_man", 1, true)
end

local function isDupeOrVacuum(name)
    local n = tostring(name or ""):lower()
    return n:find("dupe", 1, true) or n:find("vacuum", 1, true) or n:find("fake", 1, true)
end

AntiLeft:AddToggle("AntiEyesLookToggle", {
    Text = "Anti Eyes & LookMan", Default = false,
    Tooltip = "Chan dame khi nhin, khong destroy entity"
}):OnChanged(function(v)
    antiEyesActive = v
    if v then
        pcall(function()
            local mt = getrawmetatable(game)
            if not oldNamecall then oldNamecall = mt.__namecall end
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if antiEyesActive and method == "Raycast" and self == Workspace then
                    local result = oldNamecall(self, ...)
                    if result and result.Instance then
                        local inst = result.Instance
                        local mod = inst:FindFirstAncestorOfClass("Model") or inst
                        if isEyesOrLook(mod.Name) or isEyesOrLook(inst.Name) then
                            return nil
                        end
                    end
                    return result
                end
                return oldNamecall(self, ...)
            end)
            setreadonly(mt, true)
        end)
        antiEyesConn = RunService.Heartbeat:Connect(function()
            if not antiEyesActive then return end
            pcall(function()
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if isEyesOrLook(obj.Name) then
                        for _, p in ipairs(obj:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanQuery = false
                                p.CanTouch = false
                            end
                        end
                    end
                end
            end)
        end)
    else
        if antiEyesConn then antiEyesConn:Disconnect() antiEyesConn = nil end
        pcall(function()
            if oldNamecall then
                local mt = getrawmetatable(game)
                setreadonly(mt, false)
                mt.__namecall = oldNamecall
                setreadonly(mt, true)
            end
        end)
    end
end)

AntiRight:AddToggle("AntiDupeVacuumToggle", {
    Text = "Anti Dupe & Vacuum", Default = false,
    Tooltip = "Chan tuong tac cua gia / vacuum"
}):OnChanged(function(v)
    antiDupeActive = v
    if v then
        task.spawn(function()
            while antiDupeActive do
                pcall(function()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                            local par = obj.Parent
                            local n = (par and par.Name or "") .. " " .. (obj.ActionText or "")
                            if isDupeOrVacuum(n) or isDupeOrVacuum(obj.ObjectText) then
                                obj.Enabled = false
                                obj.MaxActivationDistance = 0
                            end
                        end
                        if obj:IsA("BasePart") and isDupeOrVacuum(obj.Name) then
                            obj.CanTouch = false
                            obj.CanQuery = false
                        end
                        local mod = obj:IsA("Model") and obj or nil
                        if mod and isDupeOrVacuum(mod.Name) then
                            for _, p in ipairs(mod:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.CanTouch = false
                                    p.CanQuery = false
                                elseif p:IsA("ProximityPrompt") then
                                    p.Enabled = false
                                end
                            end
                        end
                    end
                end)
                task.wait(0.35)
            end
        end)
    end

    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://1548304764"
        sound.Volume = 4
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        task.delay(1.5, function()
            if sound then sound:Destroy() end
        end)
    end)
end)

task.spawn(function()
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        InfoGroup:AddImage("Avatar", {
            Image = thumb,
            Height = 110,
            Tooltip = "Your Avatar"
        })
    end)
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if playerInfoLabel then playerInfoLabel:SetText("Player: " .. LocalPlayer.Name) end
    end)
end)

local resetClickCount = 0
local resetClickTime = 0
local resetBtn = InfoGroup:AddButton("Reset Player", function()
    local now = tick()
    if now - resetClickTime > 2 then
        resetClickCount = 0
    end
    resetClickCount = resetClickCount + 1
    resetClickTime = now
    if resetClickCount == 1 then
        pcall(function()
            Obsidian:Notify({Title = "RESET", Description = "<font color='#FF3232'><b>Chắc Chắn Reset?</b></font>", Time = 2})
        end)
    elseif resetClickCount >= 2 then
        resetClickCount = 0
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local diedConn
                diedConn = hum.Died:Connect(function()
                    pcall(function()
                        hum:SetAttribute("DiedBy", "PaintCrack")
                        hum:SetAttribute("DeathCause", "Died By PaintCrack")
                    end)
                    if diedConn then diedConn:Disconnect() end
                end)
                pcall(function()
                    hum:SetAttribute("DiedBy", "PaintCrack")
                    hum:SetAttribute("DeathCause", "Died By PaintCrack")
                end)
                task.wait(0.1)
                hum.Health = 0
            end
        end
    end
end)

local ndOn = false
local ndConn, ndDesc, ndHumConn, ndHookConn = nil, nil, nil, nil
local ndTick, ndSaved = 0, {}
local ndChar = nil

local ndKeys = {"fire","flame","lava","burn","spike","debris","rock","fall","falling","seek","chase","running","damage","hurt","kill","touchdamage","touchhurt","blood"}

local function ndMatch(n)
    n = tostring(n or ""):lower()
    for i = 1, #ndKeys do
        if n:find(ndKeys[i], 1, true) then return true end
    end
    return false
end

local function ndKill(obj)
    if not obj or not obj.Parent then return end
    pcall(function()
        if obj:IsA("BasePart") then
            if ndSaved[obj] == nil then
                ndSaved[obj] = {t = obj.CanTouch, c = obj.CanCollide}
            end
            obj.CanTouch = false
        elseif obj:IsA("Script") or obj:IsA("LocalScript") then
            obj.Disabled = true
        elseif obj:IsA("ScreenGui") then
            obj.Enabled = false
        elseif obj:IsA("GuiObject") then
            obj.Visible = false
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        end
    end)
end

local function ndHookHum(hum)
    if not hum then return end
    if ndHumConn then ndHumConn:Disconnect() end
    ndHumConn = hum.HealthChanged:Connect(function(newH)
        if not ndOn then return end
        if newH < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
    if not ndHookConn then
        ndHookConn = RunService.Heartbeat:Connect(function()
            if not ndOn then return end
            local c = LocalPlayer.Character
            if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid")
            if h and h.Health < h.MaxHealth then
                pcall(function() h.Health = h.MaxHealth end)
            end
        end)
    end
end

local function ndBindChar(c)
    if not c then return end
    ndChar = c
    local h = c:WaitForChild("Humanoid", 5)
    if h then ndHookHum(h) end
end

if LocalPlayer.Character then ndBindChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(ndBindChar)

local ndTog = VisualRight:AddToggle("NoDameRunningSeekToggle", {
    Text = "No Dame Running Screen Seek",
    Default = false
})

ndTog:OnChanged(function(v)
    ndOn = v
    if v then
        task.spawn(function()
            local i = 0
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if not ndOn then break end
                if ndMatch(obj.Name) then ndKill(obj) end
                i = i + 1
                if i % 200 == 0 then RunService.Heartbeat:Wait() end
            end
            for _, obj in ipairs(PlayerGui:GetDescendants()) do
                if not ndOn then break end
                if ndMatch(obj.Name) then ndKill(obj) end
                i = i + 1
                if i % 200 == 0 then RunService.Heartbeat:Wait() end
            end
        end)

        ndDesc = Workspace.DescendantAdded:Connect(function(d)
            if ndOn and ndMatch(d.Name) then
                task.defer(ndKill, d)
            end
        end)

        ndConn = RunService.Heartbeat:Connect(function()
            if not ndOn then return end
            ndTick = ndTick + 1
            if ndTick % 18 ~= 0 then return end
            local hrp = ndChar and ndChar:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local pos = hrp.Position
            local parts = Workspace:GetPartBoundsInRadius(pos, 60)
            for _, p in ipairs(parts) do
                if p.CanTouch and ndMatch(p.Name) then
                    if ndSaved[p] == nil then
                        ndSaved[p] = {t = p.CanTouch, c = p.CanCollide}
                    end
                    p.CanTouch = false
                end
            end
            local h = ndChar and ndChar:FindFirstChildOfClass("Humanoid")
            if h and h.Health < h.MaxHealth then
                pcall(function() h.Health = h.MaxHealth end)
            end
        end)
    else
        if ndConn then ndConn:Disconnect() ndConn = nil end
        if ndDesc then ndDesc:Disconnect() ndDesc = nil end
        if ndHumConn then ndHumConn:Disconnect() ndHumConn = nil end
        if ndHookConn then ndHookConn:Disconnect() ndHookConn = nil end
        ndTick = 0
        for p, d in pairs(ndSaved) do
            if p and p.Parent then
                pcall(function()
                    p.CanTouch = d.t
                    p.CanCollide = d.c
                end)
            end
        end
        ndSaved = {}
    end
end)  
local function getCrouchRemote()
    local char = LocalPlayer.Character
    if char then
        local c1 = char:FindFirstChild("Crouch")
        if c1 and c1:IsA("RemoteEvent") then return c1 end
        local c2 = char:FindFirstChild("crouch")
        if c2 and c2:IsA("RemoteEvent") then return c2 end
    end
    local remotes = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
    local names = {"Crouch", "crouch", "CrouchRemote", "CrouchEvent"}
    for _, n in ipairs(names) do
        local r = remotes:FindFirstChild(n)
        if r and r:IsA("RemoteEvent") then return r end
    end
    return nil
end

local function safeUnlockCharacter()
    pcall(function()
        ContextActionService:UnbindAction("DisableInputs")
    end)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.PlatformStand = false
        end
        if hrp then hrp.Anchored = false end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
                p.CustomPhysicalProperties = nil
            end
        end
    end
end

local function lockInputs(lock)
    if lock then
        ContextActionService:BindActionAtPriority(
            "DisableInputs",
            function() return Enum.ContextActionResult.Sink end,
            false,
            3000,
            Enum.PlayerActions.CharacterForward,
            Enum.PlayerActions.CharacterBackward,
            Enum.PlayerActions.CharacterLeft,
            Enum.PlayerActions.CharacterRight,
            Enum.PlayerActions.CharacterJump
        )
    else
        safeUnlockCharacter()
    end
end

local S = {
    char = nil, hrp = nil, humanoid = nil, loaded = false, enabled = false,
    baseY = nil, DEPTH = 2.346, c1Origin = nil, crouchConn = nil,
    uiWidget = nil, uiLabel = nil, uiStroke = nil, updateConn = nil,
}

local function loadPositionSpoof()
    if S.loaded then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not hrp or not humanoid then return end
    S.char = char; S.hrp = hrp; S.humanoid = humanoid
    local t0 = tick()
    while tick() - t0 < 5 do
        if humanoid.FloorMaterial ~= Enum.Material.Air then break end
        task.wait(0.1)
    end
    task.wait(0.3)
    for _, n in ipairs({"CollisionPart", "Collision"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then p.CanCollide = false end
    end
    hrp.Anchored = true
    hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + 2.34, hrp.Position.Z)
    task.wait(0.05)
    hrp.Anchored = false
    humanoid.HipHeight = 2.396
    local t1 = tick()
    while tick() - t1 < 3 do
        if math.abs(hrp.Position.Y) < 1 then break end
        task.wait(0.05)
    end
    task.wait(0.3)
    local crouchRemote = getCrouchRemote()
    if crouchRemote then
        pcall(function() crouchRemote:FireServer(true, true) end)
    end
    task.wait(0.3)
    for _, n in ipairs({"CollisionPartClone", "CollisionClone"}) do
        local old = char:FindFirstChild(n)
        if old then old:Destroy() end
    end
    local cpClone = Instance.new("Part")
    cpClone.Name = "CollisionPartClone"
    cpClone.Size = Vector3.new(1, 1, 1)
    cpClone.Transparency = 1
    cpClone.CanCollide = false
    cpClone.CanQuery = true
    cpClone.CanTouch = true
    cpClone.Massless = true
    cpClone.Anchored = false
    cpClone.Parent = char
    pcall(function() cpClone.CollisionGroup = "Player" end)
    local w1 = Instance.new("Weld")
    w1.Part0 = cpClone; w1.Part1 = hrp
    w1.C0 = CFrame.new(0, 0.271744013, 0); w1.C1 = CFrame.new()
    w1.Parent = cpClone
    local collision = char:FindFirstChild("Collision")
    local colSize = collision and collision.Size or Vector3.new(5.5, 3, 3)
    local ccClone = Instance.new("Part")
    ccClone.Name = "CollisionClone"
    ccClone.Size = colSize
    ccClone.Transparency = 1
    ccClone.CanCollide = false
    ccClone.CanQuery = true
    ccClone.CanTouch = true
    ccClone.Massless = true
    ccClone.Anchored = false
    ccClone.Parent = char
    pcall(function() ccClone.CollisionGroup = "Player" end)
    local w2 = Instance.new("Weld")
    w2.Part0 = ccClone; w2.Part1 = hrp
    w2.C0 = CFrame.new(0, 0.0905, 0); w2.C1 = CFrame.new()
    w2.Parent = ccClone
    local cpOrig = char:FindFirstChild("CollisionPart")
    if cpOrig then char.PrimaryPart = cpOrig end
    S.loaded = true
end

local function createFloatingWidget()
    if S.uiWidget then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpoofWidgetGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 200
    local frame = Instance.new("Frame")
    frame.Name = "WidgetFrame"
    frame.Size = UDim2.new(0, 150, 0, 36)
    frame.Position = UDim2.new(0.05, 0, 0.4, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.ZIndex = 500
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 18); corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Name = "WidgetStroke"; stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 50, 50); stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = "WidgetLabel"
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "HRP.Y: 0.00"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.ZIndex = 501; label.Parent = frame
    gui.Parent = PlayerGui
    frame.Parent = gui
    S.uiWidget = gui; S.uiLabel = label; S.uiStroke = stroke
end

local function destroyFloatingWidget()
    if S.uiWidget then
        S.uiWidget:Destroy()
        S.uiWidget = nil; S.uiLabel = nil; S.uiStroke = nil
    end
end

local function togglePositionSpoof(enable)
    if enable then
        if S.enabled or not S.loaded then return end
        if not S.hrp or not S.humanoid then return end
        S.enabled = true
        local char = S.char; local hrp = S.hrp; local humanoid = S.humanoid
        local crouchRemote = getCrouchRemote()
        local baseY = hrp.Position.Y
        local spoofY = baseY - S.DEPTH
        S.baseY = baseY
        hrp.CFrame = CFrame.new(hrp.Position.X, spoofY, hrp.Position.Z)
        humanoid.HipHeight = 0.05
        if crouchRemote then
            pcall(function() crouchRemote:FireServer(true, true) end)
        end
        local lt = char:FindFirstChild("LowerTorso")
        if lt then
            for _, m in ipairs(lt:GetChildren()) do
                if m:IsA("Motor6D") and m.Name == "Root" then
                    S.c1Origin = m.C1
                    m.C1 = CFrame.new(S.c1Origin.X, S.c1Origin.Y - S.DEPTH, S.c1Origin.Z)
                    break
                end
            end
        end
        local cp = char:FindFirstChild("CollisionPart")
        if cp then
            for _, w in ipairs(cp:GetChildren()) do
                if w:IsA("Weld") and w.Part1 == hrp then
                    local cpBaseY = baseY - 0.31
                    w.C0 = CFrame.new(w.C0.X, spoofY - cpBaseY, w.C0.Z)
                end
            end
        end
        if S.crouchConn then S.crouchConn:Disconnect() end
        S.crouchConn = RunService.Heartbeat:Connect(function()
            if not S.enabled then return end
            S._last = S._last or 0
            if tick() - S._last > 0.1 then
                S._last = tick()
                local cr = getCrouchRemote()
                if cr then pcall(function() cr:FireServer(true, true) end) end
            end
        end)
        createFloatingWidget()
        S.updateConn = RunService.RenderStepped:Connect(function()
            if not S.enabled or not hrp or not hrp.Parent then return end
            local relY = hrp.Position.Y - S.baseY
            if S.uiLabel and S.uiStroke then
                S.uiLabel.Text = string.format("HRP.Y: %.2f", relY)
                if relY > -1.00 then
                    S.uiStroke.Color = Color3.fromRGB(255, 50, 50)
                elseif relY > -2.20 then
                    S.uiStroke.Color = Color3.fromRGB(255, 200, 0)
                else
                    S.uiStroke.Color = Color3.fromRGB(50, 255, 100)
                end
            end
        end)
    else
        if not S.enabled then return end
        S.enabled = false
        if S.crouchConn then S.crouchConn:Disconnect() S.crouchConn = nil end
        if S.updateConn then S.updateConn:Disconnect() S.updateConn = nil end
        local char = S.char; local hrp = S.hrp; local humanoid = S.humanoid
        local crouchRemote = getCrouchRemote()
        if char then
            local lt = char:FindFirstChild("LowerTorso")
            if lt and S.c1Origin then
                for _, m in ipairs(lt:GetChildren()) do
                    if m:IsA("Motor6D") and m.Name == "Root" then
                        m.C1 = S.c1Origin
                    end
                end
            end
        end
        if hrp and hrp.Parent then
            pcall(function()
                hrp.CFrame = CFrame.new(hrp.Position.X, S.baseY or hrp.Position.Y, hrp.Position.Z)
            end)
        end
        if humanoid and humanoid.Parent then
            pcall(function() humanoid.HipHeight = 2.396 end)
        end
        if crouchRemote then
            pcall(function() crouchRemote:FireServer(false, true) end)
        end
        destroyFloatingWidget()
    end
end

task.spawn(loadPositionSpoof)
LocalPlayer.CharacterAdded:Connect(function()
    S.loaded = false
    task.delay(1, loadPositionSpoof)
end)

local velocityConn = nil
local speedConn = nil
local remoteThreadSpeed = nil
local remoteThreadVel = nil
local isSpeedActive = false
local isVelocityActive = false
local velocitySpeedVal = 6.5
local targetWalkSpeed = 16
local velocitySavedCanCollide = {}

local axialActive = false
local axialSpeed = 6.0
local axialConn = nil
local axialSaved = setmetatable({}, {__mode = "k"})

local function stopAxial()
    axialActive = false
    if axialConn then axialConn:Disconnect() axialConn = nil end
    for part, data in pairs(axialSaved) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = data.CanCollide
                part.CanQuery = data.CanQuery
                part.CanTouch = data.CanTouch
                part.Transparency = data.Transparency
            end)
        end
    end
    axialSaved = setmetatable({}, {__mode = "k"})
    safeUnlockCharacter()
end

local function startAxial()
    stopAxial()
    axialActive = true
    local cam = Workspace.CurrentCamera
    axialConn = RunService.Heartbeat:Connect(function()
        if not axialActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                if axialSaved[p] == nil then
                    axialSaved[p] = {
                        CanCollide = p.CanCollide,
                        CanQuery = p.CanQuery,
                        CanTouch = p.CanTouch,
                        Transparency = p.Transparency,
                    }
                end
                p.CanCollide = false
                p.CanQuery = false
                p.CanTouch = false
                p.Transparency = 1
            end
        end
        for _, n in ipairs({"Collision", "CollisionPart", "CollisionClone", "CollisionPartClone"}) do
            local sp = char:FindFirstChild(n)
            if sp and sp:IsA("BasePart") then
                if axialSaved[sp] == nil then
                    axialSaved[sp] = {
                        CanCollide = sp.CanCollide,
                        CanQuery = sp.CanQuery,
                        CanTouch = sp.CanTouch,
                        Transparency = sp.Transparency,
                    }
                end
                sp.CanCollide = false
                sp.CanQuery = false
                sp.CanTouch = false
                sp.Transparency = 1
            end
        end

        hum.WalkSpeed = 0
        local look = cam.CFrame.LookVector
        hrp.CFrame = hrp.CFrame + look * (axialSpeed * (1/60))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

local axialToggle = FuncLeft:AddToggle("AxialVelocityToggle", {
    Text = "Axial Velocity", Default = false,
    Tooltip = "Di chuyen 6.0 theo huong cam, xuyen vat can tranh keo lui"
})
local axialSlider = FuncLeft:AddSlider("AxialSpeedSlider", {
    Text = "Axial Speed", Default = 6.0, Min = 6.0, Max = 8.0, Rounding = 1, Compact = true
})
axialSlider:OnChanged(function(v) axialSpeed = v end)

axialToggle:OnChanged(function(Value)
    if Value then startAxial() else stopAxial() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if axialActive then
        task.wait(1)
        if axialToggle.Value then startAxial() end
    end
end)

local noClipActive = false
local noClipSavedCanCollide = {}
local noClipToggle = FuncLeft:AddToggle("NoClipToggle", {
    Text = "No Clip", Default = false,
    Tooltip = "Di xuyen qua vat the nho"
})
noClipToggle:OnChanged(function(Value)
    noClipActive = Value
    local char = LocalPlayer.Character
    if Value then
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if noClipSavedCanCollide[p] == nil then
                        noClipSavedCanCollide[p] = {
                            CanCollide = p.CanCollide, CanQuery = p.CanQuery, CanTouch = p.CanTouch
                        }
                    end
                    p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
                end
            end
            for _, n in ipairs({"Collision","CollisionPart","CollisionClone","CollisionPartClone"}) do
                local spPart = char:FindFirstChild(n)
                if spPart and spPart:IsA("BasePart") then
                    if noClipSavedCanCollide[spPart] == nil then
                        noClipSavedCanCollide[spPart] = {
                            CanCollide = spPart.CanCollide, CanQuery = spPart.CanQuery, CanTouch = spPart.CanTouch
                        }
                    end
                    spPart.CanCollide = false; spPart.CanQuery = false; spPart.CanTouch = false
                end
            end
        end
    else
        for part, data in pairs(noClipSavedCanCollide) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
                part.CanQuery = data.CanQuery
                part.CanTouch = data.CanTouch
            end
        end
        noClipSavedCanCollide = {}
        safeUnlockCharacter()
    end
end)

local positionSpoofToggle = FuncLeft:AddToggle("PositionSpoofToggle", {
    Text = "Position Spoof", Default = false,
    Tooltip = "Gia Mao vi tri,danh lua sever va entity"
})
positionSpoofToggle:OnChanged(function(Value)
    togglePositionSpoof(Value)
end)

local flyActive = false
local flySpeed = 30
local flyVelocity = nil
local flyAttachment = nil
local flyUpdateConn = nil
local flyInputConn = nil

local function stopFly()
    flyActive = false
    if flyUpdateConn then flyUpdateConn:Disconnect() flyUpdateConn = nil end
    if flyInputConn then flyInputConn:Disconnect() flyInputConn = nil end
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
    if flyAttachment then flyAttachment:Destroy() flyAttachment = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.WalkSpeed = 16
        end
    end
end

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    stopFly()
    flyActive = true
    hum.PlatformStand = true
    hum.WalkSpeed = 0

    flyAttachment = Instance.new("Attachment")
    flyAttachment.Name = "PaintFlyAttachment"
    flyAttachment.Parent = hrp

    flyVelocity = Instance.new("LinearVelocity")
    flyVelocity.Name = "PaintFlyVelocity"
    flyVelocity.Attachment0 = flyAttachment
    flyVelocity.MaxForce = math.huge
    flyVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    flyVelocity.VectorVelocity = Vector3.zero
    flyVelocity.Parent = hrp

    local function getCameraRelativeInput()
        local md = hum.MoveDirection
        if md.Magnitude < 0.05 then return 0, 0 end
        local cam = Workspace.CurrentCamera
        if not cam then return 0, 0 end
        local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
        if flatLook.Magnitude > 0 then flatLook = flatLook.Unit end
        local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
        if flatRight.Magnitude > 0 then flatRight = flatRight.Unit end
        local forward = md:Dot(flatLook)
        local strafe = md:Dot(flatRight)
        return forward, strafe
    end

    flyUpdateConn = RunService.RenderStepped:Connect(function()
        if not flyActive or not flyVelocity or not flyVelocity.Parent then
            stopFly()
            return
        end
        local cam = Workspace.CurrentCamera
        if not cam then return end

        local forward, strafe = getCameraRelativeInput()
local look = cam.CFrame.LookVector
local right = cam.CFrame.RightVector
local moveDir = Vector3.zero

        if forward ~= 0 or strafe ~= 0 then
            moveDir = look * forward + right * strafe

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit
            end
        end

        local vertical = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vertical = vertical + 1
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            vertical = vertical - 1
        end

        local finalDir = moveDir

        if vertical ~= 0 then
            finalDir = finalDir + Vector3.new(0, vertical, 0)
        end

        if finalDir.Magnitude > 0 then
            finalDir = finalDir.Unit
                end
end

flyVelocity.VectorVelocity = finalDir * flySpeed

local flyToggle = FuncLeft:AddToggle("FlyToggle", {
    Text = "Fly", Default = false,
    Tooltip = "Giup Nhan Vat Bay"
})
local flySlider = FuncLeft:AddSlider("FlySpeedSlider", {
    Text = "Fly Speed", Default = 30, Min = 25, Max = 80, Rounding = 1, Compact = true
})
flySlider:OnChanged(function(v) flySpeed = v end)

flyToggle:OnChanged(function(Value)
    if Value then startFly() else stopFly() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if flyActive then
        task.wait(1)
        if flyToggle.Value then startFly() end
    end
end)

local speedMethod = "Boost"
local speedMethodDropdown = FuncRight:AddDropdown("SpeedMethodDropdown", {
    Text = "Speed Method",
    Values = {"Boost", "Instant"},
    Default = 1,
    Tooltip = "Boost: tang toc tu tu | Instant: chay nhanh ngay"
})
speedMethodDropdown:OnChanged(function(Value) speedMethod = Value end)

local speedToggle = FuncRight:AddToggle("SpeedBypassToggle", {
    Text = "Speed", Default = false,
    Tooltip = "Doi WalkSpeed tuy chinh tang toc tu tu hoac tuc thi"
})
speedToggle:OnChanged(function(Value)
    isSpeedActive = Value
    if Value then
        speedConn = RunService.PreRender:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if speedMethod == "Instant" then
                    hum.WalkSpeed = targetWalkSpeed
                else
                    if hum.WalkSpeed < targetWalkSpeed then
                        hum.WalkSpeed = math.min(hum.WalkSpeed + 1.5, targetWalkSpeed)
                    elseif hum.WalkSpeed > targetWalkSpeed then
                        hum.WalkSpeed = targetWalkSpeed
                    end
                end
            end
        end)
        remoteThreadSpeed = task.spawn(function()
            while isSpeedActive do
                if not S.enabled then
                    local cr = getCrouchRemote()
                    if cr then pcall(function() cr:FireServer(false, true) end) end
                end
                task.wait(0.4)
            end
        end)
    else
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if remoteThreadSpeed then task.cancel(remoteThreadSpeed) remoteThreadSpeed = nil end
        safeUnlockCharacter()
    end
end)
local thirdPersonActive = false
local thirdPersonConn = nil
local thirdPersonZ = 8
local thirdPersonSens = 0.6
local yaw, pitch = 0, 0
local cam = Workspace.CurrentCamera

local thirdPersonToggle = FuncRight:AddToggle("ThirdPersonToggle", {
    Text = "Third Person", Default = false,
    Tooltip = "Ho Tro Goc nhin So 3 của Game Doors"
})
FuncRight:AddSlider("ThirdPersonZSlider", {
    Text = "Z offset Cam", Default = 8, Min = 1, Max = 20, Rounding = 1, Compact = true
}):OnChanged(function(v) thirdPersonZ = v end)
FuncRight:AddSlider("ThirdPersonSensSlider", {
    Text = "Do Nhay Cua Camera", Default = 3, Min = 1.0, Max = 3.75, Rounding = 2, Compact = true
}):OnChanged(function(v) thirdPersonSens = v end)

thirdPersonToggle:OnChanged(function(Value)
    thirdPersonActive = Value
    if Value then
        cam.CameraType = Enum.CameraType.Scriptable
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end
        thirdPersonConn = RunService.RenderStepped:Connect(function()
            if not thirdPersonActive then return end
            local char = LocalPlayer.Character
            if not char then return end
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not head or not hrp then return end
            local focus = head.Position
            local cf = CFrame.new(focus) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0) * CFrame.new(0, 0, thirdPersonZ)
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local ray = Workspace:Raycast(focus, (cf.Position - focus), params)
            if ray then
                cf = CFrame.new(ray.Position + ray.Normal * 0.5) * (cf - cf.Position)
            end
            cam.CFrame = cf
            hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, yaw, 0)
        end)
    else
        if thirdPersonConn then thirdPersonConn:Disconnect() thirdPersonConn = nil end
        cam.CameraType = Enum.CameraType.Custom
    end
end)

UserInputService.InputChanged:Connect(function(input, gp)
    if gp or not thirdPersonActive then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        yaw = yaw - input.Delta.X * 0.003 * thirdPersonSens
        pitch = math.clamp(pitch - input.Delta.Y * 0.003 * thirdPersonSens, -1.2, 1.2)
    elseif input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.X > cam.ViewportSize.X * 0.35 then
            yaw = yaw - input.Delta.X * 0.004 * thirdPersonSens
            pitch = math.clamp(pitch - input.Delta.Y * 0.004 * thirdPersonSens, -1.2, 1.2)
        end
    end
end)

FuncRight:AddSlider("SpeedBypassSlider", {
    Text = "Speed Val", Default = 16, Min = 0, Max = 80, Rounding = 1, Compact = true
}):OnChanged(function(Value) targetWalkSpeed = Value end)

local paintEspToggle = VisualLeft:AddToggle("PaintEspToggle", {
    Text = "Paint ESP", Default = false, Tooltip = "Load PaintDoorsVisual"
})
local paintEspLoaded = false
paintEspToggle:OnChanged(function(Value)
    if Value then
        if not paintEspLoaded then
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/nguyenthienanbinh2012-pixel/PaintDoorsVisual/refs/heads/main/VisualEspDoors.lua"))()
            end)
            paintEspLoaded = true
        end
    else
        pcall(function()
            local cg = game:GetService("CoreGui")
            for _, gui in ipairs(cg:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    local n = gui.Name:lower()
                    if n:find("paint") or n:find("visual") or n:find("esp") then
                        gui:Destroy()
                    end
                end
            end
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                for _, gui in ipairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local n = gui.Name:lower()
                        if n:find("paint") or n:find("visual") or n:find("esp") then
                            gui:Destroy()
                        end
                    end
                end
            end
        end)
        paintEspLoaded = false
    end
end)

local bookEspActive = false
local bookEspConnections = {}
local bookEspCache = setmetatable({}, {__mode = "k"})
local bookEspUpdateConn = nil

local function createBookEsp(bookObj)
    if not bookObj or not bookObj.Parent then return end
    if bookEspCache[bookObj] then return end

    local prompt = bookObj:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt or not prompt.Enabled then return end
    local actionText = tostring(prompt.ActionText or ""):lower()
    if not actionText:find("read") and not actionText:find("book") and not actionText:find("take") then
        return
    end

    -- Hiệu ứng Highlight ma mị
    local highlight = Instance.new("Highlight")
    highlight.Name = "BookEspHighlight"
    highlight.FillColor = Color3.fromRGB(0, 255, 100)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(0, 255, 150)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = bookObj

    -- Bảng thông tin
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BookEspBillboard"
    billboard.Size = UDim2.new(0, 100, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Book [--m]"
    textLabel.TextColor3 = Color3.fromRGB(50, 255, 100) -- Xanh lá ma mị
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 50, 0) -- Viền xanh đen
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard

    local holder = nil
    if bookObj:IsA("BasePart") then
        holder = bookObj
    elseif bookObj:IsA("Model") and bookObj.PrimaryPart then
        holder = bookObj.PrimaryPart
    elseif bookObj:IsA("Model") then
        holder = bookObj:FindFirstChildWhichIsA("BasePart")
    end

    if holder then
        billboard.Parent = holder
        bookEspCache[bookObj] = {
            billboard = billboard,
            highlight = highlight,
            label = textLabel
        }
    end
end

local function removeBookEsp()
    if bookEspUpdateConn then bookEspUpdateConn:Disconnect() bookEspUpdateConn = nil end
    for obj, data in pairs(bookEspCache) do
        if data.billboard and data.billboard.Parent then data.billboard:Destroy() end
        if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
    end
    bookEspCache = setmetatable({}, {__mode = "k"})
end

local bookEspToggle = VisualLeft:AddToggle("BookEspToggle", {
    Text = "Book ESP (Room 50)", Default = false,
    Tooltip = "ESP sach ma mi, do khoang cach [m]"
})

bookEspToggle:OnChanged(function(Value)
    bookEspActive = Value
    if Value then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                local actionText = tostring(desc.ActionText or ""):lower()
                if actionText:find("read") or actionText:find("book") or actionText:find("take") then
                    local target = desc.Parent
                    if target then
                        pcall(function() createBookEsp(target) end)
                    end
                end
            end
        end

        table.insert(bookEspConnections, Workspace.DescendantAdded:Connect(function(desc)
            if not bookEspActive then return end
            if desc:IsA("ProximityPrompt") then
                local actionText = tostring(desc.ActionText or ""):lower()
                if actionText:find("read") or actionText:find("book") or actionText:find("take") then
                    local target = desc.Parent
                    if target then
                        task.defer(function() 
                            pcall(function() createBookEsp(target) end)
                        end)
                    end
                end
            end
        end))

        -- Cập nhật khoảng cách [m] liên tục (tối ưu 0.5s/lần)
        local tickCount = 0
        bookEspUpdateConn = RunService.RenderStepped:Connect(function()
            tickCount = tickCount + 1
            if tickCount % 30 ~= 0 then return end
            
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for obj, data in pairs(bookEspCache) do
                if data.label and data.label.Parent and obj.Parent then
                    local targetPart = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                    if targetPart then
                        local dist = math.floor((hrp.Position - targetPart.Position).Magnitude)
                        data.label.Text = string.format("Book [%dm]", dist)
                    end
                end
            end
        end)
    else
        for _, conn in ipairs(bookEspConnections) do
            if conn then conn:Disconnect() end
        end
        bookEspConnections = {}
        removeBookEsp()
    end
end)

local seeThroughActive = false
local seeThroughVal = 0.5
local seeThroughConn = nil
local seeThroughTick = 0
local cachedWardrobes = {}
local cacheBuilt = false

local function buildWardrobeCache()
    cachedWardrobes = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local n = obj.Name:lower()
            if n:find("wardrobe") or n:find("closet") or n:find("hide") or n:find("locker") then
                local pivotPos = nil
                pcall(function() pivotPos = obj:GetPivot().Position end)
                if not pivotPos then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary then pivotPos = primary.Position end
                end
                if pivotPos then
                    local parts = {}
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                            parts[#parts + 1] = p
                        end
                    end
                    cachedWardrobes[#cachedWardrobes + 1] = {
                        position = pivotPos,
                        parts = parts,
                    }
                end
            end
        end
    end
    cacheBuilt = true
end

local seeThroughToggle = VisualLeft:AddToggle("SeeThroughHidingToggle", {
    Text = "See-through while hiding", Default = false,
    Tooltip = "Chi lam mo tu khi nhan vat thuc su dang tron ben trong"
})
local seeThroughSlider = VisualLeft:AddSlider("SeeThroughSlider", {
    Text = "Opacity Val", Default = 0.5, Min = 0.1, Max = 1.0, Rounding = 1, Compact = true
})
seeThroughSlider:OnChanged(function(v) seeThroughVal = v end)
seeThroughToggle:OnChanged(function(Value)
    seeThroughActive = Value
    if Value then
        if not cacheBuilt then
            task.spawn(buildWardrobeCache)
        end
        seeThroughConn = RunService.Heartbeat:Connect(function()
            if not seeThroughActive then return end
            seeThroughTick = seeThroughTick + 1
            if seeThroughTick % 30 ~= 0 then return end

            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local hrp = char.HumanoidRootPart

            local isHiding = false
            pcall(function()
                local hiding = char:GetAttribute("Hiding") or char:GetAttribute("IsHiding")
                if hiding then isHiding = true end
            end)
            if not isHiding then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Sit then isHiding = true end
            end

            for _, data in ipairs(cachedWardrobes) do
                local near = (hrp.Position - data.position).Magnitude < 4.5
                local shouldFade = isHiding and near
                for _, p in ipairs(data.parts) do
                    if p and p.Parent then
                        p.Transparency = shouldFade and seeThroughVal or 0
                    end
                end
            end
        end)
    else
        if seeThroughConn then
            seeThroughConn:Disconnect()
            seeThroughConn = nil
        end
        for _, data in ipairs(cachedWardrobes) do
            for _, p in ipairs(data.parts) do
                if p and p.Parent then
                    p.Transparency = 0
                end
            end
        end
        cachedWardrobes = {}
        cacheBuilt = false
        seeThroughTick = 0
    end
end)

local fullBrightConn = nil
local fullBrightActive = false
local fullBrightLevel = 2
local fullBrightToggle = VisualRight:AddToggle("FullBrightToggle", {
    Text = "Full Bright", Default = false, Tooltip = "Lam sang moi truong"
})
local fullBrightSlider = VisualRight:AddSlider("FullBrightSlider", {
    Text = "Brightness", Default = 2, Min = 0.5, Max = 10, Rounding = 1, Compact = true
})
fullBrightSlider:OnChanged(function(Value) fullBrightLevel = Value end)
fullBrightToggle:OnChanged(function(Value)
    fullBrightActive = Value
    if Value then
        if not fullBrightConn then
            fullBrightConn = RunService.RenderStepped:Connect(function()
                if not fullBrightActive then return end
                pcall(function()
                    Lighting.Brightness = fullBrightLevel
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 1000000
                    Lighting.FogStart = 0
                    Lighting.GlobalShadows = false
                    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                    Lighting.EnvironmentDiffuseScale = 1
                    Lighting.EnvironmentSpecularScale = 1
                    Lighting.Ambient = Color3.fromRGB(200, 200, 200)
                end)
            end)
        end
    else
        if fullBrightConn then
            fullBrightConn:Disconnect()
            fullBrightConn = nil
        end
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

local antiLagActive = false
local antiLagDescConn = nil
local originalLightingState = {}
local originalPostEffects = {}
local originalPartProps = setmetatable({}, {__mode = "k"})
local antiLagProcessed = setmetatable({}, {__mode = "k"})

local function applyAntiLagToPart(part)
local model = part:FindFirstAncestorOfClass("Model")
if model then
    local n = model.Name:lower()
    if n:find("rush") or n:find("ambush") or n:find("seek") or n:find("figure")
        or n:find("screech") or n:find("halt") or n:find("eyes") or n:find("lookman")
        or n:find("dread") or n:find("timothy") or n:find("jack") or n:find("dupe")
        or n:find("a-90") or n:find("a90") or n:find("glitch") or n:find("vacuum") then
        return
    end
                    end
    if not part or not part.Parent then return end
    if antiLagProcessed[part] then return end
    if part.Name == "HumanoidRootPart" or part.Name == "Baseplate" then return end
    local char = LocalPlayer.Character
    if char and part:IsDescendantOf(char) then return end
    antiLagProcessed[part] = true
    if originalPartProps[part] == nil then
        originalPartProps[part] = {
            Material = part.Material,
            CastShadow = part.CastShadow,
            Reflectance = part.Reflectance,
            TextureID = part:IsA("MeshPart") and part.TextureID or nil,
        }
    end
    part.Material = Enum.Material.SmoothPlastic
    part.CastShadow = false
    part.Reflectance = 0
    if part:IsA("MeshPart") and part.TextureID ~= "" then
        part.TextureID = ""
    end
    end
local function applyAntiLagToEffect(effect)
    if not effect or not effect.Parent then return end
    if antiLagProcessed[effect] then return end
    antiLagProcessed[effect] = true
    if effect:IsA("ParticleEmitter") or effect:IsA("Smoke") or effect:IsA("Fire")
        or effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("Sparkles") then
        if originalPartProps[effect] == nil then
            originalPartProps[effect] = {Enabled = effect.Enabled}
        end
        effect.Enabled = false
    end
end

local function restoreAntiLag()
    for obj, data in pairs(originalPartProps) do
        if obj and obj.Parent then
            pcall(function()
                if data.Material ~= nil then obj.Material = data.Material end
                if data.CastShadow ~= nil then obj.CastShadow = data.CastShadow end
                if data.Reflectance ~= nil then obj.Reflectance = data.Reflectance end
                if data.TextureID and obj:IsA("MeshPart") then obj.TextureID = data.TextureID end
                if data.Enabled ~= nil then obj.Enabled = data.Enabled end
            end)
        end
    end
    originalPartProps = setmetatable({}, {__mode = "k"})
    antiLagProcessed = setmetatable({}, {__mode = "k"})
end

local antiLagToggle = MiscLeft:AddToggle("AntiLagToggle", {
    Text = "Anti-Lag", Default = false,
    Tooltip = "Boost FPS, giam do hoa, tranh lag"
})

antiLagToggle:OnChanged(function(Value)
    antiLagActive = Value
    if Value then
        originalLightingState = {
            GlobalShadows = Lighting.GlobalShadows,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogEnd = Lighting.FogEnd,
            ColorShift_Top = Lighting.ColorShift_Top,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
        }
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.ClockTime = 12

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") then
                originalPostEffects[obj] = obj.Enabled
                obj.Enabled = false
            end
        end

        task.spawn(function()
            local count = 0
            for _, child in ipairs(Workspace:GetDescendants()) do
                if not antiLagActive then break end
                if child:IsA("BasePart") then
                    applyAntiLagToPart(child)
                elseif child:IsA("ParticleEmitter") or child:IsA("Smoke") or child:IsA("Fire")
                    or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Sparkles") then
                    applyAntiLagToEffect(child)
                end
                count = count + 1
                if count % 50 == 0 then
                    RunService.Heartbeat:Wait()
                end
            end
        end)

        antiLagDescConn = Workspace.DescendantAdded:Connect(function(desc)
            if not antiLagActive then return end
            task.defer(function()
                pcall(function()
                    if desc:IsA("BasePart") then
                        applyAntiLagToPart(desc)
                    elseif desc:IsA("ParticleEmitter") or desc:IsA("Smoke") or desc:IsA("Fire")
                        or desc:IsA("Trail") or desc:IsA("Beam") or desc:IsA("Sparkles") then
                        applyAntiLagToEffect(desc)
                    end
                end)
            end)
        end)
    else
        if antiLagDescConn then antiLagDescConn:Disconnect() antiLagDescConn = nil end

        if originalLightingState then
            pcall(function()
                Lighting.GlobalShadows = originalLightingState.GlobalShadows
                Lighting.Brightness = originalLightingState.Brightness
                Lighting.ClockTime = originalLightingState.ClockTime
                Lighting.Ambient = originalLightingState.Ambient
                Lighting.OutdoorAmbient = originalLightingState.OutdoorAmbient
                Lighting.FogEnd = originalLightingState.FogEnd
                Lighting.ColorShift_Top = originalLightingState.ColorShift_Top
                Lighting.ColorShift_Bottom = originalLightingState.ColorShift_Bottom
            end)
            originalLightingState = {}
        end

        for obj, enabled in pairs(originalPostEffects) do
            if obj and obj.Parent then
                pcall(function() obj.Enabled = enabled end)
            end
        end
        originalPostEffects = {}

        restoreAntiLag()
    end
end)

local noShakeActive = false
local noShakeConn = nil
local noShakeOffsetConn = nil
local noShakeToggle = VisualRight:AddToggle("NoShakeToggle", {
    Text = "No Shake", Default = false,
    Tooltip = "Chong rung camera va bobbing tan goc"
})
noShakeToggle:OnChanged(function(Value)
    noShakeActive = Value
    if Value then
        pcall(function()
            for _, v in ipairs(getgc(true)) do
                if type(v) == "table" then
                    local ok, name = pcall(function() return tostring(v.Name or v.name or "") end)
                    if ok and (name:lower():find("shake") or name:lower():find("shakeonce")) then
                        if type(v.Shake) == "function" then v.Shake = function() end end
                        if type(v.ShakeOnce) == "function" then v.ShakeOnce = function() end end
                    end
                    if type(v) == "function" then
                        local info = debug.getinfo(v)
                        if info and info.name and (info.name:lower():find("shake") or info.name:lower():find("shakeonce")) then
                            -- leave as is, override via table
                        end
                    end
                end
            end
        end)
        noShakeOffsetConn = RunService.RenderStepped:Connect(function()
            if not noShakeActive then return end
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.CameraOffset = Vector3.new(0, 0, 0)
                end
            end
        end)
        noShakeConn = RunService.RenderStepped:Connect(function()
            if not noShakeActive then return end
            pcall(function()
                local cam = Workspace.CurrentCamera
                if cam then
                    for _, child in ipairs(cam:GetChildren()) do
                        local n = child.Name:lower()
                        if n:find("shake") or n:find("quake") or n:find("rumble") or n:find("camshaker") or n:find("bob") then
                            child:Destroy()
                        end
                    end
                end
                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    local mainUI = pg:FindFirstChild("MainUI")
                    if mainUI then
                        local initiator = mainUI:FindFirstChild("Initiator")
                        if initiator then
                            local animHolder = initiator:FindFirstChild("AnimationHolder")
                            if animHolder then
                                for _, v in ipairs(animHolder:GetChildren()) do
                                    if v.Name:lower():find("shake") or v.Name:lower():find("rumble") or v.Name:lower():find("bob") then
                                        v:Destroy()
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        if noShakeConn then noShakeConn:Disconnect() noShakeConn = nil end
        if noShakeOffsetConn then noShakeOffsetConn:Disconnect() noShakeOffsetConn = nil end
    end
end)

local noJumpScareActive = false
local noJumpScareConn = nil
local noJumpScareDescConn = nil
local JUMP_KEYS = {"jumpscare","screech","glitch","static","vignette","flash","blind","darkness","hideoverlay","locker","scare","death","dying","eyes","dread","timothy","a-90","a90","figure","seek","chase","running","red","blood","screen","overlay","damage","hurt","scary"}
local noJumpScareToggle = VisualRight:AddToggle("NoJumpScareToggle", {
    Text = "No JumpScare", Default = false,
    Tooltip = "Bo qua doan cat canh kinh di"
})
noJumpScareToggle:OnChanged(function(Value)
    noJumpScareActive = Value
    if Value then
    local function cleanGui(obj)
    if not obj then return end
    local n = tostring(obj.Name or ""):lower()
    for _, k in ipairs(JUMP_KEYS) do
        if n:find(k, 1, true) then
            pcall(function()
                if obj:IsA("ScreenGui") then
                    obj.Enabled = false
                elseif obj:IsA("GuiObject") then
                    obj.Visible = false
                    obj.BackgroundTransparency = 1
                    if obj:IsA("ImageLabel") then obj.ImageTransparency = 1 end
                elseif obj:IsA("Sound") then
                    obj.Volume = 0
                    obj:Stop()
                elseif obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = false
                end
            end)
            return
        end
    end
                end
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            cleanGui(gui)
        end
        for _, obj in ipairs(Lighting:GetChildren()) do
            cleanGui(obj)
        end
        noJumpScareDescConn = PlayerGui.DescendantAdded:Connect(function(desc)
            if not noJumpScareActive then return end
            task.defer(function() cleanGui(desc) end)
        end)
        noJumpScareConn = RunService.Heartbeat:Connect(function()
            if not noJumpScareActive then return end
            pcall(function()
                for _, gui in ipairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local n = gui.Name:lower()
                        for _, k in ipairs(JUMP_KEYS) do
                            if n:find(k, 1, true) then
                                gui.Enabled = false
                                break
                            end
                        end
                    end
                end
            end)
        end)
    else
        if noJumpScareConn then noJumpScareConn:Disconnect() noJumpScareConn = nil end
        if noJumpScareDescConn then noJumpScareDescConn:Disconnect() noJumpScareDescConn = nil end
    end
end)

local removeEntityActive = false
local removeEntityConn = nil
local removeEntityDescConn = nil
local TargetEntities = {"dread", "screech", "timothy", "halt", "a-90", "a90"}

local function matchEntity(name)
    local n = tostring(name or ""):lower()
    for _, k in ipairs(TargetEntities) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local removeEntityToggle = MiscLeft:AddToggle("RemoveEntityDameToggle", {
    Text = "Remove Entity & Dame", Default = false,
    Tooltip = "Xoa Entity va damage cua entity duoc chon"
})

local removedFunctions = {}
local function tryHookDamageFuncs()
    if next(removedFunctions) then return end
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.name then
                    local n = tostring(info.name):lower()
                    if n:find("screech") or n:find("bite") or n:find("damage") or n:find("takeDamage") or n:find("applyDamage") then
                        removedFunctions[v] = true
                    end
                end
            end
        end
    end)
end
removeEntityToggle:OnChanged(function(Value)
    removeEntityActive = Value
    if Value then
        tryHookDamageFuncs()
        removeEntityDescConn = Workspace.DescendantAdded:Connect(function(desc)
            if not removeEntityActive then return end
            if matchEntity(desc.Name) then
                task.defer(function()
                    pcall(function()
                        for _, p in ipairs(desc:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanTouch = false
                                p.CanQuery = false
                                p.Transparency = 1
                            elseif p:IsA("Sound") or p:IsA("ParticleEmitter") or p:IsA("Light") or p:IsA("BillboardGui") then
                                p:Destroy()
                            end
                        end
                        desc:Destroy()
                    end)
                end)
            end
        end)
        removeEntityConn = task.spawn(function()
            while removeEntityActive do
                pcall(function()
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if matchEntity(obj.Name) then
                            for _, p in ipairs(obj:GetDescendants()) do
                                if p:IsA("BasePart") then p.CanTouch = false
                                elseif p:IsA("Sound") or p:IsA("ParticleEmitter") then p:Destroy() end
                            end
                            obj:Destroy()
                        end
                    end
                end)
                task.wait(0.25)
            end
        end)
    else
        if removeEntityConn then task.cancel(removeEntityConn) removeEntityConn = nil end
        if removeEntityDescConn then removeEntityDescConn:Disconnect() removeEntityDescConn = nil end
    end
end)

local autoPadlockActive = false
local autoPadlockThread = nil
local autoPadlockToggle = MiscRight:AddToggle("AutoPadlockCodeToggle", {
    Text = "Auto Padlock Code", Default = false,
    Tooltip = "Tu dong do code va bypass o khoa room 50, di nhanh tuc thi"
})
autoPadlockToggle:OnChanged(function(Value)
    autoPadlockActive = Value
    if Value then
        if not autoPadlockThread then
            autoPadlockThread = task.spawn(function()
                while autoPadlockActive do
                    pcall(function()
                        local currentRoom = LocalPlayer:GetAttribute("CurrentRoom")
                        if currentRoom and tonumber(currentRoom) == 50 then
                            local code = nil
                            for _, desc in ipairs(Workspace:GetDescendants()) do
                                if desc:IsA("StringValue") or desc:IsA("IntValue") or desc:IsA("NumberValue") then
                                    local n = desc.Name:lower()
                                    if n:find("code") or n:find("pass") or n:find("padlock") or n:find("password") then
                                        code = tostring(desc.Value)
                                        break
                                    end
                                end
                            end
                            if not code then
                                for _, gui in ipairs(PlayerGui:GetDescendants()) do
                                    if gui:IsA("TextLabel") or gui:IsA("TextBox") then
                                        local t = tostring(gui.Text or ""):gsub("%D", "")
                                        if #t == 5 then
                                            code = t
                                            break
                                        end
                                    end
                                end
                            end
                            if code and #code >= 4 then
                                for _, desc in ipairs(Workspace:GetDescendants()) do
                                    if desc:IsA("ProximityPrompt") then
                                        local pName = tostring(desc.Parent and desc.Parent.Name or ""):lower()
                                        local aText = tostring(desc.ActionText or ""):lower()
                                        if pName:find("padlock") or pName:find("lock") or aText:find("code") or aText:find("unlock") or aText:find("enter") then
                                            pcall(function()
                                                fireproximityprompt(desc, 0)
                                            end)
                                        end
                                    end
                                end
                                local remotes = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
                                for _, r in ipairs(remotes:GetDescendants()) do
                                    if r:IsA("RemoteEvent") then
                                        local rn = r.Name:lower()
                                        if rn:find("padlock") or rn:find("code") or rn:find("unlock") or rn:find("door50") then
                                            pcall(function() r:FireServer(code) end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.25)
                end
            end)
        end
    else
        if autoPadlockThread then
            task.cancel(autoPadlockThread)
            autoPadlockThread = nil
        end
    end
end)

local autoInteractActive = false
local autoInteractThread = nil
local autoInteractRange = 4
local autoInteractCooldown = setmetatable({}, {__mode = "k"})

local INTERACT_BLACKLIST = {
    bed = true, seat = true, chair = true, armchair = true,
    couch = true, sofa = true,
    photo = true, picture = true, painting = true, frame = true,
    art = true, canvas = true, portrait = true, poster = true,
}

local function isInteractBlacklisted(prompt, parent)
    local pName = tostring(parent and parent.Name or ""):lower()
    local aText = tostring(prompt.ActionText or ""):lower()
    local oText = tostring(prompt.ObjectText or ""):lower()
    for key, _ in pairs(INTERACT_BLACKLIST) do
        if pName:find(key, 1, true) or aText:find(key, 1, true) or oText:find(key, 1, true) then
            return true
        end
    end
    return false
end

local function preparePrompt(prompt)
    pcall(function()
        if prompt.HoldDuration and prompt.HoldDuration > 0 then
            prompt.HoldDuration = 0
        end
        if prompt.RequiresLineOfSight then
            prompt.RequiresLineOfSight = false
        end
        if prompt.MaxActivationDistance and prompt.MaxActivationDistance < 10 then
            prompt.MaxActivationDistance = 10
        end
    end)
end

local autoInteractToggle = MiscRight:AddToggle("AutoInteractToggle", {
    Text = "Auto Interact", Default = false,
    Tooltip = "Tu Dong Tuong Tac"
})

autoInteractToggle:OnChanged(function(Value)
    autoInteractActive = Value
    if Value then
        if not autoInteractThread then
            autoInteractThread = task.spawn(function()
                while autoInteractActive do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local pos = hrp.Position
                                local parts = Workspace:GetPartBoundsInRadius(pos, autoInteractRange)
                                local nearestPrompt = nil
                                local nearestDist = math.huge

                                for _, part in ipairs(parts) do
                                    if not part:IsDescendantOf(char) then
                                                        local prompt = part:FindFirstChildWhichIsA("ProximityPrompt", true)
if not prompt and part.Parent then
    prompt = part.Parent:FindFirstChildWhichIsA("ProximityPrompt", true)
                                                        end
                                        if prompt and prompt.Enabled then
                                            local parent = prompt.Parent
                                            if parent and not isInteractBlacklisted(prompt, parent) then
                                                local promptPos = part.Position
                                                local dist = (pos - promptPos).Magnitude
                                                if dist <= autoInteractRange and dist < nearestDist then
                                                    nearestDist = dist
                                                    nearestPrompt = prompt
                                                end
                                            end
                                        end
                                    end
                                end

                                if nearestPrompt then
                                    preparePrompt(nearestPrompt)
                                    local now = tick()
                                    if not autoInteractCooldown[nearestPrompt] or (now - autoInteractCooldown[nearestPrompt] > 0.15) then
                                        autoInteractCooldown[nearestPrompt] = now
                                        pcall(function()
                                            fireproximityprompt(nearestPrompt, 0)
                                        end)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.12)
                end
            end)
        end
    else
        if autoInteractThread then
            task.cancel(autoInteractThread)
            autoInteractThread = nil
        end
        autoInteractCooldown = setmetatable({}, {__mode = "k"})
    end
end)

local skipProximityActive = false
local skipProximityConn = nil
local skipProximityToggle = MiscRight:AddToggle("ProximitySkipToggle", {
    Text = "Proximity Skip", Default = false,
    Tooltip = "Bo qua thoi ProximityPrompt cua Roblox"
})
local function applySkipPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 20)
        prompt.RequiresLineOfSight = false
    end
end
skipProximityToggle:OnChanged(function(Value)
    skipProximityActive = Value
    if Value then
        for _, d in ipairs(Workspace:GetDescendants()) do
            pcall(applySkipPrompt, d)
        end
        if not skipProximityConn then
            skipProximityConn = Workspace.DescendantAdded:Connect(function(d)
                if skipProximityActive then
                    pcall(applySkipPrompt, d)
                end
            end)
        end
    else
        if skipProximityConn then
            skipProximityConn:Disconnect()
            skipProximityConn = nil
        end
    end
end)

local escapeTimerActive = false
local escapeTimerGui = nil
local escapeTimerLabel = nil
local escapeTimerConn = nil
local hideStartTime = 0
local HIDE_LIMIT = 15.5

local function createEscapeTimerUI()
    if escapeTimerGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "EscapeTimerGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 300
    local frame = Instance.new("Frame")
    frame.Name = "TimerFrame"
    frame.Size = UDim2.new(0, 70, 0, 90)
    frame.Position = UDim2.new(0.92, 0, 0.35, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.ZIndex = 400
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(80, 180, 255)
    stroke.Parent = frame
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.BackgroundTransparency = 1
    title.Text = "HIDE"
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.ZIndex = 401
    title.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = "TimerLabel"
    label.Size = UDim2.new(1, 0, 0, 40)
    label.Position = UDim2.new(0, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.Text = "00:00"
    label.TextColor3 = Color3.fromRGB(100, 255, 150)
    label.TextSize = 22
    label.Font = Enum.Font.Code
    label.ZIndex = 401
    label.Parent = frame
    gui.Parent = PlayerGui
    frame.Parent = gui
    escapeTimerGui = gui
    escapeTimerLabel = label
end

local function destroyEscapeTimerUI()
    if escapeTimerGui then
        escapeTimerGui:Destroy()
        escapeTimerGui = nil
        escapeTimerLabel = nil
    end
end

local escapeTimerToggle = MiscLeft:AddToggle("EscapeTimerToggle", {
    Text = "Escape Timer", Default = false,
    Tooltip = "Hien thi dem nguoc thoi gian tron tu, keo tha duoc"
})
escapeTimerToggle:OnChanged(function(Value)
    escapeTimerActive = Value
    if Value then
        createEscapeTimerUI()
        if not escapeTimerConn then
            escapeTimerConn = RunService.Heartbeat:Connect(function()
                if not escapeTimerActive then return end
                local char = LocalPlayer.Character
                if not char then return end
                local isHiding = false
                pcall(function()
                    if char:GetAttribute("Hiding") or char:GetAttribute("IsHiding") then
                        isHiding = true
                    end
                end)
                if not isHiding then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Sit then isHiding = true end
                end
                if isHiding then
                    if hideStartTime == 0 then
                        hideStartTime = tick()
                    end
                    local elapsed = tick() - hideStartTime
                    local remain = math.max(0, HIDE_LIMIT - elapsed)
                    local mins = math.floor(remain / 60)
                    local secs = math.floor(remain % 60)
                    if escapeTimerLabel then
                        escapeTimerLabel.Text = string.format("%02d:%02d", mins, secs)
                        if remain <= 5 then
                            escapeTimerLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                        elseif remain <= 10 then
                            escapeTimerLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
                        else
                            escapeTimerLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
                        end
                    end
                else
                    hideStartTime = 0
                    if escapeTimerLabel then
                        escapeTimerLabel.Text = "00:00"
                        escapeTimerLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
                    end
                end
            end)
        end
    else
        if escapeTimerConn then
            escapeTimerConn:Disconnect()
            escapeTimerConn = nil
        end
        destroyEscapeTimerUI()
        hideStartTime = 0
    end
end)

local weirdToggle = FuncRight:AddToggle("MakeWeirdToggle", {
    Text = "Make yourself weird", Default = false,
    Tooltip = "Lam Nhan vat khong hoat anh,vao tu nhanh"
})
local weirdConn = nil
local weirdActive = false
local weirdSaved = {}
local weirdAnimConn = nil
local function hookWeirdAnimator(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 15)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 15)
    if not animator then return end
    if weirdAnimConn then weirdAnimConn:Disconnect() end
    weirdAnimConn = animator.AnimationPlayed:Connect(function(track)
        if not weirdActive then return end
        pcall(function()
            track:AdjustSpeed(0)
            track:Stop(0)
        end)
    end)
end
if LocalPlayer.Character then task.spawn(hookWeirdAnimator, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookWeirdAnimator)
weirdToggle:OnChanged(function(Value)
    weirdActive = Value
    local char = LocalPlayer.Character
    if Value then
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function()
                    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(0)
                        track:Stop(0)
                    end
                end)
            end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    if weirdSaved[p] == nil then
                        weirdSaved[p] = {
                            Transparency = p.Transparency,
                            Material = p.Material,
                            Color = p.Color,
                            Reflectance = p.Reflectance,
                        }
                    end
                    if p.Name ~= "HumanoidRootPart" and p.Name ~= "CollisionPart"
                        and p.Name ~= "Collision" and p.Name ~= "CollisionClone"
                        and p.Name ~= "CollisionPartClone" then
                        p.Transparency = 0.5
                        p.Material = Enum.Material.ForceField
                        p.Color = Color3.fromRGB(50, 255, 150)
                        p.Reflectance = 0.3
                    end
                end
            end
        end
        if not weirdConn then
            weirdConn = RunService.Heartbeat:Connect(function()
                if not weirdActive then return end
                local c = LocalPlayer.Character
                if not c then return end
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then
                    pcall(function()
                        for _, track in ipairs(h:GetPlayingAnimationTracks()) do
                            track:AdjustSpeed(0)
                            track:Stop(0)
                        end
                    end)
                end
            end)
        end
    else
        if weirdConn then
            weirdConn:Disconnect()
            weirdConn = nil
        end
        if weirdAnimConn then
            weirdAnimConn:Disconnect()
            weirdAnimConn = nil
        end
        if char then
            for part, data in pairs(weirdSaved) do
                if part and part.Parent then
                    part.Transparency = data.Transparency
                    part.Material = data.Material
                    part.Color = data.Color
                    part.Reflectance = data.Reflectance
                end
            end
        end
        weirdSaved = {}
    end
end)

local footMusicToggle = MiscLeft:AddToggle("NoFootMusicToggle", {
    Text = "No Foot Music[50]", Default = false, Tooltip = "An tieng buoc chan"
})
local footMusicConn = nil
local footMusicActive = false
footMusicToggle:OnChanged(function(Value)
    footMusicActive = Value
    if Value then
        if not footMusicConn then
            footMusicConn = Workspace.DescendantAdded:Connect(function(desc)
                if not footMusicActive then return end
                if desc:IsA("Sound") then
                    local n = desc.Name:lower()
                    if n:find("footstep") or n:find("walk") or n:find("step")
                    or n:find("running") or n:find("sprint") then
                        desc.Volume = 0
                        pcall(function() desc:Stop() end)
                    end
                end
            end)
        end
        local char = LocalPlayer.Character
        if char then
            for _, desc in ipairs(char:GetDescendants()) do
                if desc:IsA("Sound") then
                    local n = desc.Name:lower()
                    if n:find("footstep") or n:find("walk") or n:find("step")
                    or n:find("running") or n:find("sprint") then
                        desc.Volume = 0
                        pcall(function() desc:Stop() end)
                    end
                end
            end
        end
    else
        if footMusicConn then
            footMusicConn:Disconnect()
            footMusicConn = nil
        end
    end
end)

Obsidian:OnUnload(function()
    safeUnlockCharacter()
    togglePositionSpoof(false)
    if velocityConn then velocityConn:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    if noClipActive and noClipToggle then noClipToggle:SetValue(false) end
    if footMusicActive and footMusicToggle then footMusicToggle:SetValue(false) end
    if antiLagDescConn then antiLagDescConn:Disconnect() end
    if noShakeConn then noShakeConn:Disconnect() end
    if noShakeOffsetConn then noShakeOffsetConn:Disconnect() end
    if noJumpScareConn then noJumpScareConn:Disconnect() end
    if noJumpScareDescConn then noJumpScareDescConn:Disconnect() end
    if removeEntityConn then task.cancel(removeEntityConn) end
    if removeEntityDescConn then removeEntityDescConn:Disconnect() end
    if removeEntityGCConn then removeEntityGCConn:Disconnect() end
    if autoPadlockThread then task.cancel(autoPadlockThread) end
    if autoInteractThread then task.cancel(autoInteractThread) end
    if skipProximityConn then skipProximityConn:Disconnect() end
    if escapeTimerConn then escapeTimerConn:Disconnect() end
    destroyEscapeTimerUI()
    if weirdConn then weirdConn:Disconnect() end
    if weirdAnimConn then weirdAnimConn:Disconnect() end
    if fullBrightConn then fullBrightConn:Disconnect() end
    if seeThroughConn then seeThroughConn:Disconnect() end
    if remoteThreadSpeed then task.cancel(remoteThreadSpeed) end
    if remoteThreadVel then task.cancel(remoteThreadVel) end
    if bookEspToggle and bookEspToggle.Value then bookEspToggle:SetValue(false) end
    table.clear(velocitySavedCanCollide)
    table.clear(noClipSavedCanCollide)
    table.clear(weirdSaved)
    table.clear(autoInteractCooldown)
    table.clear(originalPartProps)
    table.clear(originalPostEffects)
end)
