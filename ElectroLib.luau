local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

function Library:Init(title)
    local Window = {
        Tabs = {},
        FirstTab = nil,
        CurrentTab = nil
    }

    title = title or "StellarZ <font color=\"#FF8742\">hub</font>"

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StellarZ_ScreenGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainuiframe = Instance.new("Frame")
    mainuiframe.Name = "Mainuiframe"
    mainuiframe.AnchorPoint = Vector2.new(0.5, 0.5)
    mainuiframe.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainuiframe.ClipsDescendants = true
    mainuiframe.Position = UDim2.fromScale(0.5, 0.5)
    mainuiframe.Size = UDim2.fromOffset(754, 524)
    mainuiframe.Parent = screenGui

    local uICorner1 = Instance.new("UICorner")
    uICorner1.CornerRadius = UDim.new(0, 14)
    uICorner1.Parent = mainuiframe

    local dragging, dragInput, dragStart, startPos
    mainuiframe.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainuiframe.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    mainuiframe.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainuiframe.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local topbarHolder = Instance.new("Frame")
    topbarHolder.Name = "TopbarHolder"
    topbarHolder.BackgroundTransparency = 1
    topbarHolder.ClipsDescendants = true
    topbarHolder.Position = UDim2.fromScale(-0.00262812, 0)
    topbarHolder.Size = UDim2.fromOffset(762, 66)
    topbarHolder.Parent = mainuiframe

    local topbarorheaderig = Instance.new("Frame")
    topbarorheaderig.Name = "topbarorheaderig"
    topbarorheaderig.AnchorPoint = Vector2.new(0.5, 0.5)
    topbarorheaderig.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    topbarorheaderig.Position = UDim2.fromScale(0.499004, 0.653842)
    topbarorheaderig.Size = UDim2.fromOffset(756, 86)
    topbarorheaderig.Parent = topbarHolder

    local uICorner28 = Instance.new("UICorner")
    uICorner28.CornerRadius = UDim.new(0, 14)
    uICorner28.Parent = topbarorheaderig

    local libaryName = Instance.new("TextLabel")
    libaryName.Name = "Libary_Name"
    libaryName.AnchorPoint = Vector2.new(0, 0.5)
    libaryName.BackgroundTransparency = 1
    libaryName.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
    libaryName.Position = UDim2.fromScale(0.0277778, 0.406977)
    libaryName.RichText = true
    libaryName.Size = UDim2.fromOffset(1, 1)
    libaryName.AutomaticSize = Enum.AutomaticSize.XY
    libaryName.Text = title
    libaryName.TextColor3 = Color3.new(1, 1, 1)
    libaryName.TextSize = 25
    libaryName.Parent = topbarorheaderig

    local hEader = Instance.new("Frame")
    hEader.Name = "HEader"
    hEader.AnchorPoint = Vector2.new(0.5, 0)
    hEader.BackgroundTransparency = 1
    hEader.Position = UDim2.fromScale(0.5, 0)
    hEader.Size = UDim2.fromOffset(767, 64)
    hEader.Parent = mainuiframe

    local linerthingy = Instance.new("Frame")
    linerthingy.Name = "Linerthingyorseparatoridontremmember"
    linerthingy.AnchorPoint = Vector2.new(0.5, 1)
    linerthingy.BackgroundColor3 = Color3.fromRGB(31, 31, 45)
    linerthingy.BorderSizePixel = 0
    linerthingy.Position = UDim2.fromScale(0.499511, 1.01562)
    linerthingy.Size = UDim2.fromOffset(760, 2)
    linerthingy.Parent = hEader

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundTransparency = 1
    sidebar.Position = UDim2.fromScale(0, 0.136082)
    sidebar.Size = UDim2.fromOffset(100, 436)
    sidebar.Parent = mainuiframe

    local sidebaranother = Instance.new("Frame")
    sidebaranother.Name = "Sidebaranother"
    sidebaranother.BackgroundTransparency = 1
    sidebaranother.Size = UDim2.fromOffset(100, 419)
    sidebaranother.Parent = sidebar

    local holder = Instance.new("Frame")
    holder.Name = "Holder"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.fromScale(0.5, 0.5)
    holder.Size = UDim2.fromOffset(75, 436)
    holder.Parent = sidebaranother

    local uIListLayout = Instance.new("UIListLayout")
    uIListLayout.Padding = UDim.new(0, 5)
    uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uIListLayout.Parent = holder

    local uIPadding = Instance.new("UIPadding")
    uIPadding.PaddingLeft = UDim.new(0, 9)
    uIPadding.PaddingTop = UDim.new(0, 10)
    uIPadding.Parent = holder

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.AnchorPoint = Vector2.new(1, 0.5)
    indicator.BackgroundColor3 = Color3.fromRGB(254, 254, 254)
    indicator.Position = UDim2.new(1, 0, 0, 0) -- Matches right edge of sidebar
    indicator.Size = UDim2.fromOffset(27, 33)
    indicator.Parent = sidebaranother

    local uICorner3 = Instance.new("UICorner")
    uICorner3.CornerRadius = UDim.new(0, 12)
    uICorner3.Parent = indicator

    local indGradient = Instance.new("UIGradient")
    indGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 100, 52)),
        ColorSequenceKeypoint.new(0.313149, Color3.fromRGB(243, 131, 39)),
        ColorSequenceKeypoint.new(0.536332, Color3.fromRGB(255, 157, 0)),
        ColorSequenceKeypoint.new(0.647059, Color3.fromRGB(255, 157, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 100, 52)),
    })
    indGradient.Rotation = 70
    indGradient.Parent = indicator

    local pageholder = Instance.new("Frame")
    pageholder.Name = "Pageholder"
    pageholder.AnchorPoint = Vector2.new(0.5, 0.5)
    pageholder.BackgroundTransparency = 1
    pageholder.ClipsDescendants = true
    pageholder.Position = UDim2.fromScale(0.565867, 0.562023)
    pageholder.Size = UDim2.fromOffset(660, 459)
    pageholder.Parent = mainuiframe

    Window.SidebarAnother = sidebaranother
    Window.Holder = holder
    Window.Indicator = indicator
    Window.PageHolder = pageholder

    function Window:CreateTab(iconId)
        local tabData = {}

        local tab = Instance.new("TextButton")
        tab.Name = "Tab"
        tab.BackgroundColor3 = Color3.fromRGB(247, 247, 247)
        tab.BackgroundTransparency = 1
        tab.ClipsDescendants = true
        tab.Size = UDim2.fromOffset(55, 60)
        tab.Text = ""
        tab.Parent = self.Holder

        local uICorner2 = Instance.new("UICorner")
        uICorner2.CornerRadius = UDim.new(0, 5)
        uICorner2.Parent = tab

        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(iconId)
        icon.ImageColor3 = Color3.fromRGB(69, 71, 90)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromOffset(24, 22)
        icon.Parent = tab

        local divider = Instance.new("Frame")
        divider.Name = "Divider"
        divider.AnchorPoint = Vector2.new(0.5, 1)
        divider.BackgroundTransparency = 1
        divider.ClipsDescendants = true
        divider.Position = UDim2.fromScale(0.5, 1)
        divider.Size = UDim2.fromOffset(55, 5)
        divider.Parent = tab

        local uICorner4 = Instance.new("UICorner")
        uICorner4.CornerRadius = UDim.new(0, 5)
        uICorner4.Parent = divider

        local frame1 = Instance.new("Frame")
        frame1.Name = "Frame"
        frame1.AnchorPoint = Vector2.new(0.5, 1)
        frame1.BackgroundColor3 = Color3.fromRGB(31, 31, 45)
        frame1.Position = UDim2.new(0.5, 0, 1, 3)
        frame1.Size = UDim2.fromOffset(25, 6)
        frame1.Parent = divider

        local uICorner5 = Instance.new("UICorner")
        uICorner5.CornerRadius = UDim.new(0, 12)
        uICorner5.Parent = frame1

        local pagenScrolling = Instance.new("ScrollingFrame")
        pagenScrolling.Name = "PagenScrolling"
        pagenScrolling.Active = true
        pagenScrolling.AnchorPoint = Vector2.new(0.5, 0.5)
        pagenScrolling.BackgroundTransparency = 1
        pagenScrolling.Position = UDim2.fromScale(0.496496, 0.498638)
        pagenScrolling.ScrollBarImageColor3 = Color3.new()
        pagenScrolling.ScrollBarThickness = 5
        pagenScrolling.Size = UDim2.fromOffset(665, 458)
        pagenScrolling.Visible = false
        pagenScrolling.Parent = self.PageHolder

        local uICorner19 = Instance.new("UICorner")
        uICorner19.CornerRadius = UDim.new(0, 14)
        uICorner19.Parent = pagenScrolling

        local uIListLayout1 = Instance.new("UIListLayout")
        uIListLayout1.FillDirection = Enum.FillDirection.Horizontal
        uIListLayout1.Padding = UDim.new(0, 14)
        uIListLayout1.SortOrder = Enum.SortOrder.LayoutOrder
        uIListLayout1.Parent = pagenScrolling

        local uIPadding1 = Instance.new("UIPadding")
        uIPadding1.PaddingLeft = UDim.new(0, 18)
        uIPadding1.PaddingTop = UDim.new(0, 25)
        uIPadding1.Parent = pagenScrolling

        tabData.Button = tab
        tabData.Page = pagenScrolling
        tabData.Icon = icon
        table.insert(self.Tabs, tabData)

        if not self.FirstTab then
            self.FirstTab = tabData
        end

        tab.MouseButton1Click:Connect(function()
            if self.CurrentTab == tabData then return end
            
            for _, t in ipairs(self.Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Icon.ImageColor3 = Color3.fromRGB(69, 71, 90)
            end

            tabData.Page.Visible = true
            tabData.Button.BackgroundTransparency = 0.9
            tabData.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 100, 52)),
                ColorSequenceKeypoint.new(0.313149, Color3.fromRGB(243, 131, 39)),
                ColorSequenceKeypoint.new(0.536332, Color3.fromRGB(255, 157, 0)),
                ColorSequenceKeypoint.new(0.647059, Color3.fromRGB(255, 157, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 100, 52)),
            })
            gradient.Rotation = 70
            
            for _, g in ipairs(tabData.Icon:GetChildren()) do
                if g:IsA("UIGradient") then g:Destroy() end
            end
            gradient:Clone().Parent = tabData.Icon

            self.CurrentTab = tabData

            local relativeY = (tab.AbsolutePosition.Y - self.SidebarAnother.AbsolutePosition.Y) + (tab.AbsoluteSize.Y / 2)
            TweenService:Create(self.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 0, 0, relativeY)
            }):Play()
        end)

        function tabData:CreateSection(name)
            local Section = {}

            local sectionLeft = Instance.new("Frame")
            sectionLeft.Name = "Section_Left"
            sectionLeft.AnchorPoint = Vector2.new(0.5, 0)
            sectionLeft.AutomaticSize = Enum.AutomaticSize.Y
            sectionLeft.BackgroundColor3 = Color3.fromRGB(19, 19, 23)
            sectionLeft.BackgroundTransparency = 0.45
            sectionLeft.ClipsDescendants = true
            sectionLeft.Size = UDim2.fromOffset(312, 70)
            sectionLeft.Parent = pagenScrolling

            local uICorner27 = Instance.new("UICorner")
            uICorner27.CornerRadius = UDim.new(0, 6)
            uICorner27.Parent = sectionLeft

            local uIStroke7 = Instance.new("UIStroke")
            uIStroke7.Color = Color3.fromRGB(32, 34, 45)
            uIStroke7.Parent = sectionLeft

            local header = Instance.new("Frame")
            header.Name = "Header"
            header.AnchorPoint = Vector2.new(0.5, 0)
            header.BackgroundColor3 = Color3.fromRGB(23, 24, 30)
            header.BorderSizePixel = 0
            header.Position = UDim2.fromScale(0.5, 0)
            header.Size = UDim2.fromOffset(312, 30)
            header.Parent = sectionLeft

            local liner1 = Instance.new("Frame")
            liner1.Name = "Liner"
            liner1.AnchorPoint = Vector2.new(0.5, 1)
            liner1.BackgroundColor3 = Color3.fromRGB(21, 21, 25)
            liner1.BorderSizePixel = 0
            liner1.Position = UDim2.fromScale(0.5, 1)
            liner1.Size = UDim2.new(1, 1, 0, 1)
            liner1.Parent = header

            local sectionName = Instance.new("TextLabel")
            sectionName.Name = "Section_Name"
            sectionName.AnchorPoint = Vector2.new(0, 0.5)
            sectionName.AutomaticSize = Enum.AutomaticSize.XY
            sectionName.BackgroundTransparency = 1
            sectionName.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium)
            sectionName.Position = UDim2.fromScale(0.0576923, 0.5)
            sectionName.Size = UDim2.fromOffset(1, 1)
            sectionName.Text = name
            sectionName.TextColor3 = Color3.new(1, 1, 1)
            sectionName.TextSize = 14
            sectionName.Parent = header

            local uIStroke6 = Instance.new("UIStroke")
            uIStroke6.Color = Color3.fromRGB(31, 31, 45)
            uIStroke6.Thickness = 2
            uIStroke6.Parent = header

            local holder1 = Instance.new("Frame")
            holder1.Name = "Holder"
            holder1.AnchorPoint = Vector2.new(0.5, 0)
            holder1.AutomaticSize = Enum.AutomaticSize.XY
            holder1.BackgroundTransparency = 1
            holder1.Position = UDim2.fromScale(0.5, 0)
            local function GetSection()
                return self.Holder
            end
            holder1.Size = UDim2.fromOffset(1, 1)
            holder1.Parent = header

            local uIListLayout2 = Instance.new("UIListLayout")
            uIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
            uIListLayout2.Parent = holder1

            local uIPadding2 = Instance.new("UIPadding")
            uIPadding2.PaddingBottom = UDim.new(0, 5)
            uIPadding2.PaddingTop = UDim.new(0, 5)
            uIPadding2.Parent = holder1

            Section.Holder = holder1

            function Section:CreateButton(btnName, callback)
                local buttonComponent = Instance.new("Frame")
                buttonComponent.Name = "Button_Component"
                buttonComponent.AnchorPoint = Vector2.new(0.5, 0)
                buttonComponent.BackgroundTransparency = 1
                buttonComponent.Size = UDim2.fromOffset(312, 40)
                buttonComponent.Parent = self.Holder

                local button = Instance.new("TextButton")
                button.Name = "Button"
                button.AnchorPoint = Vector2.new(0.5, 0.5)
                button.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
                button.Position = UDim2.fromScale(0.5, 0.5)
                button.Size = UDim2.fromOffset(275, 30)
                button.Text = ""
                button.AutoButtonColor = false
                button.Parent = buttonComponent

                local uICorner23 = Instance.new("UICorner")
                uICorner23.CornerRadius = UDim.new(0, 3)
                uICorner23.Parent = button

                local uIStroke3 = Instance.new("UIStroke")
                uIStroke3.Color = Color3.fromRGB(34, 34, 41)
                uIStroke3.Parent = button

                local buttonText = Instance.new("TextLabel")
                buttonText.Name = "Button_Text"
                buttonText.AnchorPoint = Vector2.new(0.5, 0.5)
                buttonText.AutomaticSize = Enum.AutomaticSize.XY
                buttonText.BackgroundTransparency = 1
                buttonText.FontFace = Font.new("rbxassetid://12187365364")
                buttonText.Position = UDim2.fromScale(0.5, 0.5)
                buttonText.Size = UDim2.fromOffset(1, 1)
                buttonText.Text = btnName
                buttonText.TextColor3 = Color3.fromRGB(83, 83, 89)
                buttonText.TextSize = 15
                buttonText.Parent = button

                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(29, 29, 35)}):Play()
                end)
                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(24, 24, 30)}):Play()
                end)
                button.MouseButton1Click:Connect(function()
                    if callback then callback() end
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(34, 34, 40)}):Play()
                    task.wait(0.1)
                    TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(29, 29, 35)}):Play()
                end)
            end

            function Section:CreateToggle(toggleNameTxt, default, callback)
                local state = default or false

                local toggleComponent = Instance.new("Frame")
                toggleComponent.Name = "Toggle_Component"
                toggleComponent.AnchorPoint = Vector2.new(0.5, 0)
                toggleComponent.BackgroundTransparency = 1
                toggleComponent.Size = UDim2.fromOffset(312, 30)
                toggleComponent.Parent = self.Holder

                local toggleBtn = Instance.new("TextButton")
                toggleBtn.Name = "Toggle"
                toggleBtn.AnchorPoint = Vector2.new(0, 0.5)
                toggleBtn.BackgroundColor3 = state and Color3.fromRGB(255, 135, 66) or Color3.fromRGB(26, 26, 33)
                toggleBtn.BorderSizePixel = 0
                toggleBtn.Position = UDim2.new(0, 19, 0.5, 0)
                toggleBtn.Size = UDim2.fromOffset(25, 25)
                toggleBtn.Text = ""
                toggleBtn.Parent = toggleComponent
                
                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 4)
                toggleCorner.Parent = toggleBtn

                local checkIcon = Instance.new("ImageLabel")
                checkIcon.Name = "Check_Icon"
                checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
                checkIcon.BackgroundTransparency = 1
                checkIcon.Image = "rbxassetid://83899464799881"
                checkIcon.Position = UDim2.fromScale(0.5, 0.5)
                checkIcon.Size = UDim2.fromOffset(10, 10)
                checkIcon.Visible = state
                checkIcon.Parent = toggleBtn

                local toggleName = Instance.new("TextLabel")
                toggleName.Name = "Toggle_Name"
                toggleName.AnchorPoint = Vector2.new(0, 0.5)
                toggleName.AutomaticSize = Enum.AutomaticSize.XY
                toggleName.BackgroundTransparency = 1
                toggleName.FontFace = Font.new("rbxassetid://12187365364")
                toggleName.Position = UDim2.new(0, 53, 0.5, 0)
                toggleName.Size = UDim2.fromOffset(1, 1)
                toggleName.Text = toggleNameTxt
                toggleName.TextColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(83, 83, 89)
                toggleName.TextSize = 14
                toggleName.Parent = toggleComponent

                toggleBtn.MouseEnter:Connect(function()
                    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
                end)
                toggleBtn.MouseLeave:Connect(function()
                    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                end)
                toggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    if callback then callback(state) end
                    
                    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = state and Color3.fromRGB(255, 135, 66) or Color3.fromRGB(26, 26, 33)
                    }):Play()
                    TweenService:Create(toggleName, TweenInfo.new(0.2), {
                        TextColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(83, 83, 89)
                    }):Play()
                    
                    checkIcon.Visible = state
                end)
            end

            function Section:CreateSlider(sliderNameTxt, min, max, default, callback)
                local sliderComponent = Instance.new("Frame")
                sliderComponent.Name = "Slider_Component"
                sliderComponent.AnchorPoint = Vector2.new(0.5, 0)
                sliderComponent.BackgroundTransparency = 1
                sliderComponent.Size = UDim2.fromOffset(312, 40)
                sliderComponent.Parent = self.Holder

                local sliderText = Instance.new("TextLabel")
                sliderText.Name = "Slider_Text"
                sliderText.AnchorPoint = Vector2.new(0, 0.5)
                sliderText.AutomaticSize = Enum.AutomaticSize.XY
                sliderText.BackgroundTransparency = 1
                sliderText.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
                sliderText.Position = UDim2.new(0, 19, 0.5, -8)
                sliderText.Size = UDim2.fromOffset(1, 1)
                sliderText.Text = sliderNameTxt
                sliderText.TextColor3 = Color3.new(1, 1, 1)
                sliderText.TextSize = 14
                sliderText.Parent = sliderComponent

                local value = Instance.new("TextLabel")
                value.Name = "Value"
                value.AnchorPoint = Vector2.new(1, 0.5)
                value.AutomaticSize = Enum.AutomaticSize.XY
                value.BackgroundTransparency = 1
                value.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
                value.Position = UDim2.new(1, -20, 0.5, -8)
                value.Size = UDim2.fromOffset(1, 1)
                value.Text = tostring(default)
                value.TextColor3 = Color3.new(1, 1, 1)
                value.TextSize = 14
                value.Parent = sliderComponent

                local progressBG = Instance.new("TextButton")
                progressBG.Name = "Progress_BG"
                progressBG.AnchorPoint = Vector2.new(0, 0.5)
                progressBG.BackgroundColor3 = Color3.fromRGB(32, 32, 39)
                progressBG.BorderSizePixel = 0
                progressBG.Position = UDim2.new(0, 19, 0.6125, 13)
                progressBG.Size = UDim2.fromOffset(272, 16)
                progressBG.Text = ""
                progressBG.Parent = sliderComponent

                local progress = Instance.new("Frame")
                progress.Name = "Progress"
                progress.AnchorPoint = Vector2.new(0, 0.5)
                progress.BackgroundColor3 = Color3.fromRGB(255, 135, 66)
                progress.BorderSizePixel = 0
                progress.Position = UDim2.new(0, 0, 0.5, 0)
                local defPercent = math.clamp((default - min) / (max - min), 0, 1)
                progress.Size = UDim2.fromScale(defPercent, 1)
                progress.Parent = progressBG
                
                local dragging = false
                progressBG.MouseEnter:Connect(function()
                    TweenService:Create(progressBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
                end)
                progressBG.MouseLeave:Connect(function()
                    TweenService:Create(progressBG, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 39)}):Play()
                end)
                progressBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local sizeX = math.clamp((input.Position.X - progressBG.AbsolutePosition.X) / progressBG.AbsoluteSize.X, 0, 1)
                        progress.Size = UDim2.fromScale(sizeX, 1)
                        local val = math.floor((sizeX * (max - min)) + min)
                        value.Text = tostring(val)
                        if callback then callback(val) end
                    end
                end)
            end

            function Section:CreateDropdown(dropName, optionsList, callback)
                local dropdownComponent = Instance.new("Frame")
                dropdownComponent.Name = "Dropdown_Component"
                dropdownComponent.AnchorPoint = Vector2.new(0.5, 0)
                dropdownComponent.BackgroundTransparency = 1
                dropdownComponent.Size = UDim2.fromOffset(312, 55)
                dropdownComponent.Parent = self.Holder

                local dropdownName = Instance.new("TextLabel")
                dropdownName.Name = "Dropdown_Name"
                dropdownName.AutomaticSize = Enum.AutomaticSize.XY
                dropdownName.BackgroundTransparency = 1
                dropdownName.FontFace = Font.new("rbxassetid://12187365364")
                dropdownName.Position = UDim2.fromOffset(20, 5)
                dropdownName.Size = UDim2.fromOffset(1, 1)
                dropdownName.Text = dropName
                dropdownName.TextColor3 = Color3.fromRGB(204, 204, 209)
                dropdownName.TextSize = 14
                dropdownName.Parent = dropdownComponent

                local holder2 = Instance.new("TextButton")
                holder2.Name = "Holder"
                holder2.AnchorPoint = Vector2.new(0.5, 1)
                holder2.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
                holder2.Position = UDim2.fromScale(0.5, 1)
                holder2.Size = UDim2.fromOffset(272, 22)
                holder2.Text = ""
                holder2.Parent = dropdownComponent

                local uIStroke = Instance.new("UIStroke")
                uIStroke.Color = Color3.fromRGB(34, 34, 41)
                uIStroke.Parent = holder2

                local uICorner20 = Instance.new("UICorner")
                uICorner20.CornerRadius = UDim.new(0, 2)
                uICorner20.Parent = holder2

                local options = Instance.new("TextLabel")
                options.Name = "Options"
                options.AnchorPoint = Vector2.new(0, 0.5)
                options.AutomaticSize = Enum.AutomaticSize.XY
                options.BackgroundTransparency = 1
                options.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold)
                options.Position = UDim2.new(0, 8, 0.5, -1)
                options.Size = UDim2.fromOffset(1, 1)
                options.Text = optionsList[1] or "Select..."
                options.TextColor3 = Color3.new(1, 1, 1)
                options.TextSize = 14
                options.Parent = holder2

                local iconHolder = Instance.new("Frame")
                iconHolder.Name = "Icon_Holder"
                iconHolder.AnchorPoint = Vector2.new(1, 0.5)
                iconHolder.BackgroundTransparency = 1
                iconHolder.Position = UDim2.fromScale(1, 0.5)
                iconHolder.Size = UDim2.fromOffset(22, 22)
                iconHolder.Parent = holder2

                local imageLabel = Instance.new("ImageLabel")
                imageLabel.Name = "ImageLabel"
                imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
                imageLabel.BackgroundTransparency = 1
                imageLabel.Image = "rbxassetid://78175665375427"
                imageLabel.Position = UDim2.fromScale(0.5, 0.5)
                imageLabel.ScaleType = Enum.ScaleType.Fit
                imageLabel.Size = UDim2.fromOffset(15, 15)
                imageLabel.Parent = iconHolder
                
                holder2.MouseEnter:Connect(function()
                    TweenService:Create(holder2, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
                end)
                holder2.MouseLeave:Connect(function()
                    TweenService:Create(holder2, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(26, 26, 33)}):Play()
                end)
                
                local idx = 1
                holder2.MouseButton1Click:Connect(function()
                    if #optionsList > 0 then
                        idx = idx + 1
                        if idx > #optionsList then idx = 1 end
                        options.Text = optionsList[idx]
                        if callback then callback(optionsList[idx]) end
                    end
                end)
            end

            function Section:CreateKeybind(keyName, default, callback)
                local keybindComponent = Instance.new("Frame")
                keybindComponent.Name = "Keybind_Component"
                keybindComponent.AnchorPoint = Vector2.new(0.5, 0)
                keybindComponent.BackgroundTransparency = 1
                keybindComponent.Size = UDim2.fromOffset(312, 50)
                keybindComponent.Parent = self.Holder

                local toggleName1 = Instance.new("TextLabel")
                toggleName1.Name = "Toggle_Name"
                toggleName1.AnchorPoint = Vector2.new(0, 0.5)
                toggleName1.AutomaticSize = Enum.AutomaticSize.XY
                toggleName1.BackgroundTransparency = 1
                toggleName1.FontFace = Font.new("rbxassetid://12187365364")
                toggleName1.Position = UDim2.new(0, 19, 0.5, 0)
                toggleName1.Size = UDim2.fromOffset(1, 1)
                toggleName1.Text = keyName
                toggleName1.TextColor3 = Color3.new(1, 1, 1)
                toggleName1.TextSize = 14
                toggleName1.Parent = keybindComponent

                local holder3 = Instance.new("TextButton")
                holder3.Name = "Holder"
                holder3.AnchorPoint = Vector2.new(1, 0.5)
                holder3.AutomaticSize = Enum.AutomaticSize.XY
                holder3.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
                holder3.Position = UDim2.new(1, -19, 0.5, 0)
                holder3.Size = UDim2.fromOffset(16, 16)
                holder3.Text = ""
                holder3.Parent = keybindComponent

                local uIStroke1 = Instance.new("UIStroke")
                uIStroke1.Color = Color3.fromRGB(34, 34, 41)
                uIStroke1.Parent = holder3

                local uICorner21 = Instance.new("UICorner")
                uICorner21.CornerRadius = UDim.new(0, 3)
                uICorner21.Parent = holder3

                local uIListLayout3 = Instance.new("UIListLayout")
                uIListLayout3.FillDirection = Enum.FillDirection.Horizontal
                uIListLayout3.Parent = holder3

                local iconHolder1 = Instance.new("Frame")
                iconHolder1.Name = "Icon_Holder"
                iconHolder1.BackgroundTransparency = 1
                iconHolder1.Size = UDim2.fromOffset(22, 22)
                iconHolder1.Parent = holder3

                local imageLabel1 = Instance.new("ImageLabel")
                imageLabel1.AnchorPoint = Vector2.new(0.5, 0.5)
                imageLabel1.BackgroundTransparency = 1
                imageLabel1.Image = "rbxassetid://112243474448065"
                imageLabel1.ImageColor3 = Color3.fromRGB(255, 135, 66)
                imageLabel1.Position = UDim2.new(0.5, 2, 0.5, 0)
                imageLabel1.ScaleType = Enum.ScaleType.Fit
                imageLabel1.Size = UDim2.fromOffset(20, 20)
                imageLabel1.Parent = iconHolder1

                local inline = Instance.new("Frame")
                inline.AnchorPoint = Vector2.new(1, 0.5)
                inline.BackgroundColor3 = Color3.fromRGB(34, 34, 41)
                inline.BorderSizePixel = 0
                inline.Position = UDim2.new(1, 5, 0.5, 0)
                inline.Size = UDim2.new(0.01, 1, 0.6, 1)
                inline.Parent = iconHolder1

                local value1 = Instance.new("TextLabel")
                value1.Name = "Value"
                value1.AnchorPoint = Vector2.new(0, 0.5)
                value1.AutomaticSize = Enum.AutomaticSize.XY
                value1.BackgroundTransparency = 1
                value1.FontFace = Font.new("rbxassetid://12187365364")
                value1.Size = UDim2.fromOffset(1, 1)
                value1.Text = default
                value1.TextColor3 = Color3.new(1, 1, 1)
                value1.TextSize = 14
                value1.Parent = holder3

                local uIPadding3 = Instance.new("UIPadding")
                uIPadding3.PaddingBottom = UDim.new(0, 4)
                uIPadding3.PaddingLeft = UDim.new(0, 10)
                uIPadding3.PaddingRight = UDim.new(0, 10)
                uIPadding3.PaddingTop = UDim.new(0, 4)
                uIPadding3.Parent = value1

                holder3.MouseEnter:Connect(function()
                    TweenService:Create(holder3, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
                end)
                holder3.MouseLeave:Connect(function()
                    TweenService:Create(holder3, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(26, 26, 33)}):Play()
                end)

                local binding = false
                holder3.MouseButton1Click:Connect(function()
                    binding = true
                    value1.Text = "..."
                end)
                UserInputService.InputBegan:Connect(function(input)
                    if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        binding = false
                        value1.Text = input.KeyCode.Name
                        if callback then callback(input.KeyCode) end
                    end
                end)
            end

            function Section:CreateTextbox(boxName, default, callback)
                local keybindComponent = Instance.new("Frame")
                keybindComponent.Name = "Textbox_Component"
                keybindComponent.AnchorPoint = Vector2.new(0.5, 0)
                keybindComponent.BackgroundTransparency = 1
                keybindComponent.Size = UDim2.fromOffset(312, 50)
                keybindComponent.Parent = self.Holder

                local toggleName = Instance.new("TextLabel")
                toggleName.AnchorPoint = Vector2.new(0, 0.5)
                toggleName.AutomaticSize = Enum.AutomaticSize.XY
                toggleName.BackgroundTransparency = 1
                toggleName.FontFace = Font.new("rbxassetid://12187365364")
                toggleName.Position = UDim2.new(0, 19, 0.25, 0)
                toggleName.Size = UDim2.fromOffset(1, 1)
                toggleName.Text = boxName
                toggleName.TextColor3 = Color3.new(1, 1, 1)
                toggleName.TextSize = 14
                toggleName.Parent = keybindComponent

                local holder3 = Instance.new("Frame")
                holder3.AnchorPoint = Vector2.new(0.5, 1)
                holder3.AutomaticSize = Enum.AutomaticSize.XY
                holder3.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
                holder3.Position = UDim2.fromScale(0.5, 1)
                holder3.Size = UDim2.fromOffset(272, 16)
                holder3.Parent = keybindComponent

                local uIStroke = Instance.new("UIStroke")
                uIStroke.Color = Color3.fromRGB(34, 34, 41)
                uIStroke.Parent = holder3

                local uICorner = Instance.new("UICorner")
                uICorner.CornerRadius = UDim.new(0, 3)
                uICorner.Parent = holder3

                local uIListLayout = Instance.new("UIListLayout")
                uIListLayout.FillDirection = Enum.FillDirection.Horizontal
                uIListLayout.Parent = holder3

                local value = Instance.new("TextBox")
                value.Name = "Value"
                value.AnchorPoint = Vector2.new(0, 0.5)
                value.AutomaticSize = Enum.AutomaticSize.XY
                value.BackgroundTransparency = 1
                value.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium)
                value.Size = UDim2.fromOffset(113, 32)
                value.Text = default
                value.TextColor3 = Color3.new(1, 1, 1)
                value.TextSize = 14
                value.ClearTextOnFocus = false
                value.Parent = holder3

                local uIPadding = Instance.new("UIPadding")
                uIPadding.PaddingBottom = UDim.new(0, 4)
                uIPadding.PaddingRight = UDim.new(0, 3)
                uIPadding.PaddingTop = UDim.new(0, 4)
                uIPadding.Parent = value
                
                value.Focused:Connect(function()
                    TweenService:Create(holder3, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(32, 32, 40)}):Play()
                end)
                value.FocusLost:Connect(function()
                    TweenService:Create(holder3, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(26, 26, 33)}):Play()
                    if callback then callback(value.Text) end
                end)
            end

            return Section
        end

        return tabData
    end

    function Window:SelectFirst()
        if self.FirstTab then
            self.Holder.UIListLayout:ApplyLayout()
            
            local tabData = self.FirstTab
            local tab = tabData.Button
            
            tabData.Page.Visible = true
            tabData.Button.BackgroundTransparency = 0.9
            tabData.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)

            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 100, 52)),
                ColorSequenceKeypoint.new(0.313149, Color3.fromRGB(243, 131, 39)),
                ColorSequenceKeypoint.new(0.536332, Color3.fromRGB(255, 157, 0)),
                ColorSequenceKeypoint.new(0.647059, Color3.fromRGB(255, 157, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 100, 52)),
            })
            gradient.Rotation = 70
            gradient:Clone().Parent = tabData.Icon

            self.CurrentTab = tabData

            task.spawn(function()
                task.wait(0.05) 
                local relativeY = (tab.AbsolutePosition.Y - self.SidebarAnother.AbsolutePosition.Y) + (tab.AbsoluteSize.Y / 2)
                self.Indicator.Position = UDim2.new(1, 0, 0, relativeY)
            end)
        end
    end

    return Window
end

return Library
