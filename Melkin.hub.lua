import shutil, textwrap, os
os.makedirs('/mnt/agents/output', exist_ok=True)
shutil.copy('/mnt/agents/upload/828.png', '/mnt/agents/output/melkin_logo.png')

lua = r'''--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    M E L K I N   H U B                       ║
    ║          Interfaz moderna | PC + Móvil | v1.0                ║
    ╚══════════════════════════════════════════════════════════════╝

    ► Toggle del menú:  RightShift  (PC)  |  botón con tu logo (Móvil)
    ► Para usar tu logo: sube la imagen en el Creator Dashboard de
      Roblox (Decal), copia el ID del asset y pégalo en LOGO_ID abajo.
]]

--━━━━━━━━━━━━━━━━━━━━━〔 CONFIGURACIÓN 〕━━━━━━━━━━━━━━━━━━━━━━
local LOGO_ID = "rbxassetid://0" -- ← CAMBIA POR EL ID DE TU IMAGEN

--━━━━━━━━━━━━━━━━━━━━━〔 SERVICIOS 〕━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local SoundService     = game:GetService("SoundService")
local VirtualInputMgr  = game:GetService("VirtualInputManager")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

--━━━━━━━━━━━━━━━━━━━━━〔 SETTINGS 〕━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local S = {
    Enabled = true, Notifications = true, Sounds = true,
    Animations = true, MobileMode = IS_MOBILE, Debug = false,

    Aimbot = false, SilentAim = false, TriggerBot = false,
    TeamCheck = true, WallCheck = true, TargetPart = "Head",
    Smoothness = 0.18, FOV = 120, FOVVisible = true,

    BoxESP = false, NameESP = false, HealthESP = false,
    DistanceESP = false, TracerESP = false, BulletTracers = false, InventoryESP = false,

    Speed = 16, JumpPower = 50, InfiniteJump = false, Noclip = false,

    CameraFOV = 70, FullBright = false, NoFog = false, Crosshair = false,
}

local function Debug(...)
    if S.Debug then print("[MelkinHub]", ...) end
end

--━━━━━━━━━━━━━━━━━━━━━〔 TEMA / COLORES 〕━━━━━━━━━━━━━━━━━━━━━━
local Theme = {
    Background  = Color3.fromRGB(14, 14, 18),
    Sidebar     = Color3.fromRGB(10, 10, 13),
    Element     = Color3.fromRGB(24, 24, 30),
    Element2    = Color3.fromRGB(32, 32, 40),
    Stroke      = Color3.fromRGB(45, 45, 55),
    Text        = Color3.fromRGB(235, 235, 240),
    TextDark    = Color3.fromRGB(130, 130, 145),
    Accent      = Color3.fromRGB(255, 40, 55),
    AccentDark  = Color3.fromRGB(180, 20, 35),
    Green       = Color3.fromRGB(80, 220, 120),
}

local Sounds = {
    Click   = "rbxassetid://6895079853",
    Toggle  = "rbxassetid://911882310",
    Notify  = "rbxassetid://9089820810",
}

local function PlaySound(id, vol)
    if not S.Sounds then return end
    local s = Instance.new("Sound")
    s.SoundId = id; s.Volume = vol or 0.25; s.Parent = SoundService
    s:Play()
    task.delay(1.5, function() s:Destroy() end)
end

--━━━━━━━━━━━━━━━━━━━━━〔 PROTECCIÓN 〕━━━━━━━━━━━━━━━━━━━━━━━━━━
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local success = pcall(function()
    local t = Instance.new("ScreenGui"); t.Parent = CoreGui; t:Destroy()
end)
local ParentGui = success and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

for _, v in ipairs(ParentGui:GetChildren()) do
    if v.Name == "MelkinHub" then v:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MelkinHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = ParentGui

--━━━━━━━━━━━━━━━━━━━━━〔 HELPERS UI 〕━━━━━━━━━━━━━━━━━━━━━━━━━━
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

local function Round(parent, r)
    return Create("UICorner", { CornerRadius = UDim.new(0, r or 8), Parent = parent })
end

local function Stroke(parent, color, t)
    return Create("UIStroke", {
        Color = color or Theme.Stroke, Thickness = t or 1,
        Transparency = 0.35, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = parent
    })
end

local function Tween(obj, time, props)
    if S.Animations then
        TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
    else
        for k, v in pairs(props) do obj[k] = v end
    end
end

local function AddLabel(parent, text, size, color, order)
    return Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, size or 20),
        Text = text, TextColor3 = color or Theme.Text,
        Font = Enum.Font.GothamBold, TextSize = size or 14,
        TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order or 0, Parent = parent
    })
end

--━━━━━━━━━━━━━━━━━━━━━〔 NOTIFICACIONES 〕━━━━━━━━━━━━━━━━━━━━━━
local NotifHolder = Create("Frame", {
    Name = "NotifHolder", BackgroundTransparency = 1,
    Position = UDim2.new(1, -320, 0, 12), Size = UDim2.new(0, 300, 1, -24),
    ZIndex = 100, Parent = ScreenGui
})
Create("UIListLayout", {
    Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Top,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifHolder
})

local function Notify(title, msg, dur)
    if not S.Notifications or not S.Enabled then return end
    local n = Create("Frame", {
        BackgroundColor3 = Theme.Element, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true, ZIndex = 101, Parent = NotifHolder
    })
    Round(n, 10); Stroke(n, Theme.Accent, 1.5)
    local bar = Create("Frame", {
        BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 3, 1, 0), ZIndex = 102, Parent = n
    })
    Round(bar, 2)
    local pad = Create("UIPadding", {
        PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 10), Parent = n
    })
    Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = title,
        TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = n
    })
    Create("TextLabel", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 0, 18),
        Text = msg, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 102, Parent = n
    })
    n.Position = UDim2.new(1, 60, 0, 0)
    Tween(n, 0.35, { Position = UDim2.new(0, 0, 0, 0) })
    PlaySound(Sounds.Notify, 0.2)
    task.delay(dur or 3, function()
        Tween(n, 0.3, { Position = UDim2.new(1, 60, 0, 0), BackgroundTransparency = 1 })
        task.wait(0.3)
        n:Destroy()
    end)
end

--━━━━━━━━━━━━━━━━━━━━━〔 VENTANA PRINCIPAL 〕━━━━━━━━━━━━━━━━━━━
local UIScale = Create("UIScale", { Scale = IS_MOBILE and 0.85 or 1, Parent = ScreenGui })

local Main = Create("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, -40), Size = UDim2.new(0, 580, 0, 430),
    BackgroundColor3 = Theme.Background, Visible = true, Parent = ScreenGui
})
Round(Main, 14); Stroke(Main, Theme.Stroke, 1.5)

local Shadow = Create("ImageLabel", {
    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(1, 60, 1, 60), BackgroundTransparency = 1,
    Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(49, 49, 450, 450), Parent = Main
})

-- Header
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Theme.Sidebar, Parent = Main
})
Round(Header, 14)
Create("Frame", {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Theme.Sidebar, BorderSizePixel = 0, Parent = Header
})

local LogoDot = Create("Frame", {
    Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(0, 14, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Accent, Parent = Header
})
Round(LogoDot, 8)
Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "M",
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 16, Parent = LogoDot
})

Create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 48, 0, 0),
    BackgroundTransparency = 1, Text = "MELKIN HUB",
    TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
})
Create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 150, 0, 0),
    BackgroundTransparency = 1, Text = "v1.0",
    TextColor3 = Theme.Accent, Font = Enum.Font.Gotham, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
})

local CloseBtn = Create("TextButton", {
    Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -42, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Element,
    Text = "✕", TextColor3 = Theme.TextDark, Font = Enum.Font.GothamBold,
    TextSize = 14, AutoButtonColor = false, Parent = Header
})
Round(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.15, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1) }) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.15, { BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDark }) end)
CloseBtn.MouseButton1Click:Connect(function() PlaySound(Sounds.Click); ToggleMenu() end)

-- Sidebar (pestañas)
local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 132, 1, -46), Position = UDim2.new(0, 0, 0, 46),
    BackgroundColor3 = Theme.Sidebar, Parent = Main
})
Create("Frame", {
    Size = UDim2.new(0, 100, 0, 2), Position = UDim2.new(0, 16, 0, 10),
    BackgroundColor3 = Theme.Stroke, BorderSizePixel = 0, Parent = Sidebar
})

local TabBtns = Create("Frame", {
    Size = UDim2.new(1, 0, 1, -22), Position = UDim2.new(0, 0, 0, 22),
    BackgroundTransparency = 1, Parent = Sidebar
})
Create("UIListLayout", {
    Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabBtns
})
Create("UIPadding", { PaddingTop = UDim.new(0, 8), Parent = TabBtns })

-- Contenido
local Content = Create("Frame", {
    Size = UDim2.new(1, -144, 1, -58), Position = UDim2.new(0, 138, 0, 52),
    BackgroundTransparency = 1, Parent = Main
})

--━━━━━━━━━━━━━━━━━━━━━〔 COMPONENTES 〕━━━━━━━━━━━━━━━━━━━━━━━━━
local function AddToggle(tab, text, key, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = Theme.Element,
        Text = "", AutoButtonColor = false, LayoutOrder = #tab:GetChildren(), Parent = tab
    })
    Round(btn, 8)
    AddLabel(btn, text, 13, Theme.Text).Position = UDim2.new(0, 12, 0.5, 0)
    AddLabel(btn, text, 13, Theme.Text).AnchorPoint = Vector2.new(0, 0.5)
    AddLabel(btn, text, 13, Theme.Text).Size = UDim2.new(1, -70, 0, 16)

    local switch = Create("Frame", {
        Size = UDim2.new(0, 40, 0, 22), Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Element2, Parent = btn
    })
    Round(switch, 11); Stroke(switch, Theme.Stroke, 1)
    local knob = Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.TextDark, Parent = switch
    })
    Round(knob, 8)

    local function Refresh()
        if S[key] then
            Tween(switch, 0.2, { BackgroundColor3 = Theme.Accent })
            Tween(knob, 0.2, { Position = UDim2.new(1, -19, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1) })
        else
            Tween(switch, 0.2, { BackgroundColor3 = Theme.Element2 })
            Tween(knob, 0.2, { Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = Theme.TextDark })
        end
    end

    btn.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        PlaySound(Sounds.Toggle, 0.15)
        Refresh()
        if callback then task.spawn(callback, S[key]) end
        Debug("Toggle:", key, "=", S[key])
    end)
    Refresh()
    return btn
end

local function AddSlider(tab, text, key, min, max, isInt, callback)
    local frame = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 52), BackgroundColor3 = Theme.Element,
        LayoutOrder = #tab:GetChildren(), Parent = tab
    })
    Round(frame, 8)

    local lbl = AddLabel(frame, text, 13, Theme.Text)
    lbl.Position = UDim2.new(0, 12, 0, 8)
    local valLbl = AddLabel(frame, tostring(S[key]), 13, Theme.Accent)
    valLbl.Position = UDim2.new(1, -12, 0, 8)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Create("Frame", {
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 1, -16),
        AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Theme.Element2, Parent = frame
    })
    Round(bar, 3)
    local fill = Create("Frame", {
        Size = UDim2.new((S[key] - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Accent, Parent = bar
    })
    Round(fill, 3)
    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((S[key] - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = bar
    })
    Round(knob, 7); Stroke(knob, Theme.AccentDark, 1)

    local dragging = false
    local function SetFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * rel
        if isInt then value = math.floor(value + 0.5) end
        value = math.clamp(value, min, max)
        if S[key] ~= value then
            S[key] = value
            valLbl.Text = tostring(value)
            Tween(fill, 0.08, { Size = UDim2.new(rel, 0, 1, 0) })
            Tween(knob, 0.08, { Position = UDim2.new(rel, 0, 0.5, 0) })
            if callback then task.spawn(callback, value) end
        end
    end
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; SetFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            SetFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return frame
end

local function AddDropdown(tab, text, key, options, callback)
    local frame = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = Theme.Element,
        ClipsDescendants = false, LayoutOrder = #tab:GetChildren(), Parent = tab
    })
    Round(frame, 8)
    AddLabel(frame, text, 13, Theme.Text).Position = UDim2.new(0, 12, 0.5, 0)
    AddLabel(frame, text, 13, Theme.Text).AnchorPoint = Vector2.new(0, 0.5)
    AddLabel(frame, text, 13, Theme.Text).Size = UDim2.new(0.5, 0, 0, 16)

    local btn = Create("TextButton", {
        Size = UDim2.new(0, 110, 0, 26), Position = UDim2.new(1, -120, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Theme.Element2,
        Text = tostring(S[key]) .. "  ▾", TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamSemibold, TextSize = 12, AutoButtonColor = false, Parent = frame
    })
    Round(btn, 6); Stroke(btn, Theme.Stroke, 1)

    local list = Create("Frame", {
        Size = UDim2.new(0, 110, 0, 0), Position = UDim2.new(1, -120, 0, 42),
        BackgroundColor3 = Theme.Element2, Visible = false, ZIndex = 50, Parent = frame
    })
    Round(list, 6); Stroke(list, Theme.Accent, 1)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

    local open = false
    local function ToggleList()
        open = not open
        list.Visible = true
        if S.Animations then
            if open then
                list:TweenSize(UDim2.new(0, 110, 0, #options * 26), "Out", "Quint", 0.2, true)
            else
                list:TweenSize(UDim2.new(0, 110, 0, 0), "Out", "Quint", 0.15, true,
                    function() list.Visible = false end)
            end
        else
            list.Size = open and UDim2.new(0, 110, 0, #options * 26) or UDim2.new(0, 110, 0, 0)
            if not open then list.Visible = false end
        end
    end

    for i, opt in ipairs(options) do
        local o = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Theme.Element2,
            Text = tostring(opt), TextColor3 = Theme.Text, Font = Enum.Font.Gotham,
            TextSize = 12, LayoutOrder = i, ZIndex = 51, AutoButtonColor = false, Parent = list
        })
        o.MouseEnter:Connect(function() o.BackgroundColor3 = Theme.Accent o.TextColor3 = Color3.new(1,1,1) end)
        o.MouseLeave:Connect(function() o.BackgroundColor3 = Theme.Element2 o.TextColor3 = Theme.Text end)
        o.MouseButton1Click:Connect(function()
            S[key] = opt
            btn.Text = tostring(opt) .. "  ▾"
            PlaySound(Sounds.Click, 0.15)
            ToggleList()
            if callback then task.spawn(callback, opt) end
            Debug("Dropdown:", key, "=", opt)
        end)
    end
    btn.MouseButton1Click:Connect(function() PlaySound(Sounds.Click, 0.15); ToggleList() end)
    return frame
end

local function AddButton(tab, text, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, -8, 0, 38), BackgroundColor3 = Theme.Accent,
        Text = text, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold,
        TextSize = 13, AutoButtonColor = false,
        LayoutOrder = #tab:GetChildren(), Parent = tab
    })
    Round(btn, 8)
    btn.MouseEnter:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = Theme.AccentDark }) end)
    btn.MouseLeave:Connect(function() Tween(btn, 0.15, { BackgroundColor3 = Theme.Accent }) end)
    btn.MouseButton1Click:Connect(function()
        PlaySound(Sounds.Click, 0.2)
        if callback then task.spawn(callback) end
    end)
    return btn
end

local function AddSection(tab, text)
    local s = AddLabel(tab, text:upper(), 12, Theme.Accent)
    s.Font = Enum.Font.GothamBold
    s.LayoutOrder = #tab:GetChildren()
    return s
end

--━━━━━━━━━━━━━━━━━━━━━〔 PESTAÑAS 〕━━━━━━━━━━━━━━━━━━━━━━━━━━━
local Tabs = {}
local TabList = {
    { name = "General",  icon = "⚙" },
    { name = "Combat",   icon = "🎯" },
    { name = "ESP",      icon = "👁" },
    { name = "Movement", icon = "🏃" },
    { name = "Visuals",  icon = "🎨" },
}

for i, info in ipairs(TabList) do
    local page = Create("ScrollingFrame", {
        Name = info.name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Visible = false, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = Content
    })
    Create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
    Create("UIPadding", { PaddingRight = UDim.new(0, 6), Parent = page })
    Tabs[info.name] = page

    local btn = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 36), BackgroundColor3 = Theme.Element,
        Text = "  " .. info.icon .. "  " .. info.name, TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = i, AutoButtonColor = false, Parent = TabBtns
    })
    Round(btn, 8)

    local function Select()
        for n, p in pairs(Tabs) do p.Visible = (n == info.name) end
        for _, b in ipairs(TabBtns:GetChildren()) do
            if b:IsA("TextButton") then
                Tween(b, 0.2, { BackgroundColor3 = Theme.Element, TextColor3 = Theme.TextDark })
            end
        end
        Tween(btn, 0.2, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1, 1, 1) })
        PlaySound(Sounds.Click, 0.1)
    end
    btn.MouseButton1Click:Connect(Select)
    btn.MouseEnter:Connect(function()
        if not page.Visible then Tween(btn, 0.15, { TextColor3 = Theme.Text }) end
    end)
    btn.MouseLeave:Connect(function()
        if not page.Visible then Tween(btn, 0.15, { TextColor3 = Theme.TextDark }) end
    end)
    Tabs[info.name .. "_btn"] = { btn = btn, select = Select }
end

--━━━━━━━━━━━━━━━━━━━━━〔 CONTENIDO DE PESTAÑAS 〕━━━━━━━━━━━━━━━━

-- ► GENERAL
do
    local t = Tabs.General
    AddToggle(t, "Enabled", "Enabled", function(v)
        if v then Notify("Melkin Hub", "Script activado") else Notify("Melkin Hub", "Script desactivado") end
    end)
    AddToggle(t, "Notifications", "Notifications")
    AddToggle(t, "Sounds", "Sounds")
    AddToggle(t, "Animations", "Animations")
    AddToggle(t, "Mobile Mode", "MobileMode", function(v)
        Tween(UIScale, 0.25, { Scale = v and 0.85 or 1 })
    end)
    AddToggle(t, "Debug Mode", "Debug")
    AddSection(t, "Info")
    AddButton(t, "Descargar configuración", function()
        Notify("Melkin Hub", "Configuración copiada a consola")
        print(game:GetService("HttpService"):JSONEncode(S))
    end)
    AddButton(t, "Uninject / Destruir UI", function()
        ScreenGui:Destroy()
    end)
end

-- ► COMBAT
do
    local t = Tabs.Combat
    AddSection(t, "Aim")
    AddToggle(t, "Aimbot", "Aimbot")
    AddToggle(t, "Silent Aim", "SilentAim")
    AddToggle(t, "TriggerBot", "TriggerBot")
    AddSection(t, "Filtros")
    AddToggle(t, "Team Check", "TeamCheck")
    AddToggle(t, "Wall Check", "WallCheck")
    AddDropdown(t, "Target Part", "TargetPart", {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"})
    AddSection(t, "Ajustes")
    AddSlider(t, "Smoothness", "Smoothness", 0, 1, false)
    AddSlider(t, "FOV", "FOV", 10, 500, true)
    AddToggle(t, "FOV Visible", "FOVVisible")
end

-- ► ESP
do
    local t = Tabs.ESP
    AddSection(t, "Jugadores")
    AddToggle(t, "Box ESP", "BoxESP")
    AddToggle(t, "Name", "NameESP")
    AddToggle(t, "Health", "HealthESP")
    AddToggle(t, "Distance", "DistanceESP")
    AddToggle(t, "Tracer", "TracerESP")
    AddSection(t, "Extra")
    AddToggle(t, "Bullets Tracers", "BulletTracers")
    AddToggle(t, "Inventory", "InventoryESP")
end

-- ► MOVEMENT
do
    local t = Tabs.Movement
    AddSlider(t, "Speed", "Speed", 16, 500, true, function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    AddSlider(t, "Jump Power", "JumpPower", 50, 500, true, function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end)
    AddToggle(t, "Infinite Jump", "InfiniteJump")
    AddToggle(t, "Noclip", "Noclip")
end

-- ► VISUALS
do
    local t = Tabs.Visuals
    AddSlider(t, "Camera FOV", "CameraFOV", 70, 120, true, function(v)
        Camera.FieldOfView = v
    end)
    AddToggle(t, "FullBright", "FullBright")
    AddToggle(t, "No Fog", "NoFog")
    AddToggle(t, "Crosshair", "Crosshair")
end

Tabs.General_btn.select()

--━━━━━━━━━━━━━━━━━━━━━〔 ARRASTRE DE VENTANA 〕━━━━━━━━━━━━━━━━━
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--━━━━━━━━━━━━━━━━━━━━━〔 BOTÓN LOGO (abrir menú) 〕━━━━━━━━━━━━━
local OpenBtn = Create("ImageButton", {
    Name = "OpenBtn", Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 14, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(8, 8, 10), Image = LOGO_ID,
    ScaleType = Enum.ScaleType.Crop, Visible = false, AutoButtonColor = false, Parent = ScreenGui
})
Round(OpenBtn, 27); Stroke(OpenBtn, Theme.Accent, 2)

local MenuOpen = true
function ToggleMenu()
    MenuOpen = not MenuOpen
    if MenuOpen then
        OpenBtn.Visible = false
        Main.Visible = true
        Main.Position = UDim2.new(0.5, 0, 0.5, -40)
        Tween(Main, 0.3, { Position = UDim2.new(0.5, 0, 0.5, 0), GroupTransparency = 0 })
        PlaySound(Sounds.Toggle, 0.2)
    else
        Tween(Main, 0.25, { Position = UDim2.new(0.5, 0, 0.5, 30), GroupTransparency = 1 })
        task.delay(0.25, function()
            Main.Visible = false
            OpenBtn.Visible = true
            OpenBtn.Position = UDim2.new(0, 14, 0.5, 0)
            Tween(OpenBtn, 0.3, { Position = UDim2.new(0, 14, 0.5, 0) })
            PlaySound(Sounds.Toggle, 0.2)
        end)
    end
end
OpenBtn.MouseButton1Click:Connect(ToggleMenu)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleMenu()
    end
end)

-- Arrastre del botón logo
do
    local dragging, ds, sp
    OpenBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = input.Position; sp = OpenBtn.Position
            local ended = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false ended = true end
            end)
            task.delay(0.25, function()
                if ended then
                    local dist = (input.Position - ds).Magnitude
                    if dist < 10 then ToggleMenu() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - ds
            OpenBtn.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

--━━━━━━━━━━━━━━━━━━━━━〔 DRAWING HELPERS 〕━━━━━━━━━━━━━━━━━━━━━
local DrawingOK, Drawing = pcall(function() return Drawing end)
if not DrawingOK then Drawing = nil end

local function NewDrawing(type, props)
    if not Drawing then return nil end
    local d = Drawing.new(type)
    for k, v in pairs(props) do d[k] = v end
    return d
end

-- FOV Circle
local FOVCircle = NewDrawing("Circle", {
    Visible = false, Radius = S.FOV, Position = Vector2.zero,
    Color = Theme.Accent, Thickness = 1.5, Transparency = 0.7, NumSides = 64, Filled = false
})

-- Crosshair
local CrossH = NewDrawing("Line", { Visible = false, Color = Color3.new(1,1,1), Thickness = 1.5, Transparency = 0.6 })
local CrossV = NewDrawing("Line", { Visible = false, Color = Color3.new(1,1,1), Thickness = 1.5, Transparency = 0.6 })

--━━━━━━━━━━━━━━━━━━━━━〔 ESP SYSTEM 〕━━━━━━━━━━━━━━━━━━━━━━━━━━
local ESP = {}

local function NewESPObj(plr)
    return {
        Box    = NewDrawing("Square",   { Visible = false, Thickness = 1, Transparency = 1, Color = Theme.Accent, Filled = false }),
        BoxFill= NewDrawing("Square",   { Visible = false, Filled = true, Transparency = 0.85, Color = Theme.Accent }),
        Name   = NewDrawing("Text",     { Visible = false, Size = 13, Color = Color3.new(1,1,1), Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Transparency = 1 }),
        Health = NewDrawing("Text",     { Visible = false, Size = 11, Color = Theme.Green, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Transparency = 1 }),
        Dist   = NewDrawing("Text",     { Visible = false, Size = 11, Color = Theme.TextDark, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Transparency = 1 }),
        Tracer = NewDrawing("Line",     { Visible = false, Thickness = 1, Transparency = 1, Color = Theme.Accent }),
        Inv    = NewDrawing("Text",     { Visible = false, Size = 11, Color = Color3.fromRGB(255,200,80), Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Transparency = 1 }),
    }
end

local function HideESP(o)
    for _, d in pairs(o) do if d then d.Visible = false end end
end

local function RemoveESP(plr)
    local o = ESP[plr]
    if o then for _, d in pairs(o) do if d then d:Remove() end end end
    ESP[plr] = nil
end

local function GetChar(plr) return plr.Character end
local function GetHum(plr) local c = GetChar(plr); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetRoot(plr) local c = GetChar(plr); return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end

local function IsTeammate(plr)
    if not S.TeamCheck then return false end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then return true end
    return false
end

local function IsVisible(targetPart, root)
    if not S.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(origin, dir, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(targetPart.Parent)
end

local function AnyESPOn()
    return S.BoxESP or S.NameESP or S.HealthESP or S.DistanceESP or S.TracerESP or S.InventoryESP
end

--━━━━━━━━━━━━━━━━━━━━━〔 BULLET TRACERS 〕━━━━━━━━━━━━━━━━━━━━━━
local BulletLines = {}
if Drawing then
    Workspace.DescendantAdded:Connect(function(d)
        if S.BulletTracers and d:IsA("BasePart") and d.Velocity.Magnitude > 150 and not d:IsDescendantOf(LocalPlayer.Character or {}) then
            local line = Drawing.new("Line")
            line.Color = Theme.Accent; line.Thickness = 1.5
            local startPos = Camera:WorldToViewportPoint(d.Position).Position
            local t = 0
            task.spawn(function()
                while t < 0.6 and d.Parent do
                    t = t + RunService.RenderStepped:Wait()
                    local p, on = Camera:WorldToViewportPoint(d.Position)
                    if on then
                        line.From = startPos; line.To = p.Position
                        line.Transparency = 1 - (t / 0.6)
                        line.Visible = true
                    end
                end
                line:Remove()
            end)
        end
    end)
end

--━━━━━━━━━━━━━━━━━━━━━〔 SILENT AIM HOOK 〕━━━━━━━━━━━━━━━━━━━━━
pcall(function()
    if not hookmetamethod then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if S.SilentAim and not checkcaller() then
            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast" then
                local target = GetClosestToMouse()
                if target then
                    local args = {...}
                    if #args > 0 and typeof(args[1]) == "Ray" then
                        return target, target.Position, Vector3.zero, target.Material
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
end)

--━━━━━━━━━━━━━━━━━━━━━〔 AIM HELPERS 〕━━━━━━━━━━━━━━━━━━━━━━━━━
local CurrentTarget = nil

function GetClosestToMouse()
    local closest, dist = nil, S.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and not IsTeammate(plr) then
            local part = GetChar(plr) and GetChar(plr):FindFirstChild(S.TargetPart)
            local hum = GetHum(plr)
            if part and hum and hum.Health > 0 then
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if d < dist and IsVisible(part) then
                        closest = part; dist = d
                    end
                end
            end
        end
    end
    return closest
end

--━━━━━━━━━━━━━━━━━━━━━〔 TRIGGERBOT 〕━━━━━━━━━━━━━━━━━━━━━━━━━━
task.spawn(function()
    while true do
        task.wait(0.05)
        if S.TriggerBot and S.Enabled and not IS_MOBILE then
            local target = GetClosestToMouse()
            if target and target.Parent then
                local plr = Players:GetPlayerFromCharacter(target.Parent)
                if plr and not IsTeammate(plr) then
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.02)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end)
                end
            end
        end
    end
end)

--━━━━━━━━━━━━━━━━━━━━━〔 MOVEMENT / MISC HOOKS 〕━━━━━━━━━━━━━━━━
UserInputService.JumpRequest:Connect(function()
    if S.InfiniteJump and S.Enabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local oldLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
}

RunService.Stepped:Connect(function()
    if not S.Enabled then return end

    -- Noclip
    if S.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- FullBright
    if S.FullBright then
        Lighting.Brightness = 2; Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(180, 180, 180)
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = oldLight.Brightness; Lighting.ClockTime = oldLight.ClockTime
        Lighting.GlobalShadows = oldLight.GlobalShadows
        Lighting.Ambient = oldLight.Ambient; Lighting.OutdoorAmbient = oldLight.OutdoorAmbient
    end

    -- No Fog
    if S.NoFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = oldLight.FogEnd
    end
end)

Players.PlayerRemoving:Connect(function(plr) RemoveESP(plr) end)

--━━━━━━━━━━━━━━━━━━━━━〔 LOOP PRINCIPAL 〕━━━━━━━━━━━━━━━━━━━━━━━━
local AIM_KEY = Enum.UserInputType.MouseButton2
RunService.RenderStepped:Connect(function()
    if not S.Enabled then return end
    local mousePos = UserInputService:GetMouseLocation()

    -- FOV Circle
    if FOVCircle then
        FOVCircle.Visible = S.FOVVisible and (S.Aimbot or S.SilentAim or S.TriggerBot)
        FOVCircle.Position = mousePos
        FOVCircle.Radius = S.FOV
    end

    -- Crosshair
    if CrossH and CrossV then
        local show = S.Crosshair
        CrossH.Visible = show; CrossV.Visible = show
        if show then
            local c = Camera.ViewportSize / 2
            CrossH.From = Vector2.new(c.X - 8, c.Y); CrossH.To = Vector2.new(c.X + 8, c.Y)
            CrossV.From = Vector2.new(c.X, c.Y - 8); CrossV.To = Vector2.new(c.X, c.Y + 8)
        end
    end

    -- Aimbot
    if S.Aimbot then
        local aiming = IS_MOBILE and true or UserInputService:IsMouseButtonPressed(AIM_KEY)
        if aiming then
            if not CurrentTarget then CurrentTarget = GetClosestToMouse() end
        else
            CurrentTarget = nil
        end
        if CurrentTarget and CurrentTarget.Parent then
            local hum = CurrentTarget.Parent:FindFirstChildOfClass("Humanoid")
            local plr = Players:GetPlayerFromCharacter(CurrentTarget.Parent)
            if hum and hum.Health > 0 and plr and not IsTeammate(plr) then
                local targetPos = CurrentTarget.Position
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.clamp(1 - S.Smoothness, 0.02, 1))
            else
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end
    else
        CurrentTarget = nil
    end

    -- ESP
    if Drawing and AnyESPOn() then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and not IsTeammate(plr) then
                local char = GetChar(plr)
                local hum = GetHum(plr)
                local root = GetRoot(plr)
                if char and hum and root and hum.Health > 0 then
                    local o = ESP[plr] or NewESPObj(plr); ESP[plr] = o
                    local cf, size = char:GetBoundingBox()
                    local pos, on = Camera:WorldToViewportPoint(root.Position)
                    if on and pos.Z > 0 then
                        local top, onTop = Camera:WorldToViewportPoint(cf.Position + Vector3.new(0, size.Y/2, 0))
                        local bottom, onBot = Camera:WorldToViewportPoint(cf.Position - Vector3.new(0, size.Y/2, 0))
                        if onTop and onBot then
                            local h = math.abs(top.Y - bottom.Y)
                            local w = h * 0.55
                            local x = top.X - w/2
                            local y = top.Y

                            if S.BoxESP then
                                o.Box.Size = Vector2.new(w, h)
                                o.Box.Position = Vector2.new(x, y)
                                o.Box.Transparency = 1
                                o.Box.Visible = true
                                o.BoxFill.Size = Vector2.new(w, h)
                                o.BoxFill.Position = Vector2.new(x, y)
                                o.BoxFill.Transparency = 0.9
                                o.BoxFill.Visible = true
                                local hpColor = Color3.fromRGB(255,0,0):Lerp(Theme.Green, hum.Health / hum.MaxHealth)
                                o.Box.Color = hpColor; o.BoxFill.Color = hpColor
                            else o.Box.Visible = false; o.BoxFill.Visible = false end

                            if S.NameESP then
                                o.Name.Text = plr.DisplayName
                                o.Name.Position = Vector2.new(x + w/2, y - 16)
                                o.Name.Transparency = 1; o.Name.Visible = true
                            else o.Name.Visible = false end

                            if S.HealthESP then
                                o.Health.Text = tostring(math.floor(hum.Health)) .. " HP"
                                o.Health.Position = Vector2.new(x + w/2, y + h + 3)
                                o.Health.Transparency = 1; o.Health.Visible = true
                            else o.Health.Visible = false end

                            if S.DistanceESP then
                                local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                                o.Dist.Text = dist .. "m"
                                o.Dist.Position = Vector2.new(x + w/2, y + h + (S.HealthESP and 15 or 3))
                                o.Dist.Transparency = 1; o.Dist.Visible = true
                            else o.Dist.Visible = false end

                            if S.TracerESP then
                                local origin = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                                o.Tracer.From = origin; o.Tracer.To = Vector2.new(pos.X, pos.Y)
                                o.Tracer.Transparency = 1; o.Tracer.Visible = true
                            else o.Tracer.Visible = false end

                            if S.InventoryESP then
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then
                                    o.Inv.Text = tool.Name
                                    o.Inv.Position = Vector2.new(x + w/2, y - 30)
                                    o.Inv.Transparency = 1; o.Inv.Visible = true
                                else o.Inv.Visible = false end
                            else o.Inv.Visible = false end
                        else HideESP(o) end
                    else HideESP(o) end
                else
                    if ESP[plr] then HideESP(ESP[plr]) end
                end
            elseif ESP[plr] then HideESP(ESP[plr]) end
        end
    elseif Drawing then
        for plr, o in pairs(ESP) do HideESP(o) end
    end
end)

--━━━━━━━━━━━━━━━━━━━━━〔 INICIO 〕━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
task.wait(0.5)
Notify("Melkin Hub", "Script cargado correctamente ✓", 4)
Debug("Melkin Hub iniciado | Mobile:", IS_MOBILE)
'''

with open('/mnt/agents/output/melkin_hub.lua', 'w', encoding='utf-8') as f:
    f.write(lua)
print("OK", os.path.getsize('/mnt/agents/output/melkin_hub.lua'), "bytes")
