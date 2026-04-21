--!nocheck
-- ElectroLib - themed UI for ELECTRO.FUN scripts.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local FONT_ID = "rbxassetid://12187365364"
local FONT = Font.new(FONT_ID)
local FONT_BOLD = Font.new(FONT_ID, Enum.FontWeight.Bold)

local palette = {
	accent      = Color3.fromRGB(235, 100, 52),
	accentDim   = Color3.fromRGB(175, 70, 35),
	window      = Color3.fromRGB(22, 21, 27),
	header      = Color3.fromRGB(33, 31, 40),
	section     = Color3.fromRGB(19, 19, 23),
	secHeader   = Color3.fromRGB(23, 24, 30),
	secStroke   = Color3.fromRGB(32, 34, 45),
	liner       = Color3.fromRGB(21, 21, 25),
	control     = Color3.fromRGB(26, 26, 33),
	ctrlStroke  = Color3.fromRGB(34, 34, 41),
	ctrlHover   = Color3.fromRGB(55, 55, 65),
	barBg       = Color3.fromRGB(32, 32, 39),
	barStroke   = Color3.fromRGB(40, 40, 46),
	muted       = Color3.fromRGB(83, 83, 89),
	text        = Color3.new(1, 1, 1),
	idle        = Color3.fromRGB(120, 120, 128),
	hover       = Color3.fromRGB(180, 180, 190),
	brand       = Color3.fromRGB(161, 152, 159),
}

local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local TAB_W, TAB_H = 58, 54
local TAB_GAP, TABS_LPAD = 3, 15

local function make(class, props)
	local inst = Instance.new(class)
	if props then
		for k, v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

local function play(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function host()
	if typeof(gethui) == "function" then
		local ok, h = pcall(gethui)
		if ok and h then return h end
	end
	local cg = game:GetService("CoreGui")
	local canUse = pcall(function()
		local probe = Instance.new("ScreenGui")
		probe.Parent = cg
		probe:Destroy()
	end)
	if canUse then return cg end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- helper for slider / drag: returns fractional position of x within a frame
local function fractionAt(frame, x)
	local origin, width = frame.AbsolutePosition.X, frame.AbsoluteSize.X
	if width <= 0 then return 0 end
	return math.clamp((x - origin) / width, 0, 1)
end


local Toggle = {}
Toggle.__index = Toggle

function Toggle:Set(state, silent)
	state = not not state
	if state == self._on then return end
	self._on = state

	local target = state and self._accent or palette.control
	play(self._box, FAST, { BackgroundColor3 = target })
	play(self._stroke, FAST, { Transparency = state and 1 or 0 })
	play(self._check, FAST, { TextTransparency = state and 0 or 1 })
	play(self._label, FAST, { TextColor3 = state and palette.text or palette.muted })

	if not silent and self._cb then
		task.spawn(self._cb, state)
	end
end

function Toggle:Get() return self._on end
function Toggle:OnChanged(fn) self._cb = fn end


local Slider = {}
Slider.__index = Slider

function Slider:_apply(value, silent, animate)
	local step = self._step
	if step > 0 then
		value = math.floor(value / step + 0.5) * step
	end
	value = math.clamp(value, self._min, self._max)
	if value == self._value and not animate then return end
	self._value = value

	local alpha = (value - self._min) / (self._max - self._min)
	local size = UDim2.fromScale(alpha, 1)
	if animate then
		play(self._fill, FAST, { Size = size })
	else
		self._fill.Size = size
	end
	self._valueLbl.Text = self._fmt(value)

	if not silent and self._cb then
		task.spawn(self._cb, value)
	end
end

function Slider:Set(value, silent)
	self:_apply(value, silent, true)
end

function Slider:Get() return self._value end
function Slider:OnChanged(fn) self._cb = fn end


local Section = {}
Section.__index = Section

function Section:AddToggle(opts)
	opts = opts or {}

	local row = make("Frame", {
		Name = "ToggleRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 26),
	})

	local box = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = palette.control,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 9, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		Parent = row,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 3), Parent = box })
	local stroke = make("UIStroke", {
		Color = palette.ctrlStroke,
		Thickness = 1,
		Parent = box,
	})

	-- Crisp vector check mark via bold unicode glyph
	local check = make("TextLabel", {
		Name = "Check",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		FontFace = FONT_BOLD,
		Position = UDim2.new(0.5, 0, 0.5, 1),
		Size = UDim2.fromScale(1, 1),
		Text = "✓",
		TextColor3 = Color3.new(0, 0, 0),
		TextScaled = true,
		TextTransparency = 1,
		Parent = box,
	})
	make("UITextSizeConstraint", { MaxTextSize = 14, Parent = check })

	local label = make("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		FontFace = FONT,
		Position = UDim2.new(0, 33, 0.5, 0),
		Size = UDim2.fromOffset(0, 14),
		Text = opts.Name or "Toggle",
		TextColor3 = palette.muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local hit = make("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Parent = row,
	})

	local self_ = setmetatable({
		_on      = false,
		_cb      = opts.Callback,
		_accent  = self._tab._window.Accent,
		_box     = box,
		_stroke  = stroke,
		_check   = check,
		_label   = label,
	}, Toggle)

	hit.MouseButton1Click:Connect(function()
		self_:Set(not self_._on)
	end)
	hit.MouseEnter:Connect(function()
		if not self_._on then
			play(stroke, FAST, { Color = palette.ctrlHover })
		end
	end)
	hit.MouseLeave:Connect(function()
		if not self_._on then
			play(stroke, FAST, { Color = palette.ctrlStroke })
		end
	end)

	row.Parent = self._holder
	if opts.Default then
		self_:Set(true, true)
	end
	return self_
end

function Section:AddSlider(opts)
	opts = opts or {}
	local min = opts.Min or 0
	local max = opts.Max or 100
	local step = opts.Increment or opts.Step or 1
	local default = math.clamp(opts.Default or min, min, max)
	local fmt = opts.Format or tostring

	local accent = self._tab._window.Accent

	local row = make("Frame", {
		Name = "SliderRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 38),
	})

	make("TextLabel", {
		Name = "Name",
		BackgroundTransparency = 1,
		FontFace = FONT,
		Position = UDim2.new(0, 9, 0, 2),
		Size = UDim2.new(1, -18, 0, 14),
		Text = opts.Name or "Slider",
		TextColor3 = palette.muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local valueLbl = make("TextLabel", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		FontFace = FONT,
		Position = UDim2.new(1, -9, 0, 2),
		Size = UDim2.fromOffset(80, 14),
		Text = fmt(default),
		TextColor3 = palette.muted,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})

	local bar = make("Frame", {
		Name = "Bar",
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = palette.barBg,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 9, 1, -6),
		Size = UDim2.new(1, -18, 0, 7),
		Parent = row,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = bar })
	make("UIStroke", { Color = palette.barStroke, Parent = bar })

	local fill = make("Frame", {
		Name = "Fill",
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0, 1),
		Parent = bar,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
	make("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, accent),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 165, 100)),
		}),
		Parent = fill,
	})

	-- Taller hit box than the bar so dragging feels forgiving.
	local hit = make("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0.5, -9),
		Size = UDim2.new(1, 0, 0, 18),
		Text = "",
		Parent = bar,
	})

	local self_ = setmetatable({
		_value    = default,
		_min      = min,
		_max      = max,
		_step     = step,
		_cb       = opts.Callback,
		_fmt      = fmt,
		_fill     = fill,
		_valueLbl = valueLbl,
	}, Slider)

	local dragging = false
	local function updateFromX(x)
		local f = fractionAt(bar, x)
		self_:_apply(min + f * (max - min), false, false)
	end

	hit.MouseButton1Down:Connect(function()
		dragging = true
		play(fill, FAST, { BackgroundColor3 = accent:Lerp(Color3.new(1, 1, 1), 0.08) })
		updateFromX(UserInputService:GetMouseLocation().X)
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			play(fill, FAST, { BackgroundColor3 = accent })
		end
	end)

	self_:_apply(default, true, false)
	row.Parent = self._holder
	return self_
end


local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(opts)
	opts = opts or {}
	local side = opts.Side == "Right" and "Right" or "Left"

	-- Layout order interleaves Left/Right so two columns line up cleanly.
	local order
	if side == "Left" then
		self._leftCount += 1
		order = (self._leftCount - 1) * 2
	else
		self._rightCount += 1
		order = (self._rightCount - 1) * 2 + 1
	end

	local frame = make("Frame", {
		Name = "Section_" .. side,
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = palette.section,
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Size = UDim2.fromOffset(341, 0),
	})
	make("UICorner", { CornerRadius = UDim.new(0, 6), Parent = frame })
	make("UIStroke", { Color = palette.secStroke, Parent = frame })

	local header = make("Frame", {
		Name = "Header",
		BackgroundColor3 = palette.secHeader,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 30),
		Parent = frame,
	})
	make("Frame", {
		Name = "Liner",
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = palette.liner,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = header,
	})
	make("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		FontFace = FONT,
		Position = UDim2.new(0, 9, 0.5, 0),
		Size = UDim2.fromOffset(1, 1),
		Text = opts.Name or "Section",
		TextColor3 = palette.text,
		TextSize = 14,
		Parent = header,
	})

	local holder = make("Frame", {
		Name = "Items",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 30),
		Size = UDim2.new(1, 0, 0, 0),
		Parent = frame,
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
		Parent = holder,
	})

	frame.Parent = self._container
	return setmetatable({
		_tab    = self,
		_frame  = frame,
		_holder = holder,
		_side   = side,
	}, Section)
end


local Window = {}
Window.__index = Window

function Window:_resolveCenterX(tab)
	local wrapX = self._tabsWrap.AbsolutePosition.X
	local tabX = tab._holder.AbsolutePosition.X
	if tabX > 0 then
		return (tabX + tab._holder.AbsoluteSize.X * 0.5) - wrapX
	end
	-- Geometry fallback before layout has solved.
	return TABS_LPAD + (tab._index - 1) * (TAB_W + TAB_GAP) + TAB_W * 0.5
end

function Window:_moveIndicator(tab, animate)
	local x = self:_resolveCenterX(tab)
	local target = UDim2.new(0, x, 1, 15)
	if animate then
		play(self._indicator, MED, { Position = target })
	else
		self._indicator.Position = target
	end
end

function Window:SelectTab(index)
	local next_ = self._tabs[index]
	if not next_ or self._selected == index then return end

	local prev = self._tabs[self._selected]
	if prev then
		play(prev._image, FAST, { ImageColor3 = palette.idle })
		local page = prev._page
		play(page, FAST, { GroupTransparency = 1 })
		task.delay(0.16, function()
			if self._selected ~= prev._index then
				page.Visible = false
			end
		end)
	end

	next_._page.GroupTransparency = 1
	next_._page.Visible = true
	play(next_._page, FAST, { GroupTransparency = 0 })
	play(next_._image, FAST, { ImageColor3 = self.Accent })

	self._selected = index
	self:_moveIndicator(next_, prev ~= nil)
end

function Window:CreateTab(opts)
	opts = opts or {}
	local index = #self._tabs + 1

	local holder = make("Frame", {
		Name = "Tab" .. index,
		BackgroundTransparency = 1,
		LayoutOrder = index,
		Size = UDim2.fromOffset(TAB_W, TAB_H),
		Parent = self._tabsList,
	})

	local image = make("ImageButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Image = opts.Icon or "",
		ImageColor3 = palette.idle,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(30, 30),
		ZIndex = 5,
		Parent = holder,
	})

	local page = make("CanvasGroup", {
		Name = "Page" .. index,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		GroupTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = self._pages,
	})

	local scroller = make("ScrollingFrame", {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		BottomImage = "",
		CanvasSize = UDim2.new(),
		Position = UDim2.fromScale(0.5, 0.5),
		ScrollBarImageColor3 = self.Accent,
		ScrollBarThickness = 4,
		Size = UDim2.new(1, -16, 1, -20),
		TopImage = "",
		Parent = page,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Wraps = true,
		Parent = scroller,
	})
	make("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 10),
		PaddingRight = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		Parent = scroller,
	})

	local tab = setmetatable({
		_window      = self,
		_index       = index,
		_holder      = holder,
		_image       = image,
		_page        = page,
		_container   = scroller,
		_leftCount   = 0,
		_rightCount  = 0,
	}, Tab)

	self._tabs[index] = tab

	image.MouseButton1Click:Connect(function()
		self:SelectTab(index)
	end)
	image.MouseEnter:Connect(function()
		if self._selected ~= index then
			play(image, FAST, { ImageColor3 = palette.hover })
		end
	end)
	image.MouseLeave:Connect(function()
		if self._selected ~= index then
			play(image, FAST, { ImageColor3 = palette.idle })
		end
	end)

	if index == 1 then
		task.spawn(function()
			RunService.Heartbeat:Wait()
			RunService.Heartbeat:Wait()
			self:SelectTab(1)
		end)
	end

	return tab
end


local ElectroLib = {}

function ElectroLib:CreateWindow(opts)
	opts = opts or {}
	local accent = opts.Accent or palette.accent

	local gui = make("ScreenGui", {
		Name = "ElectroLib",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	})

	local root = make("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = palette.window,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(747, 594),
		Parent = gui,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = root })

	local headerWrap = make("Frame", {
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 69),
		Parent = root,
	})

	local header = make("Frame", {
		Name = "Header",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = palette.header,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 64),
		Parent = headerWrap,
	})
	make("UICorner", { CornerRadius = UDim.new(0, 14), Parent = header })

	local brand = make("Frame", {
		Name = "Brand",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(131, 73),
		Parent = header,
	})
	make("ImageLabel", {
		Name = "BrandGlow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://95531037500951",
		Position = UDim2.fromScale(0.377863, 0.541096),
		Size = UDim2.fromOffset(195, 197),
		Parent = brand,
	})
	make("ImageLabel", {
		Name = "Logo",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = opts.Logo or "rbxassetid://128573523116063",
		Position = UDim2.fromScale(-0.0992366, 0.541096),
		Size = UDim2.fromOffset(69, 41),
		Parent = brand,
	})
	make("TextLabel", {
		Name = "Title",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		FontFace = FONT_BOLD,
		Position = UDim2.fromScale(0.847328, 0.541096),
		Size = UDim2.fromOffset(55, 37),
		Text = opts.Title or "ELECTRO.FUN",
		TextColor3 = palette.brand,
		TextSize = 15,
		Parent = brand,
	})

	local tabsWrap = make("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.215894, 0),
		Size = UDim2.fromOffset(437, 64),
		Parent = header,
	})

	local initX = TABS_LPAD + TAB_W * 0.5

	local tabsList = make("Frame", {
		Name = "TabsList",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = tabsWrap,
	})
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, TAB_GAP),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabsList,
	})
	make("UIPadding", {
		PaddingLeft = UDim.new(0, TABS_LPAD),
		PaddingTop = UDim.new(0, 5),
		Parent = tabsList,
	})

	local indicator = make("Frame", {
		Name = "Indicator",
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = accent,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = UDim2.new(0, initX, 1, 15),
		Size = UDim2.fromOffset(40, 21),
		ZIndex = 4,
		Parent = tabsWrap,
	})
	make("UICorner", { CornerRadius = UDim.new(1, 0), Parent = indicator })
	make("ImageLabel", {
		Name = "Glow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://83933299080110",
		ImageColor3 = Color3.fromRGB(255, 170, 110),
		ImageTransparency = 0.15,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(70, 34),
		Parent = indicator,
	})

	local pages = make("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 0, 0, 69),
		Size = UDim2.new(1, 0, 1, -69),
		Parent = root,
	})

	local window = setmetatable({
		Accent     = accent,
		_gui       = gui,
		_root      = root,
		_header    = header,
		_tabsWrap  = tabsWrap,
		_tabsList  = tabsList,
		_indicator = indicator,
		_pages     = pages,
		_tabs      = {},
		_selected  = 0,
	}, Window)

	gui.Parent = host()
	return window
end

return ElectroLib
