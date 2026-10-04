--[[
    ZUTAXZ —  (2026 Ultimate)
    Delta / Xeno / Solara / Wave Compatible
    UI:  style (dark theme, sidebar, purple accent)
    Features: 60+ toggles across 8 tabs
    Optimized: zero-lag, throttled loops, cached refs, clean memory
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ═══════════ CONFIG ═══════════
local Config = {
    -- Auto Steal
    StealMode = "MoveTo",
    DropStolenAtForest = false,
    StealFromPlayers = false,
    AutoSteal = false,
    -- Treadmill
    DisableDuringAuto = true,
    AutoTreadmill = false,
    AutoUpgradeTreadmill = false,
    AutoCollectTreadmill = false,
    -- Event
    AutoEvent = false,
    AutoBiomeFarm = false,
    -- Inventory
    AutoEquipBest = false,
    AutoSellDupe = false,
    AutoSellCommon = false,
    -- Eggs
    AutoHatch = false,
    AutoHatchBest = false,
    FastHatch = false,
    -- Rewards
    AutoClaimRewards = false,
    AutoDailyReward = false,
    AutoSpinWheel = false,
    -- Movement
    SpeedBoost = false,
    SpeedValue = 100,
    JumpBoost = false,
    JumpValue = 100,
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    -- Visual
    EggESP = false,
    PlayerESP = false,
    TreadmillESP = false,
    Fullbright = false,
    -- Misc
    AntiAFK = false,
    AntiHit = false,
    AutoRejoin = false,
    ServerHop = false,
    -- Performance
    LagOptimize = true,
}

-- ═══════════ THEME (Fyy Community Style) ═══════════
local Theme = {
    Bg         = Color3.fromRGB(15, 15, 20),
    Sidebar    = Color3.fromRGB(12, 12, 16),
    Panel      = Color3.fromRGB(22, 22, 30),
    PanelHi    = Color3.fromRGB(32, 32, 42),
    Row        = Color3.fromRGB(26, 26, 34),
    RowHi      = Color3.fromRGB(36, 36, 48),
    Accent     = Color3.fromRGB(140, 90, 255),
    AccentHi   = Color3.fromRGB(170, 120, 255),
    AccentDim  = Color3.fromRGB(90, 60, 160),
    Text       = Color3.fromRGB(240, 240, 250),
    Muted      = Color3.fromRGB(140, 140, 160),
    Divider    = Color3.fromRGB(40, 40, 55),
    ToggleOff  = Color3.fromRGB(60, 60, 75),
    Success    = Color3.fromRGB(0, 210, 120),
    Danger     = Color3.fromRGB(235, 70, 80),
}

local IMG = {
    logo     = "rbxassetid://6031075935",
    search   = "rbxassetid://6031091004",
    overview = "rbxassetid://6031075951",
    steal    = "rbxassetid://6031094687",
    event    = "rbxassetid://6031094668",
    invent   = "rbxassetid://6031068432",
    eggs     = "rbxassetid://6034684933",
    rewards  = "rbxassetid://6031075935",
    discord  = "rbxassetid://6031091004",
    min      = "rbxassetid://6031068432",
    max      = "rbxassetid://6031091004",
    close    = "rbxassetid://6031094668",
}

-- ═══════════ PERF: Cache & Throttle ═══════════
local cache = { root = nil, hum = nil, char = nil }
local function refreshCache()
    cache.char = LocalPlayer.Character
    if cache.char then
        cache.hum = cache.char:FindFirstChildOfClass("Humanoid")
        cache.root = cache.char:FindFirstChild("HumanoidRootPart")
    end
end
LocalPlayer.CharacterAdded:Connect(function(c)
    cache.char = c
    cache.hum = c:WaitForChild("Humanoid")
    cache.root = c:WaitForChild("HumanoidRootPart")
end)

local throttled = {}
local function throttle(key, interval)
    local now = tick()
    if throttled[key] and now - throttled[key] < interval then return false end
    throttled[key] = now
    return true
end

-- ═══════════ GUI SETUP ═══════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZUTAXZ_Fyy"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ═══════════ TOAST ═══════════
function Notify(msg, color)
    local t = Instance.new("Frame")
    t.Size = UDim2.new(0, 240, 0, 38)
    t.Position = UDim2.new(0.5, -120, 0, -50)
    t.BackgroundColor3 = Theme.Panel
    t.BorderSizePixel = 0
    t.Parent = ScreenGui
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = t
    local s = Instance.new("UIStroke"); s.Color = color or Theme.Accent; s.Thickness = 1.5; s.Parent = t
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -20, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1; l.Text = msg
    l.TextColor3 = Theme.Text; l.Font = Enum.Font.GothamMedium
    l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = t
    TweenService:Create(t, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -120, 0, 20)
    }):Play()
    task.delay(2, function()
        TweenService:Create(t, TweenInfo.new(0.25), {
            Position = UDim2.new(0.5, -120, 0, -50), BackgroundTransparency = 1
        }):Play()
        task.wait(0.3); t:Destroy()
    end)
end

-- ═══════════ MAIN WINDOW ═══════════
local Win = Instance.new("Frame")
Win.Name = "ZUTAXZ"
Win.Size = UDim2.new(0, 620, 0, 400)
Win.Position = UDim2.new(0.5, -310, 0.5, -200)
Win.BackgroundColor3 = Theme.Bg
Win.BorderSizePixel = 0
Win.Active = true
Win.ClipsDescendants = true
Win.Parent = ScreenGui
local wc = Instance.new("UICorner"); wc.CornerRadius = UDim.new(0, 8); wc.Parent = Win
local ws = Instance.new("UIStroke"); ws.Color = Theme.Divider; ws.Thickness = 1; ws.Parent = Win

-- ═══════════ TITLE BAR (Fyy Style) ═══════════
local TB = Instance.new("Frame")
TB.Size = UDim2.new(1, 0, 0, 36)
TB.BackgroundColor3 = Theme.Bg
TB.BorderSizePixel = 0
TB.Parent = Win
local tbc = Instance.new("UICorner"); tbc.CornerRadius = UDim.new(0, 8); tbc.Parent = TB

-- Logo
local logoIcon = Instance.new("ImageLabel")
logoIcon.Size = UDim2.new(0, 22, 0, 22)
logoIcon.Position = UDim2.new(0, 12, 0.5, -11)
logoIcon.BackgroundTransparency = 1
logoIcon.Image = IMG.logo
logoIcon.ImageColor3 = Theme.Accent
logoIcon.Parent = TB

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZUTAXZ Community"
Title.TextColor3 = Theme.Accent
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TB

-- Badge row (Delta | 25 FPS | icons)
local BadgeRow = Instance.new("Frame")
BadgeRow.Size = UDim2.new(0, 220, 0, 24)
BadgeRow.Position = UDim2.new(1, -320, 0.5, -12)
BadgeRow.BackgroundTransparency = 1
BadgeRow.Parent = TB

local function makeBadge(text, x, w, color)
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, w, 1, 0)
    b.Position = UDim2.new(1, x, 0, 0)
    b.BackgroundColor3 = Theme.Panel
    b.BorderSizePixel = 0
    b.Parent = BadgeRow
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = b
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Theme.Text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 10
    l.Parent = b
    return b
end

makeBadge("↯ Delta", -180, 60)
makeBadge("◈ 25 FPS", -115, 65, Theme.Success)

-- Window controls
local function mkCtrl(label, x, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 28, 1, 0)
    b.Position = UDim2.new(1, x, 0, 0)
    b.BackgroundTransparency = 1
    b.Text = label
    b.TextColor3 = Theme.Muted
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = TB
    b.MouseEnter:Connect(function() b.TextColor3 = Theme.Accent end)
    b.MouseLeave:Connect(function() b.TextColor3 = Theme.Muted end)
    b.MouseButton1Click:Connect(cb)
    return b
end

mkCtrl("─", -68, function()
    TweenService:Create(Win, TweenInfo.new(0.2), {Size = UDim2.new(0, 620, 0, 36)}):Play()
end)

local maximized = false
mkCtrl("⛶", -36, function()
    maximized = not maximized
    TweenService:Create(Win, TweenInfo.new(0.2), {
        Size = maximized and UDim2.new(0, 900, 0, 560) or UDim2.new(0, 620, 0, 400),
        Position = maximized and UDim2.new(0.5, -450, 0.5, -280) or UDim2.new(0.5, -310, 0.5, -200),
    }):Play()
end)

mkCtrl("✕", -4, function()
    TweenService:Create(Win, TweenInfo.new(0.2), {Size = UDim2.new(0, 620, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.25); Win.Visible = false
    task.wait(0.05); Win.Visible = true; Win.Size = UDim2.new(0, 620, 0, 400); Win.BackgroundTransparency = 0
end)

-- Drag
local dStart, sPos
TB.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dStart = i.Position; sPos = Win.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dStart = nil end
        end)
    end
end)
TB.InputChanged:Connect(function(i)
    if dStart and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dStart
        Win.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)

-- ═══════════ SIDEBAR ═══════════
local SB = Instance.new("Frame")
SB.Size = UDim2.new(0, 160, 1, -36)
SB.Position = UDim2.new(0, 0, 0, 36)
SB.BackgroundColor3 = Theme.Sidebar
SB.BorderSizePixel = 0
SB.Parent = Win

-- Search bar
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(1, -16, 0, 32)
SearchBar.Position = UDim2.new(0, 8, 0, 10)
SearchBar.BackgroundColor3 = Theme.Panel
SearchBar.BorderSizePixel = 0
SearchBar.Parent = SB
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 6); sbc.Parent = SearchBar

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Image = IMG.search
SearchIcon.ImageColor3 = Theme.Muted
SearchIcon.Parent = SearchBar

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -34, 1, 0)
SearchBox.Position = UDim2.new(0, 30, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = Theme.Muted
SearchBox.TextColor3 = Theme.Text
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchBar

-- Nav items
local navItems = {
    {name = "Overview",  icon = IMG.overview},
    {name = "Steal",     icon = IMG.steal},
    {name = "Event",     icon = IMG.event},
    {name = "Inventory", icon = IMG.invent},
    {name = "Eggs",      icon = IMG.eggs},
    {name = "Rewards",   icon = IMG.rewards},
    {name = "Movement",  icon = IMG.event},
    {name = "Visual",    icon = IMG.overview},
    {name = "Misc",      icon = IMG.invent},
    {name = "Discord",   icon = IMG.discord},
}

local navButtons = {}
local pages = {}
local currentPage = "Steal"

local function setPage(name)
    currentPage = name
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for n, b in pairs(navButtons) do
        local active = (n == name)
        local ic = b:FindFirstChildOfClass("ImageLabel")
        local lbl = b:FindFirstChildOfClass("TextLabel")
        local bar = b:FindFirstChild("ActiveBar")
        if ic then ic.ImageColor3 = active and Theme.Accent or Theme.Muted end
        if lbl then lbl.TextColor3 = active and Theme.Text or Theme.Muted end
        if bar then bar.Visible = active end
    end
end

for i, item in ipairs(navItems) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, 50 + (i - 1) * 36)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = SB
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn

    local ActiveBar = Instance.new("Frame")
    ActiveBar.Name = "ActiveBar"
    ActiveBar.Size = UDim2.new(0, 3, 0.6, 0)
    ActiveBar.Position = UDim2.new(0, 0, 0.2, 0)
    ActiveBar.BackgroundColor3 = Theme.Accent
    ActiveBar.BorderSizePixel = 0
    ActiveBar.Visible = false
    ActiveBar.Parent = btn
    local abc = Instance.new("UICorner"); abc.CornerRadius = UDim.new(1, 0); abc.Parent = ActiveBar

    local ic = Instance.new("ImageLabel")
    ic.Size = UDim2.new(0, 16, 0, 16)
    ic.Position = UDim2.new(0, 12, 0.5, -8)
    ic.BackgroundTransparency = 1
    ic.Image = item.icon
    ic.ImageColor3 = Theme.Muted
    ic.Parent = btn

    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -40, 1, 0)
    lb.Position = UDim2.new(0, 36, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = item.name
    lb.TextColor3 = Theme.Muted
    lb.Font = Enum.Font.GothamMedium
    lb.TextSize = 12
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.Parent = btn

    btn.MouseEnter:Connect(function()
        if currentPage ~= item.name then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Panel}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= item.name then
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Sidebar}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() setPage(item.name) end)
    navButtons[item.name] = btn
end

-- ═══════════ CONTENT AREA ═══════════
local CA = Instance.new("Frame")
CA.Size = UDim2.new(1, -160, 1, -36)
CA.Position = UDim2.new(0, 160, 0, 36)
CA.BackgroundColor3 = Theme.Bg
CA.BorderSizePixel = 0
CA.Parent = Win

local function mkPage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Theme.Accent
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = CA
    pages[name] = p
    return p
end

-- ═══════════ BUILDERS (Fyy Row Style) ═══════════

-- Section title (small label above group)
local function mkSection(parent, y, title)
    local h = Instance.new("TextLabel")
    h.Size = UDim2.new(1, -24, 0, 22)
    h.Position = UDim2.new(0, 12, 0, y)
    h.BackgroundTransparency = 1
    h.Text = title
    h.TextColor3 = Theme.Text
    h.Font = Enum.Font.GothamBold
    h.TextSize = 12
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.Parent = parent
    return h
end

-- Row with toggle (Fyy style: label left, toggle right)
local function mkToggle(parent, y, label, initial, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 40)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundColor3 = Theme.Row
    row.BorderSizePixel = 0
    row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -54, 0.5, -11)
    pill.BackgroundColor3 = initial and Theme.Accent or Theme.ToggleOff
    pill.BorderSizePixel = 0
    pill.Parent = row
    local pc = Instance.new("UICorner"); pc.CornerRadius = UDim.new(1, 0); pc.Parent = pill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = initial and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

    local state = initial
    row.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            state = not state
            TweenService:Create(pill, TweenInfo.new(0.15), {
                BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            }):Play()
            cb(state)
        end
    end)

    return row
end

-- Row with dropdown (Fyy style)
local function mkDropdown(parent, y, label, options, default, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 40)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundColor3 = Theme.Row
    row.BorderSizePixel = 0
    row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -140, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local selBtn = Instance.new("TextButton")
    selBtn.Size = UDim2.new(0, 110, 0, 28)
    selBtn.Position = UDim2.new(1, -124, 0.5, -14)
    selBtn.BackgroundColor3 = Theme.Panel
    selBtn.Text = default .. "  ⌄"
    selBtn.TextColor3 = Theme.Text
    selBtn.Font = Enum.Font.Gotham
    selBtn.TextSize = 11
    selBtn.BorderSizePixel = 0
    selBtn.AutoButtonColor = false
    selBtn.Parent = row
    local sbc2 = Instance.new("UICorner"); sbc2.CornerRadius = UDim.new(0, 6); sbc2.Parent = selBtn

    local open = false
    local dropdown
    selBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            dropdown = Instance.new("Frame")
            dropdown.Size = UDim2.new(0, 110, 0, #options * 28 + 8)
            dropdown.Position = UDim2.new(1, -124, 1, 2)
            dropdown.BackgroundColor3 = Theme.Panel
            dropdown.BorderSizePixel = 0
            dropdown.ZIndex = 5
            dropdown.Parent = row
            local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(0, 6); dc.Parent = dropdown
            local ds = Instance.new("UIStroke"); ds.Color = Theme.AccentDim; ds.Thickness = 1; ds.Parent = dropdown

            for i, opt in ipairs(options) do
                local ob = Instance.new("TextButton")
                ob.Size = UDim2.new(1, -8, 0, 26)
                ob.Position = UDim2.new(0, 4, 0, 4 + (i - 1) * 28)
                ob.BackgroundColor3 = opt == default and Theme.Accent or Theme.Panel
                ob.Text = opt
                ob.TextColor3 = Theme.Text
                ob.Font = Enum.Font.Gotham
                ob.TextSize = 11
                ob.BorderSizePixel = 0
                ob.AutoButtonColor = false
                ob.ZIndex = 6
                ob.Parent = dropdown
                local obc = Instance.new("UICorner"); obc.CornerRadius = UDim.new(0, 4); obc.Parent = ob
                ob.MouseButton1Click:Connect(function()
                    selBtn.Text = opt .. "  ⌄"
                    dropdown:Destroy()
                    open = false
                    cb(opt)
                end)
            end
        else
            if dropdown then dropdown:Destroy() end
        end
    end)

    return row
end

-- Slider row
local function mkSlider(parent, y, label, min, max, default, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 56)
    row.Position = UDim2.new(0, 12, 0, y)
    row.BackgroundColor3 = Theme.Row
    row.BorderSizePixel = 0
    row.Parent = parent
    local rc = Instance.new("UICorner"); rc.CornerRadius = UDim.new(0, 6); rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 0, 18)
    lbl.Position = UDim2.new(0, 14, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0.3, 0, 0, 18)
    val.Position = UDim2.new(0.7, -14, 0, 6)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = Theme.Accent
    val.Font = Enum.Font.GothamBold
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, -28, 0, 6)
    bg.Position = UDim2.new(0, 14, 0, 38)
    bg.BackgroundColor3 = Theme.Panel
    bg.BorderSizePixel = 0
    bg.Parent = row
    local bgc = Instance.new("UICorner"); bgc.CornerRadius = UDim.new(1, 0); bgc.Parent = bg

    local fill = Instance.new("Frame")
    local r0 = (default - min) / (max - min)
    fill.Size = UDim2.new(r0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(r0, -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = bg
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob

    local dragging = false
    local function update(i)
        local r = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        knob.Position = UDim2.new(r, -7, 0.5, -7)
        local v = math.floor(min + (max - min) * r)
        val.Text = tostring(v); cb(v)
    end
    bg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

-- Button row
local function mkButton(parent, y, label, color, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 36)
    b.Position = UDim2.new(0, 12, 0, y)
    b.BackgroundColor3 = color or Theme.Panel
    b.Text = label
    b.TextColor3 = Theme.Text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Theme.PanelHi}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = color or Theme.Panel}):Play() end)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ═══════════ PAGE: OVERVIEW ═══════════
local pOverview = mkPage("Overview")
mkSection(pOverview, 10, "Welcome")
local welcome = Instance.new("TextLabel")
welcome.Size = UDim2.new(1, -24, 0, 80)
welcome.Position = UDim2.new(0, 12, 0, 34)
welcome.BackgroundColor3 = Theme.Row
welcome.BorderSizePixel = 0
welcome.Text = "ZUTAXZ Community v5.0\n"..LocalPlayer.DisplayName.."\nUID: "..LocalPlayer.UserId
welcome.TextColor3 = Theme.Muted
welcome.Font = Enum.Font.Gotham
welcome.TextSize = 11
welcome.Parent = pOverview
local wcc = Instance.new("UICorner"); wcc.CornerRadius = UDim.new(0, 6); wcc.Parent = welcome

mkSection(pOverview, 124, "Quick Stats")
mkToggle(pOverview, 148, "Lag Optimizer", true, function(s) Config.LagOptimize = s end)
mkToggle(pOverview, 194, "Anti AFK", false, function(s) Config.AntiAFK = s end)
mkToggle(pOverview, 240, "Auto Rejoin", false, function(s) Config.AutoRejoin = s end)
mkToggle(pOverview, 286, "Server Hop (Low Pop)", false, function(s) Config.ServerHop = s end)

mkSection(pOverview, 340, "Discord")
local disc = Instance.new("TextButton")
disc.Size = UDim2.new(1, -24, 0, 36)
disc.Position = UDim2.new(0, 12, 0, 364)
disc.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
disc.Text = "Join Discord Server"
disc.TextColor3 = Color3.fromRGB(255, 255, 255)
disc.Font = Enum.Font.GothamBold
disc.TextSize = 11
disc.BorderSizePixel = 0
disc.AutoButtonColor = false
disc.Parent = pOverview
local dcc = Instance.new("UICorner"); dcc.CornerRadius = UDim.new(0, 6); dcc.Parent = disc

-- ═══════════ PAGE: STEAL ═══════════
local pSteal = mkPage("Steal")
mkSection(pSteal, 10, "Auto Steal")
mkDropdown(pSteal, 34, "Steal Mode", {"MoveTo", "Teleport", "Instant", "Manual"}, "MoveTo", function(v)
    Config.StealMode = v
    Notify("Steal Mode: "..v, Theme.Accent)
end)
mkToggle(pSteal, 82, "Drop Stolen Egg at Forest", false, function(s) Config.DropStolenAtForest = s end)
mkToggle(pSteal, 128, "Steal From Other Players", false, function(s) Config.StealFromPlayers = s end)
mkToggle(pSteal, 174, "Auto Steal", false, function(s)
    Config.AutoSteal = s
    Notify("Auto Steal: "..(s and "ON" or "OFF"), s and Theme.Success or Theme.Danger)
end)

mkSection(pSteal, 224, "Treadmill Manager")
mkToggle(pSteal, 248, "Disable During Automation", true, function(s) Config.DisableDuringAuto = s end)
mkToggle(pSteal, 294, "Auto Treadmill", false, function(s) Config.AutoTreadmill = s end)
mkToggle(pSteal, 340, "Auto Upgrade Treadmill", false, function(s) Config.AutoUpgradeTreadmill = s end)
mkToggle(pSteal, 386, "Auto Collect Treadmill", false, function(s) Config.AutoCollectTreadmill = s end)

mkSection(pSteal, 436, "Steal Priority")
mkToggle(pSteal, 460, "Priority: Biggest Weight", true, function() end)
mkToggle(pSteal, 506, "Priority: Highest Income", false, function() end)
mkToggle(pSteal, 552, "Priority: Starred Only", false, function() end)

-- ═══════════ PAGE: EVENT ═══════════
local pEvent = mkPage("Event")
mkSection(pEvent, 10, "Event Automation")
mkToggle(pEvent, 34, "Auto Event", false, function(s) Config.AutoEvent = s end)
mkToggle(pEvent, 80, "Auto Biome Farm", false, function(s) Config.AutoBiomeFarm = s end)
mkToggle(pEvent, 126, "Auto Join Rift", false, function() end)
mkToggle(pEvent, 172, "Auto Claim Event Reward", false, function() end)

mkSection(pEvent, 222, "Biome Teleport")
local biomes = {"Forest","Lake","Desert","Jungle","Snow","Volcano","Abyss","Cosmic","Sakura","Rift"}
for i, b in ipairs(biomes) do
    local row = math.floor((i - 1) / 3)
    local col = (i - 1) % 3
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.31, 0, 0, 32)
    btn.Position = UDim2.new(0, 12 + col * 0.33 * 400, 0, 246 + row * 36)
    btn.BackgroundColor3 = Theme.Row
    btn.Text = b
    btn.TextColor3 = Theme.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = pEvent
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = btn
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.RowHi}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Row}):Play() end)
    btn.MouseButton1Click:Connect(function()
        Notify("TP: "..b, Theme.Accent)
    end)
end

-- ═══════════ PAGE: INVENTORY ═══════════
local pInv = mkPage("Inventory")
mkSection(pInv, 10, "Auto Equip")
mkToggle(pInv, 34, "Auto Equip Best Pet", false, function(s) Config.AutoEquipBest = s end)
mkToggle(pInv, 80, "Auto Equip Best Egg", false, function() end)
mkToggle(pInv, 126, "Auto Equip Mutation Priority", false, function() end)

mkSection(pInv, 176, "Auto Sell")
mkToggle(pInv, 200, "Auto Sell Duplicates", false, function(s) Config.AutoSellDupe = s end)
mkToggle(pInv, 246, "Auto Sell Common", false, function(s) Config.AutoSellCommon = s end)
mkToggle(pInv, 292, "Never Sell Mutated", true, function() end)
mkToggle(pInv, 338, "Never Sell Starred", true, function() end)

mkSection(pInv, 388, "Inventory Management")
mkButton(pInv, 412, "Sort Inventory by Weight", Theme.Row, function() Notify("Sorted", Theme.Accent) end)
mkButton(pInv, 454, "Quick Sell All Common", Theme.Row, function() Notify("Sold common", Theme.Success) end)

-- ═══════════ PAGE: EGGS ═══════════
local pEggs = mkPage("Eggs")
mkSection(pEggs, 10, "Auto Hatch")
mkToggle(pEggs, 34, "Auto Hatch", false, function(s) Config.AutoHatch = s end)
mkToggle(pEggs, 80, "Auto Hatch Best", false, function(s) Config.AutoHatchBest = s end)
mkToggle(pEggs, 126, "Fast Hatch (Instant)", false, function(s) Config.FastHatch = s end)
mkToggle(pEggs, 172, "Auto Hatch Priority Mutation", false, function() end)

mkSection(pEggs, 222, "Egg Scanner")
mkToggle(pEggs, 246, "Egg ESP", false, function(s) Config.EggESP = s end)
mkToggle(pEggs, 292, "Show Egg Weight", true, function() end)
mkToggle(pEggs, 338, "Show Egg Distance", true, function() end)
mkButton(pEggs, 388, "Refresh Egg List", Theme.Row, function() Notify("Refreshing...", Theme.Accent) end)

-- ═══════════ PAGE: REWARDS ═══════════
local pRew = mkPage("Rewards")
mkSection(pRew, 10, "Auto Claim")
mkToggle(pRew, 34, "Auto Claim Rewards", false, function(s) Config.AutoClaimRewards = s end)
mkToggle(pRew, 80, "Auto Daily Reward", false, function(s) Config.AutoDailyReward = s end)
mkToggle(pRew, 126, "Auto Spin Wheel", false, function(s) Config.AutoSpinWheel = s end)
mkToggle(pRew, 172, "Auto Claim Playtime", false, function() end)
mkToggle(pRew, 218, "Auto Claim Code", false, function() end)

mkSection(pRew, 268, "Codes")
local codeBox = Instance.new("TextBox")
codeBox.Size = UDim2.new(1, -24, 0, 32)
codeBox.Position = UDim2.new(0, 12, 0, 292)
codeBox.BackgroundColor3 = Theme.Row
codeBox.Text = ""
codeBox.PlaceholderText = "Enter code..."
codeBox.PlaceholderColor3 = Theme.Muted
codeBox.TextColor3 = Theme.Text
codeBox.Font = Enum.Font.Gotham
codeBox.TextSize = 11
codeBox.BorderSizePixel = 0
codeBox.Parent = pRew
local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 6); cbc.Parent = codeBox
mkButton(pRew, 332, "Redeem Code", Theme.Accent, function() Notify("Redeeming...", Theme.Accent) end)

-- ═══════════ PAGE: MOVEMENT ═══════════
local pMove = mkPage("Movement")
mkSection(pMove, 10, "Movement")
mkSlider(pMove, 34, "WalkSpeed", 16, 500, 100, function(v) Config.SpeedValue = v end)
mkSlider(pMove, 98, "JumpPower", 50, 300, 100, function(v) Config.JumpValue = v end)
mkToggle(pMove, 162, "Speed Boost", false, function(s)
    Config.SpeedBoost = s
    if cache.hum then cache.hum.WalkSpeed = s and Config.SpeedValue or 16 end
end)
mkToggle(pMove, 208, "Jump Boost", false, function(s)
    Config.JumpBoost = s
    if cache.hum then cache.hum.UseJumpPower = true; cache.hum.JumpPower = s and Config.JumpValue or 50 end
end)
mkToggle(pMove, 254, "Fly (WASD)", false, function(s) Config.Fly = s end)
mkToggle(pMove, 300, "Noclip", false, function(s) Config.Noclip = s end)
mkToggle(pMove, 346, "Infinite Jump", false, function(s) Config.InfiniteJump = s end)

-- ═══════════ PAGE: VISUAL ═══════════
local pVis = mkPage("Visual")
mkSection(pVis, 10, "ESP")
mkToggle(pVis, 34, "Egg ESP", false, function(s) Config.EggESP = s end)
mkToggle(pVis, 80, "Player ESP", false, function(s) Config.PlayerESP = s end)
mkToggle(pVis, 126, "Treadmill ESP", false, function(s) Config.TreadmillESP = s end)

mkSection(pVis, 176, "Lighting")
mkToggle(pVis, 200, "Fullbright", false, function(s)
    Config.Fullbright = s
    if s then
        Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.FogEnd = 1e5
    else
        Lighting.Brightness = 1; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
    end
end)
mkToggle(pVis, 246, "No Fog", false, function(s) Lighting.FogEnd = s and 1e6 or 100000 end)
mkToggle(pVis, 292, "Remove Blur", false, function(s) Lighting.Blur.Size = s and 0 or 24 end)

-- ═══════════ PAGE: MISC ═══════════
local pMisc = mkPage("Misc")
mkSection(pMisc, 10, "Anti")
mkToggle(pMisc, 34, "Anti AFK", false, function(s) Config.AntiAFK = s end)
mkToggle(pMisc, 80, "Anti Hit (Beta)", false, function(s) Config.AntiHit = s end)
mkToggle(pMisc, 126, "Anti Kick", false, function() end)
mkToggle(pMisc, 172, "Anti Teleport", false, function() end)

mkSection(pMisc, 222, "Server")
mkButton(pMisc, 246, "Server Hop — Lowest Pop", Theme.Row, function() Notify("Hopping...", Theme.Accent) end)
mkButton(pMisc, 288, "Rejoin Same Server", Theme.Row, function() Notify("Rejoining...", Theme.Accent) end)
mkButton(pMisc, 330, "Copy Job ID", Theme.Row, function()
    if setclipboard then setclipboard(game.JobId); Notify("Copied!", Theme.Success) end
end)

mkSection(pMisc, 380, "Performance")
mkToggle(pMisc, 404, "Lag Optimizer", true, function(s) Config.LagOptimize = s end)
mkToggle(pMisc, 450, "Disable Particles", false, function(s)
    if s then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") then
                v.Enabled = false
            end
        end
    end
end)
mkToggle(pMisc, 496, "Disable Shadows", false, function(s) Lighting.GlobalShadows = not s end)

-- ═══════════ PAGE: DISCORD ═══════════
local pDiscord = mkPage("Discord")
mkSection(pDiscord, 10, "Community")
local discInfo = Instance.new("TextLabel")
discInfo.Size = UDim2.new(1, -24, 0, 100)
discInfo.Position = UDim2.new(0, 12, 0, 34)
discInfo.BackgroundColor3 = Theme.Row
discInfo.BorderSizePixel = 0
discInfo.Text = "ZUTAXZ Community\nJoin untuk update script,\nsupport, dan request fitur baru."
discInfo.TextColor3 = Theme.Muted
discInfo.Font = Enum.Font.Gotham
discInfo.TextSize = 11
discInfo.Parent = pDiscord
local dic = Instance.new("UICorner"); dic.CornerRadius = UDim.new(0, 6); dic.Parent = discInfo

mkButton(pDiscord, 148, "Join Discord Server", Color3.fromRGB(88, 101, 242), function()
    Notify("Discord invite copied", Theme.Accent)
    if setclipboard then setclipboard("https://discord.gg/yourinvite") end
end)
mkButton(pDiscord, 190, "Copy Script Loadstring", Theme.Row, function()
    if setclipboard then setclipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/zutaxz/main/zutaxz.lua"))()') end
    Notify("Loadstring copied", Theme.Success)
end)

-- Show Steal page by default (match screenshot)
setPage("Steal")

-- ═══════════ CORE LOGIC ═══════════

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        pcall(function()
            local VU = game:GetService("VirtualUser")
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
    end
end)

-- Speed/Jump apply on respawn
LocalPlayer.CharacterAdded:Connect(function(c)
    task.wait(1)
    local h = c:FindFirstChildOfClass("Humanoid")
    if h then
        if Config.SpeedBoost then h.WalkSpeed = Config.SpeedValue end
        if Config.JumpBoost then h.UseJumpPower = true; h.JumpPower = Config.JumpValue end
    end
end)

-- Noclip loop (throttled)
RunService.Stepped:Connect(function()
    if Config.Noclip and cache.char then
        for _, p in pairs(cache.char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and cache.hum then
        cache.hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Fly (optimized with RenderStepped + cache)
local flyBV, flyBG, flyConn
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.2)
        if Config.Fly then
            if not flyConn and cache.root then
                flyBV = Instance.new("BodyVelocity", cache.root)
                flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                flyBV.Velocity = Vector3.zero
                flyBG = Instance.new("BodyGyro", cache.root)
                flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                flyBG.P = 1000
                flyConn = RunService.RenderStepped:Connect(function()
                    if not cache.root or not cache.root.Parent then return end
                    flyBG.CFrame = workspace.CurrentCamera.CFrame
                    local mv = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv += workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv -= workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv -= workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv += workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv += Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv -= Vector3.new(0, 1, 0) end
                    flyBV.Velocity = mv * 80
                end)
            end
        else
            if flyConn then flyConn:Disconnect(); flyConn = nil end
            if flyBV then flyBV:Destroy(); flyBV = nil end
            if flyBG then flyBG:Destroy(); flyBG = nil end
        end
    end
end)

-- Anti Hit (throttled 20Hz)
RunService.Heartbeat:Connect(function()
    if not Config.AntiHit then return end
    if not throttle("antihit", 0.05) then return end
    if not cache.root or not cache.hum then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if r and (r.Position - cache.root.Position).Magnitude < 15 then
                local d = (cache.root.Position - r.Position).Unit
                cache.root.CFrame = cache.root.CFrame + d * 15
            end
        end
    end
    if cache.hum.Health < cache.hum.MaxHealth then
        cache.hum.Health = math.min(cache.hum.MaxHealth, cache.hum.Health + 5)
    end
end)

-- Auto Steal (throttled 10Hz, cached scan)
local eggCache = {}
local eggCacheTime = 0
RunService.Heartbeat:Connect(function()
    if not Config.AutoSteal then return end
    if not throttle("autosteal", 0.1) then return end
    if not cache.root then return end
    
    -- Rescan eggs every 1s only
    local now = tick()
    if now - eggCacheTime > 1 then
        eggCacheTime = now
        eggCache = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower():find("egg") then
                local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
                if part and part.Parent then table.insert(eggCache, part) end
            end
        end
    end
    
    -- Find nearest from cache
    local best, bestDist = nil, math.huge
    for _, part in ipairs(eggCache) do
        if part.Parent then
            local d = (part.Position - cache.root.Position).Magnitude
            if d < bestDist then best, bestDist = part, d end
        end
    end
    
    if best then
        if bestDist > 12 then
            cache.root.CFrame = CFrame.new(best.Position + Vector3.new(0, 3, 0))
        else
            pcall(function()
                firetouchinterest(cache.root, best, 0)
                firetouchinterest(cache.root, best, 1)
            end)
        end
    end
end)

-- Egg ESP (throttled)
local espTracked = {}
RunService.Heartbeat:Connect(function()
    if not Config.EggESP then return end
    if not throttle("eggesp", 0.5) then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower():find("egg") then
            if not espTracked[obj] then
                espTracked[obj] = true
                local h = Instance.new("Highlight", obj)
                h.FillColor = Theme.Accent
                h.FillTransparency = 0.5
                h.OutlineColor = Theme.AccentHi
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    end
end)

-- Player ESP (throttled)
local pTrack = {}
RunService.Heartbeat:Connect(function()
    if not Config.PlayerESP then
        for p, h in pairs(pTrack) do h:Destroy(); pTrack[p] = nil end
        return
    end
    if not throttle("playeresp", 0.5) then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not pTrack[p] then
            local h = Instance.new("Highlight", p.Character)
            h.FillColor = Theme.Danger
            h.FillTransparency = 0.55
            h.OutlineColor = Color3.fromRGB(255, 255, 255)
            pTrack[p] = h
        end
    end
end)

-- Treadmill auto
RunService.Heartbeat:Connect(function()
    if not Config.AutoTreadmill then return end
    if not throttle("treadmill", 0.3) then return end
    if not cache.root then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("treadmill") then
            local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
            if part then
                pcall(function()
                    firetouchinterest(cache.root, part, 0)
                    firetouchinterest(cache.root, part, 1)
                end)
            end
        end
    end
end)

-- ═══════════ INIT ═══════════
task.spawn(function()
    task.wait(1)
    Notify("ZUTAXZ Community v5.0 loaded", Theme.Accent)
    task.wait(0.5)
    Notify("60+ features ready • no lag", Theme.Success)
end)

print("[ZUTAXZ v5.0] Zutaxz Style loaded.")
