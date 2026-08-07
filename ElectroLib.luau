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
local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

Stellar.Flags = {}
Stellar.Connections = {}
Stellar.Threads = {}
Stellar.Tabs = {}

local OrangeGradientSequence = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 165, 50)),
    ColorSequenceKeypoint.new(0.32, Color3.fromRGB(230, 140, 40)),
    ColorSequenceKeypoint.new(0.60, Color3.fromRGB(200, 115, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 70, 15))
})

local FontSemiBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
local FontBold = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

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

function Stellar:MakeDraggable(gui, handle)
    handle = handle or gui
    local dragging = false
    local dragStart, startPos

    self:Connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    self:Connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local parentSize = gui.Parent and gui.Parent.AbsoluteSize or Vector2.new(1920, 1080)
            local guiSize = gui.AbsoluteSize
            
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, parentSize.X - guiSize.X)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, parentSize.Y - guiSize.Y)
            
            self:Tween(gui, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(newX, newY)
            })
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
    getgenv().StellarLib = nil
end

function Stellar:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Name or "stellar"
    local menuKey = options.Keybind or Enum.KeyCode.RightControl

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

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "tabcontainer"
    tabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    tabContainer.Position = UDim2.fromScale(0, 0)
    tabContainer.Size = UDim2.fromScale(0.120609, 1)
    tabContainer.Parent = mainUI

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabContainer

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "list"
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.BackgroundTransparency = 1
    tabList.CanvasSize = UDim2.new()
    tabList.ScrollBarThickness = 0
    tabList.Size = UDim2.new(1, 0, 1, -20)
    tabList.Position = UDim2.fromOffset(0, 10)
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
    subTabHolder.Size = UDim2.new(0.85, 0, 0, 24)
    subTabHolder.ZIndex = 2
    subTabHolder.Parent = topHeader

    local subTabLayout = Instance.new("UIListLayout")
    subTabLayout.FillDirection = Enum.FillDirection.Horizontal
    subTabLayout.Padding = UDim.new(0, 10)
    subTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subTabLayout.Parent = subTabHolder

    local contentHolder = Instance.new("Frame")
    contentHolder.Name = "ContentHolder"
    contentHolder.BackgroundTransparency = 1
    contentHolder.Position = UDim2.fromScale(0.121809, 0.0940516)
    contentHolder.Size = UDim2.fromScale(0.878191, 0.905948)
    contentHolder.Parent = mainUI

    self:MakeDraggable(mainUI, topHeader)

    local visible = true
    self:Connect(UserInputService.InputBegan, function(input, gpe)
        if gpe then return end
        if input.KeyCode == menuKey then
            visible = not visible
            mainUI.Visible = visible
        end
    end)

    if options.WatermarkEnabled then
        self:CreateWatermark(options.WatermarkText or windowTitle)
    end

    local windowObj = {
        MainUI = mainUI,
        TabList = tabList,
        SubTabHolder = subTabHolder,
        ContentHolder = contentHolder,
        Tabs = {},
        ActiveTab = nil
    }

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
            if windowObj.ActiveTab == tabObj then return end

            if windowObj.ActiveTab then
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

            tabObj.ContentArea.Visible = true
            for _, st in ipairs(tabObj.SubTabs) do
                st.PillFrame.Visible = true
            end

            if tabObj.ActiveSubTab then
                tabObj.ActiveSubTab:Select()
            elseif #tabObj.SubTabs > 0 then
                tabObj.SubTabs[1]:Select()
            end
        end

        Stellar:Connect(tabBtn.MouseButton1Click, function()
            tabObj:Select()
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
            pillLabel.TextSize = 13
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

            function subTabObj:Select()
                if tabObj.ActiveSubTab == subTabObj then return end

                if tabObj.ActiveSubTab then
                    local prev = tabObj.ActiveSubTab
                    prev.Gradient.Enabled = false
                    prev.PillFrame.BackgroundColor3 = Color3.fromRGB(9, 9, 9)
                    Stellar:Tween(prev.Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        TextColor3 = Color3.fromRGB(110, 110, 110)
                    })
                    
                    Stellar:Tween(prev.Content, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        CanvasPosition = Vector2.new(0, 0)
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
            end

            Stellar:Connect(pillBtn.MouseButton1Click, function()
                subTabObj:Select()
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
                secTitleLabel.TextSize = 13
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

                    local togTitle = Instance.new("TextLabel")
                    togTitle.BackgroundTransparency = 1
                    togTitle.FontFace = FontSemiBold
                    togTitle.Position = UDim2.fromOffset(0, 0)
                    togTitle.Size = UDim2.new(1, -45, 1, 0)
                    togTitle.Text = togName
                    togTitle.TextColor3 = Color3.fromRGB(245, 245, 245)
                    togTitle.TextSize = 13
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

                    Stellar:Connect(togBtn.MouseButton1Click, function()
                        updateToggle(not state)
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
                    btn.TextSize = 13
                    btn.ZIndex = 4
                    btn.Parent = container

                    local btnCorner = Instance.new("UICorner")
                    btnCorner.CornerRadius = UDim.new(0, 4)
                    btnCorner.Parent = btn

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

                    Stellar:Connect(btn.MouseButton1Click, function()
                        Stellar:Tween(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        })
                        task.delay(0.08, function()
                            Stellar:Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                            })
                        end)
                        Stellar:SafeCall(btnCallback)
                    end)

                    return btn
                end

                return sectionObj
            end

            table.insert(tabObj.SubTabs, subTabObj)
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

function Stellar:CreateWatermark(text)
    local wmFrame = Instance.new("Frame")
    wmFrame.Name = "StellarWatermark"
    wmFrame.AnchorPoint = Vector2.new(0, 0)
    wmFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 11)
    wmFrame.Position = UDim2.fromOffset(20, 20)
    wmFrame.Size = UDim2.fromOffset(160, 28)
    wmFrame.ZIndex = 100
    wmFrame.Parent = self.ScreenGui

    local wmCorner = Instance.new("UICorner")
    wmCorner.CornerRadius = UDim.new(0, 6)
    wmCorner.Parent = wmFrame

    local wmStroke = Instance.new("UIStroke")
    wmStroke.Color = Color3.fromRGB(24, 24, 24)
    wmStroke.Parent = wmFrame

    local wmLabel = Instance.new("TextLabel")
    wmLabel.BackgroundTransparency = 1
    wmLabel.FontFace = FontBold
    wmLabel.Position = UDim2.fromOffset(10, 0)
    wmLabel.Size = UDim2.new(1, -20, 1, 0)
    wmLabel.Text = text or "stellar | v1.0"
    wmLabel.TextColor3 = Color3.fromRGB(255, 165, 50)
    wmLabel.TextSize = 13
    wmLabel.TextXAlignment = Enum.TextXAlignment.Left
    wmLabel.Parent = wmFrame

    self:MakeDraggable(wmFrame)
    self.WatermarkFrame = wmFrame

    return {
        SetText = function(_, newText)
            wmLabel.Text = newText
        end
    }
end

getgenv().StellarLib = Stellar
return Stellar
