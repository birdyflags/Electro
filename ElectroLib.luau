--!nocheck
--[[
    ElectroLib
    A small UI library for the ELECTRO.FUN visual style.

    Currently supported:
        Library:CreateWindow({ Title, Logo, Accent })
        Window:CreateTab({ Icon })
        Tab:CreateSection({ Side = "Left" | "Right", Name })
        Section:AddToggle({ Name, Default, Callback })

    Toggle object:
        Toggle:Set(bool)
        Toggle:Get() -> bool
        Toggle:OnChanged(fn)
]]

local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")

local FONT         = Font.new("rbxassetid://12187365364")
local FONT_BOLD    = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)

local DEFAULT_ACCENT = Color3.fromRGB(235, 100, 52)
local COLOR_TAB_IDLE = Color3.fromRGB(120, 120, 128)
local COLOR_TAB_HOVER = Color3.fromRGB(180, 180, 190)

local COLOR_TOGGLE_OFF  = Color3.fromRGB(26, 26, 33)
local COLOR_STROKE_OFF  = Color3.fromRGB(34, 34, 41)
local COLOR_LABEL_OFF   = Color3.fromRGB(83, 83, 89)
local COLOR_LABEL_ON    = Color3.new(1, 1, 1)

local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local TAB_WIDTH     = 58
local TAB_HEIGHT    = 54
local TAB_PADDING   = 3
local TABS_PAD_LEFT = 15

local function make(class, props, children)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            inst[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = inst
        end
    end
    return inst
end

local function tween(obj, info, props)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function getUIParent()
    local ok, hui = pcall(function()
        if gethui then
            return gethui()
        end
    end)
    if ok and hui then
        return hui
    end

    local coreOk, coregui = pcall(game.GetService, game, "CoreGui")
    if coreOk and coregui then
        local canUse = pcall(function()
            local tmp = Instance.new("ScreenGui")
            tmp.Parent = coregui
            tmp:Destroy()
        end)
        if canUse then
            return coregui
        end
    end

    local lp = Players.LocalPlayer
    if lp then
        return lp:WaitForChild("PlayerGui")
    end
    return game:GetService("CoreGui")
end

------------------------------------------------------------
-- Toggle
------------------------------------------------------------
local Toggle = {}
Toggle.__index = Toggle

function Toggle:Set(state, silent)
    state = state and true or false
    if state == self.State then
        return
    end
    self.State = state

    local accent = self.Window.Accent
    if state then
        tween(self.Box,       TWEEN_FAST, { BackgroundColor3 = accent })
        tween(self.Stroke,    TWEEN_FAST, { Transparency = 1 })
        tween(self.CheckIcon, TWEEN_FAST, { ImageTransparency = 0 })
        tween(self.NameLabel, TWEEN_FAST, { TextColor3 = COLOR_LABEL_ON })
    else
        tween(self.Box,       TWEEN_FAST, { BackgroundColor3 = COLOR_TOGGLE_OFF })
        tween(self.Stroke,    TWEEN_FAST, { Transparency = 0 })
        tween(self.CheckIcon, TWEEN_FAST, { ImageTransparency = 1 })
        tween(self.NameLabel, TWEEN_FAST, { TextColor3 = COLOR_LABEL_OFF })
    end

    if not silent and self.Callback then
        task.spawn(self.Callback, state)
    end
end

function Toggle:Get()
    return self.State
end

function Toggle:OnChanged(fn)
    self.Callback = fn
end

------------------------------------------------------------
-- Section
------------------------------------------------------------
local Section = {}
Section.__index = Section

function Section:AddToggle(opts)
    opts = opts or {}
    local name     = opts.Name or "Toggle"
    local default  = opts.Default and true or false
    local callback = opts.Callback

    local component = make("Frame", {
        Name = "Toggle_Component",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 26),
    })

    local box = make("Frame", {
        Name = "Toggle",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = COLOR_TOGGLE_OFF,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Parent = component,
    })
    local stroke = make("UIStroke", {
        Color = COLOR_STROKE_OFF,
        Parent = box,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = box })

    local checkIcon = make("ImageLabel", {
        Name = "Check_Icon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://83899464799881",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(8, 7),
        Parent = box,
    })

    local nameLabel = make("TextLabel", {
        Name = "Toggle_Name",
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        FontFace = FONT,
        Position = UDim2.new(0, 33, 0.5, 0),
        Size = UDim2.fromOffset(1, 1),
        Text = name,
        TextColor3 = COLOR_LABEL_OFF,
        TextSize = 14,
        Parent = component,
    })

    local hitbox = make("TextButton", {
        Name = "Hitbox",
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
        Parent = component,
    })

    component.Parent = self.Holder

    local toggle = setmetatable({
        Window    = self.Tab.Window,
        State     = false,
        Callback  = callback,
        Component = component,
        Box       = box,
        Stroke    = stroke,
        CheckIcon = checkIcon,
        NameLabel = nameLabel,
    }, Toggle)

    hitbox.MouseButton1Click:Connect(function()
        toggle:Set(not toggle.State)
    end)

    hitbox.MouseEnter:Connect(function()
        if not toggle.State then
            tween(stroke, TWEEN_FAST, { Color = Color3.fromRGB(55, 55, 65) })
        end
    end)
    hitbox.MouseLeave:Connect(function()
        if not toggle.State then
            tween(stroke, TWEEN_FAST, { Color = COLOR_STROKE_OFF })
        end
    end)

    if default then
        toggle:Set(true, true)
    end

    return toggle
end

------------------------------------------------------------
-- Tab
------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(opts)
    opts = opts or {}
    local name = opts.Name or "Section"
    local side = (opts.Side == "Right") and "Right" or "Left"

    local layoutOrder
    if side == "Left" then
        self.LeftCount = self.LeftCount + 1
        layoutOrder = (self.LeftCount - 1) * 2
    else
        self.RightCount = self.RightCount + 1
        layoutOrder = (self.RightCount - 1) * 2 + 1
    end

    local section = make("Frame", {
        Name = "Section_" .. side,
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(19, 19, 23),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder,
        Size = UDim2.fromOffset(341, 0),
    })
    make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = section })
    make("UIStroke", { Color = Color3.fromRGB(32, 34, 45), Parent = section })

    local header = make("Frame", {
        Name = "Header",
        BackgroundColor3 = Color3.fromRGB(23, 24, 30),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = section,
    })

    make("Frame", {
        Name = "Liner",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(21, 21, 25),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.new(1, 0, 0, 1),
        Parent = header,
    })

    make("TextLabel", {
        Name = "Section_Name",
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundTransparency = 1,
        FontFace = FONT,
        Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.fromOffset(1, 1),
        Text = name,
        TextColor3 = COLOR_LABEL_ON,
        TextSize = 14,
        Parent = header,
    })

    make("ImageLabel", {
        Name = "Arrow_Icon",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://133540734301865",
        Position = UDim2.new(1, -12, 0.5, 0),
        ScaleType = Enum.ScaleType.Fit,
        Size = UDim2.fromOffset(16, 16),
        Parent = header,
    })

    local holder = make("Frame", {
        Name = "Holder",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        Parent = section,
    })

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder,
    })

    make("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 0),
        PaddingRight = UDim.new(0, 0),
        Parent = holder,
    })

    section.Parent = self.Container

    return setmetatable({
        Tab     = self,
        Section = section,
        Header  = header,
        Holder  = holder,
        Name    = name,
        Side    = side,
    }, Section)
end

------------------------------------------------------------
-- Window
------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:_tabCenterX(tab)
    local wrap = self.TabsWrapper
    local holder = tab.Holder
    local wrapX = wrap.AbsolutePosition.X
    local tabX  = holder.AbsolutePosition.X
    if tabX > 0 and wrap.AbsoluteSize.X > 0 then
        return (tabX + holder.AbsoluteSize.X * 0.5) - wrapX
    end
    return TABS_PAD_LEFT + (tab.Index - 1) * (TAB_WIDTH + TAB_PADDING) + TAB_WIDTH * 0.5
end

function Window:_moveIndicator(tab, animate)
    local x = self:_tabCenterX(tab)
    local target = UDim2.new(0, x, 1, 0)
    if animate then
        tween(self.Indicator, TWEEN_MED, { Position = target })
    else
        self.Indicator.Position = target
    end
end

function Window:SelectTab(index)
    local newTab = self.Tabs[index]
    if not newTab then
        return
    end
    if self.SelectedIndex == index then
        return
    end

    local oldTab = self.Tabs[self.SelectedIndex]
    if oldTab then
        tween(oldTab.Image, TWEEN_FAST, { ImageColor3 = COLOR_TAB_IDLE })
        local oldPage = oldTab.Page
        tween(oldPage, TWEEN_FAST, { GroupTransparency = 1 })
        task.delay(0.16, function()
            if self.SelectedIndex ~= oldTab.Index then
                oldPage.Visible = false
            end
        end)
    end

    newTab.Page.GroupTransparency = 1
    newTab.Page.Visible = true
    tween(newTab.Page, TWEEN_FAST, { GroupTransparency = 0 })
    tween(newTab.Image, TWEEN_FAST, { ImageColor3 = self.Accent })

    self.SelectedIndex = index
    self:_moveIndicator(newTab, oldTab ~= nil)
end

function Window:CreateTab(opts)
    opts = opts or {}
    local icon = opts.Icon or ""

    local index = #self.Tabs + 1

    local holder = make("Frame", {
        Name = "Tab" .. index .. "_Holder",
        BackgroundTransparency = 1,
        LayoutOrder = index,
        Size = UDim2.fromOffset(TAB_WIDTH, TAB_HEIGHT),
    })

    local image = make("ImageButton", {
        Name = "Tab_Image",
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Image = icon,
        ImageColor3 = COLOR_TAB_IDLE,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(30, 30),
        Parent = holder,
    })

    holder.Parent = self.TabsList

    local page = make("CanvasGroup", {
        Name = "Page" .. index,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    })

    local container = make("ScrollingFrame", {
        Name = "Container",
        Active = true,
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Position = UDim2.fromScale(0.5, 0.5),
        ScrollBarImageColor3 = self.Accent,
        ScrollBarThickness = 4,
        Size = UDim2.new(1, -16, 1, -20),
        TopImage = "",
        BottomImage = "",
        Parent = page,
    })

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Wraps = true,
        Parent = container,
    })

    make("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = container,
    })

    page.Parent = self.PageContainer

    local tab = setmetatable({
        Window     = self,
        Index      = index,
        Holder     = holder,
        Image      = image,
        Page       = page,
        Container  = container,
        LeftCount  = 0,
        RightCount = 0,
    }, Tab)

    self.Tabs[index] = tab

    image.MouseButton1Click:Connect(function()
        self:SelectTab(index)
    end)

    image.MouseEnter:Connect(function()
        if self.SelectedIndex ~= index then
            tween(image, TWEEN_FAST, { ImageColor3 = COLOR_TAB_HOVER })
        end
    end)
    image.MouseLeave:Connect(function()
        if self.SelectedIndex ~= index then
            tween(image, TWEEN_FAST, { ImageColor3 = COLOR_TAB_IDLE })
        end
    end)

    if index == 1 then
        task.spawn(function()
            for _ = 1, 2 do
                RunService.Heartbeat:Wait()
            end
            self:SelectTab(1)
        end)
    end

    return tab
end

------------------------------------------------------------
-- Library
------------------------------------------------------------
local ElectroLib = {}

function ElectroLib:CreateWindow(opts)
    opts = opts or {}
    local title  = opts.Title  or "ELECTRO.FUN"
    local logo   = opts.Logo   or "rbxassetid://128573523116063"
    local accent = opts.Accent or DEFAULT_ACCENT

    local screenGui = make("ScreenGui", {
        Name = "ElectroLib",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })

    local mainBack = make("Frame", {
        Name = "MainBack",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(22, 21, 27),
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(747, 594),
        Parent = screenGui,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = mainBack })

    local headerContainer = make("Frame", {
        Name = "HeaderContainer",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Size = UDim2.new(1, 0, 0, 69),
        Parent = mainBack,
    })

    local header = make("Frame", {
        Name = "Header",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(33, 31, 40),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 64),
        Parent = headerContainer,
    })
    make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })

    local logoTitleHolder = make("Frame", {
        Name = "Logo_TitleHolder",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(131, 73),
        Parent = header,
    })

    make("ImageLabel", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://95531037500951",
        Position = UDim2.fromScale(0.377863, 0.541096),
        Size = UDim2.fromOffset(195, 197),
        Parent = logoTitleHolder,
    })

    make("ImageLabel", {
        Name = "Logo",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = logo,
        Position = UDim2.fromScale(-0.0992366, 0.541096),
        Size = UDim2.fromOffset(69, 41),
        Parent = logoTitleHolder,
    })

    make("TextLabel", {
        Name = "Title",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        FontFace = FONT_BOLD,
        Position = UDim2.fromScale(0.847328, 0.541096),
        Size = UDim2.fromOffset(55, 37),
        Text = title,
        TextColor3 = Color3.fromRGB(161, 152, 159),
        TextSize = 15,
        Parent = logoTitleHolder,
    })

    local tabsWrapper = make("Frame", {
        Name = "TabsWrapper",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.215894, 0),
        Size = UDim2.fromOffset(437, 64),
        Parent = header,
    })

    local tabsList = make("Frame", {
        Name = "TabsList",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = tabsWrapper,
    })

    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, TAB_PADDING),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabsList,
    })

    make("UIPadding", {
        PaddingLeft = UDim.new(0, TABS_PAD_LEFT),
        PaddingTop  = UDim.new(0, 5),
        Parent = tabsList,
    })

    local initialIndicatorX = TABS_PAD_LEFT + TAB_WIDTH * 0.5
    local indicator = make("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0, initialIndicatorX, 1, 0),
        Size = UDim2.fromOffset(53, 21),
        Visible = true,
        ZIndex = 3,
        Parent = tabsWrapper,
    })
    make("UICorner", { Parent = indicator })

    make("ImageLabel", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://83933299080110",
        ImageColor3 = accent,
        ImageTransparency = 0.4,
        Position = UDim2.fromScale(0.5, 0.229055),
        Size = UDim2.fromOffset(96, 43),
        ZIndex = 2,
        Parent = indicator,
    })

    local pageContainer = make("Frame", {
        Name = "PageContainer",
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(0, 0, 0, 69),
        Size = UDim2.new(1, 0, 1, -69),
        Parent = mainBack,
    })

    local window = setmetatable({
        ScreenGui     = screenGui,
        MainBack      = mainBack,
        Header        = header,
        TabsWrapper   = tabsWrapper,
        TabsList      = tabsList,
        Indicator     = indicator,
        PageContainer = pageContainer,
        Accent        = accent,
        Tabs          = {},
        SelectedIndex = 0,
    }, Window)

    screenGui.Parent = getUIParent()

    return window
end

return ElectroLib
