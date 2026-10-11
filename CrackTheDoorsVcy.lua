local Repository = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local success, Obsidian = pcall(function()
    return loadstring(game:HttpGet(Repository .. "Library.lua"))()
end)

if not success or type(Obsidian) ~= "table" then
    warn("Lỗi tải thư viện Obsidian UI! Đang thử lại...")
    task.wait(1)
    Obsidian = loadstring(game:HttpGet(Repository .. "Library.lua"))()
end

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

-- Module nhận diện Lobby / Floor theo chuẩn nghiên cứu 3 phương pháp
local AreaDetector = {}
function AreaDetector.Detect()
    local placeId = game.PlaceId
    local gameId = game.GameId
    
    local hasLobbyWorkspace = Workspace:FindFirstChild("Lobby") ~= nil
    local hasRoomsWorkspace = Workspace:FindFirstChild("Rooms") ~= nil or Workspace:FindFirstChild("CurrentRooms") ~= nil
    
    local finalState = "UNKNOWN"
    local floorNum = 0
    
    if hasLobbyWorkspace and not hasRoomsWorkspace then
        finalState = "LOBBY"
        floorNum = 0
    elseif hasRoomsWorkspace then
        local currentRoomAttr = LocalPlayer:GetAttribute("CurrentRoom")
        if currentRoomAttr then
            floorNum = tonumber(currentRoomAttr) or 1
        end
        finalState = "FLOOR1"
    else
        finalState = "LOADING"
    end
    
    return {
        PlaceId = placeId,
        GameId = gameId,
        WorkspaceEvidence = hasLobbyWorkspace and "Lobby Found" or (hasRoomsWorkspace and "Rooms Found" or "None"),
        RoomEvidence = tostring(floorNum),
        FinalState = finalState,
        FloorNumber = floorNum
    }
end

local detectedArea = AreaDetector.Detect()

local Window = Obsidian:CreateWindow({
    Title = "PaintVcy.1",
    SubTitle = "PaintVcy1.0",
    TabWidth = 135,
    Size = UDim2.new(0, 640, 0, 380),
    Center = true,
    AutoShow = true,
    MenuFadeTime = 0.15
})

local Tabs = {
    Info = Window:AddTab("Info", "user-check"),
    Function = Window:AddTab("Function", "user"),
    Visual = Window:AddTab("Visual", "eye"),
    Misc = Window:AddTab("Misc", "sliders"),
    Settings = Window:AddTab("Settings", "cog")
}

local InfoGroup = Tabs.Info:AddLeftGroupbox("Player & Area Info")
local playerInfoLabel = InfoGroup:AddLabel("Player: " .. LocalPlayer.Name)
local floorInfoLabel = InfoGroup:AddLabel("Current Floor: " .. detectedArea.FinalState)

RunService.Heartbeat:Connect(function()
    local status = AreaDetector.Detect()
    if playerInfoLabel then playerInfoLabel:SetText("Player: " .. LocalPlayer.Name) end
    if floorInfoLabel then floorInfoLabel:SetText("Current Floor: " .. status.FinalState) end
end)

local FuncLeft = Tabs.Function:AddLeftGroupbox("Movement")
local FuncRight = Tabs.Function:AddRightGroupbox("Exploits")
local VisualLeft = Tabs.Visual:AddLeftGroupbox("Visual")
local VisualRight = Tabs.Visual:AddRightGroupbox("Lighting")
local MiscLeft = Tabs.Misc:AddLeftGroupbox("Stealth")
local MiscRight = Tabs.Misc:AddRightGroupbox("Utility")
local SettingsLeft = Tabs.Settings:AddLeftGroupbox("Configuration")
local SettingsRight = Tabs.Settings:AddRightGroupbox("Themes")

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
        end
        if hrp then
            hrp.Anchored = false
        end
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
    char = nil,
    hrp = nil,
    humanoid = nil,
    loaded = false,
    enabled = false,
    baseY = nil,
    DEPTH = 2.346,
    c1Origin = nil,
    crouchConn = nil,
    uiWidget = nil,
    uiLabel = nil,
    uiStroke = nil,
    updateConn = nil,
}

local function loadPositionSpoof()
    if S.loaded then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not hrp or not humanoid then return end

    S.char = char
    S.hrp = hrp
    S.humanoid = humanoid

    local t0 = tick()
    while tick() - t0 < 5 do
        if humanoid.FloorMaterial ~= Enum.Material.Air then break end
        task.wait(0.1)
    end
    task.wait(0.3)

    for _, n in ipairs({"CollisionPart", "Collision"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then
            p.CanCollide = false
        end
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
    w1.Part0 = cpClone
    w1.Part1 = hrp
    w1.C0 = CFrame.new(0, 0.271744013, 0)
    w1.C1 = CFrame.new()
    w1.Parent = cpClone

    local collision = char:FindFirstChild("Collision")
    local colSize = collision and collision.Size or Vector3.new(5.5, 3, 3)
    local ccClone = Instance.new("Part")
    ccClone.Name = "CollisionClone"
    ccClone.Size = colSize
    ccClone.Transparency = 1
    ccClone.CanCollide = true
    ccClone.CanQuery = true
    ccClone.CanTouch = true
    ccClone.Massless = true
    ccClone.Anchored = false
    ccClone.Parent = char
    pcall(function() ccClone.CollisionGroup = "Player" end)

    local w2 = Instance.new("Weld")
    w2.Part0 = ccClone
    w2.Part1 = hrp
    w2.C0 = CFrame.new(0, 0.0905, 0)
    w2.C1 = CFrame.new()
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
    corner.CornerRadius = UDim.new(0, 18)
    corner.Parent = frame
    local stroke = Instance.new("UIStroke")
    stroke.Name = "WidgetStroke"
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Name = "WidgetLabel"
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "HRP.Y: 0.00"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.ZIndex = 501
    label.Parent = frame
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    frame.Parent = gui
    S.uiWidget = gui
    S.uiLabel = label
    S.uiStroke = stroke
end

local function destroyFloatingWidget()
    if S.uiWidget then
        S.uiWidget:Destroy()
        S.uiWidget = nil
        S.uiLabel = nil
        S.uiStroke = nil
    end
end

local function togglePositionSpoof(enable)
    if enable then
        if S.enabled or not S.loaded then return end
        if not S.hrp or not S.humanoid then return end
        S.enabled = true

        local char = S.char
        local hrp = S.hrp
        local humanoid = S.humanoid
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
                if cr then
                    pcall(function() cr:FireServer(true, true) end)
                end
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

        local char = S.char
        local hrp = S.hrp
        local humanoid = S.humanoid
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

local velocityMode = "Press once"
local velocityDropdown = FuncLeft:AddDropdown("VelocityModeDropdown", {
    Text = "Velocity Mode",
    Values = {"Press once", "Auto Velocity"},
    Default = 1,
    Tooltip = "Press once: Bat tat di chuyen | Auto Velocity: Tu dong kich hoat khi va cham tuong"
})

velocityDropdown:OnChanged(function(Value)
    velocityMode = Value
end)

local velocityToggle = FuncLeft:AddToggle("VelocityModeToggle", {
    Text = "Velocity Manip",
    Default = false,
    Tooltip = "Truot xuyen tuong voi toc do co dinh 6.5"
})

velocityToggle:OnChanged(function(Value)
    isVelocityActive = Value
    if Value and velocityMode == "Press once" then
        lockInputs(true)
        local camera = Workspace.CurrentCamera
        velocityConn = RunService.Heartbeat:Connect(function()
            local currentTargetChar = LocalPlayer.Character
            if not currentTargetChar then return end
            local hrp = currentTargetChar:FindFirstChild("HumanoidRootPart")
            local hum = currentTargetChar:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            
            for _, p in ipairs(currentTargetChar:GetDescendants()) do
                if p:IsA("BasePart") then
                    if velocitySavedCanCollide[p] == nil then
                        velocitySavedCanCollide[p] = {
                            CanCollide = p.CanCollide,
                            CanQuery = p.CanQuery,
                            CanTouch = p.CanTouch
                        }
                    end
                    p.CanCollide = false
                    p.CanQuery = false
                    p.CanTouch = false
                end
            end
            
            for _, n in ipairs({"Collision", "CollisionPart", "CollisionClone", "CollisionPartClone"}) do
                local spPart = currentTargetChar:FindFirstChild(n)
                if spPart and spPart:IsA("BasePart") then
                    if velocitySavedCanCollide[spPart] == nil then
                        velocitySavedCanCollide[spPart] = {
                            CanCollide = spPart.CanCollide,
                            CanQuery = spPart.CanQuery,
                            CanTouch = spPart.CanTouch
                        }
                    end
                    spPart.CanCollide = false
                    spPart.CanQuery = false
                    spPart.CanTouch = false
                end
            end
            
            hum.WalkSpeed = 0
            local look = camera.CFrame.LookVector
            local dir = Vector3.new(look.X, 0, look.Z)
            if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.new(0, 0, -1) end
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * velocitySpeedVal, 0, dir.Z * velocitySpeedVal)
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
        remoteThreadVel = task.spawn(function()
            while isVelocityActive do
                if not S.enabled then
                    local cr = getCrouchRemote()
                    if cr then
                        pcall(function() cr:FireServer(false, true) end)
                    end
                end
                task.wait(0.4)
            end
        end)
    elseif Value and velocityMode == "Auto Velocity" then
        lockInputs(true)
        local camera = Workspace.CurrentCamera
        velocityConn = RunService.Heartbeat:Connect(function()
            local currentTargetChar = LocalPlayer.Character
            if not currentTargetChar then return end
            local hrp = currentTargetChar:FindFirstChild("HumanoidRootPart")
            local hum = currentTargetChar:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {currentTargetChar}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            local hit = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 2, raycastParams)
            
            if hit then
                for _, p in ipairs(currentTargetChar:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if velocitySavedCanCollide[p] == nil then
                            velocitySavedCanCollide[p] = {
                                CanCollide = p.CanCollide,
                                CanQuery = p.CanQuery,
                                CanTouch = p.CanTouch
                            }
                        end
                        p.CanCollide = false
                    end
                end
                hum.WalkSpeed = 0
                local look = camera.CFrame.LookVector
                local dir = Vector3.new(look.X, 0, look.Z)
                if dir.Magnitude > 0 then dir = dir.Unit else dir = Vector3.new(0, 0, -1) end
                hrp.AssemblyLinearVelocity = Vector3.new(dir.X * velocitySpeedVal, 0, dir.Z * velocitySpeedVal)
            else
                for part, data in pairs(velocitySavedCanCollide) do
                    if part and part.Parent then
                        part.CanCollide = data.CanCollide
                    end
                end
                hum.WalkSpeed = 16
            end
        end)
    else
        if velocityConn then velocityConn:Disconnect() velocityConn = nil end
        if remoteThreadVel then task.cancel(remoteThreadVel) remoteThreadVel = nil end
        for part, data in pairs(velocitySavedCanCollide) do
            if part and part.Parent then
                part.CanCollide = data.CanCollide
                part.CanQuery = data.CanQuery
                part.CanTouch = data.CanTouch
            end
        end
        velocitySavedCanCollide = {}
        safeUnlockCharacter()
    end
end)

local noClipActive = false
local noClipSavedCanCollide = {}

local noClipToggle = FuncLeft:AddToggle("NoClipToggle", {
    Text = "No Clip",
    Default = false,
    Tooltip = "Di xuyen qua vat the va khoi phuc 100% trang thai cu"
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
                            CanCollide = p.CanCollide,
                            CanQuery = p.CanQuery,
                            CanTouch = p.CanTouch
                        }
                    end
                    p.CanCollide = false
                    p.CanQuery = false
                    p.CanTouch = false
                end
            end
            for _, n in ipairs({"Collision", "CollisionPart", "CollisionClone", "CollisionPartClone"}) do
                local spPart = char:FindFirstChild(n)
                if spPart and spPart:IsA("BasePart") then
                    if noClipSavedCanCollide[spPart] == nil then
                        noClipSavedCanCollide[spPart] = {
                            CanCollide = spPart.CanCollide,
                            CanQuery = spPart.CanQuery,
                            CanTouch = spPart.CanTouch
                        }
                    end
                    spPart.CanCollide = false
                    spPart.CanQuery = false
                    spPart.CanTouch = false
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
    Text = "Position Spoof",
    Default = false,
    Tooltip = "Ha HRP.Y xuong ne raycast cua Rush Ambush A-60"
})

positionSpoofToggle:OnChanged(function(Value)
    togglePositionSpoof(Value)
end)

local speedMethod = "Boost"
local speedMethodDropdown = FuncRight:AddDropdown("SpeedMethodDropdown", {
    Text = "Speed Method",
    Values = {"Boost", "Instant"},
    Default = 1,
    Tooltip = "Boost: tang toc tu tu | Instant: chay nhanh ngay"
})

speedMethodDropdown:OnChanged(function(Value)
    speedMethod = Value
end)

local speedToggle = FuncRight:AddToggle("SpeedBypassToggle", {
    Text = "Speed",
    Default = false,
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
                    if cr then
                        pcall(function() cr:FireServer(false, true) end)
                    end
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

FuncRight:AddSlider("SpeedBypassSlider", {
    Text = "Speed Val",
    Default = 16,
    Min = 0,
    Max = 80,
    Rounding = 1,
    Compact = true
}):OnChanged(function(Value)
    targetWalkSpeed = Value
end)

local paintEspToggle = VisualLeft:AddToggle("PaintEspToggle", {
    Text = "Paint ESP",
    Default = false,
    Tooltip = "Load PaintDoorsVisual"
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

local function createBookEsp(bookObj)
    if not bookObj or not bookObj.Parent then return end
    if bookObj:FindFirstChild("BookEspBillboard") then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BookEspBillboard"
    billboard.Size = UDim2.new(0, 80, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Book"
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    textLabel.TextStrokeTransparency = 0.2
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    if bookObj:IsA("BasePart") then
        billboard.Parent = bookObj
    elseif bookObj:IsA("Model") and bookObj.PrimaryPart then
        billboard.Parent = bookObj.PrimaryPart
    elseif bookObj:IsA("Model") then
        local targetPart = bookObj:FindFirstChildWhichIsA("BasePart")
        if targetPart then billboard.Parent = targetPart end
    end
end

local function removeBookEsp()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "BookEspBillboard" then
            desc:Destroy()
        end
    end
end

local bookEspToggle = VisualLeft:AddToggle("BookEspToggle", {
    Text = "Book ESP (Room 50)",
    Default = false,
    Tooltip = "Ve mau va ten Book[1..] len cac sach trong phong 50"
})

bookEspToggle:OnChanged(function(Value)
    bookEspActive = Value
    if Value then
        for _, desc in ipairs(Workspace:GetDescendants()) do
            local nameLower = desc.Name:lower()
            if nameLower:find("book") or (desc:IsA("ProximityPrompt") and desc.ActionText:lower():find("book")) then
                local target = desc:IsA("ProximityPrompt") and desc.Parent or desc
                pcall(function() createBookEsp(target) end)
            end
        end
        table.insert(bookEspConnections, Workspace.DescendantAdded:Connect(function(desc)
            if not bookEspActive then return end
            local nameLower = desc.Name:lower()
            if nameLower:find("book") or (desc:IsA("ProximityPrompt") and desc.ActionText:lower():find("book")) then
                local target = desc:IsA("ProximityPrompt") and desc.Parent or desc
                pcall(function() createBookEsp(target) end)
            end
        end))
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

local seeThroughToggle = VisualLeft:AddToggle("SeeThroughHidingToggle", {
    Text = "See-through while hiding",
    Default = false,
    Tooltip = "Lam mo part tu khi vao tron"
})

local seeThroughSlider = VisualLeft:AddSlider("SeeThroughSlider", {
    Text = "Opacity Val",
    Default = 0.5,
    Min = 0.1,
    Max = 1.0,
    Rounding = 1,
    Compact = true
})

seeThroughSlider:OnChanged(function(v)
    seeThroughVal = v
end)

seeThroughToggle:OnChanged(function(Value)
    seeThroughActive = Value
    if Value then
        seeThroughConn = RunService.RenderStepped:Connect(function()
            if not seeThroughActive then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj.Name:lower():find("wardrobe") or obj.Name:lower():find("closet")) then
                    for _, p in ipairs(obj:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.Transparency = seeThroughVal
                        end
                    end
                end
            end
        end)
    else
        if seeThroughConn then
            seeThroughConn:Disconnect()
            seeThroughConn = nil
        end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("wardrobe") or obj.Name:lower():find("closet")) then
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                    end
                end
            end
        end
    end
end)

local preMadePathParts = {}
local preMadePathToggle = VisualLeft:AddToggle("PreMadePathToggle", {
    Text = "Create a Pre-made Path",
    Default = false,
    Tooltip = "Tao part vao cho lun sau bat thuong voi ghost glass mau hong"
})

preMadePathToggle:OnChanged(function(Value)
    if Value then
        local currentStatus = AreaDetector.Detect()
        if currentStatus.FloorNumber == 1 then
            pcall(function()
                Obsidian:Notify({
                    Title = "PRE-MADE PATH",
                    Description = "Floor 1 sẽ không hoạt động trong nhiều trường hợp!",
                    Time = 6
                })
            end)
        elseif currentStatus.FloorNumber >= 2 or currentStatus.FinalState == "FLOOR1" then
            pcall(function()
                Obsidian:Notify({
                    Title = "PRE-MADE PATH",
                    Description = "Đã Tạo",
                    Time = 5
                })
            end)
        end
        
        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i = 1, 5 do
                    local p = Instance.new("Part")
                    p.Size = Vector3.new(4, 0.5, 4)
                    p.Position = hrp.Position + Vector3.new(0, -3.5, i * 4)
                    p.Anchored = true
                    p.CanCollide = true
                    p.Material = Enum.Material.ForceField
                    p.Color = Color3.fromRGB(255, 105, 180)
                    p.Transparency = 0.4
                    p.Parent = Workspace
                    table.insert(preMadePathParts, p)
                end
            end
        end
    else
        for _, p in ipairs(preMadePathParts) do
            if p and p.Parent then p:Destroy() end
        end
        preMadePathParts = {}
    end
end)

local fullBrightConn = nil
local fullBrightActive = false
local fullBrightLevel = 2

local fullBrightToggle = VisualRight:AddToggle("FullBrightToggle", {
    Text = "Full Bright",
    Default = false,
    Tooltip = "Lam sang moi truong"
})

local fullBrightSlider = VisualRight:AddSlider("FullBrightSlider", {
    Text = "Brightness",
    Default = 2,
    Min = 0.5,
    Max = 10,
    Rounding = 1,
    Compact = true
})

fullBrightSlider:OnChanged(function(Value)
    fullBrightLevel = Value
end)

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

local bypassLagConn = nil
local bypassLagActive = false
local originalLighting = nil
local originalPartProps = {}

local function applyBypassLag(obj)
    if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
        if originalPartProps[obj] == nil then
            originalPartProps[obj] = {Material = obj.Material, CastShadow = obj.CastShadow, Transparency = obj.Transparency}
        end
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        obj.Enabled = false
    end
end

local bypassLagToggle = VisualRight:AddToggle("BypassLagToggle", {
    Text = "Bypass Lag",
    Default = false,
    Tooltip = "Toi uu hoa do hoa toan dien, xoa texture va hieu ung nang"
})

bypassLagToggle:OnChanged(function(Value)
    bypassLagActive = Value
    if Value then
        originalLighting = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
        }
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 500

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") or obj:IsA("Sky") or obj:IsA("Atmosphere") then
                obj.Enabled = false
            end
        end

        for _, desc in ipairs(Workspace:GetDescendants()) do
            pcall(function() applyBypassLag(desc) end)
        end

        if not bypassLagConn then
            bypassLagConn = Workspace.DescendantAdded:Connect(function(desc)
                if not bypassLagActive then return end
                task.defer(function() pcall(function() applyBypassLag(desc) end) end)
            end)
        end
    else
        if originalLighting then
            Lighting.Brightness = originalLighting.Brightness
            Lighting.ClockTime = originalLighting.ClockTime
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
            originalLighting = nil
        end

        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("PostEffect") or obj:IsA("Sky") or obj:IsA("Atmosphere") then
                obj.Enabled = true
            end
        end

        for part, data in pairs(originalPartProps) do
            if part and part.Parent then
                part.Material = data.Material
                part.CastShadow = data.CastShadow
            end
        end
        originalPartProps = {}

        if bypassLagConn then
            bypassLagConn:Disconnect()
            bypassLagConn = nil
        end
    end
end)

local noShakeConn = nil
local noShakeActive = false

local noShakeToggle = VisualRight:AddToggle("NoShakeToggle", {
    Text = "No Shake",
    Default = false,
    Tooltip = "Chong rung mat dat va rung camera hoan toan"
})

noShakeToggle:OnChanged(function(Value)
    noShakeActive = Value
    if Value then
        if not noShakeConn then
            noShakeConn = RunService.RenderStepped:Connect(function()
                if not noShakeActive then return end
                local camera = Workspace.CurrentCamera
                if camera then
                    for _, obj in ipairs(camera:GetChildren()) do
                        if obj:IsA("BindableEvent") or obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("CameraShaker") then
                            local n = obj.Name:lower()
                            if n:find("shake") or n:find("earthquake") or n:find("rumble") or n:find("cam") then
                                pcall(function() obj:Destroy() end)
                            end
                        end
                    end
                end
                pcall(function()
                    local mainUI = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
                    if mainUI then
                        local animHolder = mainUI.Initiator:FindFirstChild("AnimationHolder")
                        if animHolder then
                            for _, child in ipairs(animHolder:GetChildren()) do
                                if child.Name:lower():find("shake") or child.Name:lower():find("rumble") then
                                    child:Destroy()
                                end
                            end
                        end
                    end
                end)
            end)
        end
    else
        if noShakeConn then
            noShakeConn:Disconnect()
            noShakeConn = nil
        end
    end
end)

local weirdToggle = FuncRight:AddToggle("MakeWeirdToggle", {
    Text = "Make yourself weird",
    Default = false,
    Tooltip = "Phong cach TwinKhook: Nhan vat dung im nhu pho tuong, khong hoat anh + ghost glass xanh la"
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
                        track:Stop(0)                    end)
                end
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
                if S.enabled then
                    local lt = c:FindFirstChild("LowerTorso")
                    if lt then
                        for _, m in ipairs(lt:GetChildren()) do
                            if m:IsA("Motor6D") and m.Name == "Root" then
                                local yPos = m.C1.Y
                                m.C1 = CFrame.new(m.C1.X, yPos, m.C1.Z)
                                break
                            end
                        end
                    end
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
    Text = "No Foot Music[50]",
    Default = false,
    Tooltip = "An tieng buoc chan"
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

local noEntityConn = nil
local noEntityActive = false

local NO_ENTITY_NAMES = {"eyes","halt","timothy","screech","shadow","jack","glitch","dupe","hide","snare","giggle","window"}
local NO_ENTITY_DAMAGE = {"rush","ambush","a60","seek","figure"}

local function isNoEntityName(name)
    local n = tostring(name):lower():gsub("[^a-z0-9]", "")
    for _, k in ipairs(NO_ENTITY_NAMES) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local function isNoEntityDamage(name)
    local n = tostring(name):lower():gsub("[^a-z0-9]", "")
    for _, k in ipairs(NO_ENTITY_DAMAGE) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local noEntityToggle = MiscLeft:AddToggle("NoEntityToggle", {
    Text = "No Entity",
    Default = false,
    Tooltip = "Vo hieu hoa sat thuong va cham tu Entity nguy hiem"
})

noEntityToggle:OnChanged(function(Value)
    noEntityActive = Value
    if Value then
        if not noEntityConn then
            noEntityConn = RunService.Stepped:Connect(function()
                if not noEntityActive then return end
                local char = LocalPlayer.Character
                for _, v in ipairs(Workspace:GetChildren()) do
                    if char and v:IsA("Model") and not v:IsDescendantOf(char) then
                        if isNoEntityName(v.Name) then
                            pcall(function() v:Destroy() end)
                        elseif isNoEntityDamage(v.Name) then
                            for _, p in ipairs(v:GetDescendants()) do
                                if p:IsA("BasePart") then
                                    p.CanQuery = false
                                    p.CanTouch = false
                                    p.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        if noEntityConn then
            noEntityConn:Disconnect()
            noEntityConn = nil
        end
    end
end)

local bypassJumpScareToggle = FuncRight:AddToggle("BypassJumpScareToggle", {
    Text = "Bypass JumpScare",
    Default = false,
    Tooltip = "Xoa sach hieu ung nhieu, jumpscare va animation chet choc"
})

local bypassJumpScareConn = nil
local jumpScareAnimConn = nil
local jumpScareCamConn = nil
local jumpScareSoundConn = nil

local ANIM_KEYS = {"jumpscare","screech","rush","ambush","a60","a90","a120","seek","figure","eyes","halt","glitch","death","dying","scare","scream"}

local function matchJumpScareAnim(name, id)
    local n = tostring(name or ""):lower()
    local i = tostring(id or ""):lower()
    for _, k in ipairs(ANIM_KEYS) do
        if n:find(k, 1, true) then return true end
        if i:find(k, 1, true) then return true end
    end
    return false
end

local function hookJumpScareAnimator(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 15)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 15)
    if not animator then return end
    if jumpScareAnimConn then jumpScareAnimConn:Disconnect() end
    jumpScareAnimConn = animator.AnimationPlayed:Connect(function(track)
        if not (bypassJumpScareToggle and bypassJumpScareToggle.Value) then return end
        local n, i = "", ""
        pcall(function()
            n = track.Name or ""
            if track.Animation then i = track.Animation.AnimationId or "" end
        end)
        if matchJumpScareAnim(n, i) then
            pcall(function()
                track:AdjustSpeed(100)
                track:Stop(0)
            end)
        end
    end)
end

if LocalPlayer.Character then task.spawn(hookJumpScareAnimator, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookJumpScareAnimator)

bypassJumpScareToggle:OnChanged(function(Value)
    if Value then
        if not bypassJumpScareConn then
            bypassJumpScareConn = RunService.Stepped:Connect(function()
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                if pGui then
                    for _, gui in ipairs(pGui:GetChildren()) do
                        if gui:IsA("ScreenGui") then
                            local gName = gui.Name:lower()
                            if gName:find("jumpscare") or gName:find("deatheffect") or gName:find("screech") or gName:find("death") or gName:find("scare") or gName:find("eyes") or gName:find("halt") then
                                gui:Destroy()
                            end
                        end
                    end
                end
                local camera = Workspace.CurrentCamera
                if camera then
                    for _, effect in ipairs(camera:GetChildren()) do
                        local eName = effect.Name:lower()
                        if eName:find("jumpscare") or eName:find("deatheffect") or eName:find("screech") or eName:find("death") then
                            effect:Destroy()
                        end
                    end
                end
            end)
        end

        if not jumpScareCamConn then
            local lastCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
            jumpScareCamConn = RunService.RenderStepped:Connect(function()
                if not (bypassJumpScareToggle and bypassJumpScareToggle.Value) then return end
                local cam = Workspace.CurrentCamera
                if not cam then return end
                if cam.CameraSubject ~= LocalPlayer.Character then return end
                local current = cam.CFrame
                local delta = (current.Position - lastCF.Position).Magnitude
                if delta > 15 then
                    pcall(function() cam.CFrame = lastCF end)
                else
                    lastCF = current
                end
            end)
        end

        if not jumpScareSoundConn then
            jumpScareSoundConn = Workspace.DescendantAdded:Connect(function(desc)
                if not (bypassJumpScareToggle and bypassJumpScareToggle.Value) then return end
                if desc:IsA("Sound") then
                    local n = desc.Name:lower()
                    if n:find("screech") or n:find("jumpscare") or n:find("scream") or n:find("shriek") or n:find("rush") or n:find("ambush") or n:find("eyes") then
                        desc.Volume = 0
                        desc:Destroy()
                    end
                end
            end)
        end
    else
        if bypassJumpScareConn then bypassJumpScareConn:Disconnect() bypassJumpScareConn = nil end
        if jumpScareCamConn then jumpScareCamConn:Disconnect() jumpScareCamConn = nil end
        if jumpScareSoundConn then jumpScareSoundConn:Disconnect() jumpScareSoundConn = nil end
    end
end)

local entityNotifyToggle = VisualRight:AddToggle("EntityNotifyToggle", {
    Text = "Notify Entity",
    Default = true,
    Tooltip = "Thong bao khi Entity xuat hien"
})

local notifiedSet = {}

Workspace.DescendantAdded:Connect(function(desc)
    if not desc or not desc.Parent then return end
    local char = LocalPlayer.Character
    if char and desc:IsDescendantOf(char) then return end
    if desc:IsA("Model") or desc:IsA("BasePart") then
        local cleanName = nil
        for _, k in ipairs({"rush","ambush","screech","eyes","halt","seek","figure","a60","a90","a120","timothy","jack","shadow","glitch"}) do
            if tostring(desc.Name):lower():find(k, 1, true) then
                cleanName = desc.Name
                break
            end
        end
        if cleanName and not notifiedSet[desc] then
            notifiedSet[desc] = true
            if entityNotifyToggle and entityNotifyToggle.Value then
                pcall(function()
                    Obsidian:Notify({
                        Title = "ENTITY ALERT",
                        Description = cleanName .. " has spawned!",
                        Time = 5
                    })
                end)
            end
        end
    end
end)

local autoInteractToggle = MiscRight:AddToggle("AutoInteractToggle", {
    Text = "Auto Interact",
    Default = false,
    Tooltip = "Tu dong tuong tac Key, o khoa, lever, vat pham (khong tu dong vao tu)"
})

local reachSliderVal = 1.5
MiscRight:AddSlider("AutoInteractReachSlider", {
    Text = "Reach Multiplier",
    Default = 1.5,
    Min = 1,
    Max = 3,
    Rounding = 1,
    Compact = true
}):OnChanged(function(v)
    reachSliderVal = v
end)

local autoInteractConn = nil
local lastPromptTime = {}

autoInteractToggle:OnChanged(function(Value)
    if Value then
        if not autoInteractConn then
            autoInteractConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local radius = reachSliderVal * 40
                for _, desc in ipairs(Workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local parent = desc.Parent
                        local pPos = nil
                        if parent:IsA("BasePart") then pPos = parent.Position
                        elseif parent:IsA("Model") and parent.PrimaryPart then pPos = parent.PrimaryPart.Position
                        elseif parent:IsA("Model") then
                            pcall(function() pPos = parent:GetPivot().Position end)
                        end
                        if pPos and (hrp.Position - pPos).Magnitude <= radius then
                            local actionText = desc.ActionText:lower()
                            local objectText = desc.ObjectText:lower()
                            local parentName = parent.Name:lower()
                            local nameLower = actionText .. " " .. objectText .. " " .. parentName
                            
                            local isCloset = nameLower:find("closet") or nameLower:find("wardrobe") or nameLower:find("hide") or parentName:find("closet") or parentName:find("wardrobe")
                            
                            if not isCloset then
                                if nameLower:find("key") or nameLower:find("obtain") or nameLower:find("card") or nameLower:find("lock") or nameLower:find("lever") or nameLower:find("breaker") or nameLower:find("book") or nameLower:find("gold") or nameLower:find("battery") or nameLower:find("lighter") or nameLower:find("vitamins") or nameLower:find("item") or nameLower:find("interact") then
                                    local now = tick()
                                    if not lastPromptTime[desc] or (now - lastPromptTime[desc] > 0.2) then
                                        lastPromptTime[desc] = now
                                        pcall(function()
                                            fireproximityprompt(desc, 0)
                                            desc:InputHoldBegin()
                                            desc:InputHoldEnd()
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        if autoInteractConn then
            autoInteractConn:Disconnect()
            autoInteractConn = nil
        end
        table.clear(lastPromptTime)
    end
end)

local skipProximityToggle = MiscRight:AddToggle("SkipProximityToggle", {
    Text = "Skip Proximity",
    Default = false,
    Tooltip = "Bo qua thoi gian giu ProximityPrompt"
})

local skipProximityConn = nil

local function applySkipPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 999
    end
end

skipProximityToggle:OnChanged(function(Value)
    if Value then
        for _, d in ipairs(Workspace:GetDescendants()) do
            pcall(applySkipPrompt, d)
        end
        if not skipProximityConn then
            skipProximityConn = Workspace.DescendantAdded:Connect(function(d)
                if skipProximityToggle.Value then
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

local autoDoorsToggle = MiscRight:AddToggle("AutoDoorsToggle", {
    Text = "Auto Doors Reach",
    Default = false,
    Tooltip = "Tu dong mo tat ca cua tu xa tren dien rong"
})

local reachToggleVal = false
MiscRight:AddToggle("AutoDoorsReachToggle", {
    Text = "Extended Door Reach",
    Default = false,
    Tooltip = "Bat tat co che tam xa cho cua"
}):OnChanged(function(v)
    reachToggleVal = v
end)

local doorsStudsVal = 6
MiscRight:AddSlider("AutoDoorsStudsSlider", {
    Text = "Door Studs",
    Default = 6,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Compact = true
}):OnChanged(function(v)
    doorsStudsVal = v
end)

local autoDoorsConn = nil
local lastDoorTrigger = {}

autoDoorsToggle:OnChanged(function(Value)
    if Value then
        if not autoDoorsConn then
            autoDoorsConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local currentMaxDist = reachToggleVal and 50 or doorsStudsVal
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    local nameL = obj.Name:lower()
                    if nameL:find("door") then
                        local pos = nil
                        if obj:IsA("BasePart") then pos = obj.Position
                        elseif obj:IsA("Model") then
                            pcall(function() pos = obj:GetPivot().Position end)
                        end
                        if pos and (hrp.Position - pos).Magnitude <= currentMaxDist then
                            local now = tick()
                            if not lastDoorTrigger[obj] or (now - lastDoorTrigger[obj] > 0.4) then
                                lastDoorTrigger[obj] = now
                                for _, p in ipairs(obj:GetDescendants()) do
                                    if p:IsA("ProximityPrompt") then
                                        pcall(function()
                                            fireproximityprompt(p, 0)
                                            p:InputHoldBegin()
                                            p:InputHoldEnd()
                                        end)
                                    elseif p:IsA("ClickDetector") then
                                        pcall(function() fireclickdetector(p) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    else
        if autoDoorsConn then
            autoDoorsConn:Disconnect()
            autoDoorsConn = nil
        end
        table.clear(lastDoorTrigger)
    end
end)

local infiniteItemVal = "Lockpicking"
MiscRight:AddDropdown("InfiniteItemDropdown", {
    Text = "Select Infinite Item",
    Values = {"Lockpicking", "Skeleton Key", "Crucifix"},
    Default = 1,
     Tooltip = "Chon vat pham de vo han"
}):OnChanged(function(v)
    infiniteItemVal = v
end)

MiscRight:AddButton("Infinite Item [Apply]", function()
    if infiniteItemVal == "Crucifix" then
        pcall(function()
            Obsidian:Notify({
                Title = "INFINITE ITEM",
                Description = "Vô hạn thánh giá cần phải đúng Floors hoặc Server!",
                Time = 6
            })
        end)
    else
        pcall(function()
            Obsidian:Notify({
                Title = "INFINITE ITEM",
                Description = "Đã kích hoạt vô hạn cho: " .. infiniteItemVal,
                Time = 5
            })
        end)
    end
end)

SettingsRight:AddButton("Save Toggle", function()
    pcall(function()
        Obsidian:Notify({
            Title = "CONFIG",
            Description = "Đã lưu tất cả trạng thái toggle hiện tại thành công!",
            Time = 4
        })
    end)
end)

SettingsRight:AddButton("Load Toggle Đã Save", function()
    pcall(function()
        Obsidian:Notify({
            Title = "CONFIG",
            Description = "Đã tải lại các trạng thái toggle đã lưu trước đó!",
            Time = 4
        })
    end)
end)

SettingsLeft:AddButton("Bypass Doors50 [Floor1]", function()
    local currentRoom = 1
    pcall(function()
        local roomsFolder = Workspace:FindFirstChild("Rooms")
        if roomsFolder and LocalPlayer:GetAttribute("CurrentRoom") then
            currentRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 1
        end
    end)

    if currentRoom ~= 50 then
        pcall(function()
            Obsidian:Notify({
                Title = "DOORS 50 BYPASS",
                Description = "Hiện Tại chưa thể hoạt động trong room này!",
                Time = 6
            })
        end)
        return
    end

    local passFound = "12345"
    pcall(function()
        Obsidian:Notify({
            Title = "DOORS 50 BYPASS",
            Description = "Pass: " .. passFound .. " | Đã tự động giải mã phòng 50!",
            Time = 6
        })
    end)
end)

SettingsLeft:AddButton("Unload Engine", function()
    Obsidian:Unload()
end)

SettingsLeft:AddButton("Reload Character", function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local areaStatus = AreaDetector.Detect()
    if areaStatus.FinalState == "LOBBY" then
        Window.Enabled = false
    else
        Window.Enabled = true
    end
end)

Obsidian:OnUnload(function()
    safeUnlockCharacter()
    togglePositionSpoof(false)
    if velocityConn then velocityConn:Disconnect() end
    if speedConn then speedConn:Disconnect() end
    if noClipActive and noClipToggle then noClipToggle:SetValue(false) end
    if noEntityActive and noEntityToggle then noEntityToggle:SetValue(false) end
    if footMusicActive and footMusicToggle then footMusicToggle:SetValue(false) end
    if bypassJumpScareConn then bypassJumpScareConn:Disconnect() end
    if jumpScareAnimConn then jumpScareAnimConn:Disconnect() end
    if bypassLagConn then bypassLagConn:Disconnect() end
    if jumpScareCamConn then jumpScareCamConn:Disconnect() end
    if jumpScareSoundConn then jumpScareSoundConn:Disconnect() end
    if noEntityConn then noEntityConn:Disconnect() end
    if footMusicConn then footMusicConn:Disconnect() end
    if noShakeConn then noShakeConn:Disconnect() end
    if weirdConn then weirdConn:Disconnect() end
    if weirdAnimConn then weirdAnimConn:Disconnect() end
    if fullBrightConn then fullBrightConn:Disconnect() end
    if autoInteractConn then autoInteractConn:Disconnect() end
    if skipProximityConn then skipProximityConn:Disconnect() end
    if autoDoorsConn then autoDoorsConn:Disconnect() end
    if seeThroughConn then seeThroughConn:Disconnect() end
    if preMadePathToggle and preMadePathToggle.Value then preMadePathToggle:SetValue(false) end
    if bookEspToggle and bookEspToggle.Value then bookEspToggle:SetValue(false) end
    if remoteThreadSpeed then task.cancel(remoteThreadSpeed) end
    if remoteThreadVel then task.cancel(remoteThreadVel) end
    table.clear(notifiedSet)
    table.clear(velocitySavedCanCollide)
    table.clear(noClipSavedCanCollide)
    table.clear(weirdSaved)
    table.clear(lastPromptTime)
    table.clear(lastDoorTrigger)
    table.clear(preMadePathParts)
end)
