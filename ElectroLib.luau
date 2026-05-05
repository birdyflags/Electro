local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}

function Library:Init()
    local Window = {
        Tabs = {},
        FirstTab = nil,
        CurrentTab = nil
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ScreenGui"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui

    local mainuiframe = Instance.new("Frame")
    mainuiframe.Name = "Mainuiframe"
    mainuiframe.AnchorPoint = Vector2.new(0.5, 0.5)
    mainuiframe.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    mainuiframe.ClipsDescendants = true
    mainuiframe.Position = UDim2.fromScale(0.49746, 0.5)
    mainuiframe.Size = UDim2.fromOffset(754, 524)
    mainuiframe.Parent = screenGui

    local hEader = Instance.new("Frame")
    hEader.Name = "HEader"
    hEader.AnchorPoint = Vector2.new(0.5, 0)
    hEader.BackgroundTransparency = 1
    hEader.Position = UDim2.fromScale(0.5, 0)
    hEader.Size = UDim2.fromOffset(767, 64)
    hEader.Parent = mainuiframe

    local uICorner = Instance.new("UICorner")
    uICorner.CornerRadius = UDim.new(0, 14)
    uICorner.Parent = hEader

    local linerthingyorseparatoridontremmember = Instance.new("Frame")
    linerthingyorseparatoridontremmember.Name = "Linerthingyorseparatoridontremmember"
    linerthingyorseparatoridontremmember.AnchorPoint = Vector2.new(0.5, 1)
    linerthingyorseparatoridontremmember.BackgroundColor3 = Color3.fromRGB(31, 31, 45)
    linerthingyorseparatoridontremmember.BorderSizePixel = 0
    linerthingyorseparatoridontremmember.Position = UDim2.fromScale(0.499511, 1.01562)
    linerthingyorseparatoridontremmember.Size = UDim2.fromOffset(760, 2)
    linerthingyorseparatoridontremmember.Parent = hEader

    local uICorner1 = Instance.new("UICorner")
    uICorner1.CornerRadius = UDim.new(0, 14)
    uICorner1.Parent = mainuiframe

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
    indicator.Position = UDim2.new(1, -5, 0, 0) -- Adjusted X slightly to fit sidebar
    indicator.Size = UDim2.fromOffset(27, 33)
    indicator.Parent = sidebaranother

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 12)
    indCorner.Parent = indicator

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
        pagenScrolling.CanvasPosition = Vector2.new(0, 0)
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
                Position = UDim2.new(1, -5, 0, relativeY)
            }):Play()
        end)

        return tabData
    end

    function Window:SelectFirst()
        if self.FirstTab then
            -- Initial forced layout update for AbsolutePosition
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
                self.Indicator.Position = UDim2.new(1, -5, 0, relativeY)
            end)
        end
    end

    return Window
end

return Library
