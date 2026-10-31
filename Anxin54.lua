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
Obsidian.Scheme = {
    BackgroundColor  = Color3.fromRGB(255, 236, 242), -- nền hong nhat
    MainColor        = Color3.fromRGB(255, 220, 230), -- panel hong nhat
    AccentColor      = Color3.fromRGB(255, 140, 175), -- icon / toggle / slider
    OutlineColor     = Color3.fromRGB(45, 45, 55),    -- VIEN KHUNG xam (khong hong)
    FontColor        = Color3.fromRGB(130, 115, 125),
    Font             = Font.fromEnum(Enum.Font.Gotham),
    RedColor         = Color3.fromRGB(255, 50, 50),
    DestructiveColor = Color3.fromRGB(220, 38, 38),
    DarkColor        = Color3.new(0, 0, 0),
    WhiteColor       = Color3.new(1, 1, 1),
    BackgroundImage  = ""
}
local Window = Obsidian:CreateWindow({
    Title = "PaintCrack1.5",
    SubTitle = "PaintVcyCrack",
    TabWidth = 180,
    Size = UDim2.new(0, 720, 0, 410),
    Center = true,
    AutoShow = true,
    MenuFadeTime = 0.8,
    Footer = "https://discord.gg/3eHTX99Zz",
})
pcall(function()
    Obsidian.Scheme.AccentColor  = Color3.fromRGB(255, 140, 175)
    Obsidian.Scheme.OutlineColor = Color3.fromRGB(45, 45, 55)
    Obsidian.Scheme.FontColor = Color3.fromRGB(130, 115, 125)
if Obsidian.UpdateColors then Obsidian:UpdateColors() end
    if Obsidian.UpdateColors then Obsidian:UpdateColors() end
end)
Obsidian.Scheme.FontColor = Color3.fromRGB(130, 115, 125)
if Obsidian.UpdateColors then Obsidian:UpdateColors() end

local menuUnlocked = false
local _obsidianToggle = Obsidian.Toggle
local VALID_KEY = "FREEKEYDOORS"

pcall(function()
    if Window and Window.SetVisible then Window:SetVisible(false) end
end)

Obsidian.Toggle = function(...)
    if not menuUnlocked then return end
    return _obsidianToggle(Obsidian, ...)
end


local Tabs = {
    Key = Window:AddTab("Key", "key"),
    Info = Window:AddTab("Info", "user-check"),
    Function = Window:AddTab("Function", "house"),
    Visual = Window:AddTab("Visual", "eye"),
    Misc = Window:AddTab("Misc", "door-open"),
    Anti = Window:AddTab("Anti", "skull"),
    Settings = Window:AddTab("Settings", "cog"),
    Path = Window:AddTab("Room Path", "footprints"),
    }
local function setTabsLocked(locked)
    for name, tab in pairs(Tabs) do
        if name ~= "Key" then
            pcall(function()
                if tab.Disabled ~= nil then tab.Disabled = locked end
                if tab.SetDisabled then tab:SetDisabled(locked) end
            end)
        end
    end
end
setTabsLocked(true)
local KEY_FILE = "PaintCrack_Key24.txt"
local rememberKey = false
local keyExpireAt = nil
local keyCountdownConn = nil

local function playKeySound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://3318713980"
        s.Volume = 10
        s.Parent = game:GetService("SoundService")
        s:Play()
        task.delay(4, function() if s then s:Destroy() end end)
    end)
end

local function saveKey24(k)
    local exp = os.time() + 86400
    pcall(function() writefile(KEY_FILE, k .. "\n" .. tostring(exp)) end)
    keyExpireAt = exp
end

local function loadKey24()
    local ok, data = pcall(function() return readfile(KEY_FILE) end)
    if not ok or not data then return nil, nil end
    local k, exp = data:match("([^\n]+)\n(%d+)")
    exp = tonumber(exp)
    if k and exp and os.time() < exp then return k, exp end
    return nil, nil
end

local function formatHMS(sec)
    sec = math.max(0, math.floor(sec))
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function unlockMenu()
    menuUnlocked = true
    Obsidian.Toggle = _obsidianToggle
    pcall(function() setTabsLocked(false) end)
    pcall(function()
        if Window and Window.SetVisible then
            Window:SetVisible(true)
        end
    end)
    -- mo menu 1 lan sau key
    pcall(function()
        if type(_obsidianToggle) == "function" then
            _obsidianToggle(Obsidian)
        end
    end)
    playKeySound()
    pcall(function()
        Obsidian:Notify({ Title = "PaintCrack", Description = "Key hop le! Menu da mo.", Time = 5 })
    end)
    end

;(function()
local KeyLeft = Tabs.Key:AddLeftGroupbox("Executor Check","terminal")
local KeyRight = Tabs.Key:AddRightGroupbox("License")

local checks = {
    {"Drawing", function() return typeof(Drawing) == "table" end},
    {"getgc", function() return type(getgc) == "function" end},
    {"getgenv", function() return type(getgenv) == "function" end},
    {"getrenv", function() return type(getrenv) == "function" end},
    {"getrawmetatable", function() return type(getrawmetatable) == "function" end},
    {"setreadonly", function() return type(setreadonly) == "function" end},
    {"hookfunction", function() return type(hookfunction) == "function" or type(hookfunc) == "function" end},
    {"hookmetamethod", function() return type(hookmetamethod) == "function" end},
    {"newcclosure", function() return type(newcclosure) == "function" end},
    {"getnamecallmethod", function() return type(getnamecallmethod) == "function" end},
    {"checkcaller", function() return type(checkcaller) == "function" end},
    {"getconnections", function() return type(getconnections) == "function" end},
    {"firesignal", function() return type(firesignal) == "function" end},
    {"fireproximityprompt", function() return type(fireproximityprompt) == "function" end},
    {"islclosure", function() return type(islclosure) == "function" end},
    {"cloneref", function() return type(cloneref) == "function" end},
    {"gethui", function() return type(gethui) == "function" end},
    {"setclipboard", function() return type(setclipboard) == "function" end},
    {"writefile", function() return type(writefile) == "function" end},
    {"readfile", function() return type(readfile) == "function" end},
    {"loadstring", function() return type(loadstring) == "function" end},
    {"HttpGet", function() return pcall(function() return game:HttpGet("https://example.com", true) end) end},
}
for _, c in ipairs(checks) do
    local ok = false
    pcall(function() ok = c[2]() and true or false end)
    KeyLeft:AddLabel((ok and "✅ " or "❌ ") .. c[1])
end
KeyLeft:AddLabel("Welcome to PaintCrack")

KeyRight:AddLabel("Key")
local keyInput = KeyRight:AddInput("PaintKeyInput", {
    Default = "",
    Numeric = false,
    Text = "Key",
    Placeholder = "Paste your key here",
    Callback = function() end,
})

KeyRight:AddToggle("RememberKey24h", {
    Text = "Remember Key For 24 Hours",
    Default = false,
}):OnChanged(function(v)
    rememberKey = v
    if not v then
        -- Tắt nhớ key → xóa file, dừng đếm, khóa tab, bắt nhập lại
        if keyCountdownConn then
            keyCountdownConn:Disconnect()
            keyCountdownConn = nil
        end
        keyExpireAt = nil
        pcall(function()
            if isfile and isfile(KEY_FILE) and delfile then
                delfile(KEY_FILE)
            end
        end)
        pcall(function()
            countdownLbl:SetText("<font color='#FF3232'>Key time: --:--:--</font>")
        end)
        menuUnlocked = false
        Obsidian.Toggle = function(...) end
        pcall(function() setTabsLocked(true) end)
        pcall(function()
            Obsidian:Notify({
                Title = "PaintCrack",
                Description = "<font color='#FF3232'>Đã tắt Remember — nhập lại key!</font>",
                Time = 4,
            })
        end)
    end
end)

local countdownLbl = KeyRight:AddLabel("Key time: --:--:--")
pcall(function()
    countdownLbl:SetText("<font color='#FF3232'>Key time: --:--:--</font>")
end)

local function startCountdown()
    if keyCountdownConn then keyCountdownConn:Disconnect() end
    if not keyExpireAt then return end
    keyCountdownConn = RunService.Heartbeat:Connect(function()
        local left = (keyExpireAt or 0) - os.time()
        local t = formatHMS(left)
        pcall(function()
            countdownLbl:SetText("<font color='#FF3232'>Key time: " .. t .. "</font>")
        end)
        if left <= 0 then
            keyCountdownConn:Disconnect()
            keyCountdownConn = nil
            keyExpireAt = nil
            menuUnlocked = false
            Obsidian.Toggle = function(...) end
            pcall(function() setTabsLocked(true) end)
            pcall(function()
                countdownLbl:SetText("<font color='#FF3232'>Key time: --:--:--</font>")
            end)
            pcall(function()
                Obsidian:Notify({
                    Title = "PaintCrack",
                    Description = "<font color='#FF3232'>KEY ĐÃ HẾT HẠN!</font>",
                    Time = 5,
                })
            end)
        end
    end)
end

local function lockMenu()
    menuUnlocked = false
    Obsidian.Toggle = function(...) end
    pcall(function() setTabsLocked(true) end)
    keyExpireAt = nil
    if keyCountdownConn then
        keyCountdownConn:Disconnect()
        keyCountdownConn = nil
    end
    pcall(function()
        countdownLbl:SetText("<font color='#FF3232'>Key time: --:--:--</font>")
    end)
end

KeyRight:AddButton("Continue", function()
    local input = ""
    pcall(function()
        input = tostring(keyInput.Value or keyInput.Text or "")
    end)
    input = input:gsub("^%s+", ""):gsub("%s+$", "")

    if input == VALID_KEY then
        if rememberKey then
            -- Có nhớ key → lưu 24h + bộ đếm + mở menu
            saveKey24(input)
            startCountdown()
            unlockMenu()
            playKeySound()
            pcall(function()
                Obsidian:Notify({
                    Title = "PaintCrack",
                    Description = "Key hợp lệ — Remember 24h!",
                    Time = 4,
                })
            end)
        else
            -- Không nhớ key → chỉ mở session, không đếm, không lưu
            -- (tab mở trong session này; tắt script / rejoin phải nhập lại)
            pcall(function()
                if isfile and isfile(KEY_FILE) and delfile then
                    delfile(KEY_FILE)
                end
            end)
            keyExpireAt = nil
            if keyCountdownConn then
                keyCountdownConn:Disconnect()
                keyCountdownConn = nil
            end
            pcall(function()
                countdownLbl:SetText("<font color='#FF3232'>Key time: --:--:--</font>")
            end)
            unlockMenu()
            playKeySound()
            pcall(function()
                Obsidian:Notify({
                    Title = "PaintCrack",
                    Description = "Key OK (không nhớ — chỉ session này)",
                    Time = 4,
                })
            end)
        end
    else
        playKeySound()
        lockMenu()
        Obsidian:Notify({
            Title = "PaintCrack",
            Description = "KEY ĐÃ HẾT HẠN HOẶC SAI!",
            Time = 4,
        })
    end
end)

task.defer(function()
    local k, exp = loadKey24()
    if k == VALID_KEY and exp then
        -- Chỉ auto-mở khi đã từng Remember
        rememberKey = true
        keyExpireAt = exp
        startCountdown()
        unlockMenu()
        pcall(function()
            -- sync toggle UI nếu lib hỗ trợ
            if KeyRight then end
        end)
    else
        lockMenu()
    end
end)
end)()
local InfoGroup = Tabs.Info:AddLeftGroupbox("Player & Area Info")
local playerInfoLabel = InfoGroup:AddLabel("Player: " .. LocalPlayer.Name)
local floorInfoLabel = InfoGroup:AddLabel("Status: Crack Xcode Ho Tro Doors")
local loadedLabel = InfoGroup:AddLabel("<font color='#32FF64'><b>PaintVcy1.2 Loaded Successfully!</b></font>", true)

local noteGroup = Tabs.Info:AddRightGroupbox("Changelog")
noteGroup:AddLabel("<font color='#FF3232'><b>PaintV1.5 Fix + Add</b></font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Add Axial Velocity</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Fix Bug Lag</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Fix infinite item</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Fix Remove Dame,Lag</font>", true)
noteGroup:AddLabel("<font color='#FF3232'>+ Add Remove Chaos visual effects</font>", true)
noteGroup:AddLabel("<font color='#32FF64'>Thời điểm Fix + Add: 22/10/2026</font>", true)
local checkGroup = Tabs.Info:AddRightGroupbox("Check System")

local checkPlayerLabel = checkGroup:AddLabel("<font color='#32FF64'>Check Player: Đang quét...</font>", true)
local checkRoomLabel = checkGroup:AddLabel("<font color='#32FF64'>Check Room: Đang quét...</font>", true)
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

task.spawn(function()
    while task.wait(0.5) do
        
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
local FuncRight = Tabs.Function:AddRightGroupbox("Exploits","Flame")
local IndexLeft = Tabs.Function:AddLeftGroupbox("Index")

local jumpPowerVal = 50
local jumpPowerOn = false
local infJumpOn = false
local infJumpConn = nil

IndexLeft:AddToggle("JumpPowerToggle", {
    Text = "JumpPower", Default = false,
}):OnChanged(function(v)
    jumpPowerOn = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.UseJumpPower = true
            hum.JumpPower = v and jumpPowerVal or 50
            hum.JumpHeight = v and (jumpPowerVal / 5) or 7.2
        end)
    end
end)

IndexLeft:AddToggle("JumpPowerToggle", {
    Text = "JumpPower", Default = false,
}):OnChanged(function(v)
    jumpPowerOn = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if char then char:SetAttribute("CanJump", true) end
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum.UseJumpPower = true
        hum.JumpPower = v and jumpPowerVal or 50
        hum.JumpHeight = v and math.clamp(jumpPowerVal / 5, 7.2, 50) or 7.2
    end)
end)

IndexLeft:AddSlider("JumpPowerSlider", {
    Text = "Jump Power", Default = 50, Min = 50, Max = 250, Rounding = 0, Compact = true,
}):OnChanged(function(v)
    jumpPowerVal = v
    if not jumpPowerOn then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    pcall(function()
        if char then char:SetAttribute("CanJump", true) end
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        hum.UseJumpPower = true
        hum.JumpPower = v
        hum.JumpHeight = math.clamp(v / 5, 7.2, 50)
    end)
end)
IndexLeft:AddLabel("<font color='#FFAA00'> Enable Jumping/Sliding có thể bị anticheat phát hiện trong một số floor.</font>", true)

local enableJumpOn = false
local oldJumpValue = nil
local enableSlideOn = false
local oldSlideValue = nil
local infiniteJumpsOn = false
local infJumpConn1 = nil
local infJumpConn2 = nil
local isTyping = false
local indexAutoInteractOn = false
local indexAutoInteractConn = nil
local lastInteractFire = 0
local interactDebounce = false
local interactIgnoreList = {
    HidePrompt = true, RiftPrompt = true, StarRiftPrompt = true, InteractPrompt = true,
    ClimbPrompt = true, DonatePrompt = true, DialoguePrompt = true, RevivePrompt = true,
    EnterPrompt = true, AnimatePrompt = true, ToolEventPrompt = true, Prompt = true,
    PropPrompt = true, TrackLever = true,
    SeatPrompt = true, SitPrompt = true, ChairPrompt = true,
}

local function applyCanJump(char)
    if not char then return end
    pcall(function()
        if oldJumpValue == nil then
            oldJumpValue = char:GetAttribute("CanJump")
        end
        char:SetAttribute("CanJump", true)
    end)
end

local function applyCanSlide(char)
    if not char then return end
    pcall(function()
        if oldSlideValue == nil then
            oldSlideValue = char:GetAttribute("CanSlide")
        end
        char:SetAttribute("CanSlide", true)
    end)
end

IndexLeft:AddToggle("EnableJumpToggle", {
    Text = "Enable Jumping",
    Default = false,
}):OnChanged(function(v)
    enableJumpOn = v
    local char = LocalPlayer.Character
    if v then
        applyCanJump(char)
        if infJumpConn1 then else end
        task.spawn(function()
            while enableJumpOn do
                local c = LocalPlayer.Character
                if c then pcall(function() c:SetAttribute("CanJump", true) end) end
                task.wait(0.1)
            end
        end)
    else
        if char and oldJumpValue ~= nil then
            pcall(function() char:SetAttribute("CanJump", oldJumpValue) end)
        end
        oldJumpValue = nil
    end
end)

IndexLeft:AddToggle("EnableSlideToggle", {
    Text = "Enable Sliding",
    Default = false,
}):OnChanged(function(v)
    enableSlideOn = v
    local char = LocalPlayer.Character
    if v then
        applyCanSlide(char)
        task.spawn(function()
            while enableSlideOn do
                local c = LocalPlayer.Character
                if c then pcall(function() c:SetAttribute("CanSlide", true) end) end
                task.wait(0.1)
            end
        end)
    else
        if char and oldSlideValue ~= nil then
            pcall(function() char:SetAttribute("CanSlide", oldSlideValue) end)
        end
        oldSlideValue = nil
    end
end)

IndexLeft:AddToggle("InfiniteJumpsToggle", {
    Text = "Infinite Jumps",
    Default = false,
}):OnChanged(function(v)
    infiniteJumpsOn = v
    if infJumpConn1 then infJumpConn1:Disconnect() infJumpConn1 = nil end
    if infJumpConn2 then infJumpConn2:Disconnect() infJumpConn2 = nil end
    if not v then return end

    pcall(function()
        UserInputService.TextBoxFocused:Connect(function() isTyping = true end)
        UserInputService.TextBoxFocusReleased:Connect(function() isTyping = false end)
    end)

    infJumpConn1 = UserInputService.InputBegan:Connect(function(input, gp)
        if not infiniteJumpsOn or gp or isTyping then return end
        if input.KeyCode == Enum.KeyCode.Space then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
        end
    end)

    pcall(function()
        local btn = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
            and LocalPlayer.PlayerGui.MainUI:FindFirstChild("MainFrame")
            and LocalPlayer.PlayerGui.MainUI.MainFrame:FindFirstChild("MobileButtons")
            and LocalPlayer.PlayerGui.MainUI.MainFrame.MobileButtons:FindFirstChild("JumpButton")
        if btn then
            infJumpConn2 = btn.MouseButton1Down:Connect(function()
                if not infiniteJumpsOn then return end
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
            end)
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if enableJumpOn then applyCanJump(char) end
    if enableSlideOn then applyCanSlide(char) end
end)
local VisualLeft = Tabs.Visual:AddLeftGroupbox("Visual")
local VisualRight = Tabs.Visual:AddRightGroupbox("Lighting & Lag","measuring instrument")
local MiscLeft = Tabs.Misc:AddLeftGroupbox("Stealth")
local MiscRight = Tabs.Misc:AddRightGroupbox("Utility & Auto","wrench")
local MiscInteract = Tabs.Misc:AddLeftGroupbox("Interact","hand")
;(function()
local AntiLeft = Tabs.Anti:AddLeftGroupbox("Anti Entity","shield")
local AntiRight = Tabs.Anti:AddRightGroupbox("Anti Trap","Shield-off")
pcall(function()
    local fn = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/nguyenthienanbinh2012-pixel/Sad_Heart54/refs/heads/main/SemiGodMode_36.lua"
    ))()
    if type(fn) == "function" then
        fn(AntiLeft, AntiRight, Obsidian, {
            Workspace = Workspace,
            RunService = RunService,
            ReplicatedStorage = ReplicatedStorage,
            Players = Players,
            LocalPlayer = LocalPlayer,
            MiscTab = Tabs.Misc,
            VisualTab = Tabs.Visual,
        })
    end
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

local PS = {
    on = false,
    c1Origin = nil,
    conn = nil,
    lastCrouch = 0,
    ui = nil,
    label = nil,
    stroke = nil,
}

local function psNotify(on)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://3318713980"
        s.Volume = 8
        s.Parent = game:GetService("SoundService")
        s:Play()
        task.delay(2.2, function() if s then s:Destroy() end end)
    end)
    if on then
        pcall(function()
            Obsidian:Notify({
                Title = "Position Spoof",
                Description = "<font color='#FF3232'>Position Spoof chi an toan khi dung im hoac di chuyen, Nhay hay di cau thang se dan toi cai chet</font>",
                Time = 2.2,
            })
        end)
    end
end

local function psDestroyUI()
    if PS.ui then pcall(function() PS.ui:Destroy() end) end
    PS.ui, PS.label, PS.stroke = nil, nil, nil
end

local function psCreateUI()
    if PS.ui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "SpoofWidgetGui"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 200
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 36)
    frame.Position = UDim2.new(0.5, -75, 0, 2)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 18)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(50, 255, 100)
    stroke.Parent = frame
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "HRP.Y: -2.35"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.Parent = frame
    frame.Parent = gui
    gui.Parent = PlayerGui
    PS.ui, PS.label, PS.stroke = gui, label, stroke
end

local function psGetCrouch()
    local rf = ReplicatedStorage:FindFirstChild("RemotesFolder")
        or ReplicatedStorage:FindFirstChild("EntityInfo")
        or ReplicatedStorage:FindFirstChild("Bricks")
        or ReplicatedStorage
    return rf:FindFirstChild("Crouch") or rf:FindFirstChild("Crouch", true)
end

local function psMainLoop()
    if PS.conn then PS.conn:Disconnect() PS.conn = nil end
    PS.conn = RunService.RenderStepped:Connect(function()
        if not PS.on then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local Collision = char:FindFirstChild("Collision")
        local CollisionPart = char:FindFirstChild("CollisionPart")
        local CollisionClone = char:FindFirstChild("CollisionClone") or char:FindFirstChild("CollisionPartClone")

        if tick() - PS.lastCrouch > 0.1 then
            PS.lastCrouch = tick()
            local cr = psGetCrouch()
            if cr then pcall(function() cr:FireServer(true, true) end) end
        end

        if Collision then
            Collision.CanCollide = false
            local cc = Collision:FindFirstChild("CollisionCrouch")
            if cc then cc.CanCollide = false end
        end

        local lt = char:FindFirstChild("LowerTorso")
        local root = lt and lt:FindFirstChild("Root")
        if root and root:IsA("Motor6D") then
            if not PS.c1Origin then PS.c1Origin = root.C1 end
            root.C1 = PS.c1Origin * CFrame.new(0, -2.346, 0)
        end

        local SpoofY = 2.328
        if Collision and Collision:IsA("BasePart") then
            Collision.Position = hrp.Position + Vector3.new(0, SpoofY, 0)
        end
        if CollisionPart and CollisionPart:IsA("BasePart") then
            CollisionPart.Position = hrp.Position + Vector3.new(0, SpoofY, 0)
        end

        if Collision and Collision:FindFirstChild("CollisionCrouch") then
            Collision.CollisionCrouch.Position = hrp.Position + Vector3.new(0, 1.328, 0)
        end
        if CollisionClone and CollisionClone:IsA("BasePart") then
            if Collision then
                pcall(function() CollisionClone.CollisionGroup = Collision.CollisionGroup end)
            end
            CollisionClone.Position = hrp.Position + Vector3.new(0, 1.75, 0)
            local ccc = CollisionClone:FindFirstChild("CollisionCrouch")
            if ccc then ccc.Position = hrp.Position + Vector3.new(0, 0.75, 0) end
        end

        if PS.label then
            PS.label.Text = string.format("HRP.Y: %.2f", -2.346)
            if PS.stroke then PS.stroke.Color = Color3.fromRGB(50, 255, 100) end
        end
    end)
end

local function togglePositionSpoof(Value)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hrp or not hum then return end

    local cr = psGetCrouch()

    if Value then
        if PS.on then return end
        PS.on = true
        local lt = char:FindFirstChild("LowerTorso")
        local root = lt and lt:FindFirstChild("Root")
        if root and root:IsA("Motor6D") and not PS.c1Origin then
            PS.c1Origin = root.C1
        end
        hrp.CFrame = hrp.CFrame * CFrame.new(0, -2.346, 0)
        hum.HipHeight = 0.05
        if cr then pcall(function() cr:FireServer(true, true) end) end
        psCreateUI()
        psMainLoop()
        psNotify(true)
    else
        if not PS.on then return end
        PS.on = false
        if PS.conn then PS.conn:Disconnect() PS.conn = nil end

        hrp.CFrame = hrp.CFrame * CFrame.new(0, 2.346, 0)
        hum.HipHeight = 2.396

        local rp = hrp.Position + Vector3.new(0, 0.18, 0)
        for _, n in ipairs({"Collision", "CollisionPart", "CollisionClone", "CollisionPartClone"}) do
            local p = char:FindFirstChild(n)
            if p and p:IsA("BasePart") then p.Position = rp end
        end
        local lt = char:FindFirstChild("LowerTorso")
        local root = lt and lt:FindFirstChild("Root")
        if root and PS.c1Origin then root.C1 = PS.c1Origin end

        if cr then pcall(function() cr:FireServer(false, true) end) end
        psDestroyUI()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    PS.c1Origin = nil
    if PS.on then
        task.delay(1, function()
            PS.on = false
            togglePositionSpoof(true)
        end)
    end
end)

local axialActive = false
local axialSpeed = 4
local axialConn = nil
local axialJumpConn = nil
local axialSaved = setmetatable({}, { __mode = "k" })
local axialLastDir = Vector3.new(0, 0, -1)
local axialHumBackup = nil

local function forceNoclip(char)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if axialSaved[p] == nil then
                axialSaved[p] = {
                    CanCollide = p.CanCollide,
                    CanQuery = p.CanQuery,
                    CanTouch = p.CanTouch,
                    CollisionGroup = p.CollisionGroup,
                }
            end
            p.CanCollide = false
            p.CanQuery = false
            p.CanTouch = false
            pcall(function() p.CollisionGroup = "NoCollision" end)
        end
    end
    for _, n in ipairs({"Collision", "CollisionPart", "CollisionClone", "CollisionPartClone"}) do
        local p = char:FindFirstChild(n)
        if p and p:IsA("BasePart") then
            if axialSaved[p] == nil then
                axialSaved[p] = {
                    CanCollide = p.CanCollide,
                    CanQuery = p.CanQuery,
                    CanTouch = p.CanTouch,
                    CollisionGroup = p.CollisionGroup,
                }
            end
            p.CanCollide = false
            p.CanQuery = false
            p.CanTouch = false
        end
    end
end

local function stopAxial()
    axialActive = false
    if axialConn then axialConn:Disconnect(); axialConn = nil end
    if axialJumpConn then axialJumpConn:Disconnect(); axialJumpConn = nil end
    for part, data in pairs(axialSaved) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = data.CanCollide
                part.CanQuery = data.CanQuery
                part.CanTouch = data.CanTouch
                if data.CollisionGroup then part.CollisionGroup = data.CollisionGroup end
            end)
        end
    end
    table.clear(axialSaved)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        pcall(function() hrp:SetNetworkOwner(LocalPlayer) end)
    end
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.WalkSpeed = axialHumBackup and axialHumBackup.ws or 16
            hum.JumpPower = axialHumBackup and axialHumBackup.jp or 50
            hum.UseJumpPower = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
    axialHumBackup = nil
end

local function startAxial()
    if axialConn then axialConn:Disconnect(); axialConn = nil end
    if axialJumpConn then axialJumpConn:Disconnect(); axialJumpConn = nil end
    axialActive = true
    axialJumpConn = UserInputService.JumpRequest:Connect(function()
        if not axialActive then return end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.Jump = false end) end
    end)
    axialConn = RunService.Heartbeat:Connect(function(dt)
        if not axialActive then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local cam = Workspace.CurrentCamera
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not cam or not hum then return end
        forceNoclip(char)
        pcall(function()
            hum.JumpPower = 0
            hum.JumpHeight = 0
            hum.PlatformStand = true
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end)
        pcall(function() hrp:SetNetworkOwner(nil) end)
        local dir = cam.CFrame.LookVector
        if dir.Magnitude > 0.05 then dir = dir.Unit; axialLastDir = dir else dir = axialLastDir end
        local step = math.clamp(dt or 0.016, 0.008, 0.05)
        local speed = axialSpeed
        hrp.CFrame = hrp.CFrame + dir * speed * step
        hrp.AssemblyLinearVelocity = dir * speed
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
end

local axialToggle = FuncLeft:AddToggle("AxialVelocityToggle", {
    Text = "<font color='#C4A574'>Axial Velocity</font>",
    Default = false,
    Tooltip = "Don tho - xuyen theo cam,tranh game keo lui lai",
})
local axialSlider = FuncLeft:AddSlider("Axial Speed", {
    Text = "Toc do Don Tho",
    Default = 4,
    Min = 1,
    Max = 6,
    Rounding = 1,
    Compact = true,
})
axialSlider:OnChanged(function(v) axialSpeed = v end)
axialToggle:OnChanged(function(Value)
    if Value then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then axialHumBackup = { ws = hum.WalkSpeed, jp = hum.JumpPower } end
        startAxial()
    else
        stopAxial()
    end
end)
LocalPlayer.CharacterAdded:Connect(function()
    if axialToggle and axialToggle.Value then
        task.wait(0.8)
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
local removeVoidOn = false
local voidConn = nil

FuncLeft:AddToggle("RemoveVoidToggle", {
    Text = "Remove Void Roblox", Default = false,
    Tooltip = "Xoa Voids Roblox+Anti Kill brick!",
}):OnChanged(function(v)
    removeVoidOn = v
    if voidConn then voidConn:Disconnect() voidConn = nil end
    if not v then return end
    local function strip(obj)
        if not obj then return end
        local n = string.lower(tostring(obj.Name or ""))
        if n:find("void", 1, true) or n:find("kill", 1, true) then
            pcall(function()
                if obj:IsA("BasePart") then
                    obj.CanTouch = false
                    obj.CanQuery = false
                end
            end)
        end
        if obj:IsA("BasePart") and obj.Position.Y < -20 and obj.Size.X > 40 and obj.Size.Z > 40 then
            pcall(function()
                obj.CanTouch = false
                obj.CanQuery = false
            end)
        end
    end
    for _, d in ipairs(Workspace:GetDescendants()) do strip(d) end
    voidConn = Workspace.DescendantAdded:Connect(function(d)
        if removeVoidOn then task.defer(strip, d) end
    end)
end)

positionSpoofToggle:OnChanged(function(Value)
    pcall(togglePositionSpoof, Value)
    if Value then
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://3318713980"
            s.Volume = 8
            s.Parent = game:GetService("SoundService")
            s:Play()
            task.delay(2.2, function() if s then s:Destroy() end end)
        end)
        pcall(function()
            Obsidian:Notify({
                Title = "Position Spoof",
                Description = "<font color='#FF3232'>Position Spoof chi an toan khi dung im hoac di chuyen, Nhay hay di len,xuong cau thang se dan toi cai chet</font>",
                Time = 5,
            })
        end)
    end
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
            hum.WalkSpeed = 30
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
    flyVelocity.VectorVelocity = finalDir * flySpeed
end)
    end

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
if flyToggle and flyToggle.Value then startFly() end
    end
end)

local targetWalkSpeed = 30
local isSpeedActive = false
local speedActive = false
local speedMethod = "Instant"
local speedConn = nil
local remoteThreadSpeed = nil

local speedMethodDropdown = FuncRight:AddDropdown("SpeedMethodDropdown", {
    Text = "Speed Method",
    Values = {"Boost", "Instant"},
    Default = 2,
    Tooltip = "Boost: tang dan | Instant: set ngay"
})
speedMethodDropdown:OnChanged(function(Value)
    speedMethod = Value
end)
local speedToggle = FuncRight:AddToggle("SpeedBypassToggle", {
    Text = "Speed", Default = false,
    Tooltip = "Doi WalkSpeed tuy chinh tang toc tu tu hoac tuc thi"
})
speedToggle:OnChanged(function(Value)
    isSpeedActive = Value
    speedActive = Value
    if Value then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function(dt)
        if remoteThreadSpeed then task.cancel(remoteThreadSpeed) end
        remoteThreadSpeed = task.spawn(function()
            while speedActive do
                pcall(function()
                    local cr = (rawget(_G, "getCrouchRemote") or getCrouchRemote)
                    if type(cr) == "function" then cr = cr() end
                    if not cr then
                        local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
                        cr = rf:FindFirstChild("Crouch", true)
                    end
                    if cr and cr:IsA("RemoteEvent") then
                        cr:FireServer(false, true)
                        task.wait(0.05)
                        cr:FireServer(true, true)
                    end
                end)
                task.wait(0.5)
            end
        end)
            if not speedActive then return end
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local finalSpeed = targetWalkSpeed * 1.0
            if finalSpeed < 16 then finalSpeed = 16 end
            if speedMethod == "Instant" then
                hum.WalkSpeed = finalSpeed
                local md = hum.MoveDirection
                if md.Magnitude > 0.05 then
                    local u = Vector3.new(md.X,0,md.Z)
                    if u.Magnitude>0 then u=u.Unit end
                    local step=math.clamp(dt or 0.016,0.008,0.05)
                    local vy=hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity=Vector3.new(u.X*finalSpeed,vy,u.Z*finalSpeed)
                else
                    local vy=hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity=Vector3.new(0,vy,0)
                end
            else
                if hum.WalkSpeed < finalSpeed then
                    hum.WalkSpeed = math.min(hum.WalkSpeed + 2.5, finalSpeed)
                else
                    hum.WalkSpeed = finalSpeed
                end
            end
        end)
    else
        if speedConn then speedConn:Disconnect(); speedConn=nil end
        if remoteThreadSpeed then task.cancel(remoteThreadSpeed); remoteThreadSpeed=nil end
        pcall(safeUnlockCharacter)
    end
end)
local thirdPersonActive = false
local thirdPersonConn = nil
local thirdPersonZ = 11
local thirdPersonSens = 1
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
    Text = "Do Nhay Cua Camera", Default = 4.3, Min = 1.0, Max = 6, Rounding = 2, Compact = true
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
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.LocalTransparencyModifier = 0
                end
                        end
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
        local c = LocalPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.LocalTransparencyModifier = 0
                end
            end
                end
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
    Text = "Speed Val", Default = 30, Min = 1, Max = 125, Rounding = 1, Compact = true
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

local ENTITY_SKIP = {
    rush=true, ambush=true, seek=true, figure=true, screech=true, halt=true,
    eyes=true, lookman=true, dread=true, timothy=true, jack=true, dupe=true,
    ["a-90"]=true, a90=true, ["a-60"]=true, a60=true, ["a-120"]=true, a120=true,
    glitch=true, vacuum=true, giggle=true, snare=true, shadow=true, sally=true,
    blitz=true, arox=true,
}

local function isEntityModel(model)
    if not model then return false end
    local n = tostring(model.Name or ""):lower()
    for k in pairs(ENTITY_SKIP) do
        if n:find(k, 1, true) then return true end
    end
    return false
end

local function shouldSkipAntiLag(inst)
    if not inst or not inst.Parent then return true end
    local char = LocalPlayer.Character
    if char and inst:IsDescendantOf(char) then return true end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and inst:IsDescendantOf(plr.Character) then return true end
    end
    local model = inst:FindFirstAncestorOfClass("Model") or (inst:IsA("Model") and inst)
    if model and isEntityModel(model) then return true end
    return false
end

local function applyAntiLagToPart(part)
    if not part or not part:IsA("BasePart") then return end
    if antiLagProcessed[part] then return end
    if part.Name == "HumanoidRootPart" or part.Name == "Baseplate" then return end
    if shouldSkipAntiLag(part) then return end

    antiLagProcessed[part] = true
    if originalPartProps[part] == nil then
        originalPartProps[part] = {
            Material = part.Material,
            CastShadow = part.CastShadow,
            Reflectance = part.Reflectance,
            Color = part.Color,
            TextureID = part:IsA("MeshPart") and part.TextureID or nil,
        }
    end
    -- carton / nhua tron
    part.Material = Enum.Material.SmoothPlastic
    part.CastShadow = false
    part.Reflectance = 0
    if part:IsA("MeshPart") then
        pcall(function() part.TextureID = "" end)
    end

    -- xoa hoa tiet tren part
    for _, ch in ipairs(part:GetChildren()) do
        if ch:IsA("Decal") or ch:IsA("Texture") then
            if originalPartProps[ch] == nil then
                originalPartProps[ch] = {Transparency = ch.Transparency}
            end
            ch.Transparency = 1
        elseif ch:IsA("SurfaceAppearance") then
            if originalPartProps[ch] == nil then
                originalPartProps[ch] = {Parent = ch.Parent}
            end
            pcall(function() ch:Destroy() end)
        elseif ch:IsA("SpecialMesh") or ch:IsA("FileMesh") then
            pcall(function()
                if ch.TextureId ~= nil then ch.TextureId = "" end
            end)
        elseif ch:IsA("SurfaceGui") or ch:IsA("BillboardGui") then
            if originalPartProps[ch] == nil then
                originalPartProps[ch] = {Enabled = ch.Enabled}
            end
            ch.Enabled = false
        end
    end
end

local function applyAntiLagToEffect(effect)
    if not effect or not effect.Parent then return end
    if antiLagProcessed[effect] then return end
    if shouldSkipAntiLag(effect) then return end

    antiLagProcessed[effect] = true

    -- tat particle / anh sang / vet
    if effect:IsA("ParticleEmitter") or effect:IsA("Smoke") or effect:IsA("Fire")
        or effect:IsA("Trail") or effect:IsA("Beam") or effect:IsA("Sparkles")
        or effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then
        if originalPartProps[effect] == nil then
            originalPartProps[effect] = {Enabled = effect.Enabled}
        end
        effect.Enabled = false

    -- xoa hoa tiet
    elseif effect:IsA("Decal") or effect:IsA("Texture") then
        if originalPartProps[effect] == nil then
            originalPartProps[effect] = {Transparency = effect.Transparency}
        end
        effect.Transparency = 1

    elseif effect:IsA("SurfaceAppearance") then
        pcall(function() effect:Destroy() end)

    elseif effect:IsA("SurfaceGui") or effect:IsA("BillboardGui") then
        if originalPartProps[effect] == nil then
            originalPartProps[effect] = {Enabled = effect.Enabled}
        end
        effect.Enabled = false

    -- tat animation the gioi (khong phai player/entity)
    elseif effect:IsA("AnimationController") or effect:IsA("Animator") then
        pcall(function()
            for _, t in ipairs(effect:GetPlayingAnimationTracks()) do
                t:Stop(0)
            end
        end)
    elseif effect:IsA("Animation") then
        pcall(function() effect:Destroy() end)
    end
end

local function restoreAntiLag()
    for obj, data in pairs(originalPartProps) do
        if obj and obj.Parent then
            pcall(function()
                if data.Color ~= nil and obj:IsA("BasePart") then obj.Color = data.Color end
                if data.Transparency ~= nil then obj.Transparency = data.Transparency end
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
    or child:IsA("Trail") or child:IsA("Beam") or child:IsA("Sparkles")
    or child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight")
    or child:IsA("Decal") or child:IsA("Texture") or child:IsA("SurfaceAppearance")
    or child:IsA("SurfaceGui") or child:IsA("BillboardGui")
    or child:IsA("Animator") or child:IsA("AnimationController") then
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

-- key match trong ten model (lower)
local ENTITY_KEYS = {
    ["Screech"] = {"screech"},
    ["Timothy"] = {"timothy"},
    ["A-90"] = {"a-90", "a90", "a_90"},
    ["Glitch Errors"] = {"glitch", "error", "glitcherror"},
    ["Haste"] = {"haste"},
    ["Halt"] = {"halt"},
    ["Dread"] = {"dread"},
}

local selectedRemove = {
    Screech = true,
    Timothy = true,
    ["A-90"] = true,
    ["Glitch Errors"] = true,
    Haste = true,
    Halt = true,
    Dread = true,
}

local function matchEntity(name)
    local n = tostring(name or ""):lower()
    for label, keys in pairs(ENTITY_KEYS) do
        if selectedRemove[label] then
            for _, k in ipairs(keys) do
                if n:find(k, 1, true) then
                    return true
                end
            end
        end
    end
    return false
end


-- Obsidian: multi dropdown neu co; neu khong dung tung toggle
pcall(function()
    AntiLeft:AddDropdown("RemoveEntityList", {
        Text = "Entities to Remove",
        Values = {"Screech", "Timothy", "A-90", "Glitch Errors", "Haste", "Halt", "Dread"},
        Multi = true,
        Default = {"Screech", "Timothy", "A-90", "Glitch Errors", "Haste", "Halt", "Dread"},
    }):OnChanged(function(val)
        -- val: table { [name]=true } hoac array tuy ban Obsidian
        for k in pairs(selectedRemove) do
            selectedRemove[k] = false
        end
        if type(val) == "table" then
            for k, v in pairs(val) do
                if v == true and ENTITY_KEYS[k] then
                    selectedRemove[k] = true
                elseif type(k) == "number" and type(v) == "string" and ENTITY_KEYS[v] then
                    selectedRemove[v] = true
                end
            end
        end
    end)
end)
AntiLeft:AddToggle("RemoveEntityToggle", {
    Text = "Remove Entity & Dame cua chúng", Default = false,
}):OnChanged(function(v)
    if v then
        startRemoveEntity()
    else
        stopRemoveEntity()
    end
end)

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
local function stopRemoveEntity()
    removeEntityActive = false
    if removeEntityConn then
        task.cancel(removeEntityConn)
        removeEntityConn = nil
    end
    if removeEntityDescConn then
        removeEntityDescConn:Disconnect()
        removeEntityDescConn = nil
    end
end

local function startRemoveEntity()
    stopRemoveEntity()
    removeEntityActive = true
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
                        elseif p:IsA("Sound") or p:IsA("ParticleEmitter")
                            or p:IsA("Light") or p:IsA("BillboardGui") then
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
                local rooms = Workspace:FindFirstChild("CurrentRooms")
                local roots = rooms and rooms:GetChildren() or Workspace:GetChildren()
                for _, obj in ipairs(roots) do
                    if matchEntity(obj.Name) then
                        pcall(function() obj:Destroy() end)
                    end
                end
            end)
            task.wait(0.35)
        end
    end)
end

local function anySelected()
    for _, on in pairs(selectedRemove) do
        if on then return true end
    end
    return false
end

-- Gắn lại dropdown: chon entity = bat remove, bo het = tat
pcall(function()
    -- neu da AddDropdown o tren, chi can goi start khi load
    if anySelected() then startRemoveEntity() end
end)
end)()
local autoPadlockActive = false
local autoPadlockThread = nil
local autoPadlockToggle = MiscRight:AddToggle("AutoPadlockCodeToggle", {
    Text = "Auto Padlock Code", Default = false,
    Tooltip = "Tu dong do code va bypass o khoa room 50,Chi khi tim du 5 Sach moi BYPASS duoc!",
})

local function getLibraryCode()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    local paper = (char and (char:FindFirstChild("LibraryHintPaper") or char:FindFirstChild("LibraryHintPaperHard")))
        or (bp and (bp:FindFirstChild("LibraryHintPaper") or bp:FindFirstChild("LibraryHintPaperHard")))
    if not paper or not paper:FindFirstChild("UI") then return nil end
    local code = {"_", "_", "_", "_", "_"}
    local perm = LocalPlayer.PlayerGui:FindFirstChild("PermUI")
    local hints = perm and perm:FindFirstChild("Hints")
    if not hints then return nil end
    for _, hint in ipairs(hints:GetChildren()) do
        if hint:IsA("ImageLabel") then
            for _, ui in ipairs(paper.UI:GetChildren()) do
                if ui:IsA("ImageLabel") and hint.ImageRectOffset == ui.ImageRectOffset then
                    local idx = tonumber(ui.Name)
                    local t = hint:FindFirstChild("TextLabel")
                    if idx and code[idx] and t then code[idx] = t.Text end
                end
            end
        end
    end
    local s = table.concat(code)
    if s:find("_", 1, true) then return nil end
    return s
end

autoPadlockToggle:OnChanged(function(Value)
    autoPadlockActive = Value
    if autoPadlockThread then task.cancel(autoPadlockThread) autoPadlockThread = nil end
    if not Value then return end
    autoPadlockThread = task.spawn(function()
        while autoPadlockActive do
            local code = getLibraryCode()
            if code and tonumber(code) then
                local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
                local pl = rf:FindFirstChild("PL") or rf:FindFirstChild("PL", true)
                if pl then pcall(function() pl:FireServer(code) end) end
            end
            task.wait(0.4)
        end
    end)
end)
    

;(function()
local autoInteractActive = false
local autoInteractConn = nil
local autoInteractDebounce = false
local autoInteractLast = 0
local AutoInteractBlacklist = {
    HidePrompt = true, RiftPrompt = true, StarRiftPrompt = true, InteractPrompt = true,
    ClimbPrompt = true, DonatePrompt = true, DialoguePrompt = true, RevivePrompt = true,
    EnterPrompt = true, AnimatePrompt = true, ToolEventPrompt = true, Prompt = true,
    PropPrompt = true, TrackLever = true, SeatPrompt = true, SitPrompt = true,
}

local function isSeatLike(prompt, parent)
    if not parent then return true end
    if parent:IsA("Seat") or parent:IsA("VehicleSeat") then return true end
    local pn = tostring(parent.Name):lower()
    local an = tostring(prompt.ActionText or ""):lower()
    if pn:find("seat") or pn:find("chair") or pn:find("couch") or pn:find("sofa")
        or pn:find("bench") or pn:find("bed") or an:find("sit") then
        return true
    end
    return false
end

local autoInteractActive = false
local autoInteractConn = nil
local autoInteractLast = 0
local autoInteractDebounce = false

local autoInteractToggle = MiscRight:AddToggle("AutoInteractToggle", {
    Text = "Auto Interact", Default = false,
})
autoInteractToggle:OnChanged(function(Value)
    autoInteractActive = Value
    if autoInteractConn then autoInteractConn:Disconnect() autoInteractConn = nil end
    if not Value then return end
    autoInteractConn = RunService.Heartbeat:Connect(function()
        if not autoInteractActive or autoInteractDebounce then return end
        if tick() - autoInteractLast < (1 / 60) then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local myRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))

        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if not autoInteractActive then break end
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                if AutoInteractBlacklist[prompt.Name] then
                elseif isSeatLike(prompt, prompt.Parent) then
                elseif prompt:GetAttribute("AutoInteractIgnore") then
                else
                    local parent = prompt.Parent
                    if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
                        local pr = prompt:GetAttribute("ParentRoom")
                        if pr and myRoom and tonumber(pr) ~= myRoom then
                        else
                            local pPos
                            if parent:IsA("BasePart") then
                                pPos = parent.Position
                            else
                                local ok, pv = pcall(function() return parent:GetPivot().Position end)
                                if ok then pPos = pv end
                            end
                            local maxd = prompt.MaxActivationDistance or 10
                            if pPos and (hrp.Position - pPos).Magnitude <= maxd then
                                local pn = parent.Name
                                if pn ~= "DoorFake" and pn ~= "FakeDoor" and pn ~= "KeyObtainFake"
                                    and pn ~= "TithingPlate" and parent:GetAttribute("Locked") ~= true then
                                    autoInteractDebounce = true
                                    autoInteractLast = tick()
                                    pcall(function()
                                        if fireproximityprompt then fireproximityprompt(prompt) end
                                    end)
                                    task.delay(0.03, function() autoInteractDebounce = false end)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local infiniteItemOn = false
local infiniteItemConn = nil
local infiniteItemPickConn = nil
local infiniteItemSelected = { ["Lockpick"] = true }
local INF_ITEM_NAMES = {
    ["Lockpick"] = true,
    ["Lock Pick"] = true,
    ["Skeleton Key"] = true,
    ["SkeletonKey"] = true,
    ["Shears"] = true,
    ["Multitool"] = true,
}

local function getDropRemote()
    local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
    return rf:FindFirstChild("DropItem") or rf:FindFirstChild("DropItem", true)
end

local function toolMatches(tool)
    if not tool then return false end
    local n = tostring(tool.Name)
    if infiniteItemSelected[n] then return true end
    for sel in pairs(infiniteItemSelected) do
        if n:lower():find(tostring(sel):lower(), 1, true) then return true end
    end
    return false
end

local infItemGroup = Tabs.Misc:AddLeftGroupbox("Infinite Item", "package")
infItemGroup:AddLabel("<font color='#FF3232'>Vô hạn item (Drop + nhặt lại) — chỉ item vứt được</font>", true)
infItemGroup:AddDropdown("InfiniteItemSelect", {
    Text = "Chon item",
    Values = { "Lockpick", "Skeleton Key", "Shears", "Multitool" },
    Multi = true,
    Default = { "Lockpick" },
}):OnChanged(function(v)
    infiniteItemSelected = {}
    if type(v) == "table" then
        for k, val in pairs(v) do
            if val == true and type(k) == "string" then
                infiniteItemSelected[k] = true
            elseif type(val) == "string" then
                infiniteItemSelected[val] = true
            end
        end
    end
end)

infItemGroup:AddToggle("InfiniteItemToggle", {
    Text = "<font color='#FF3232'>Infinite Item</font>",
    Default = false,
}):OnChanged(function(v)
    infiniteItemOn = v
    if infiniteItemConn then infiniteItemConn:Disconnect() infiniteItemConn = nil end
    if not v then return end

    infiniteItemConn = game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt)
        if not infiniteItemOn then return end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool or not toolMatches(tool) then return end

        local drops = Workspace:FindFirstChild("Drops")
        local rf = ReplicatedStorage:FindFirstChild("RemotesFolder") or ReplicatedStorage
        local dropRemote = rf:FindFirstChild("DropItem") or rf:FindFirstChild("DropItem", true)
        if not dropRemote then return end

        -- chi 1 lan: cho Drops.ChildAdded roi drop
        local conn
        conn = drops and drops.ChildAdded:Connect(function(obj)
            if conn then conn:Disconnect() end
            task.defer(function()
                local p = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                    or obj:FindFirstChild("ModulePrompt", true)
                if p and fireproximityprompt then
                    pcall(function() fireproximityprompt(p) end)
                end
            end)
        end)
        pcall(function() dropRemote:FireServer(tool) end)
        task.delay(1, function()
            if conn then conn:Disconnect() end
        end)
    end)
end)

local reachState = { reachMultiplier = 1.5 }

local function checkDoorOpen(door)
    return door:GetAttribute("Opened") == true or door:GetAttribute("Open") == true
end
local function checkDoorLocked(door)
    return door:GetAttribute("Locked") == true
end

local DEFAULT_REACH_MULTI = 1.5
local ReachSlider = MiscInteract:AddSlider("ReachSlider", {
    Text = "Reach Multiplier (1-2)",
    Default = DEFAULT_REACH_MULTI,
    Min = 1, Max = 2, Rounding = 1, Compact = true,
})
ReachSlider:OnChanged(function(v)
    reachState.reachMultiplier = v
end)

local reachToggle = MiscInteract:AddToggle("ReachToggle", {
    Text = "Reach Doors", Default = false,
})
reachToggle:OnChanged(function(v)
    if not v then
        reachState.reachMultiplier = 1.5
        pcall(function() ReachSlider:SetValue(DEFAULT_REACH_MULTI) end)
        return
    end
    task.spawn(function()
        local lastTP = 0
        while reachToggle.Value do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if char and hum and hum.Health > 0 and hrp then
                local cur = tonumber(LocalPlayer:GetAttribute("CurrentRoom"))
                local rooms = Workspace:FindFirstChild("CurrentRooms")
                local roomObj = rooms and cur and rooms:FindFirstChild(tostring(cur))
                if roomObj and roomObj:FindFirstChild("Door") then
                    local door = roomObj.Door
                    local doorPart = door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart")
                    if doorPart and (hrp.Position - doorPart.Position).Magnitude <= (reachState.reachMultiplier * 12) then
                        if not checkDoorOpen(door) and not checkDoorLocked(door) and (tick() - lastTP > 0.4) then
                            lastTP = tick()
                            pcall(function()
                                if door:FindFirstChild("ClientOpen") then door.ClientOpen:FireServer() end
                                local prompt = door:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt and fireproximityprompt then fireproximityprompt(prompt) end
                            end)
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
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

local autoTpActive = false
local autoTpConn = nil
local lastTpAttempt = 0
local function getGroundYFromPos(pos)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local hit = Workspace:Raycast(pos + Vector3.new(0, 6, 0), Vector3.new(0, -30, 0), params)
    return hit and hit.Position.Y + 0.15 or pos.Y
end
local function playAlertSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://3318713980"
        s.Volume = 10
        s.Parent = game:GetService("SoundService")
        s:Play()
        task.delay(4, function() if s then s:Destroy() end end)
    end)
end
local function findDoorOpenRemote()
    local candidates = {"DoorOpen","Door_Open","OpenDoor","NextRoom","RoomChange","Crouch"}
    for _,n in ipairs(candidates) do
        local r = ReplicatedStorage:FindFirstChild(n,true)
        if r and r:IsA("RemoteEvent") then return r end
    end
    return nil
end
    
local function doTeleportToNextDoor()
    if not menuUnlocked then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end

    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if not rooms then return false end

    local myRoom = tonumber(LocalPlayer:GetAttribute("CurrentRoom")) or 0
    local targetRoom = myRoom + 1

    local roomInst = nil
    for _ = 1, 12 do
        roomInst = rooms:FindFirstChild(tostring(targetRoom))
            or rooms:FindFirstChild(tostring(targetRoom) .. "_")
            or rooms:FindFirstChild(string.format("%03d", targetRoom))
        if roomInst then break end
        task.wait(0.1)
    end
    if not roomInst then return false end

    local door, doorPart = nil, nil
    for _ = 1, 12 do
        door = roomInst:FindFirstChild("Door", true)
        if door then
            if door:GetAttribute("Locked") == true then return false end
            doorPart = door:IsA("BasePart") and door
                or door.PrimaryPart
                or door:FindFirstChild("Door")
                or door:FindFirstChildWhichIsA("BasePart", true)
            if doorPart then break end
        end
        task.wait(0.1)
    end
    if not door or not doorPart then return false end

    local look = doorPart.CFrame.LookVector
    local standPos = doorPart.Position - look * 3.5
    standPos = Vector3.new(standPos.X, doorPart.Position.Y + 1.5, standPos.Z)
    local targetCf = CFrame.new(standPos, doorPart.Position)

    local offsets = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            offsets[p] = hrp.CFrame:ToObjectSpace(p.CFrame)
        end
    end

    hum.PlatformStand = true
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    hrp.CFrame = targetCf
    for p, off in pairs(offsets) do
        if p and p.Parent and p ~= hrp then
            pcall(function() p.CFrame = targetCf:ToWorldSpace(off) end)
        end
    end

    pcall(function()
        local co = door:FindFirstChild("ClientOpen")
        if co then co:FireServer() end
    end)
    pcall(function()
        local prompt = door:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and fireproximityprompt then fireproximityprompt(prompt) end
    end)
    local cr = getCrouchRemote()
    local dr = findDoorOpenRemote()
    if cr then pcall(function() cr:FireServer(true, true) end) end
    if dr then pcall(function() dr:FireServer() end) end

    task.delay(0.12, function()
        if hum and hum.Parent then hum.PlatformStand = false end
    end)
    return true
            end

-- Nút Teleport (NGOAI function)
if MiscRight then
MiscRight:AddButton("<font color='#FF3232'>Teleport to next door</font>", function()
        local ok = doTeleportToNextDoor()
        pcall(function()
            Obsidian:Notify({
                Title = "TP tới cửa tiếp theo",
                Description = ok and "Đang Teleport",
                Time = 2,
            })
        end)
    end)
    local autoTpToggle = MiscRight:AddToggle("<font color='#FF3232'>Auto Teleport</font>", {Text="Auto Teleport",Default=false})
    autoTpToggle:OnChanged(function(v)
        autoTpActive = v
        if v then
            if autoTpConn then task.cancel(autoTpConn) end
            autoTpConn = task.spawn(function()
                while autoTpActive do
                    lastTpAttempt = tick()
                    pcall(doTeleportToNextDoor)
                    task.wait(0.18)
                end
            end)
        else
            if autoTpConn then task.cancel(autoTpConn); autoTpConn=nil end
        end
    end)
else
    print("[LỖI] MiscRight chưa tồn tại! Dán SAU local MiscRight = ... và sau skipProximityToggle!")
end
end)()

;(function()    
local escapeTimerActive = false
local escapeTimerGui = nil
local escapeTimerLabel = nil
local escapeTimerBar = nil
local escapeTimerConn = nil
local ESCAPE_MAX = 19.5
local hideStartTime = nil

local function isPlayerHiding()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, a in ipairs({"Hiding", "IsHiding", "HidingSpot"}) do
        local v = char:GetAttribute(a)
        if v == true or v == 1 then return true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local ok, tracks = pcall(function() return hum:GetPlayingAnimationTracks() end)
        if ok and tracks then
            for _, t in ipairs(tracks) do
                local n = string.lower(tostring(t.Name or ""))
                if n:find("hide") or n:find("closet") or n:find("wardrobe")
                    or n:find("locker") or n:find("bedhide") then
                    return true
                end
            end
        end
    end
    return false
    end

local function destroyEscapeTimerUI()
    if escapeTimerGui then escapeTimerGui:Destroy() end
    escapeTimerGui = nil
    escapeTimerLabel = nil
    escapeTimerBar = nil
    hideStartTime = nil
end

local function createEscapeTimerUI()
    if escapeTimerGui and escapeTimerGui.Parent then return end
    destroyEscapeTimerUI()

    local accent = (Obsidian.Scheme and Obsidian.Scheme.AccentColor)
        or Color3.fromRGB(255, 140, 175)
    local bg = (Obsidian.Scheme and Obsidian.Scheme.MainColor)
        or Color3.fromRGB(22, 20, 26)
    local outline = (Obsidian.Scheme and Obsidian.Scheme.OutlineColor)
        or Color3.fromRGB(45, 45, 55)

    local gui = Instance.new("ScreenGui")
    gui.Name = "PaintEscapeTimer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    -- Panel ngang top (style Obsidian)
    local frame = Instance.new("Frame")
    frame.Name = "Box"
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, 14)
    frame.Size = UDim2.fromOffset(220, 40)
    frame.BackgroundColor3 = bg
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Active = true -- de keo
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = accent
    stroke.Thickness = 1.5
    stroke.Parent = frame

    -- Chu thoi gian ben trai
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(10, 0)
    label.Size = UDim2.new(0, 56, 1, 0)
    label.Font = Enum.Font.Code
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = string.format("%02d", ESCAPE_MAX)
    label.Parent = frame

    -- Thanh chay ben phai
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.AnchorPoint = Vector2.new(1, 0.5)
    barBg.Position = UDim2.new(1, -10, 0.5, 0)
    barBg.Size = UDim2.new(0, 140, 0, 10)
    barBg.BackgroundColor3 = outline
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.fromScale(1, 1)
    bar.BackgroundColor3 = accent
    bar.BorderSizePixel = 0
    bar.Parent = barBg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    -- Keo tha panel
    local dragging, dragStart, startPos = false, nil, nil
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    escapeTimerGui = gui
    escapeTimerLabel = label
    escapeTimerBar = bar
    gui.Enabled = false
end

local escapeTimerToggle = MiscLeft:AddToggle("EscapeTimerToggle", {
    Text = "Escape Timer", Default = false,
    Tooltip = "Hiển thị Khi trốn có bộ đếm"
})

escapeTimerToggle:OnChanged(function(Value)
    escapeTimerActive = Value
    if Value then
        createEscapeTimerUI()
        if escapeTimerConn then escapeTimerConn:Disconnect() end
        escapeTimerConn = RunService.Heartbeat:Connect(function()
            if not escapeTimerActive then return end
            if not escapeTimerGui then createEscapeTimerUI() end

            local hiding = isPlayerHiding()
            if hiding then
                if not hideStartTime then hideStartTime = tick() end
                local left = math.max(0, ESCAPE_MAX - (tick() - hideStartTime))
                local ratio = left / ESCAPE_MAX
                escapeTimerGui.Enabled = true
                if escapeTimerLabel then
                    escapeTimerLabel.Text = string.format("%02d", math.floor(left))
                    escapeTimerLabel.TextColor3 = left <= 5 and Color3.fromRGB(255, 70, 70)
                        or left <= 10 and Color3.fromRGB(255, 200, 80)
                        or Color3.fromRGB(255, 255, 255)
                end
                if escapeTimerBar then
                    escapeTimerBar.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
                    escapeTimerBar.BackgroundColor3 = left <= 5 and Color3.fromRGB(255, 70, 70)
                        or left <= 10 and Color3.fromRGB(255, 200, 80)
                        or ((Obsidian.Scheme and Obsidian.Scheme.AccentColor) or Color3.fromRGB(255, 140, 175))
                end
            else
                hideStartTime = nil
                if escapeTimerGui then escapeTimerGui.Enabled = false end
            end
        end)
    else
        if escapeTimerConn then escapeTimerConn:Disconnect() escapeTimerConn = nil end
        destroyEscapeTimerUI()
    end
end)
end)()

;(function()
local autoAvoidActive = false
local autoAvoidConn = nil
local HIDE_NAMES = {wardrobe=true, closet=true, locker=true, bed=true, hide=true, cabinet=true}
local ENTITY_MARK = {rush=true, ambush=true, a60=true, ["a-60"]=true, a120=true, ["a-120"]=true}

local function findHidePromptNear(maxDist)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local rooms = Workspace:FindFirstChild("CurrentRooms")
    if not rooms then return nil end
    local best, bestD = nil, maxDist
    for _, room in ipairs(rooms:GetChildren()) do
        for _, d in ipairs(room:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then
                local par = d.Parent
                local n = string.lower(tostring(par and par.Name or ""))
                local okName = false
                for k in pairs(HIDE_NAMES) do
                    if n:find(k, 1, true) then okName = true break end
                end
                if okName then
                    local part = par:IsA("BasePart") and par
                        or (par and (par.PrimaryPart or par:FindFirstChildWhichIsA("BasePart")))
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist < bestD and dist <= 400 then
                            bestD, best = dist, d
                        end
                    end
                end
            end
        end
    end
    return best
end

local function tryHide()
    if isPlayerHiding() then return end
    local prompt = findHidePromptNear(400)
    if prompt and fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
end

local function tryExitHide()
    if not isPlayerHiding() then return end
    local prompt = findHidePromptNear(15)
    if prompt and fireproximityprompt then
        pcall(function() fireproximityprompt(prompt) end)
    end
end
end)()

;(function()
local weirdMode = "Ghost Green"
local weirdModeDrop = FuncRight:AddDropdown("WeirdModeDrop", {
    Text = "Weird Style",
    Values = {"Ghost Green", "Normal"},
    Default = 1,
})
weirdModeDrop:OnChanged(function(v) weirdMode = v end)
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
                        if weirdMode == "Ghost Green" then
                            p.Transparency = 0.5
                            p.Material = Enum.Material.ForceField
                            p.Color = Color3.fromRGB(50, 255, 150)
                            p.Reflectance = 0.3
                                end
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
end)()

    local setLeft = Tabs.Settings:AddLeftGroupbox("Menu")
    local setRight = Tabs.Settings:AddRightGroupbox("Config")

    setLeft:AddLabel("Toggle menu: nut Mobile / Keybind executor")
    setLeft:AddButton("Dong / Mo Menu", function()
        pcall(function()
            if type(Obsidian.Toggle) == "function" then
                Obsidian:Toggle()
            elseif Window and Window.SetVisible then
                Window:SetVisible(not (Window.Visible == true))
            end
        end)
    end)
    setLeft:AddButton("Unload Script", function()
        pcall(function()
            if Obsidian.Unload then Obsidian:Unload() end
        end)
    end)
    setLeft:AddButton("Rejoin", function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end)

    local function playNotifyTestSound()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://3318713980"
            s.Volume = 12
            s.Parent = game:GetService("SoundService")
            s:Play()
            task.delay(5, function()
                if s then s:Destroy() end
            end)
        end)
    end

    setRight:AddButton("Notify Test", function()
        playNotifyTestSound()
        pcall(function()
            Obsidian:Notify({
                Title = "PaintCrack",
                Description = "Thong bao thu nghiem thanh cong!Success notification",
                Time = 4
            })
        end)
    end)

task.spawn(function()
    local okT, ThemeManager = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
    end)
    local okS, SaveManager = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()
    end)

    if okT and type(ThemeManager) == "table" then
        pcall(function()
            ThemeManager:SetLibrary(Obsidian)
            ThemeManager:SetFolder("PaintCrackDoors")
            ThemeManager:ApplyToTab(Tabs.Settings)
        end)
    else
        warn("[PaintCrack] ThemeManager load failed")
    end

    if okS and type(SaveManager) == "table" then
        pcall(function()
            SaveManager:SetLibrary(Obsidian)
            pcall(function() SaveManager:IgnoreThemeSettings() end)
            SaveManager:SetFolder("PaintCrackDoors")
            SaveManager:BuildConfigSection(Tabs.Settings)  -- hiện Save/Load
            SaveManager:LoadAutoloadConfig()
        end)
    else
        warn("[PaintCrack] SaveManager load failed")
    end
end) 

local chaosRemoveActive = false
local chaosConn = nil

local CHAOS_NAME = {
    chaos=true, glitch=true, distort=true, static=true, noise=true,
    vignette=true, blur=true, shake=true, horror=true, effect=true,
    overexpose=true, chromatic=true, blood=true, redvignette=true,
}

local function stripChaosObject(obj)
    if not obj or not obj.Parent then return end
    local n = string.lower(obj.Name)
    for key in pairs(CHAOS_NAME) do
        if n:find(key, 1, true) then
            pcall(function()
                if obj:IsA("PostEffect") or obj:IsA("BlurEffect")
                    or obj:IsA("ColorCorrectionEffect") or obj:IsA("BloomEffect")
                    or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Beam")
                    or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = false
                elseif obj:IsA("Sound") then
                    obj.Volume = 0
                    obj:Stop()
                elseif obj:IsA("BillboardGui") or obj:IsA("ScreenGui") then
                    obj.Enabled = false
                elseif obj:IsA("BasePart") and (n:find("effect") or n:find("chaos") or n:find("glitch")) then
                    obj.Transparency = 1
                    obj.CanCollide = false
                end
            end)
            return
        end
    end
    -- PostEffect khong can dung ten
    if obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
        pcall(function()
            if obj.Parent == game:GetService("Lighting") then
                -- chi tat neu co ve "chaos" (Saturation cuc, Contrast cao)
                if obj:IsA("ColorCorrectionEffect") then
                    if math.abs(obj.Saturation or 0) > 0.5 or math.abs(obj.Contrast or 0) > 0.4 then
                        obj.Enabled = false
                    end
                end
            end
        end)
    end
end

local chaosToggle = MiscLeft:AddToggle("RemoveChaosEffectsToggle", {
    Text = "Remove Chaos Effects",
    Default = false,
    Tooltip = "An / tat hieu ung hon loan quanh nguoi & man hinh",
})

chaosToggle:OnChanged(function(on)
    chaosRemoveActive = on
    if chaosConn then chaosConn:Disconnect() chaosConn = nil end
    if not on then return end

    -- quet 1 lan
    pcall(function()
        for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
            stripChaosObject(o)
        end
        local char = LocalPlayer.Character
        if char then
            for _, o in ipairs(char:GetDescendants()) do
                stripChaosObject(o)
            end
        end
        local cam = Workspace.CurrentCamera
        if cam then
            for _, o in ipairs(cam:GetDescendants()) do
                stripChaosObject(o)
            end
        end
        for _, o in ipairs(PlayerGui:GetChildren()) do
            stripChaosObject(o)
        end
    end)

    chaosConn = Workspace.DescendantAdded:Connect(function(obj)
        if not chaosRemoveActive then return end
        task.defer(function() stripChaosObject(obj) end)
    end)
    -- Lighting / PlayerGui
    pcall(function()
        game:GetService("Lighting").ChildAdded:Connect(function(obj)
            if chaosRemoveActive then task.defer(function() stripChaosObject(obj) end) end
        end)
    end)
end)

Obsidian:OnUnload(function()
    pcall(function()
        local f = Workspace:FindFirstChild("PaintRoomPath")
        if f then f:Destroy() end
    end)
    pcall(safeUnlockCharacter)
    pcall(function() togglePositionSpoof(false) end)
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
    pcall(destroyEscapeTimerUI)
    if chaosConn then chaosConn:Disconnect() end
    if weirdConn then weirdConn:Disconnect() end
    if weirdAnimConn then weirdAnimConn:Disconnect() end
    if fullBrightConn then fullBrightConn:Disconnect() end
    if seeThroughConn then seeThroughConn:Disconnect() end
    if remoteThreadSpeed then task.cancel(remoteThreadSpeed) end
    if remoteThreadVel then task.cancel(remoteThreadVel) end
    table.clear(velocitySavedCanCollide)
    table.clear(noClipSavedCanCollide)
    table.clear(weirdSaved)
    table.clear(autoInteractCooldown)
    table.clear(originalPartProps)
    table.clear(originalPostEffects)
end)
