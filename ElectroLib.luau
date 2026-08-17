local getgenv = getgenv or function() return _G end
local cloneref = cloneref or function(obj) return obj end

if getgenv().StellarLib then
    getgenv().StellarLib:Unload()
end

local Stellar = {}
Stellar.__index = Stellar

local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = cloneref(game:GetService("CoreGui"))

local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

Stellar.Flags = {}
Stellar.Connections = {}
Stellar.Threads = {}
Stellar.Tabs = {}

local isTouch = UserInputService.TouchEnabled
local isKeyboard = UserInputService.KeyboardEnabled

Stellar.IsMobile = (isTouch and not isKeyboard) or (UserInputService:GetPlatform() == Enum.Platform.Android or UserInputService:GetPlatform() == Enum.Platform.IOS)
Stellar.Platform = Stellar.IsMobile and "Mobile" or "PC"

local FadeProps = {
    Frame = { "BackgroundTransparency" },
    ScrollingFrame = { "BackgroundTransparency" },
    TextLabel = { "BackgroundTransparency", "TextTransparency" },
    TextButton = { "BackgroundTransparency", "TextTransparency" },
    TextBox = { "BackgroundTransparency", "TextTransparency" },
    ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
    ImageButton = { "BackgroundTransparency", "ImageTransparency" },
    UIStroke = { "Transparency" }
}

local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local listfiles = listfiles or function() return {} end
local delfile = delfile or function() end

local CONFIG_DIR = "stellar_configs"
pcall(function()
    if makefolder and isfolder and not isfolder(CONFIG_DIR) then
        makefolder(CONFIG_DIR)
    end
end)

function Stellar:GetConfigPath(name)
    return CONFIG_DIR .. "/" .. tostring(name):gsub("[^%w_%-]", "") .. ".json"
end

function Stellar:SaveConfig(name)
    if not writefile then return false, "FileSystem not supported" end
    local cleanName = tostring(name or "default"):gsub("[^%w_%-]", "")
    if cleanName == "" then return false, "Invalid config name" end

    local exportData = {}
    for flagName, flagValue in pairs(self.Flags) do
        local valType = typeof(flagValue)
        if valType == "Color3" then
            exportData[flagName] = { __type = "Color3", r = flagValue.R, g = flagValue.G, b = flagValue.B }
        elseif valType == "table" and flagValue.Color and typeof(flagValue.Color) == "Color3" then
            exportData[flagName] = {
                __type = "ColorPicker",
                r = flagValue.Color.R,
                g = flagValue.Color.G,
                b = flagValue.Color.B,
                alpha = flagValue.Alpha or 0
            }
        elseif valType == "table" and flagValue.Key and flagValue.Mode then
            exportData[flagName] = {
                __type = "Keybind",
                key = flagValue.Key,
                mode = flagValue.Mode,
                toggled = flagValue.Toggled or false
            }
        elseif valType == "number" or valType == "boolean" or valType == "string" or valType == "table" then
            exportData[flagName] = flagValue
        end
    end

    local encoded = HttpService:JSONEncode(exportData)
    local ok, err = pcall(function()
        if makefolder and isfolder and not isfolder(CONFIG_DIR) then
            makefolder(CONFIG_DIR)
        end
        writefile(self:GetConfigPath(cleanName), encoded)
    end)
    return ok, err
end

function Stellar:LoadConfig(name, elementsMap)
    if not readfile or not isfile then return false, "FileSystem not supported" end
    local cleanName = tostring(name or "default"):gsub("[^%w_%-]", "")
    local path = self:GetConfigPath(cleanName)
    if not isfile(path) then return false, "Config file does not exist" end

    local ok, content = pcall(readfile, path)
    if not ok or not content or content == "" then return false, "Failed to read file" end

    local decodeOk, rawData = pcall(function() return HttpService:JSONDecode(content) end)
    if not decodeOk or typeof(rawData) ~= "table" then return false, "Corrupted config" end

    for flagName, flagVal in pairs(rawData) do
        if typeof(flagVal) == "table" and flagVal.__type then
            if flagVal.__type == "Color3" then
                self.Flags[flagName] = Color3.new(flagVal.r, flagVal.g, flagVal.b)
            elseif flagVal.__type == "ColorPicker" then
                self.Flags[flagName] = {
                    Color = Color3.new(flagVal.r, flagVal.g, flagVal.b),
                    Alpha = flagVal.alpha or 0,
                    HexValue = Color3.new(flagVal.r, flagVal.g, flagVal.b):ToHex(),
                    Transparency = 1 - (flagVal.alpha or 0)
                }
            elseif flagVal.__type == "Keybind" then
                self.Flags[flagName] = {
                    Key = flagVal.key,
                    Mode = flagVal.mode,
                    Toggled = flagVal.toggled or false
                }
            end
        else
            self.Flags[flagName] = flagVal
        end

        if elementsMap and elementsMap[flagName] and elementsMap[flagName].Set then
            pcall(function()
                elementsMap[flagName].Set(self.Flags[flagName])
            end)
        end
    end
    return true
end

function Stellar:DeleteConfig(name)
    if not delfile or not isfile then return false, "FileSystem not supported" end
    local path = self:GetConfigPath(name)
    if not isfile(path) then return false, "Config not found" end
    local ok, err = pcall(delfile, path)
    return ok, err
end

function Stellar:GetConfigs()
    local list = {}
    if not listfiles or not isfolder or not isfolder(CONFIG_DIR) then return list end
    local files = listfiles(CONFIG_DIR) or {}
    for _, file in ipairs(files) do
        local name = file:match("([^/\\]+)%.json$")
        if name then
            table.insert(list, name)
        end
    end
    return list
end

local OrangeGradientSequence = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 165, 50)),
    ColorSequenceKeypoint.new(0.32, Color3.fromRGB(230, 140, 40)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(200, 115, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 15))
})

local OrangeGlowSequence = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 160, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 125, 35))
})

local FontSemiBold, FontBold do
    local isfile = isfile or function() return false end
    local writefile = writefile or function() end
    local getcustomasset = getcustomasset or function() return "" end

    local loadedFont
    if isfile and writefile and getcustomasset then
        pcall(function()
            if not isfile("OutfitMedium.ttf") then
                writefile("OutfitMedium.ttf", game:HttpGet("https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/Outfit-Medium.ttf"))
            end
            local fontData = {
                name = "OutfitMedium",
                faces = {
                    {
                        name = "Regular",
                        weight = 400,
                        style = "normal",
                        assetId = getcustomasset("OutfitMedium.ttf")
                    }
                }
            }
            writefile("OutfitMedium.font", HttpService:JSONEncode(fontData))
            loadedFont = Font.new(getcustomasset("OutfitMedium.font"))
        end)
    end

    if not loadedFont then
        pcall(function()
            loadedFont = Font.fromEnum(Enum.Font.GothamMedium)
        end)
    end

    if loadedFont then
        FontSemiBold = loadedFont
        FontBold = loadedFont
    else
        FontSemiBold = Font.fromEnum(Enum.Font.GothamBold)
        FontBold = Font.fromEnum(Enum.Font.GothamBold)
    end
end

function Stellar:Thread(fn)
    local thread = coroutine.create(fn)
    coroutine.resume(thread)
    table.insert(self.Threads, thread)
    return thread
end

function Stellar:SafeCall(fn, ...)
    local args = {...}
    local success, result = pcall(fn, table.unpack(args))
    if not success then
        warn("[Stellar Error]:", result)
    end
    return success, result
end

function Stellar:Connect(event, callback)
    local conn = event:Connect(callback)
    table.insert(self.Connections, conn)
    return conn
end

function Stellar:Tween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

function Stellar:FadeGroup(root, shown, duration)
    local info = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local targets = root:GetDescendants()
    table.insert(targets, root)

    for _, obj in ipairs(targets) do
        local props = FadeProps[obj.ClassName]
        if props then
            local goals = {}

            for _, prop in ipairs(props) do
                local key = "stellarFade" .. prop
                local saved = obj:GetAttribute(key)

                if saved == nil then
                    saved = obj[prop]
                    obj:SetAttribute(key, saved)
                end

                goals[prop] = shown and saved or 1
            end

            self:Tween(obj, info, goals)
        end
    end
end

function Stellar:MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging = false
    local dragStart, startPos

    local function setPosition(input)
        local dragDelta = input.Position - dragStart
        local newX = startPos.X.Offset + dragDelta.X
        local newY = startPos.Y.Offset + dragDelta.Y

        local parentSize = gui.Parent and gui.Parent.AbsoluteSize or Vector2.new(1920, 1080)
        local guiSize = gui.AbsoluteSize

        -- Allow pushing UI mostly off-screen horizontally and vertically while keeping a grab edge
        newX = math.clamp(newX, -guiSize.X + 40, parentSize.X - 40)
        newY = math.clamp(newY, -guiSize.Y + 40, parentSize.Y - 30)

        self:Tween(gui, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, newX, 0, newY)
        })
    end

    local inputChangedConn

    self:Connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            if inputChangedConn then return end

            inputChangedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if inputChangedConn then
                        inputChangedConn:Disconnect()
                        inputChangedConn = nil
                    end
                end
            end)
        end
    end)

    self:Connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setPosition(input)
        end
    end)
end

function Stellar:Unload()
    for _, conn in ipairs(self.Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    for _, thread in ipairs(self.Threads) do
        if thread then
            coroutine.close(thread)
        end
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    if self.WatermarkFrame then
        self.WatermarkFrame:Destroy()
    end
    if self.NotificationHolder then
        self.NotificationHolder:Destroy()
    end
    getgenv().StellarLib = nil
end

function Stellar:Notify(options)
    options = typeof(options) == "table" and options or { Title = tostring(options) }
    local titleText = options.Title or "Notification"
    local descText = options.Content or options.Description or ""
    local duration = options.Duration or 4
    local notifType = options.Type or "Success"
    local accentColor = options.Color or (notifType == "Warning" and Color3.fromRGB(255, 214, 10) or Color3.fromRGB(47, 255, 0))
    local iconAsset = options.Icon or (notifType == "Warning" and "rbxassetid://70479764730792" or "rbxassetid://92431556586885")

    local width = 300
    local margin = 12

    if not self.ScreenGui or not self.ScreenGui.Parent then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "stellar"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = gethui()
        self.ScreenGui = screenGui
    end

    if not self.NotificationHolder or not self.NotificationHolder.Parent then
        local queue = Instance.new("Frame")
        queue.Name = "NotificationHolder"
        queue.BackgroundTransparency = 1
        queue.AnchorPoint = Vector2.new(1, 0)
        queue.Position = UDim2.new(1, -margin, 0, margin)
        queue.Size = UDim2.fromOffset(width, 0)
        queue.AutomaticSize = Enum.AutomaticSize.Y
        queue.ZIndex = 200
        queue.Parent = self.ScreenGui

        local stack = Instance.new("UIListLayout")
        stack.Padding = UDim.new(0, 8)
        stack.SortOrder = Enum.SortOrder.LayoutOrder
        stack.HorizontalAlignment = Enum.HorizontalAlignment.Right
        stack.Parent = queue

        self.NotificationHolder = queue
    end

    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundTransparency = 1
    notification.ClipsDescendants = true
    notification.Size = UDim2.new(1, 0, 0, 30)
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.ZIndex = 201
    notification.Parent = self.NotificationHolder

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
    body.ClipsDescendants = true
    body.Position = UDim2.new(1, 0, 0, 0)
    body.Size = UDim2.new(1, 0, 0, 30)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.ZIndex = 201
    body.Parent = notification

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = body

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = body

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundTransparency = 1
    header.LayoutOrder = 1
    header.Size = UDim2.new(1, 0, 0, 38)
    header.Parent = body

    local row = Instance.new("Frame")
    row.Name = "Row"
    row.BackgroundTransparency = 1
    row.Size = UDim2.new(1, 0, 1, 0)
    row.Parent = header

    local rowPadding = Instance.new("UIPadding")
    rowPadding.PaddingLeft = UDim.new(0, 10)
    rowPadding.PaddingRight = UDim.new(0, 10)
    rowPadding.PaddingTop = UDim.new(0, 6)
    rowPadding.PaddingBottom = UDim.new(0, 6)
    rowPadding.Parent = row

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Padding = UDim.new(0, 8)
    rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rowLayout.Parent = row

    local iconBox = Instance.new("Frame")
    iconBox.Name = "IconBox"
    iconBox.BackgroundTransparency = 1
    iconBox.LayoutOrder = 1
    iconBox.Size = UDim2.fromOffset(26, 26)
    iconBox.Parent = row

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = iconAsset
    icon.ImageColor3 = accentColor
    icon.Position = UDim2.fromScale(0.5, 0.5)
    icon.Size = UDim2.fromOffset(20, 20)
    icon.Parent = iconBox

    local titleBox = Instance.new("Frame")
    titleBox.Name = "TitleBox"
    titleBox.BackgroundTransparency = 1
    titleBox.LayoutOrder = 2
    titleBox.Size = UDim2.new(1, -34, 1, 0)
    titleBox.Parent = row

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.FontFace = FontBold
    title.RichText = true
    title.Size = UDim2.fromScale(1, 1)
    title.Text = titleText
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = titleBox

    if descText ~= "" or options.Buttons then
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.LayoutOrder = 2
        content.Size = UDim2.new(1, 0, 0, 0)
        content.Parent = body

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = content

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.PaddingLeft = UDim.new(0, 12)
        contentPadding.PaddingRight = UDim.new(0, 12)
        contentPadding.PaddingTop = UDim.new(0, 2)
        contentPadding.Parent = content

        if descText ~= "" then
            local descBox = Instance.new("Frame")
            descBox.Name = "DescBox"
            descBox.AutomaticSize = Enum.AutomaticSize.Y
            descBox.BackgroundTransparency = 1
            descBox.LayoutOrder = 1
            descBox.Size = UDim2.new(1, 0, 0, 0)
            descBox.Parent = content

            local desc = Instance.new("TextLabel")
            desc.Name = "Desc"
            desc.AutomaticSize = Enum.AutomaticSize.Y
            desc.BackgroundTransparency = 1
            desc.FontFace = FontSemiBold
            desc.RichText = true
            desc.Size = UDim2.new(1, 0, 0, 0)
            desc.Text = descText
            desc.TextColor3 = Color3.fromRGB(120, 125, 145)
            desc.TextSize = 13
            desc.TextWrapped = true
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = descBox
        end

        if options.Buttons then
            local actions = Instance.new("Frame")
            actions.Name = "Actions"
            actions.AutomaticSize = Enum.AutomaticSize.Y
            actions.BackgroundTransparency = 1
            actions.LayoutOrder = 2
            actions.Size = UDim2.new(1, 0, 0, 0)
            actions.Parent = content

            local actionsLayout = Instance.new("UIListLayout")
            actionsLayout.FillDirection = Enum.FillDirection.Horizontal
            actionsLayout.Padding = UDim.new(0, 8)
            actionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            actionsLayout.Parent = actions

            local actionsPadding = Instance.new("UIPadding")
            actionsPadding.PaddingLeft = UDim.new(0, 24)
            actionsPadding.Parent = actions

            for index, action in ipairs(options.Buttons) do
                local button = Instance.new("Frame")
                button.Name = "Button"
                button.AutomaticSize = Enum.AutomaticSize.XY
                button.BackgroundColor3 = action.Primary and accentColor or Color3.fromRGB(66, 68, 86)
                button.BackgroundTransparency = action.Primary and 0.90 or 1
                button.LayoutOrder = index
                button.Size = UDim2.fromOffset(0, 0)
                button.Parent = actions

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 6)
                buttonCorner.Parent = button

                if not action.Primary then
                    local buttonStroke = Instance.new("UIStroke")
                    buttonStroke.Color = Color3.fromRGB(66, 68, 86)
                    buttonStroke.Parent = button
                end

                local buttonLabel = Instance.new("TextLabel")
                buttonLabel.Name = "ButtonText"
                buttonLabel.AutomaticSize = Enum.AutomaticSize.XY
                buttonLabel.BackgroundTransparency = 1
                buttonLabel.FontFace = FontSemiBold
                buttonLabel.Size = UDim2.fromOffset(0, 0)
                buttonLabel.Text = action.Name or "Button"
                buttonLabel.TextColor3 = action.Primary and accentColor or Color3.fromRGB(160, 165, 185)
                buttonLabel.TextSize = 13
                buttonLabel.Parent = button

                local labelPadding = Instance.new("UIPadding")
                labelPadding.PaddingBottom = UDim.new(0, 5)
                labelPadding.PaddingLeft = UDim.new(0, 10)
                labelPadding.PaddingRight = UDim.new(0, 10)
                labelPadding.PaddingTop = UDim.new(0, 5)
                labelPadding.Parent = buttonLabel

                local hitbox = Instance.new("TextButton")
                hitbox.Name = "Hitbox"
                hitbox.BackgroundTransparency = 1
                hitbox.Size = UDim2.fromScale(1, 1)
                hitbox.Text = ""
                hitbox.ZIndex = 10
                hitbox.Parent = button

                local function activate()
                    if action.Callback then
                        self:SafeCall(action.Callback)
                    end
                    notification:Destroy()
                end

                self:Connect(hitbox.MouseButton1Click, activate)
                self:Connect(hitbox.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        activate()
                    end
                end)
            end
        end
    end

    local track = Instance.new("Frame")
    track.Name = "ProgressTrack"
    track.BackgroundColor3 = Color3.fromRGB(19, 20, 25)
    track.LayoutOrder = 3
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Parent = body

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = accentColor
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill

    local dismissing = false
    local function dismiss()
        if dismissing then return end
        dismissing = true

        notification.Size = UDim2.new(1, 0, 0, notification.AbsoluteSize.Y)
        notification.AutomaticSize = Enum.AutomaticSize.None

        self:Tween(body, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 0)
        })
        local collapse = self:Tween(notification, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0)
        })
        collapse.Completed:Wait()
        if notification and notification.Parent then
            notification:Destroy()
        end
    end

    -- sits on the header, not the body: body auto-sizes off its list layout, so a
    -- full-height child there would feed its own height back in and grow forever
    local dismissArea = Instance.new("TextButton")
    dismissArea.Name = "DismissArea"
    dismissArea.BackgroundTransparency = 1
    dismissArea.Size = UDim2.fromScale(1, 1)
    dismissArea.Text = ""
    dismissArea.ZIndex = 205
    dismissArea.Parent = header

    self:Connect(dismissArea.MouseButton1Click, dismiss)
    self:Connect(dismissArea.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dismiss()
        end
    end)

    self:Tween(body, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    })

    task.spawn(function()
        self:Tween(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 1, 0)
        })
        task.wait(duration)
        if notification and notification.Parent and not dismissing then
            dismiss()
        end
    end)

    return notification
end
Stellar.Notification = Stellar.Notify

function Stellar:CreateKeybindList(options)
    options = typeof(options) == "table" and options or { Title = tostring(options or "Keybinds") }
    local listTitle = options.Title or "Keybinds"
    local listIcon = options.Icon or "rbxassetid://81598136527047"
    local listWidth = options.Width or 170

    if not self.ScreenGui or not self.ScreenGui.Parent then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "stellar"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = gethui()
        self.ScreenGui = screenGui
    end

    local panel = Instance.new("Frame")
    panel.Name = "KeybindList"
    panel.AnchorPoint = Vector2.new(0, 0.5)
    panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    panel.BackgroundTransparency = 0.3
    panel.Position = UDim2.new(0, 20, 0.5, 20)
    panel.Size = UDim2.fromOffset(listWidth, 0)
    panel.ZIndex = 40
    panel.Parent = self.ScreenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 6)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    panelStroke.Color = Color3.fromRGB(24, 24, 24)
    panelStroke.Parent = panel

    local panelLayout = Instance.new("UIListLayout")
    panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    panelLayout.Parent = panel

    local top = Instance.new("Frame")
    top.Name = "top"
    top.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    top.LayoutOrder = 1
    top.Size = UDim2.new(1, 0, 0, 34)
    top.ZIndex = 41
    top.Parent = panel

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 6)
    topCorner.Parent = top

    local topIcon = Instance.new("ImageLabel")
    topIcon.Name = "icon"
    topIcon.AnchorPoint = Vector2.new(0, 0.5)
    topIcon.BackgroundTransparency = 1
    topIcon.Image = listIcon
    topIcon.Position = UDim2.new(0, 10, 0.5, 0)
    topIcon.Size = UDim2.fromOffset(18, 18)
    topIcon.ZIndex = 42
    topIcon.Parent = top

    local iconGradient = Instance.new("UIGradient")
    iconGradient.Color = OrangeGradientSequence
    iconGradient.Rotation = 90
    iconGradient.Parent = topIcon

    local topTitle = Instance.new("TextLabel")
    topTitle.Name = "title"
    topTitle.AnchorPoint = Vector2.new(0, 0.5)
    topTitle.BackgroundTransparency = 1
    topTitle.FontFace = FontBold
    topTitle.Position = UDim2.new(0, 36, 0.5, 0)
    topTitle.Size = UDim2.new(1, -46, 0, 15)
    topTitle.Text = listTitle
    topTitle.TextColor3 = Color3.fromRGB(248, 248, 248)
    topTitle.TextSize = 14
    topTitle.TextTruncate = Enum.TextTruncate.AtEnd
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.ZIndex = 42
    topTitle.Parent = top

    local topSep = Instance.new("Frame")
    topSep.Name = "sep"
    topSep.AnchorPoint = Vector2.new(0, 1)
    topSep.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    topSep.BorderSizePixel = 0
    topSep.Position = UDim2.new(0, 0, 1, 0)
    topSep.Size = UDim2.new(1, 0, 0, 1)
    topSep.ZIndex = 43
    topSep.Parent = top

    local content = Instance.new("Frame")
    content.Name = "content"
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.LayoutOrder = 2
    content.Size = UDim2.new(1, 0, 0, 0)
    content.ZIndex = 41
    content.Parent = panel

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 4)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 8)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = content

    task.spawn(function()
        task.wait()
        local absPos = panel.AbsolutePosition
        panel.AnchorPoint = Vector2.new(0, 0)
        panel.Position = UDim2.fromOffset(absPos.X, absPos.Y)
    end)

    self:MakeDraggable(panel, top)

    local motion = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local listObj = {
        Frame = panel,
        Entries = {}
    }

    function listObj:Add(name, keyText)
        local row = Instance.new("Frame")
        row.Name = "entry"
        row.BackgroundTransparency = 1
        row.LayoutOrder = #listObj.Entries + 1
        row.Size = UDim2.new(1, 0, 0, 20)
        row.ZIndex = 42
        row.Parent = content

        local dot = Instance.new("Frame")
        dot.Name = "dot"
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BackgroundTransparency = 1
        dot.Position = UDim2.new(0, 0, 0.5, 0)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.ZIndex = 43
        dot.Parent = row

        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(0, 999)
        dotCorner.Parent = dot

        local dotGradient = Instance.new("UIGradient")
        dotGradient.Color = OrangeGradientSequence
        dotGradient.Rotation = -115
        dotGradient.Parent = dot

        local rowLabel = Instance.new("TextLabel")
        rowLabel.Name = "label"
        rowLabel.AnchorPoint = Vector2.new(0, 0.5)
        rowLabel.BackgroundTransparency = 1
        rowLabel.FontFace = FontSemiBold
        rowLabel.Position = UDim2.new(0, 0, 0.5, 0)
        rowLabel.Size = UDim2.new(1, -14, 0, 15)
        rowLabel.Text = name .. " [" .. tostring(keyText) .. "]"
        rowLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
        rowLabel.TextSize = 14
        rowLabel.TextTransparency = 0.3
        rowLabel.TextTruncate = Enum.TextTruncate.AtEnd
        rowLabel.TextXAlignment = Enum.TextXAlignment.Left
        rowLabel.ZIndex = 43
        rowLabel.Parent = row

        local entry = {
            Name = name,
            Key = keyText,
            Frame = row
        }

        function entry:Set(newName, newKey)
            entry.Name = newName or entry.Name
            entry.Key = newKey or entry.Key
            rowLabel.Text = entry.Name .. " [" .. tostring(entry.Key) .. "]"
        end

        function entry:SetStatus(active)
            if active then
                Stellar:Tween(dot, motion, { BackgroundTransparency = 0 })
                Stellar:Tween(rowLabel, motion, {
                    Position = UDim2.new(0, 15, 0.5, 0),
                    TextTransparency = 0
                })
            else
                Stellar:Tween(dot, motion, { BackgroundTransparency = 1 })
                Stellar:Tween(rowLabel, motion, {
                    Position = UDim2.new(0, 0, 0.5, 0),
                    TextTransparency = 0.3
                })
            end
        end

        function entry:Remove()
            row:Destroy()
            local at = table.find(listObj.Entries, entry)
            if at then
                table.remove(listObj.Entries, at)
            end
        end

        table.insert(listObj.Entries, entry)
        return entry
    end

    function listObj:SetVisible(state)
        panel.Visible = state
    end

    self.KeyList = listObj
    return listObj
end

function Stellar:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "stellar"
    local menuKey = options.Keybind or Enum.KeyCode.RightShift
    local logoAsset = options.Logo or "rbxassetid://71540167635901"

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "stellar"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = gethui()
    self.ScreenGui = screenGui

    local mainUI = Instance.new("Frame")
    mainUI.Name = "ui"
    mainUI.AnchorPoint = Vector2.new(0.5, 0.5)
    mainUI.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    mainUI.Position = UDim2.fromScale(0.5, 0.5)
    mainUI.Size = UDim2.fromOffset(681, 480)
    mainUI.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainUI

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = mainUI

    local isMobile = self.IsMobile
    local baseScale = 1

    local function refitScale()
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
        local targetRatio = isMobile and 0.72 or 0.94
        local fit = math.min((viewport.X * targetRatio) / 681, (viewport.Y * (isMobile and 0.72 or 0.90)) / 480, 1)
        baseScale = math.max(fit, isMobile and 0.30 or 0.45)
        uiScale.Scale = baseScale
    end

    refitScale()

    if Workspace.CurrentCamera then
        self:Connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), refitScale)
    end

    task.spawn(function()
        task.wait()
        local absPos = mainUI.AbsolutePosition
        mainUI.AnchorPoint = Vector2.new(0, 0)
        mainUI.Position = UDim2.fromOffset(absPos.X, absPos.Y)
    end)

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "tabcontainer"
    tabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    tabContainer.Position = UDim2.fromScale(0, 0)
    tabContainer.Size = UDim2.fromScale(0.120609, 1)
    tabContainer.Parent = mainUI

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer

    local sidebarLogo = Instance.new("ImageLabel")
    sidebarLogo.Name = "SidebarLogo"
    sidebarLogo.AnchorPoint = Vector2.new(0.5, 0)
    sidebarLogo.BackgroundTransparency = 1
    sidebarLogo.Image = logoAsset
    sidebarLogo.Position = UDim2.new(0.5, 0, 0, 10)
    sidebarLogo.Size = UDim2.fromOffset(45, 45)
    sidebarLogo.ScaleType = Enum.ScaleType.Fit
    sidebarLogo.ZIndex = 3
    sidebarLogo.Parent = tabContainer

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "list"
    tabList.Active = true
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.BackgroundTransparency = 1
    tabList.CanvasSize = UDim2.new()
    tabList.ScrollBarThickness = 0
    tabList.Position = UDim2.fromOffset(0, 65)
    tabList.Size = UDim2.new(1, 0, 1, -75)
    tabList.ZIndex = 2
    tabList.Parent = tabContainer

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabListLayout.Padding = UDim.new(0, 11)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    tabListLayout.Parent = tabList

    local tabSep = Instance.new("Frame")
    tabSep.Name = "sep"
    tabSep.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    tabSep.BorderSizePixel = 0
    tabSep.Position = UDim2.fromScale(1, 0)
    tabSep.Size = UDim2.new(0, 1, 1, 0)
    tabSep.ZIndex = 2
    tabSep.Parent = tabContainer

    local topHeader = Instance.new("Frame")
    topHeader.Name = "frame3"
    topHeader.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
    topHeader.Position = UDim2.fromScale(0.121809, 0)
    topHeader.Size = UDim2.fromScale(0.878191, 0.0940516)
    topHeader.Parent = mainUI

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 6)
    headerCorner.Parent = topHeader

    local headerSep = Instance.new("Frame")
    headerSep.Name = "sep"
    headerSep.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    headerSep.BorderSizePixel = 0
    headerSep.Position = UDim2.fromOffset(-1, 43)
    headerSep.Size = UDim2.new(1.001, 0, 0, 1)
    headerSep.ZIndex = 2
    headerSep.Parent = topHeader

    local subTabHolder = Instance.new("Frame")
    subTabHolder.Name = "subtab"
    subTabHolder.BackgroundTransparency = 1
    subTabHolder.Position = UDim2.fromOffset(14, 10)
    subTabHolder.Size = UDim2.new(0.60, 0, 0, 24)
    subTabHolder.ZIndex = 2
    subTabHolder.Parent = topHeader

    local subTabLayout = Instance.new("UIListLayout")
    subTabLayout.FillDirection = Enum.FillDirection.Horizontal
    subTabLayout.Padding = UDim.new(0, 10)
    subTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subTabLayout.Parent = subTabHolder

    local searchBox = Instance.new("TextBox")
    searchBox.Name = "search"
    searchBox.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
    searchBox.FontFace = FontSemiBold
    searchBox.PlaceholderColor3 = Color3.fromRGB(124, 124, 125)
    searchBox.PlaceholderText = "Search for a feature"
    searchBox.Position = UDim2.fromOffset(420, 12)
    searchBox.Size = UDim2.fromOffset(166, 26)
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 14
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ZIndex = 10
    searchBox.Parent = topHeader

    local searchStroke = Instance.new("UIStroke")
    searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    searchStroke.Color = Color3.fromRGB(24, 24, 24)
    searchStroke.Parent = searchBox

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 5)
    searchCorner.Parent = searchBox

    local searchPadding = Instance.new("UIPadding")
    searchPadding.PaddingLeft = UDim.new(0, 8)
    searchPadding.Parent = searchBox

    local contentHolder = Instance.new("Frame")
    contentHolder.Name = "ContentHolder"
    contentHolder.BackgroundTransparency = 1
    contentHolder.Position = UDim2.fromScale(0.121809, 0.0940516)
    contentHolder.Size = UDim2.fromScale(0.878191, 0.905948)
    contentHolder.Parent = mainUI

    self:MakeDraggable(mainUI, topHeader)

    -- Dynamic pointer-following tooltip for desktop cursor & mobile touch
    local tooltipBadge = Instance.new("Frame")
    tooltipBadge.Name = "tooltipbadge"
    tooltipBadge.BackgroundColor3 = Color3.fromRGB(16, 17, 21)
    tooltipBadge.AutomaticSize = Enum.AutomaticSize.XY
    tooltipBadge.Visible = false
    tooltipBadge.ZIndex = 300
    tooltipBadge.Parent = screenGui

    local ttCorner = Instance.new("UICorner")
    ttCorner.CornerRadius = UDim.new(0, 5)
    ttCorner.Parent = tooltipBadge

    local ttStroke = Instance.new("UIStroke")
    ttStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ttStroke.Color = Color3.fromRGB(42, 42, 46)
    ttStroke.Thickness = 1
    ttStroke.Parent = tooltipBadge

    local ttLabel = Instance.new("TextLabel")
    ttLabel.Name = "tttext"
    ttLabel.BackgroundTransparency = 1
    ttLabel.FontFace = FontSemiBold
    ttLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    ttLabel.TextSize = 13
    ttLabel.AutomaticSize = Enum.AutomaticSize.XY
    ttLabel.Parent = tooltipBadge

    local ttPadding = Instance.new("UIPadding")
    ttPadding.PaddingTop = UDim.new(0, 5)
    ttPadding.PaddingBottom = UDim.new(0, 5)
    ttPadding.PaddingLeft = UDim.new(0, 8)
    ttPadding.PaddingRight = UDim.new(0, 8)
    ttPadding.Parent = ttLabel

    local activeTooltipTarget = nil
    local tooltipConn = nil

    local function updateTooltipPos(inputPos)
        local pointerPos = inputPos or UserInputService:GetMouseLocation()
        local bounds = screenGui.AbsoluteSize
        local ttSize = tooltipBadge.AbsoluteSize
        local targetX = math.clamp(pointerPos.X + 14, 8, bounds.X - ttSize.X - 8)
        local targetY = math.clamp(pointerPos.Y - (ttSize.Y / 2), 8, bounds.Y - ttSize.Y - 8)

        self:Tween(tooltipBadge, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
            Position = UDim2.fromOffset(targetX, targetY)
        })
    end

    local function showTooltip(text, sourceObj)
        if not text or text == "" then return end
        activeTooltipTarget = sourceObj
        ttLabel.Text = tostring(text)
        tooltipBadge.Visible = true

        local initialPos = UserInputService:GetMouseLocation()
        local bounds = screenGui.AbsoluteSize
        local ttSize = tooltipBadge.AbsoluteSize
        local targetX = math.clamp(initialPos.X + 14, 8, bounds.X - ttSize.X - 8)
        local targetY = math.clamp(initialPos.Y - (ttSize.Y / 2), 8, bounds.Y - ttSize.Y - 8)
        tooltipBadge.Position = UDim2.fromOffset(targetX, targetY)

        if tooltipConn then tooltipConn:Disconnect() end
        tooltipConn = UserInputService.InputChanged:Connect(function(input)
            if not tooltipBadge.Visible then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                updateTooltipPos(input.Position)
            end
        end)
    end

    local function hideTooltip(sourceObj)
        if sourceObj and activeTooltipTarget and sourceObj ~= activeTooltipTarget then
            return
        end
        activeTooltipTarget = nil
        if tooltipConn then
            tooltipConn:Disconnect()
            tooltipConn = nil
        end
        tooltipBadge.Visible = false
    end

    local startHidden = options.InitialHidden
    if startHidden == nil then
        startHidden = isMobile
    end

    local visible = not startHidden
    local animating = false
    local fadeTime = 0.25

    if startHidden then
        mainUI.Visible = false
    end

    local function setVisible(state)
        if animating or visible == state then return end
        visible = state
        animating = true

        if state then
            mainUI.Visible = true
            self:FadeGroup(mainUI, true, fadeTime)

            task.delay(fadeTime, function()
                animating = false
            end)
        else
            self:FadeGroup(mainUI, false, fadeTime)

            task.delay(fadeTime, function()
                mainUI.Visible = false
                animating = false
            end)
        end
    end

    self:Connect(UserInputService.InputBegan, function(input, gpe)
        if input.KeyCode == menuKey then
            setVisible(not visible)
        end
    end)

    local function getWatermarkTitle()
        return options.WatermarkText or windowTitle
    end

    -- Watermark: toggle button for mobile, standard watermark for PC
    local wmTextInitial = startHidden and "PRESS ME TO OPEN GUI" or (options.WatermarkText or windowTitle)
    local allowWatermarkClick = options.WatermarkToggle
    if allowWatermarkClick == nil then
        allowWatermarkClick = isMobile -- only mobile users toggle via watermark by default
    end

    local watermark = self:CreateWatermark({
        Text = wmTextInitial,
        Logo = options.WatermarkLogo or logoAsset,
        OnClick = allowWatermarkClick and function(wm)
            if startHidden and not visible then
                startHidden = false
                wm:SetText(options.WatermarkText or windowTitle)
            end
            setVisible(not visible)
        end or nil
    })



    -- Notify PC user of keybind upon window initialization
    if not isMobile and options.NotifyKeybind ~= false then
        local keyName = typeof(menuKey) == "EnumItem" and menuKey.Name or tostring(menuKey)
        task.spawn(function()
            task.wait(0.2)
            self:Notify({
                Title = windowTitle,
                Content = "Press <b>[" .. keyName .. "]</b> to toggle GUI.",
                Duration = 5,
                Type = "Success"
            })
        end)
    end

    -- Timer notifications removed

    local activePopup

    local windowObj = {
        MainUI = mainUI,
        TabList = tabList,
        SubTabHolder = subTabHolder,
        ContentHolder = contentHolder,
        Tabs = {},
        ActiveTab = nil,
        RegisteredSections = {},
        RegisteredElements = {}
    }

    local function applyLiveSearch(query)
        query = string.lower(query):gsub("^%s*(.-)%s*$", "%1")

        if query == "" then
            for _, sec in ipairs(windowObj.RegisteredSections) do
                sec.Frame.Visible = true
            end
            for _, elem in ipairs(windowObj.RegisteredElements) do
                elem.Frame.Visible = true
            end
            return
        end

        local firstMatchedTab = nil
        local firstMatchedSubTab = nil

        local sectionMatchCount = {}
        for _, sec in ipairs(windowObj.RegisteredSections) do
            sectionMatchCount[sec.Frame] = 0
        end

        for _, elem in ipairs(windowObj.RegisteredElements) do
            local matches = string.find(string.lower(elem.Name), query, 1, true) ~= nil
            elem.Frame.Visible = matches
            if matches then
                sectionMatchCount[elem.SectionFrame] = (sectionMatchCount[elem.SectionFrame] or 0) + 1
                if not firstMatchedTab then
                    firstMatchedTab = elem.Tab
                    firstMatchedSubTab = elem.SubTab
                end
            end
        end

        for _, sec in ipairs(windowObj.RegisteredSections) do
            sec.Frame.Visible = (sectionMatchCount[sec.Frame] or 0) > 0
        end

        if firstMatchedTab and firstMatchedSubTab then
            firstMatchedTab:Select()
            firstMatchedSubTab:Select(true)
        end
    end

    Stellar:Connect(searchBox:GetPropertyChangedSignal("Text"), function()
        applyLiveSearch(searchBox.Text)
    end)

    function windowObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = tabConfig.Icon or "rbxassetid://82741456353014"

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = "TabFrame"
        tabFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Size = UDim2.fromOffset(36, 36)
        tabFrame.Parent = tabList

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 999)
        tabCorner.Parent = tabFrame

        local tabGradient = Instance.new("UIGradient")
        tabGradient.Color = OrangeGradientSequence
        tabGradient.Rotation = 90
        tabGradient.Enabled = false
        tabGradient.Parent = tabFrame

        local tabBtn = Instance.new("ImageButton")
        tabBtn.Name = "button"
        tabBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        tabBtn.AutoButtonColor = false
        tabBtn.BackgroundTransparency = 1
        tabBtn.Image = tabIcon
        tabBtn.ImageColor3 = Color3.fromRGB(110, 110, 110)
        tabBtn.Position = UDim2.fromScale(0.5, 0.5)
        tabBtn.ScaleType = Enum.ScaleType.Fit
        tabBtn.Size = UDim2.fromOffset(20, 20)
        tabBtn.ZIndex = 2
        tabBtn.Parent = tabFrame

        local tabContentArea = Instance.new("Frame")
        tabContentArea.Name = "TabContent_" .. tabName
        tabContentArea.BackgroundTransparency = 1
        tabContentArea.Size = UDim2.fromScale(1, 1)
        tabContentArea.Visible = false
        tabContentArea.Parent = contentHolder

        local tabObj = {
            Name = tabName,
            Frame = tabFrame,
            Gradient = tabGradient,
            Button = tabBtn,
            ContentArea = tabContentArea,
            SubTabHolder = subTabHolder,
            SubTabs = {},
            ActiveSubTab = nil
        }

        function tabObj:Select()
            if windowObj.ActiveTab and windowObj.ActiveTab ~= tabObj then
                local prev = windowObj.ActiveTab
                prev.Gradient.Enabled = false
                Stellar:Tween(prev.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                })
                Stellar:Tween(prev.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    ImageColor3 = Color3.fromRGB(110, 110, 110)
                })
                prev.ContentArea.Visible = false
                for _, st in ipairs(prev.SubTabs) do
                    st.PillFrame.Visible = false
                    st.Content.Visible = false
                end
            end

            windowObj.ActiveTab = tabObj
            tabObj.Gradient.Enabled = true
            Stellar:Tween(tabObj.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0
            })
            Stellar:Tween(tabObj.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                ImageColor3 = Color3.fromRGB(255, 255, 255)
            })

            for _, t in ipairs(windowObj.Tabs) do
                if t ~= tabObj then
                    t.ContentArea.Visible = false
                    for _, st in ipairs(t.SubTabs) do
                        st.PillFrame.Visible = false
                        st.Content.Visible = false
                    end
                end
            end

            tabObj.ContentArea.Visible = true
            tabObj.ContentArea.Position = UDim2.fromOffset(0, 12)
            Stellar:Tween(tabObj.ContentArea, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(0, 0)
            })

            for _, st in ipairs(tabObj.SubTabs) do
                st.PillFrame.Visible = true
                st.Content.Visible = (tabObj.ActiveSubTab == st)
            end

            if tabObj.ActiveSubTab then
                tabObj.ActiveSubTab:Select(true)
            elseif #tabObj.SubTabs > 0 then
                tabObj.SubTabs[1]:Select(true)
            end
        end

        local function handleTabClick()
            tabObj:Select()
        end

        Stellar:Connect(tabBtn.MouseEnter, function()
            showTooltip(tabName, tabBtn)
        end)

        Stellar:Connect(tabBtn.MouseLeave, function()
            hideTooltip(tabBtn)
        end)

        Stellar:Connect(tabBtn.MouseButton1Click, function()
            hideTooltip(tabBtn)
            handleTabClick()
        end)

        Stellar:Connect(tabBtn.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                showTooltip(tabName, tabBtn)
                task.delay(1.5, function()
                    hideTooltip(tabBtn)
                end)
                handleTabClick()
            end
        end)

        function tabObj:AddSubTab(subConfig)
            subConfig = subConfig or {}
            local subName = subConfig.Name or "SubTab"

            local pillFrame = Instance.new("Frame")
            pillFrame.Name = "SubPill_" .. subName
            pillFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
            pillFrame.Size = UDim2.new(0, 95, 1, 0)
            pillFrame.Visible = false
            pillFrame.Parent = subTabHolder

            local pillCorner = Instance.new("UICorner")
            pillCorner.CornerRadius = UDim.new(0, 5)
            pillCorner.Parent = pillFrame

            local pillGradient = Instance.new("UIGradient")
            pillGradient.Color = OrangeGradientSequence
            pillGradient.Rotation = 90
            pillGradient.Enabled = false
            pillGradient.Parent = pillFrame

            local pillLabel = Instance.new("TextLabel")
            pillLabel.BackgroundTransparency = 1
            pillLabel.FontFace = FontSemiBold
            pillLabel.Size = UDim2.fromScale(1, 1)
            pillLabel.Text = subName
            pillLabel.TextColor3 = Color3.fromRGB(110, 110, 110)
            pillLabel.TextSize = 14
            pillLabel.Parent = pillFrame

            local pillBtn = Instance.new("ImageButton")
            pillBtn.BackgroundTransparency = 1
            pillBtn.Size = UDim2.fromScale(1, 1)
            pillBtn.ZIndex = 3
            pillBtn.Parent = pillFrame

            local subContent = Instance.new("ScrollingFrame")
            subContent.Name = "SubContent_" .. subName
            subContent.Active = true
            subContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
            subContent.BackgroundTransparency = 1
            subContent.CanvasSize = UDim2.new()
            subContent.Position = UDim2.fromOffset(15, 15)
            subContent.Size = UDim2.new(1, -25, 1, -25)
            subContent.ScrollBarThickness = 4
            subContent.ScrollBarImageColor3 = Color3.fromRGB(255, 165, 50)
            subContent.Visible = false
            subContent.Parent = tabContentArea

            local subListLayout = Instance.new("UIListLayout")
            subListLayout.FillDirection = Enum.FillDirection.Horizontal
            subListLayout.Padding = UDim.new(0, 20)
            subListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            subListLayout.Wraps = true
            subListLayout.Parent = subContent

            local subTabObj = {
                Name = subName,
                PillFrame = pillFrame,
                Gradient = pillGradient,
                Label = pillLabel,
                Content = subContent
            }

            function subTabObj:Select(force)
                if tabObj.ActiveSubTab == subTabObj and not force then return end

                if tabObj.ActiveSubTab and tabObj.ActiveSubTab ~= subTabObj then
                    local prev = tabObj.ActiveSubTab
                    prev.Gradient.Enabled = false
                    prev.PillFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
                    Stellar:Tween(prev.Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextColor3 = Color3.fromRGB(110, 110, 110)
                    })
                    prev.Content.Visible = false
                end

                tabObj.ActiveSubTab = subTabObj
                subTabObj.Gradient.Enabled = true
                subTabObj.PillFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Stellar:Tween(subTabObj.Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = Color3.fromRGB(0, 0, 0)
                })

                subTabObj.Content.Visible = true
                subTabObj.Content.CanvasPosition = Vector2.new(0, 0)
                subTabObj.Content.Position = UDim2.fromOffset(15, 27)
                Stellar:Tween(subTabObj.Content, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.fromOffset(15, 15)
                })
            end

            local function handleSubClick()
                subTabObj:Select()
            end

            Stellar:Connect(pillBtn.MouseButton1Click, handleSubClick)
            Stellar:Connect(pillBtn.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    handleSubClick()
                end
            end)

            function subTabObj:AddSection(sectionConfig)
                sectionConfig = sectionConfig or {}
                local secTitle = sectionConfig.Name or "Section"
                local secIcon = sectionConfig.Icon or "rbxassetid://18821845145"

                local secFrame = Instance.new("Frame")
                secFrame.Name = "section"
                secFrame.AutomaticSize = Enum.AutomaticSize.Y
                secFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                secFrame.Size = UDim2.new(0.47, 0, 0, 0)
                secFrame.ZIndex = 4
                secFrame.Parent = subContent

                table.insert(windowObj.RegisteredSections, {
                    Name = secTitle,
                    Frame = secFrame,
                    Tab = tabObj,
                    SubTab = subTabObj
                })

                local secStroke = Instance.new("UIStroke")
                secStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                secStroke.Color = Color3.fromRGB(24, 24, 24)
                secStroke.Parent = secFrame

                local secCorner = Instance.new("UICorner")
                secCorner.CornerRadius = UDim.new(0, 4)
                secCorner.Parent = secFrame

                local secPadding = Instance.new("UIPadding")
                secPadding.PaddingBottom = UDim.new(0, 12)
                secPadding.Parent = secFrame

                local secTop = Instance.new("Frame")
                secTop.Name = "top"
                secTop.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                secTop.Size = UDim2.new(1, 0, 0, 30)
                secTop.Parent = secFrame

                local topCorner = Instance.new("UICorner")
                topCorner.CornerRadius = UDim.new(0, 4)
                topCorner.Parent = secTop

                local secIconLabel = Instance.new("ImageLabel")
                secIconLabel.AnchorPoint = Vector2.new(0, 0.5)
                secIconLabel.BackgroundTransparency = 1
                secIconLabel.Image = secIcon
                secIconLabel.Position = UDim2.new(0, 10, 0.5, 0)
                secIconLabel.Size = UDim2.fromOffset(14, 14)
                secIconLabel.Parent = secTop

                local secTitleLabel = Instance.new("TextLabel")
                secTitleLabel.BackgroundTransparency = 1
                secTitleLabel.FontFace = FontSemiBold
                secTitleLabel.Position = UDim2.fromOffset(32, 4)
                secTitleLabel.Size = UDim2.new(1, -40, 1, -8)
                secTitleLabel.Text = secTitle
                secTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                secTitleLabel.TextSize = 14
                secTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                secTitleLabel.Parent = secTop

                local secSep = Instance.new("Frame")
                secSep.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                secSep.BorderSizePixel = 0
                secSep.Position = UDim2.fromOffset(0, 29)
                secSep.Size = UDim2.new(1, 0, 0, 1)
                secSep.Parent = secTop

                local container = Instance.new("Frame")
                container.Name = "CONTAINER"
                container.AutomaticSize = Enum.AutomaticSize.Y
                container.BackgroundTransparency = 1
                container.Position = UDim2.fromOffset(10, 38)
                container.Size = UDim2.new(1, -20, 0, 0)
                container.Parent = secFrame

                local containerLayout = Instance.new("UIListLayout")
                containerLayout.Padding = UDim.new(0, 8)
                containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                containerLayout.Parent = container

                local sectionObj = {
                    Container = container
                }

                function sectionObj:AddToggle(toggleConfig)
                    toggleConfig = toggleConfig or {}
                    local togName = toggleConfig.Name or "Toggle"
                    local togFlag = toggleConfig.Flag or togName
                    local togDefault = toggleConfig.Default or false
                    local togCallback = toggleConfig.Callback or function() end

                    local togFrame = Instance.new("Frame")
                    togFrame.Name = "toggle"
                    togFrame.BackgroundTransparency = 1
                    togFrame.Size = UDim2.new(1, 0, 0, 22)
                    togFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = togName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = togFrame
                    })

                    local togTitle = Instance.new("TextLabel")
                    togTitle.BackgroundTransparency = 1
                    togTitle.FontFace = FontSemiBold
                    togTitle.Position = UDim2.fromOffset(0, 0)
                    togTitle.Size = UDim2.new(1, -45, 1, 0)
                    togTitle.Text = togName
                    togTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
                    togTitle.TextSize = 14
                    togTitle.TextXAlignment = Enum.TextXAlignment.Left
                    togTitle.Parent = togFrame

                    local togBtn = Instance.new("TextButton")
                    togBtn.Name = "toggleb"
                    togBtn.AnchorPoint = Vector2.new(1, 0.5)
                    togBtn.AutoButtonColor = false
                    togBtn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    togBtn.Position = UDim2.new(1, 0, 0.5, 0)
                    togBtn.Size = UDim2.fromOffset(33, 18)
                    togBtn.Text = ""
                    togBtn.Parent = togFrame

                    local togCorner = Instance.new("UICorner")
                    togCorner.CornerRadius = UDim.new(0, 999)
                    togCorner.Parent = togBtn

                    local togGradient = Instance.new("UIGradient")
                    togGradient.Color = OrangeGradientSequence
                    togGradient.Rotation = 90
                    togGradient.Enabled = false
                    togGradient.Parent = togBtn

                    local togBg = Instance.new("Frame")
                    togBg.Name = "bg"
                    togBg.BackgroundTransparency = 1
                    togBg.Position = UDim2.fromOffset(0, 0)
                    togBg.Size = UDim2.fromScale(1, 1)
                    togBg.Parent = togBtn

                    local ball = Instance.new("Frame")
                    ball.Name = "ball"
                    ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ball.Position = UDim2.fromOffset(3, 3)
                    ball.Size = UDim2.fromOffset(12, 12)
                    ball.Parent = togBg

                    local ballCorner = Instance.new("UICorner")
                    ballCorner.CornerRadius = UDim.new(0, 999)
                    ballCorner.Parent = ball

                    local state = false

                    local function updateToggle(val)
                        state = val
                        Stellar.Flags[togFlag] = state

                        if state then
                            togGradient.Enabled = true
                            togBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            Stellar:Tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Position = UDim2.fromOffset(18, 3),
                                BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                            })
                        else
                            togGradient.Enabled = false
                            togBtn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                            Stellar:Tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Position = UDim2.fromOffset(3, 3),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            })
                        end

                        Stellar:SafeCall(togCallback, state)
                    end

                    local function handleToggleClick()
                        updateToggle(not state)
                    end

                    local isDebouncing = false
                    Stellar:Connect(togBtn.MouseButton1Click, function()
                        if isDebouncing then return end
                        isDebouncing = true
                        handleToggleClick()
                        task.wait(0.1)
                        isDebouncing = false
                    end)
                    Stellar:Connect(togBtn.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            if isDebouncing then return end
                            isDebouncing = true
                            handleToggleClick()
                            task.wait(0.1)
                            isDebouncing = false
                        end
                    end)

                    if togDefault then
                        updateToggle(true)
                    else
                        Stellar.Flags[togFlag] = false
                    end

                    return {
                        Set = updateToggle
                    }
                end

                function sectionObj:AddSlider(sliderConfig)
                    sliderConfig = sliderConfig or {}
                    local sName = sliderConfig.Name or "Slider"
                    local sFlag = sliderConfig.Flag or sName
                    local sMin = sliderConfig.Min or 0
                    local sMax = sliderConfig.Max or 100
                    local sDefault = sliderConfig.Default or sMin
                    local sDecimals = sliderConfig.Decimals or 0
                    local sSuffix = sliderConfig.Suffix or ""
                    local sCallback = sliderConfig.Callback or function() end

                    local sliderFrame = Instance.new("Frame")
                    sliderFrame.Name = "slider"
                    sliderFrame.BackgroundTransparency = 1
                    sliderFrame.Size = UDim2.new(1, 0, 0, 28)
                    sliderFrame.ZIndex = 4
                    sliderFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = sName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = sliderFrame
                    })

                    local sliderTitle = Instance.new("TextLabel")
                    sliderTitle.Name = "title"
                    sliderTitle.BackgroundTransparency = 1
                    sliderTitle.FontFace = FontSemiBold
                    sliderTitle.Position = UDim2.fromScale(0, 0)
                    sliderTitle.Size = UDim2.new(0.6, 0, 0, 15)
                    sliderTitle.Text = sName
                    sliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderTitle.TextSize = 14
                    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                    sliderTitle.ZIndex = 4
                    sliderTitle.Parent = sliderFrame

                    local sliderAmount = Instance.new("TextLabel")
                    sliderAmount.Name = "amount"
                    sliderAmount.BackgroundTransparency = 1
                    sliderAmount.FontFace = FontSemiBold
                    sliderAmount.Position = UDim2.fromScale(0.6, 0)
                    sliderAmount.Size = UDim2.new(0.4, 0, 0, 15)
                    sliderAmount.Text = tostring(sDefault) .. sSuffix
                    sliderAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderAmount.TextSize = 14
                    sliderAmount.TextXAlignment = Enum.TextXAlignment.Right
                    sliderAmount.ZIndex = 4
                    sliderAmount.Parent = sliderFrame

                    local sliderBar = Instance.new("TextButton")
                    sliderBar.Name = "bar"
                    sliderBar.AnchorPoint = Vector2.new(0, 1)
                    sliderBar.AutoButtonColor = false
                    sliderBar.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    sliderBar.Position = UDim2.new(0, 0, 1, 0)
                    sliderBar.Size = UDim2.new(1, 0, 0, 8)
                    sliderBar.Text = ""
                    sliderBar.ZIndex = 5
                    sliderBar.Parent = sliderFrame

                    local barCorner = Instance.new("UICorner")
                    barCorner.CornerRadius = UDim.new(0, 999)
                    barCorner.Parent = sliderBar

                    local sliderFill = Instance.new("Frame")
                    sliderFill.Name = "fill"
                    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    sliderFill.Position = UDim2.fromScale(0, 0)
                    sliderFill.Size = UDim2.fromScale(math.clamp((sDefault - sMin) / (sMax - sMin), 0, 1), 1)
                    sliderFill.ZIndex = 6
                    sliderFill.Parent = sliderBar

                    local fillCorner = Instance.new("UICorner")
                    fillCorner.CornerRadius = UDim.new(0, 999)
                    fillCorner.Parent = sliderFill

                    local fillGradient = Instance.new("UIGradient")
                    fillGradient.Color = OrangeGradientSequence
                    fillGradient.Rotation = 90
                    fillGradient.Parent = sliderFill

                    local sliding = false
                    local currentValue = sDefault

                    local function round(val, dec)
                        if dec == 0 then
                            return math.floor(val + 0.5)
                        end
                        local mult = 10 ^ dec
                        return math.floor(val * mult + 0.5) / mult
                    end

                    local function setSliderValue(val)
                        val = math.clamp(val, sMin, sMax)
                        val = round(val, sDecimals)
                        currentValue = val

                        local ratio = math.clamp((val - sMin) / (sMax - sMin), 0, 1)
                        sliderFill.Size = UDim2.fromScale(ratio, 1)
                        sliderAmount.Text = tostring(val) .. sSuffix

                        Stellar.Flags[sFlag] = val
                        Stellar:SafeCall(sCallback, val)
                    end

                    local inputChangedConn

                    Stellar:Connect(sliderBar.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                            local sizeX = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                            local val = ((sMax - sMin) * sizeX) + sMin
                            setSliderValue(val)

                            if inputChangedConn then return end
                            inputChangedConn = input.Changed:Connect(function()
                                if input.UserInputState == Enum.UserInputState.End then
                                    sliding = false
                                    if inputChangedConn then
                                        inputChangedConn:Disconnect()
                                        inputChangedConn = nil
                                    end
                                end
                            end)
                        end
                    end)

                    Stellar:Connect(UserInputService.InputChanged, function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            local sizeX = (input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                            local val = ((sMax - sMin) * sizeX) + sMin
                            setSliderValue(val)
                        end
                    end)

                    setSliderValue(sDefault)

                    return {
                        Set = setSliderValue,
                        Get = function()
                            return currentValue
                        end
                    }
                end

                function sectionObj:AddButton(btnConfig)
                    btnConfig = btnConfig or {}
                    local btnName = btnConfig.Name or "Button"
                    local btnCallback = btnConfig.Callback or function() end

                    local btn = Instance.new("TextButton")
                    btn.Name = "Button"
                    btn.AutoButtonColor = false
                    btn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    btn.FontFace = FontSemiBold
                    btn.Size = UDim2.new(1, 0, 0, 26)
                    btn.Text = btnName
                    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    btn.TextSize = 14
                    btn.ZIndex = 4
                    btn.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = btnName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = btn
                    })

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 4)
                    btnCorner.Parent = btn

                    local function handleBtnClick()
                        Stellar:Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        })
                        task.delay(0.08, function()
                            Stellar:Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                            })
                        end)
                        Stellar:SafeCall(btnCallback)
                    end

                    Stellar:Connect(btn.MouseEnter, function()
                        Stellar:Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                        })
                    end)

                    Stellar:Connect(btn.MouseLeave, function()
                        Stellar:Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            TextColor3 = Color3.fromRGB(200, 200, 200),
                            BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                        })
                    end)

                    Stellar:Connect(btn.MouseButton1Click, handleBtnClick)
                    Stellar:Connect(btn.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            handleBtnClick()
                        end
                    end)

                    return btn
                end

                function sectionObj:AddParagraph(paraConfig)
                    paraConfig = paraConfig or {}
                    local paraName = paraConfig.Name or paraConfig.Title or "Paragraph"
                    local paraText = paraConfig.Content or paraConfig.Text or ""

                    local paraFrame = Instance.new("Frame")
                    paraFrame.Name = "paragraph"
                    paraFrame.AutomaticSize = Enum.AutomaticSize.Y
                    paraFrame.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    paraFrame.Size = UDim2.new(1, 0, 0, 0)
                    paraFrame.ZIndex = 4
                    paraFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = paraName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = paraFrame
                    })

                    local paraCorner = Instance.new("UICorner")
                    paraCorner.CornerRadius = UDim.new(0, 4)
                    paraCorner.Parent = paraFrame

                    local paraPadding = Instance.new("UIPadding")
                    paraPadding.PaddingTop = UDim.new(0, 8)
                    paraPadding.PaddingBottom = UDim.new(0, 8)
                    paraPadding.PaddingLeft = UDim.new(0, 10)
                    paraPadding.PaddingRight = UDim.new(0, 10)
                    paraPadding.Parent = paraFrame

                    local paraLayout = Instance.new("UIListLayout")
                    paraLayout.Padding = UDim.new(0, 4)
                    paraLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    paraLayout.Parent = paraFrame

                    local paraTitle = Instance.new("TextLabel")
                    paraTitle.Name = "title"
                    paraTitle.AutomaticSize = Enum.AutomaticSize.Y
                    paraTitle.BackgroundTransparency = 1
                    paraTitle.FontFace = FontBold
                    paraTitle.LayoutOrder = 1
                    paraTitle.Size = UDim2.new(1, 0, 0, 0)
                    paraTitle.Text = paraName
                    paraTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
                    paraTitle.TextSize = 14
                    paraTitle.TextWrapped = true
                    paraTitle.TextXAlignment = Enum.TextXAlignment.Left
                    paraTitle.ZIndex = 5
                    paraTitle.Parent = paraFrame

                    local paraBody = Instance.new("TextLabel")
                    paraBody.Name = "body"
                    paraBody.AutomaticSize = Enum.AutomaticSize.Y
                    paraBody.BackgroundTransparency = 1
                    paraBody.FontFace = FontSemiBold
                    paraBody.LayoutOrder = 2
                    paraBody.RichText = true
                    paraBody.Size = UDim2.new(1, 0, 0, 0)
                    paraBody.Text = paraText
                    paraBody.TextColor3 = Color3.fromRGB(150, 150, 150)
                    paraBody.TextSize = 13
                    paraBody.TextWrapped = true
                    paraBody.TextXAlignment = Enum.TextXAlignment.Left
                    paraBody.ZIndex = 5
                    paraBody.Parent = paraFrame

                    return {
                        Set = function(text)
                            paraBody.Text = text or ""
                        end,
                        SetTitle = function(text)
                            paraTitle.Text = text or ""
                        end
                    }
                end

                local function buildInput(inputConfig)
                    inputConfig = inputConfig or {}
                    local inName = inputConfig.Name or inputConfig.Title or "Input"
                    local inFlag = inputConfig.Flag or inName
                    local inPlaceholder = inputConfig.Placeholder or inputConfig.PlaceholderText or "Enter text..."
                    local inDefault = inputConfig.Default or ""
                    local inClearOnFocus = inputConfig.ClearTextOnFocus ~= nil and inputConfig.ClearTextOnFocus or false
                    local inNumeric = inputConfig.Numeric or false
                    local inCallback = inputConfig.Callback or function() end

                    local inFrame = Instance.new("Frame")
                    inFrame.Name = "input"
                    inFrame.BackgroundTransparency = 1
                    inFrame.Size = UDim2.new(1, 0, 0, 48)
                    inFrame.ZIndex = 4
                    inFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = inName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = inFrame
                    })

                    local inTitle = Instance.new("TextLabel")
                    inTitle.Name = "title"
                    inTitle.BackgroundTransparency = 1
                    inTitle.FontFace = FontSemiBold
                    inTitle.Size = UDim2.new(1, 0, 0, 15)
                    inTitle.Text = inName
                    inTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    inTitle.TextSize = 14
                    inTitle.TextXAlignment = Enum.TextXAlignment.Left
                    inTitle.ZIndex = 4
                    inTitle.Parent = inFrame

                    local boxContainer = Instance.new("Frame")
                    boxContainer.Name = "boxholder"
                    boxContainer.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    boxContainer.Position = UDim2.fromOffset(0, 20)
                    boxContainer.Size = UDim2.new(1, 0, 0, 28)
                    boxContainer.ZIndex = 5
                    boxContainer.Parent = inFrame

                    local boxCorner = Instance.new("UICorner")
                    boxCorner.CornerRadius = UDim.new(0, 4)
                    boxCorner.Parent = boxContainer

                    local boxStroke = Instance.new("UIStroke")
                    boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    boxStroke.Color = Color3.fromRGB(24, 24, 24)
                    boxStroke.Parent = boxContainer

                    local textBox = Instance.new("TextBox")
                    textBox.Name = "textbox"
                    textBox.BackgroundTransparency = 1
                    textBox.ClearTextOnFocus = inClearOnFocus
                    textBox.FontFace = FontSemiBold
                    textBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 110)
                    textBox.PlaceholderText = inPlaceholder
                    textBox.Position = UDim2.fromOffset(8, 0)
                    textBox.Size = UDim2.new(1, -16, 1, 0)
                    textBox.Text = tostring(inDefault)
                    textBox.TextColor3 = Color3.fromRGB(245, 245, 245)
                    textBox.TextSize = 13
                    textBox.TextXAlignment = Enum.TextXAlignment.Left
                    textBox.ZIndex = 6
                    textBox.Parent = boxContainer

                    local currentValue = inDefault
                    Stellar.Flags[inFlag] = currentValue

                    local function setValue(newText, suppressCallback)
                        if inNumeric then
                            newText = tostring(newText):gsub("[^%d%.%-]", "")
                        end
                        currentValue = tostring(newText)
                        textBox.Text = currentValue
                        Stellar.Flags[inFlag] = currentValue
                        if not suppressCallback then
                            Stellar:SafeCall(inCallback, currentValue)
                        end
                    end

                    Stellar:Connect(textBox.Focused, function()
                        Stellar:Tween(boxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Color = Color3.fromRGB(255, 165, 50)
                        })
                    end)

                    Stellar:Connect(textBox.FocusLost, function(enterPressed)
                        Stellar:Tween(boxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            Color = Color3.fromRGB(24, 24, 24)
                        })
                        setValue(textBox.Text)
                    end)

                    if inNumeric then
                        Stellar:Connect(textBox:GetPropertyChangedSignal("Text"), function()
                            local clean = textBox.Text:gsub("[^%d%.%-]", "")
                            if clean ~= textBox.Text then
                                textBox.Text = clean
                            end
                        end)
                    end

                    return {
                        Set = setValue,
                        Get = function()
                            return currentValue
                        end,
                        Frame = inFrame,
                        TextBox = textBox
                    }
                end

                function sectionObj:AddInput(inputConfig)
                    return buildInput(inputConfig)
                end

                function sectionObj:AddTextBox(inputConfig)
                    return buildInput(inputConfig)
                end

                local function buildDropdown(dropConfig, multi)
                    dropConfig = dropConfig or {}
                    local dropName = dropConfig.Name or "Dropdown"
                    local dropFlag = dropConfig.Flag or dropName
                    local dropCallback = dropConfig.Callback or function() end
                    local motion = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                    local options = {}
                    local order = {}
                    local value = multi and {} or nil
                    local isOpen = false

                    local dropFrame = Instance.new("Frame")
                    dropFrame.Name = "dropdown"
                    dropFrame.BackgroundTransparency = 1
                    dropFrame.Size = UDim2.new(1, 0, 0, 48)
                    dropFrame.ZIndex = 4
                    dropFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = dropName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = dropFrame
                    })

                    local dropTitle = Instance.new("TextLabel")
                    dropTitle.Name = "title"
                    dropTitle.BackgroundTransparency = 1
                    dropTitle.FontFace = FontSemiBold
                    dropTitle.Size = UDim2.new(1, 0, 0, 15)
                    dropTitle.Text = dropName
                    dropTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    dropTitle.TextSize = 14
                    dropTitle.TextXAlignment = Enum.TextXAlignment.Left
                    dropTitle.ZIndex = 4
                    dropTitle.Parent = dropFrame

                    local control = Instance.new("TextButton")
                    control.Name = "control"
                    control.AutoButtonColor = false
                    control.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    control.Position = UDim2.fromOffset(0, 20)
                    control.Size = UDim2.new(1, 0, 0, 28)
                    control.Text = ""
                    control.ZIndex = 5
                    control.Parent = dropFrame

                    local controlCorner = Instance.new("UICorner")
                    controlCorner.CornerRadius = UDim.new(0, 4)
                    controlCorner.Parent = control

                    local controlStroke = Instance.new("UIStroke")
                    controlStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    controlStroke.Color = Color3.fromRGB(24, 24, 24)
                    controlStroke.Parent = control

                    local valueLabel = Instance.new("TextLabel")
                    valueLabel.Name = "value"
                    valueLabel.AnchorPoint = Vector2.new(0, 0.5)
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.FontFace = FontSemiBold
                    valueLabel.Position = UDim2.new(0, 8, 0.5, 0)
                    valueLabel.Size = UDim2.new(1, -40, 0, 15)
                    valueLabel.Text = "..."
                    valueLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
                    valueLabel.TextSize = 14
                    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                    valueLabel.ZIndex = 6
                    valueLabel.Parent = control

                    local divider = Instance.new("Frame")
                    divider.Name = "divider"
                    divider.AnchorPoint = Vector2.new(1, 0)
                    divider.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                    divider.BorderSizePixel = 0
                    divider.Position = UDim2.new(1, -28, 0, 0)
                    divider.Size = UDim2.new(0, 1, 1, 0)
                    divider.ZIndex = 6
                    divider.Parent = control

                    local arrow = Instance.new("ImageLabel")
                    arrow.Name = "arrow"
                    arrow.AnchorPoint = Vector2.new(1, 0.5)
                    arrow.BackgroundTransparency = 1
                    arrow.Image = "rbxassetid://72690112230014"
                    arrow.ImageColor3 = Color3.fromRGB(160, 160, 160)
                    arrow.Position = UDim2.new(1, -7, 0.5, 0)
                    arrow.Size = UDim2.fromOffset(14, 14)
                    arrow.ZIndex = 6
                    arrow.Parent = control

                    local scrim = Instance.new("TextButton")
                    scrim.Name = "dropdownscrim"
                    scrim.AutoButtonColor = false
                    scrim.BackgroundTransparency = 1
                    scrim.Size = UDim2.fromScale(1, 1)
                    scrim.Text = ""
                    scrim.Visible = false
                    scrim.ZIndex = 55
                    scrim.Parent = screenGui

                    local list = Instance.new("Frame")
                    list.Name = "dropdownlist"
                    list.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    list.ClipsDescendants = true
                    list.Size = UDim2.fromOffset(0, 0)
                    list.Visible = false
                    list.ZIndex = 60
                    list.Parent = screenGui

                    local listCorner = Instance.new("UICorner")
                    listCorner.CornerRadius = UDim.new(0, 5)
                    listCorner.Parent = list

                    local listStroke = Instance.new("UIStroke")
                    listStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    listStroke.Color = Color3.fromRGB(24, 24, 24)
                    listStroke.Parent = list

                    local listScroll = Instance.new("ScrollingFrame")
                    listScroll.Name = "scroll"
                    listScroll.Active = true
                    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    listScroll.BackgroundTransparency = 1
                    listScroll.BorderSizePixel = 0
                    listScroll.CanvasSize = UDim2.new()
                    listScroll.ScrollBarThickness = 3
                    listScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 165, 50)
                    listScroll.Size = UDim2.fromScale(1, 1)
                    listScroll.ZIndex = 61
                    listScroll.Parent = list

                    local listLayout = Instance.new("UIListLayout")
                    listLayout.Padding = UDim.new(0, 4)
                    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    listLayout.Parent = listScroll

                    local listPadding = Instance.new("UIPadding")
                    listPadding.PaddingTop = UDim.new(0, 8)
                    listPadding.PaddingBottom = UDim.new(0, 8)
                    listPadding.PaddingLeft = UDim.new(0, 8)
                    listPadding.PaddingRight = UDim.new(0, 8)
                    listPadding.Parent = listScroll

                    local function refreshText()
                        if multi then
                            local picked = {}
                            for _, name in ipairs(order) do
                                if table.find(value, name) then
                                    table.insert(picked, name)
                                end
                            end
                            valueLabel.Text = #picked > 0 and table.concat(picked, ", ") or "..."
                        else
                            valueLabel.Text = value or "..."
                        end
                    end

                    local function listHeight()
                        local count = #order
                        if count == 0 then
                            return 0
                        end
                        local content = count * 22 + (count - 1) * 4 + 16
                        return math.min(content, 150)
                    end

                    local follow

                    local function setOpen(open)
                        if isOpen == open then return end
                        isOpen = open

                        if open then
                            if activePopup and activePopup ~= setOpen then
                                activePopup(false)
                            end
                            activePopup = setOpen

                            local origin = screenGui.AbsolutePosition
                            list.Position = UDim2.fromOffset(
                                control.AbsolutePosition.X - origin.X,
                                control.AbsolutePosition.Y - origin.Y + control.AbsoluteSize.Y + 4
                            )
                            list.Size = UDim2.fromOffset(control.AbsoluteSize.X, 0)
                            list.Visible = true
                            scrim.Visible = true

                            follow = RunService.RenderStepped:Connect(function()
                                if not dropFrame.Visible or not subContent.Visible then
                                    setOpen(false)
                                    return
                                end
                                local o = screenGui.AbsolutePosition
                                list.Position = UDim2.fromOffset(
                                    control.AbsolutePosition.X - o.X,
                                    control.AbsolutePosition.Y - o.Y + control.AbsoluteSize.Y + 4
                                )
                            end)

                            Stellar:Tween(list, motion, {
                                Size = UDim2.fromOffset(control.AbsoluteSize.X, listHeight())
                            })
                            Stellar:Tween(arrow, motion, { Rotation = 180 })
                        else
                            if activePopup == setOpen then
                                activePopup = nil
                            end

                            if follow then
                                follow:Disconnect()
                                follow = nil
                            end

                            scrim.Visible = false
                            local collapse = Stellar:Tween(list, motion, {
                                Size = UDim2.fromOffset(list.AbsoluteSize.X, 0)
                            })
                            Stellar:Tween(arrow, motion, { Rotation = 0 })

                            collapse.Completed:Connect(function()
                                if not isOpen then
                                    list.Visible = false
                                end
                            end)
                        end
                    end

                    local function fire()
                        Stellar.Flags[dropFlag] = value
                        Stellar:SafeCall(dropCallback, value)
                    end

                    local function addOption(name)
                        if options[name] then return options[name] end

                        local option = Instance.new("TextButton")
                        option.Name = "option"
                        option.AutoButtonColor = false
                        option.BackgroundTransparency = 1
                        option.Size = UDim2.new(1, 0, 0, 22)
                        option.Text = ""
                        option.ZIndex = 61
                        option.Parent = listScroll

                        local marker = Instance.new("Frame")
                        marker.Name = "marker"
                        marker.AnchorPoint = Vector2.new(0, 0.5)
                        marker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        marker.BackgroundTransparency = 1
                        marker.Position = UDim2.new(0, 0, 0.5, 0)
                        marker.Size = UDim2.fromOffset(3, 0)
                        marker.ZIndex = 62
                        marker.Parent = option

                        local markerCorner = Instance.new("UICorner")
                        markerCorner.CornerRadius = UDim.new(0, 2)
                        markerCorner.Parent = marker

                        local markerGradient = Instance.new("UIGradient")
                        markerGradient.Color = OrangeGradientSequence
                        markerGradient.Rotation = 90
                        markerGradient.Parent = marker

                        local glow = Instance.new("ImageLabel")
                        glow.Name = "glow"
                        glow.AnchorPoint = Vector2.new(0.5, 0.5)
                        glow.BackgroundTransparency = 1
                        glow.Image = "rbxassetid://18245826428"
                        glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        glow.ImageTransparency = 1
                        glow.Position = UDim2.fromScale(0.5, 0.5)
                        glow.ScaleType = Enum.ScaleType.Slice
                        glow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79))
                        glow.Size = UDim2.new(1, 25, 1, 25)
                        glow.ZIndex = 61
                        glow.Parent = marker

                        local glowGradient = Instance.new("UIGradient")
                        glowGradient.Color = OrangeGlowSequence
                        glowGradient.Rotation = 90
                        glowGradient.Parent = glow

                        local optionLabel = Instance.new("TextLabel")
                        optionLabel.Name = "label"
                        optionLabel.AnchorPoint = Vector2.new(0, 0.5)
                        optionLabel.BackgroundTransparency = 1
                        optionLabel.FontFace = FontSemiBold
                        optionLabel.Position = UDim2.new(0, 0, 0.5, 0)
                        optionLabel.Size = UDim2.new(1, -14, 0, 15)
                        optionLabel.Text = name
                        optionLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
                        optionLabel.TextSize = 14
                        optionLabel.TextTransparency = 0.5
                        optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        optionLabel.ZIndex = 62
                        optionLabel.Parent = option

                        local entry = {
                            Name = name,
                            Button = option,
                            Selected = false
                        }

                        function entry:Paint(on)
                            entry.Selected = on
                            if on then
                                Stellar:Tween(marker, motion, {
                                    BackgroundTransparency = 0,
                                    Size = UDim2.fromOffset(3, 14)
                                })
                                Stellar:Tween(glow, motion, { ImageTransparency = 0.7 })
                                Stellar:Tween(optionLabel, motion, {
                                    Position = UDim2.new(0, 12, 0.5, 0),
                                    TextTransparency = 0
                                })
                            else
                                Stellar:Tween(marker, motion, {
                                    BackgroundTransparency = 1,
                                    Size = UDim2.fromOffset(3, 0)
                                })
                                Stellar:Tween(glow, motion, { ImageTransparency = 1 })
                                Stellar:Tween(optionLabel, motion, {
                                    Position = UDim2.new(0, 0, 0.5, 0),
                                    TextTransparency = 0.5
                                })
                            end
                        end

                        local function pick()
                            if multi then
                                local at = table.find(value, name)
                                if at then
                                    table.remove(value, at)
                                else
                                    table.insert(value, name)
                                end
                                entry:Paint(not at)
                            else
                                if value == name then
                                    value = nil
                                    entry:Paint(false)
                                else
                                    value = name
                                    for _, other in pairs(options) do
                                        other:Paint(other == entry)
                                    end
                                end
                                setOpen(false)
                            end

                            refreshText()
                            fire()
                        end

                        Stellar:Connect(option.MouseButton1Click, pick)
                        Stellar:Connect(option.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.Touch then
                                pick()
                            end
                        end)

                        options[name] = entry
                        table.insert(order, name)
                        return entry
                    end

                    local function removeOption(name)
                        local entry = options[name]
                        if not entry then return end

                        entry.Button:Destroy()
                        options[name] = nil

                        local at = table.find(order, name)
                        if at then
                            table.remove(order, at)
                        end

                        if multi then
                            local picked = table.find(value, name)
                            if picked then
                                table.remove(value, picked)
                            end
                        elseif value == name then
                            value = nil
                        end

                        refreshText()
                    end

                    local function setValue(newValue)
                        if multi then
                            if type(newValue) ~= "table" then return end
                            value = {}
                            for _, name in ipairs(newValue) do
                                if options[name] then
                                    table.insert(value, name)
                                end
                            end
                            for _, entry in pairs(options) do
                                entry:Paint(table.find(value, entry.Name) ~= nil)
                            end
                        else
                            if newValue ~= nil and not options[newValue] then return end
                            value = newValue
                            for _, entry in pairs(options) do
                                entry:Paint(entry.Name == newValue)
                            end
                        end

                        refreshText()
                        fire()
                    end

                    local function refresh(items)
                        for _, name in ipairs(table.clone(order)) do
                            removeOption(name)
                        end
                        for _, name in ipairs(items or {}) do
                            addOption(name)
                        end
                        if isOpen then
                            Stellar:Tween(list, motion, {
                                Size = UDim2.fromOffset(list.AbsoluteSize.X, listHeight())
                            })
                        end
                    end

                    local function handleControlClick()
                        setOpen(not isOpen)
                    end

                    Stellar:Connect(control.MouseButton1Click, handleControlClick)
                    Stellar:Connect(control.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            handleControlClick()
                        end
                    end)

                    Stellar:Connect(scrim.MouseButton1Click, function()
                        setOpen(false)
                    end)
                    Stellar:Connect(scrim.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(false)
                        end
                    end)

                    for _, name in ipairs(dropConfig.Items or dropConfig.Options or {}) do
                        addOption(name)
                    end

                    if dropConfig.Default ~= nil then
                        setValue(dropConfig.Default)
                    else
                        Stellar.Flags[dropFlag] = value
                        refreshText()
                    end

                    return {
                        Set = setValue,
                        Get = function()
                            return value
                        end,
                        Add = addOption,
                        Remove = removeOption,
                        Refresh = refresh
                    }
                end

                function sectionObj:AddDropdown(dropConfig)
                    return buildDropdown(dropConfig, false)
                end

                function sectionObj:AddMultiDropdown(dropConfig)
                    return buildDropdown(dropConfig, true)
                end

                function sectionObj:AddKeybind(bindConfig)
                    bindConfig = bindConfig or {}
                    local bindName = bindConfig.Name or "Keybind"
                    local bindFlag = bindConfig.Flag or bindName
                    local bindCallback = bindConfig.Callback or function() end
                    local motion = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                    local mouseLabels = {
                        MouseButton1 = "MB1",
                        MouseButton2 = "MB2",
                        MouseButton3 = "MB3"
                    }

                    local key = ""
                    local label = "None"
                    local mode = bindConfig.Mode or "Toggle"
                    local toggled = false
                    local picking = false
                    local isOpen = false

                    local bindFrame = Instance.new("Frame")
                    bindFrame.Name = "keybind"
                    bindFrame.BackgroundTransparency = 1
                    bindFrame.Size = UDim2.new(1, 0, 0, 22)
                    bindFrame.ZIndex = 4
                    bindFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = bindName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = bindFrame
                    })

                    local bindTitle = Instance.new("TextLabel")
                    bindTitle.Name = "title"
                    bindTitle.BackgroundTransparency = 1
                    bindTitle.FontFace = FontSemiBold
                    bindTitle.Size = UDim2.new(1, -80, 1, 0)
                    bindTitle.Text = bindName
                    bindTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
                    bindTitle.TextSize = 14
                    bindTitle.TextXAlignment = Enum.TextXAlignment.Left
                    bindTitle.ZIndex = 4
                    bindTitle.Parent = bindFrame

                    local keyBtn = Instance.new("TextButton")
                    keyBtn.Name = "key"
                    keyBtn.AnchorPoint = Vector2.new(1, 0.5)
                    keyBtn.AutoButtonColor = false
                    keyBtn.AutomaticSize = Enum.AutomaticSize.X
                    keyBtn.BackgroundColor3 = Color3.fromRGB(21, 21, 21)
                    keyBtn.FontFace = FontSemiBold
                    keyBtn.Position = UDim2.new(1, 0, 0.5, 0)
                    keyBtn.Size = UDim2.fromOffset(0, 20)
                    keyBtn.Text = "[None]"
                    keyBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
                    keyBtn.TextSize = 14
                    keyBtn.ZIndex = 5
                    keyBtn.Parent = bindFrame

                    local keyCorner = Instance.new("UICorner")
                    keyCorner.CornerRadius = UDim.new(0, 4)
                    keyCorner.Parent = keyBtn

                    local keyPadding = Instance.new("UIPadding")
                    keyPadding.PaddingLeft = UDim.new(0, 8)
                    keyPadding.PaddingRight = UDim.new(0, 8)
                    keyPadding.Parent = keyBtn

                    local scrim = Instance.new("TextButton")
                    scrim.Name = "keybindscrim"
                    scrim.AutoButtonColor = false
                    scrim.BackgroundTransparency = 1
                    scrim.Size = UDim2.fromScale(1, 1)
                    scrim.Text = ""
                    scrim.Visible = false
                    scrim.ZIndex = 55
                    scrim.Parent = screenGui

                    local modeWindow = Instance.new("Frame")
                    modeWindow.Name = "keybindmodes"
                    modeWindow.AutomaticSize = Enum.AutomaticSize.XY
                    modeWindow.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    modeWindow.Size = UDim2.fromOffset(0, 0)
                    modeWindow.Visible = false
                    modeWindow.ZIndex = 60
                    modeWindow.Parent = screenGui

                    local modeCorner = Instance.new("UICorner")
                    modeCorner.CornerRadius = UDim.new(0, 5)
                    modeCorner.Parent = modeWindow

                    local modeStroke = Instance.new("UIStroke")
                    modeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    modeStroke.Color = Color3.fromRGB(24, 24, 24)
                    modeStroke.Parent = modeWindow

                    local modeLayout = Instance.new("UIListLayout")
                    modeLayout.Padding = UDim.new(0, 6)
                    modeLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    modeLayout.Parent = modeWindow

                    local modePadding = Instance.new("UIPadding")
                    modePadding.PaddingTop = UDim.new(0, 10)
                    modePadding.PaddingBottom = UDim.new(0, 10)
                    modePadding.PaddingLeft = UDim.new(0, 10)
                    modePadding.PaddingRight = UDim.new(0, 10)
                    modePadding.Parent = modeWindow

                    local function push()
                        Stellar.Flags[bindFlag] = {
                            Key = key,
                            Mode = mode,
                            Toggled = toggled
                        }
                        Stellar:SafeCall(bindCallback, toggled, key, mode)
                    end

                    local modes = {}

                    local function setMode(newMode)
                        mode = newMode
                        for name, btn in pairs(modes) do
                            Stellar:Tween(btn, motion, {
                                TextTransparency = name == newMode and 0 or 0.5
                            })
                        end
                        push()
                    end

                    for index, name in ipairs({ "Toggle", "Hold", "Always" }) do
                        local modeBtn = Instance.new("TextButton")
                        modeBtn.Name = name
                        modeBtn.AutoButtonColor = false
                        modeBtn.AutomaticSize = Enum.AutomaticSize.X
                        modeBtn.BackgroundTransparency = 1
                        modeBtn.FontFace = FontSemiBold
                        modeBtn.LayoutOrder = index
                        modeBtn.Size = UDim2.fromOffset(0, 15)
                        modeBtn.Text = name
                        modeBtn.TextColor3 = Color3.fromRGB(245, 245, 245)
                        modeBtn.TextSize = 14
                        modeBtn.TextTransparency = name == mode and 0 or 0.5
                        modeBtn.TextXAlignment = Enum.TextXAlignment.Left
                        modeBtn.ZIndex = 61
                        modeBtn.Parent = modeWindow

                        modes[name] = modeBtn

                        local function chooseMode()
                            setMode(name)
                        end

                        Stellar:Connect(modeBtn.MouseButton1Click, chooseMode)
                        Stellar:Connect(modeBtn.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.Touch then
                                chooseMode()
                            end
                        end)
                    end

                    local function place()
                        local origin = screenGui.AbsolutePosition
                        modeWindow.Position = UDim2.fromOffset(
                            keyBtn.AbsolutePosition.X - origin.X,
                            keyBtn.AbsolutePosition.Y - origin.Y + keyBtn.AbsoluteSize.Y + 5
                        )
                    end

                    local follow

                    local function setOpen(open)
                        if isOpen == open then return end
                        isOpen = open

                        if open then
                            if activePopup and activePopup ~= setOpen then
                                activePopup(false)
                            end
                            activePopup = setOpen

                            place()
                            modeWindow.Visible = true
                            scrim.Visible = true

                            follow = RunService.RenderStepped:Connect(function()
                                if not bindFrame.Visible or not subContent.Visible then
                                    setOpen(false)
                                    return
                                end
                                place()
                            end)
                        else
                            if activePopup == setOpen then
                                activePopup = nil
                            end

                            if follow then
                                follow:Disconnect()
                                follow = nil
                            end

                            modeWindow.Visible = false
                            scrim.Visible = false
                        end
                    end

                    local function setKey(input)
                        if type(input) == "table" then
                            if input.Mode then
                                setMode(input.Mode)
                            end
                            if input.Key then
                                setKey(input.Key)
                            end
                            return
                        end

                        if typeof(input) == "EnumItem" then
                            if input.Name == "Backspace" then
                                key = ""
                                label = "None"
                            else
                                key = tostring(input)
                                label = mouseLabels[input.Name] or input.Name
                            end
                        end

                        keyBtn.Text = "[" .. label .. "]"
                        picking = false
                        push()
                    end

                    local function beginPicking()
                        if picking then return end
                        picking = true
                        keyBtn.Text = "[...]"

                        local grab
                        grab = UserInputService.InputBegan:Connect(function(input)
                            grab:Disconnect()
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                setKey(input.KeyCode)
                            else
                                setKey(input.UserInputType)
                            end
                        end)
                    end

                    local function press(down)
                        if mode == "Toggle" then
                            toggled = not toggled
                        elseif mode == "Hold" then
                            toggled = down
                        elseif mode == "Always" then
                            toggled = true
                        end
                        push()
                    end

                    Stellar:Connect(keyBtn.MouseButton1Click, beginPicking)
                    Stellar:Connect(keyBtn.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            beginPicking()
                        end
                    end)

                    Stellar:Connect(keyBtn.MouseButton2Down, function()
                        setOpen(not isOpen)
                    end)

                    Stellar:Connect(scrim.MouseButton1Click, function()
                        setOpen(false)
                    end)
                    Stellar:Connect(scrim.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(false)
                        end
                    end)

                    Stellar:Connect(UserInputService.InputBegan, function(input, gpe)
                        if gpe or picking or key == "" then return end
                        if tostring(input.KeyCode) == key or tostring(input.UserInputType) == key then
                            press(true)
                        end
                    end)

                    Stellar:Connect(UserInputService.InputEnded, function(input)
                        if picking or key == "" then return end
                        if tostring(input.KeyCode) == key or tostring(input.UserInputType) == key then
                            if mode == "Hold" then
                                press(false)
                            elseif mode == "Always" then
                                press(true)
                            end
                        end
                    end)

                    if bindConfig.Default then
                        setKey({ Key = bindConfig.Default, Mode = mode })
                    else
                        Stellar.Flags[bindFlag] = {
                            Key = key,
                            Mode = mode,
                            Toggled = toggled
                        }
                    end

                    return {
                        Set = setKey,
                        SetMode = setMode,
                        Get = function()
                            return key, mode, toggled
                        end
                    }
                end

                function sectionObj:AddColorpicker(pickConfig)
                    pickConfig = pickConfig or {}
                    local pickName = pickConfig.Name or "Colorpicker"
                    local pickFlag = pickConfig.Flag or pickName
                    local pickCallback = pickConfig.Callback or function() end
                    local motion = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

                    local hue, saturation, brightness = 0, 0, 1
                    local alpha = 0
                    local color = Color3.fromRGB(255, 255, 255)
                    local isOpen = false

                    local pickFrame = Instance.new("Frame")
                    pickFrame.Name = "colorpicker"
                    pickFrame.BackgroundTransparency = 1
                    pickFrame.Size = UDim2.new(1, 0, 0, 22)
                    pickFrame.ZIndex = 4
                    pickFrame.Parent = container

                    table.insert(windowObj.RegisteredElements, {
                        Name = pickName,
                        Tab = tabObj,
                        SubTab = subTabObj,
                        SectionFrame = secFrame,
                        Frame = pickFrame
                    })

                    local pickTitle = Instance.new("TextLabel")
                    pickTitle.Name = "title"
                    pickTitle.BackgroundTransparency = 1
                    pickTitle.FontFace = FontSemiBold
                    pickTitle.Size = UDim2.new(1, -30, 1, 0)
                    pickTitle.Text = pickName
                    pickTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
                    pickTitle.TextSize = 14
                    pickTitle.TextXAlignment = Enum.TextXAlignment.Left
                    pickTitle.ZIndex = 4
                    pickTitle.Parent = pickFrame

                    local swatch = Instance.new("ImageButton")
                    swatch.Name = "swatch"
                    swatch.AnchorPoint = Vector2.new(1, 0.5)
                    swatch.AutoButtonColor = false
                    swatch.BackgroundTransparency = 1
                    swatch.Image = pickConfig.Icon or "rbxassetid://77492218953155"
                    swatch.ImageColor3 = color
                    swatch.Position = UDim2.new(1, 0, 0.5, 0)
                    swatch.Size = UDim2.fromOffset(20, 20)
                    swatch.ZIndex = 5
                    swatch.Parent = pickFrame

                    local scrim = Instance.new("TextButton")
                    scrim.Name = "pickerscrim"
                    scrim.AutoButtonColor = false
                    scrim.BackgroundTransparency = 1
                    scrim.Size = UDim2.fromScale(1, 1)
                    scrim.Text = ""
                    scrim.Visible = false
                    scrim.ZIndex = 55
                    scrim.Parent = screenGui

                    local window = Instance.new("Frame")
                    window.Name = "pickerwindow"
                    window.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    window.Size = UDim2.fromOffset(210, 210)
                    window.Visible = false
                    window.ZIndex = 60
                    window.Parent = screenGui

                    local windowCorner = Instance.new("UICorner")
                    windowCorner.CornerRadius = UDim.new(0, 6)
                    windowCorner.Parent = window

                    local windowStroke = Instance.new("UIStroke")
                    windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    windowStroke.Color = Color3.fromRGB(24, 24, 24)
                    windowStroke.Parent = window

                    local palette = Instance.new("TextButton")
                    palette.Name = "palette"
                    palette.AutoButtonColor = false
                    palette.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
                    palette.Position = UDim2.fromOffset(12, 36)
                    palette.Size = UDim2.new(1, -50, 1, -50)
                    palette.Text = ""
                    palette.ZIndex = 61
                    palette.Parent = window

                    local paletteCorner = Instance.new("UICorner")
                    paletteCorner.CornerRadius = UDim.new(0, 6)
                    paletteCorner.Parent = palette

                    local satLayer = Instance.new("Frame")
                    satLayer.Name = "saturation"
                    satLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    satLayer.BorderSizePixel = 0
                    satLayer.Size = UDim2.fromScale(1, 1)
                    satLayer.ZIndex = 62
                    satLayer.Parent = palette

                    local satGradient = Instance.new("UIGradient")
                    satGradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                    satGradient.Parent = satLayer

                    local satCorner = Instance.new("UICorner")
                    satCorner.CornerRadius = UDim.new(0, 6)
                    satCorner.Parent = satLayer

                    local valLayer = Instance.new("Frame")
                    valLayer.Name = "value"
                    valLayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    valLayer.BorderSizePixel = 0
                    valLayer.Size = UDim2.fromScale(1, 1)
                    valLayer.ZIndex = 63
                    valLayer.Parent = palette

                    local valGradient = Instance.new("UIGradient")
                    valGradient.Rotation = 90
                    valGradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                    valGradient.Parent = valLayer

                    local valCorner = Instance.new("UICorner")
                    valCorner.CornerRadius = UDim.new(0, 6)
                    valCorner.Parent = valLayer

                    local paletteDragger = Instance.new("Frame")
                    paletteDragger.Name = "dragger"
                    paletteDragger.BackgroundTransparency = 1
                    paletteDragger.Size = UDim2.fromOffset(14, 14)
                    paletteDragger.ZIndex = 64
                    paletteDragger.Parent = palette

                    local paletteDragCorner = Instance.new("UICorner")
                    paletteDragCorner.CornerRadius = UDim.new(0, 4)
                    paletteDragCorner.Parent = paletteDragger

                    local paletteDragStroke = Instance.new("UIStroke")
                    paletteDragStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    paletteDragStroke.Color = Color3.fromRGB(255, 255, 255)
                    paletteDragStroke.Thickness = 2
                    paletteDragStroke.Parent = paletteDragger

                    local hueBar = Instance.new("TextButton")
                    hueBar.Name = "hue"
                    hueBar.AnchorPoint = Vector2.new(1, 0)
                    hueBar.AutoButtonColor = false
                    hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    hueBar.Position = UDim2.new(1, -12, 0, 12)
                    hueBar.Size = UDim2.new(0, 14, 1, -24)
                    hueBar.Text = ""
                    hueBar.ZIndex = 61
                    hueBar.Parent = window

                    local hueCorner = Instance.new("UICorner")
                    hueCorner.CornerRadius = UDim.new(0, 4)
                    hueCorner.Parent = hueBar

                    local hueGradient = Instance.new("UIGradient")
                    hueGradient.Rotation = 90
                    hueGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    })
                    hueGradient.Parent = hueBar

                    local hueDragger = Instance.new("Frame")
                    hueDragger.Name = "dragger"
                    hueDragger.BackgroundTransparency = 1
                    hueDragger.Size = UDim2.fromOffset(14, 14)
                    hueDragger.ZIndex = 62
                    hueDragger.Parent = hueBar

                    local hueDragCorner = Instance.new("UICorner")
                    hueDragCorner.CornerRadius = UDim.new(0, 4)
                    hueDragCorner.Parent = hueDragger

                    local hueDragStroke = Instance.new("UIStroke")
                    hueDragStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    hueDragStroke.Color = Color3.fromRGB(255, 255, 255)
                    hueDragStroke.Thickness = 2
                    hueDragStroke.Parent = hueDragger

                    local alphaBar = Instance.new("TextButton")
                    alphaBar.Name = "alpha"
                    alphaBar.AutoButtonColor = false
                    alphaBar.BackgroundColor3 = color
                    alphaBar.Position = UDim2.fromOffset(12, 12)
                    alphaBar.Size = UDim2.new(1, -50, 0, 14)
                    alphaBar.Text = ""
                    alphaBar.ZIndex = 61
                    alphaBar.Parent = window

                    local checkers = Instance.new("ImageLabel")
                    checkers.Name = "checkers"
                    checkers.BackgroundTransparency = 1
                    checkers.Image = "rbxassetid://18274452449"
                    checkers.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    checkers.ScaleType = Enum.ScaleType.Tile
                    checkers.Size = UDim2.fromScale(1, 1)
                    checkers.TileSize = UDim2.fromOffset(6, 6)
                    checkers.ZIndex = 62
                    checkers.Parent = alphaBar

                    local checkerGradient = Instance.new("UIGradient")
                    checkerGradient.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.37, 0.5),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                    checkerGradient.Parent = checkers

                    local checkerCorner = Instance.new("UICorner")
                    checkerCorner.CornerRadius = UDim.new(0, 4)
                    checkerCorner.Parent = checkers

                    local alphaCorner = Instance.new("UICorner")
                    alphaCorner.CornerRadius = UDim.new(0, 4)
                    alphaCorner.Parent = alphaBar

                    local alphaDragger = Instance.new("Frame")
                    alphaDragger.Name = "dragger"
                    alphaDragger.BackgroundTransparency = 1
                    alphaDragger.Size = UDim2.fromOffset(14, 14)
                    alphaDragger.ZIndex = 63
                    alphaDragger.Parent = alphaBar

                    local alphaDragCorner = Instance.new("UICorner")
                    alphaDragCorner.CornerRadius = UDim.new(0, 4)
                    alphaDragCorner.Parent = alphaDragger

                    local alphaDragStroke = Instance.new("UIStroke")
                    alphaDragStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    alphaDragStroke.Color = Color3.fromRGB(255, 255, 255)
                    alphaDragStroke.Thickness = 2
                    alphaDragStroke.Parent = alphaDragger

                    local function update(fromAlpha)
                        color = Color3.fromHSV(hue, saturation, brightness)

                        swatch.ImageColor3 = color
                        palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

                        if not fromAlpha then
                            alphaBar.BackgroundColor3 = color
                        end

                        Stellar.Flags[pickFlag] = {
                            Color = color,
                            Alpha = alpha,
                            HexValue = color:ToHex(),
                            Transparency = 1 - alpha
                        }

                        Stellar:SafeCall(pickCallback, color, alpha)
                    end

                    local function place()
                        local origin = screenGui.AbsolutePosition
                        window.Position = UDim2.fromOffset(
                            swatch.AbsolutePosition.X - origin.X - window.AbsoluteSize.X + swatch.AbsoluteSize.X,
                            swatch.AbsolutePosition.Y - origin.Y + swatch.AbsoluteSize.Y + 6
                        )
                    end

                    local follow

                    local function setOpen(open)
                        if isOpen == open then return end
                        isOpen = open

                        if open then
                            if activePopup and activePopup ~= setOpen then
                                activePopup(false)
                            end
                            activePopup = setOpen

                            place()
                            window.Visible = true
                            scrim.Visible = true

                            follow = RunService.RenderStepped:Connect(function()
                                if not pickFrame.Visible or not subContent.Visible then
                                    setOpen(false)
                                    return
                                end
                                place()
                            end)
                        else
                            if activePopup == setOpen then
                                activePopup = nil
                            end

                            if follow then
                                follow:Disconnect()
                                follow = nil
                            end

                            window.Visible = false
                            scrim.Visible = false
                        end
                    end

                    local slidingPalette = false
                    local slidingHue = false
                    local slidingAlpha = false

                    local function slidePalette(input)
                        local abs = palette.AbsolutePosition
                        local size = palette.AbsoluteSize

                        saturation = math.clamp((input.Position.X - abs.X) / size.X, 0, 1)
                        brightness = math.clamp(1 - (input.Position.Y - abs.Y) / size.Y, 0, 1)

                        Stellar:Tween(paletteDragger, motion, {
                            Position = UDim2.fromScale(
                                math.clamp((input.Position.X - abs.X) / size.X, 0, 0.92),
                                math.clamp((input.Position.Y - abs.Y) / size.Y, 0, 0.92)
                            )
                        })

                        update()
                    end

                    local function slideHue(input)
                        local abs = hueBar.AbsolutePosition
                        local size = hueBar.AbsoluteSize

                        hue = math.clamp((input.Position.Y - abs.Y) / size.Y, 0, 1)

                        Stellar:Tween(hueDragger, motion, {
                            Position = UDim2.fromScale(0, math.clamp((input.Position.Y - abs.Y) / size.Y, 0, 0.92))
                        })

                        update()
                    end

                    local function slideAlpha(input)
                        local abs = alphaBar.AbsolutePosition
                        local size = alphaBar.AbsoluteSize

                        alpha = math.clamp((input.Position.X - abs.X) / size.X, 0, 1)

                        Stellar:Tween(alphaDragger, motion, {
                            Position = UDim2.fromScale(math.clamp((input.Position.X - abs.X) / size.X, 0, 0.92), 0)
                        })

                        update(true)
                    end

                    local function setColor(newColor, newAlpha)
                        if type(newColor) == "table" then
                            newColor = Color3.fromRGB(newColor[1], newColor[2], newColor[3])
                        elseif type(newColor) == "string" then
                            newColor = Color3.fromHex(newColor)
                        end

                        if typeof(newColor) ~= "Color3" then return end

                        hue, saturation, brightness = newColor:ToHSV()
                        alpha = newAlpha or 0

                        paletteDragger.Position = UDim2.fromScale(
                            math.clamp(saturation, 0, 0.92),
                            math.clamp(1 - brightness, 0, 0.92)
                        )
                        hueDragger.Position = UDim2.fromScale(0, math.clamp(hue, 0, 0.92))
                        alphaDragger.Position = UDim2.fromScale(math.clamp(alpha, 0, 0.92), 0)

                        update()
                    end

                    local function beginSlide(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
                            return false
                        end

                        local ended
                        ended = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                slidingPalette = false
                                slidingHue = false
                                slidingAlpha = false
                                ended:Disconnect()
                            end
                        end)

                        return true
                    end

                    Stellar:Connect(palette.InputBegan, function(input)
                        if beginSlide(input) then
                            slidingPalette = true
                            slidePalette(input)
                        end
                    end)

                    Stellar:Connect(hueBar.InputBegan, function(input)
                        if beginSlide(input) then
                            slidingHue = true
                            slideHue(input)
                        end
                    end)

                    Stellar:Connect(alphaBar.InputBegan, function(input)
                        if beginSlide(input) then
                            slidingAlpha = true
                            slideAlpha(input)
                        end
                    end)

                    Stellar:Connect(UserInputService.InputChanged, function(input)
                        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end

                        if slidingPalette then
                            slidePalette(input)
                        end
                        if slidingHue then
                            slideHue(input)
                        end
                        if slidingAlpha then
                            slideAlpha(input)
                        end
                    end)

                    Stellar:Connect(swatch.MouseButton1Click, function()
                        setOpen(not isOpen)
                    end)
                    Stellar:Connect(swatch.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(not isOpen)
                        end
                    end)

                    Stellar:Connect(scrim.MouseButton1Click, function()
                        setOpen(false)
                    end)
                    Stellar:Connect(scrim.InputBegan, function(input)
                        if input.UserInputType == Enum.UserInputType.Touch then
                            setOpen(false)
                        end
                    end)

                    setColor(pickConfig.Default or Color3.fromRGB(255, 165, 50), pickConfig.Alpha)

                    return {
                        Set = setColor,
                        Get = function()
                            return color, alpha
                        end
                    }
                end

                return sectionObj
            end

            table.insert(tabObj.SubTabs, subTabObj)

            if windowObj.ActiveTab == tabObj then
                pillFrame.Visible = true

                if #tabObj.SubTabs == 1 then
                    subTabObj:Select(true)
                end
            end

            return subTabObj
        end

        table.insert(windowObj.Tabs, tabObj)

        if #windowObj.Tabs == 1 then
            tabObj:Select()
        end

        return tabObj
    end

    return windowObj
end

function Stellar:CreateWatermark(options, logoParam)
    local text = "stellar | v1.0"
    local logo = "rbxassetid://71540167635901"
    local onClickCallback = nil

    if typeof(options) == "table" then
        text = options.Text or text
        logo = options.Logo or logo
        onClickCallback = options.OnClick or options.Callback
    elseif typeof(options) == "string" then
        text = options
        logo = logoParam or logo
    end

    if not self.ScreenGui or not self.ScreenGui.Parent then
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "stellar"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = gethui()
        self.ScreenGui = screenGui
    end

    local wmFrame = Instance.new("Frame")
    wmFrame.Name = "Watermark"
    wmFrame.AnchorPoint = Vector2.new(0.5, 0)
    wmFrame.Position = UDim2.new(0.5, 0, 0, 20)
    wmFrame.Size = UDim2.new(0, 0, 0, 35)
    wmFrame.BorderSizePixel = 0
    wmFrame.AutomaticSize = Enum.AutomaticSize.X
    wmFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    wmFrame.ZIndex = 100
    wmFrame.Parent = self.ScreenGui

    self:MakeDraggable(wmFrame)

    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(0, 6)
    wmCorner.Parent = wmFrame

    local wmStroke = Instance.new("UIStroke")
    wmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    wmStroke.Color = Color3.fromRGB(24, 24, 24)
    wmStroke.Parent = wmFrame

    local wmPadding = Instance.new("UIPadding")
    wmPadding.PaddingRight = UDim.new(0, 10)
    wmPadding.PaddingLeft = UDim.new(0, 8)
    wmPadding.Parent = wmFrame

    local wmLogo = Instance.new("ImageLabel")
    wmLogo.Name = "Logo"
    wmLogo.ScaleType = Enum.ScaleType.Fit
    wmLogo.AnchorPoint = Vector2.new(0, 0.5)
    wmLogo.Image = logo
    wmLogo.BackgroundTransparency = 1
    wmLogo.Position = UDim2.new(0, 0, 0.5, 0)
    wmLogo.Size = UDim2.new(0, 25, 0, 25)
    wmLogo.BorderSizePixel = 0
    wmLogo.Parent = wmFrame

    local wmText = Instance.new("TextLabel")
    wmText.Name = "Text"
    wmText.FontFace = FontBold
    wmText.TextColor3 = Color3.fromRGB(255, 165, 50)
    wmText.Text = text
    wmText.AnchorPoint = Vector2.new(0, 0.5)
    wmText.Size = UDim2.new(0, 0, 0, 15)
    wmText.BackgroundTransparency = 1
    wmText.Position = UDim2.new(0, 34, 0.5, -1)
    wmText.BorderSizePixel = 0
    wmText.AutomaticSize = Enum.AutomaticSize.X
    wmText.TextSize = 16
    wmText.Parent = wmFrame

    local watermarkObj = {
        Frame = wmFrame,
        TextLabel = wmText
    }

    function watermarkObj:SetText(newText)
        wmText.Text = tostring(newText)
    end

    function watermarkObj:SetVisibility(bool)
        wmFrame.Visible = bool
    end

    function watermarkObj:SetCenter()
        local function align()
            local abs = wmFrame.AbsolutePosition
            wmFrame.AnchorPoint = Vector2.new(0, 0)
            wmFrame.Position = UDim2.fromOffset(abs.X, abs.Y)
        end
        task.defer(align)
    end

    watermarkObj:SetCenter()

    local clickButton = Instance.new("TextButton")
    clickButton.Name = "wmclicker"
    clickButton.BackgroundTransparency = 1
    clickButton.Size = UDim2.fromScale(1, 1)
    clickButton.Text = ""
    clickButton.ZIndex = 105
    clickButton.Parent = wmFrame

    self:MakeDraggable(wmFrame, clickButton)

    local dragDist = 0
    local dragOrigin = Vector2.new(0, 0)
    local isDown = false

    self:Connect(clickButton.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDown = true
            dragDist = 0
            dragOrigin = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)

    self:Connect(UserInputService.InputChanged, function(input)
        if isDown and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragOrigin
            dragDist = math.max(dragDist, delta.Magnitude)
        end
    end)

    self:Connect(clickButton.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDown = false
            if dragDist < 6 then
                if onClickCallback then
                    self:SafeCall(onClickCallback, watermarkObj)
                end
            end
        end
    end)

    self.WatermarkFrame = wmFrame
    return watermarkObj
end

getgenv().StellarLib = Stellar
return Stellar
