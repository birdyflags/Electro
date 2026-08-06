local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local coregui = game:GetService("CoreGui")

local plr = players.LocalPlayer

local clamp = math.clamp
local fromrgb = Color3.fromRGB
local new = UDim2.new
local fromoffset = UDim2.fromOffset
local vector2 = Vector2.new

local accent = fromrgb(255, 160, 60)
local dark = fromrgb(11, 11, 11)
local darker = fromrgb(14, 14, 14)
local darker2 = fromrgb(21, 21, 21)
local textcol = fromrgb(255, 255, 255)
local texthover = fromrgb(255, 200, 150)

local currentlib = nil
local currenttab = nil

local function ismobile()
    return uis.TouchEnabled
end

local function tween(obj, info, goal)
    ts:Create(obj, info, goal):Play()
end

local function makedraggable(gui)
    local dragging = false
    local dragstart
    local startpos

    local function set(input)
        local delta = input.Position - dragstart
        local newx = startpos.X.Offset + delta.X
        local newy = startpos.Y.Offset + delta.Y

        local screensize = gui.Parent.AbsoluteSize
        local guisize = gui.AbsoluteSize

        newx = clamp(newx, 0, screensize.X - guisize.X)
        newy = clamp(newy, 0, screensize.Y - guisize.Y)

        tween(gui, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = new(0, newx, 0, newy)})
    end

    local inputchanged

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragstart = input.Position
            startpos = gui.Position

            if inputchanged then
                return
            end

            inputchanged = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    inputchanged:Disconnect()
                    inputchanged = nil
                end
            end)
        end
    end)

    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                set(input)
            end
        end
    end)
end

local function new(name)
    local lib = {}
    lib.name = name or "stellarzfun"
    lib.open = false
    lib.tabs = {}
    
    local screensize = workspace.CurrentCamera.ViewportSize
    local ismob = ismobile()
    
    local uisize = ismob and fromoffset(math.min(screensize.X * 0.8, 400), math.min(screensize.Y * 0.6, 300)) or fromoffset(681, 480)
    
    local screen = Instance.new("ScreenGui")
    screen.Name = lib.name
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = coregui
    
    local main = Instance.new("Frame")
    main.Name = "main"
    main.AnchorPoint = vector2(0.5, 0.5)
    main.BackgroundColor3 = dark
    main.Position = new(0.5, 0, 0.5, 0)
    main.Size = uisize
    main.Parent = screen
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = new(0, 8)
    corner.Parent = main
    
    makedraggable(main)
    
    local tabcontainer = Instance.new("Frame")
    tabcontainer.Name = "tabcontainer"
    tabcontainer.BackgroundColor3 = darker
    tabcontainer.Size = new(0, ismob and 60 or 80, 1, 0)
    tabcontainer.Parent = main
    
    local tabcorner = Instance.new("UICorner")
    tabcorner.CornerRadius = new(0, 8)
    tabcorner.Parent = tabcontainer
    
    local tablist = Instance.new("ScrollingFrame")
    tablist.Name = "tablist"
    tablist.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tablist.BackgroundTransparency = 1
    tablist.CanvasSize = new(0, 0, 0, 0)
    tablist.ScrollBarThickness = 2
    tablist.ScrollBarImageColor3 = accent
    tablist.Size = new(1, 0, 1, 0)
    tablist.Parent = tabcontainer
    
    local tablayout = Instance.new("UIListLayout")
    tablayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tablayout.Padding = new(0, 8)
    tablayout.SortOrder = Enum.SortOrder.LayoutOrder
    tablayout.Parent = tablist
    
    local content = Instance.new("Frame")
    content.Name = "content"
    content.BackgroundColor3 = darker2
    content.Position = new(0, ismob and 60 or 80, 0, 0)
    content.Size = new(1, -(ismob and 60 or 80), 1, 0)
    content.Parent = main
    
    local contentcorner = Instance.new("UICorner")
    contentcorner.CornerRadius = new(0, 8)
    contentcorner.Parent = content
    
    local subtabbar = Instance.new("Frame")
    subtabbar.Name = "subtabbar"
    subtabbar.BackgroundColor3 = darker2
    subtabbar.Size = new(1, 0, 0, 45)
    subtabbar.Parent = content
    
    local subtablist = Instance.new("ScrollingFrame")
    subtablist.Name = "subtablist"
    subtablist.AutomaticCanvasSize = Enum.AutomaticSize.X
    subtablist.BackgroundTransparency = 1
    subtablist.CanvasSize = new(0, 0, 0, 0)
    subtablist.ScrollBarThickness = 0
    subtablist.Size = new(1, -20, 1, 0)
    subtablist.Position = new(0, 10, 0, 0)
    subtablist.Parent = subtabbar
    
    local subtablayout = Instance.new("UIListLayout")
    subtablayout.FillDirection = Enum.FillDirection.Horizontal
    subtablayout.Padding = new(0, 10)
    subtablayout.Parent = subtablist
    
    local pagecontainer = Instance.new("Frame")
    pagecontainer.Name = "pagecontainer"
    pagecontainer.BackgroundTransparency = 1
    pagecontainer.Position = new(0, 0, 0, 45)
    pagecontainer.Size = new(1, 0, 1, -45)
    pagecontainer.Parent = content
    
    local pagelist = Instance.new("ScrollingFrame")
    pagelist.Name = "pagelist"
    pagelist.AutomaticCanvasSize = Enum.AutomaticSize.Y
    pagelist.BackgroundTransparency = 1
    pagelist.CanvasSize = new(0, 0, 0, 0)
    pagelist.ScrollBarThickness = 2
    pagelist.ScrollBarImageColor3 = accent
    pagelist.Size = new(1, 0, 1, 0)
    pagelist.Parent = pagecontainer
    
    local pagelayout = Instance.new("UIListLayout")
    pagelayout.Padding = new(0, 10)
    pagelayout.Parent = pagelist
    
    lib.screen = screen
    lib.main = main
    lib.tablist = tablist
    lib.subtablist = subtablist
    lib.pagelist = pagelist
    lib.tabcontainer = tabcontainer
    lib.content = content
    lib.subtabbar = subtabbar
    lib.pagecontainer = pagecontainer
    
    screen.Enabled = false
    
    function lib:toggle()
        lib.open = not lib.open
        lib.screen.Enabled = lib.open
        
        if lib.open then
            tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = uisize
            })
        else
            tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = new(0, 0, 0, 0)
            })
        end
    end
    
    function lib:addtab(name)
        local tab = {}
        tab.name = name
        tab.subtabs = {}
        tab.elements = {}
        
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.BackgroundColor3 = darker
        btn.BackgroundTransparency = 1
        btn.Size = new(1, -10, 0, 35)
        btn.Text = name
        btn.TextColor3 = textcol
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.Parent = lib.tablist
        
        local btncorner = Instance.new("UICorner")
        btncorner.CornerRadius = new(0, 6)
        btncorner.Parent = btn
        
        local tabpage = Instance.new("Frame")
        tabpage.Name = name
        tabpage.BackgroundTransparency = 1
        tabpage.Size = new(1, 0, 1, 0)
        tabpage.Visible = false
        tabpage.Parent = lib.pagelist
        
        local pagepad = Instance.new("UIPadding")
        pagepad.PaddingTop = new(0, 10)
        pagepad.PaddingLeft = new(0, 10)
        pagepad.PaddingRight = new(0, 10)
        pagepad.Parent = tabpage
        
        local pagelayout = Instance.new("UIListLayout")
        pagelayout.Padding = new(0, 8)
        pagelayout.Parent = tabpage
        
        btn.MouseButton1Click:Connect(function()
            if currenttab then
                currenttab.page.Visible = false
                currenttab.btn.TextColor3 = textcol
                currenttab.btn.BackgroundTransparency = 1
            end
            
            currenttab = tab
            tab.page = tabpage
            tab.btn = btn
            
            tabpage.Visible = true
            btn.TextColor3 = accent
            btn.BackgroundTransparency = 0.5
            
            tween(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.5
            })
        end)
        
        btn.MouseEnter:Connect(function()
            tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                TextColor3 = texthover
            })
        end)
        
        btn.MouseLeave:Connect(function()
            if currenttab ~= tab then
                tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    TextColor3 = textcol
                })
            else
                tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    TextColor3 = accent
                })
            end
        end)
        
        function tab:addsubtab(name)
            local subtab = {}
            subtab.name = name
            subtab.elements = {}
            
            local subbtn = Instance.new("TextButton")
            subbtn.Name = name
            subbtn.BackgroundColor3 = darker
            subbtn.BackgroundTransparency = 1
            subbtn.Size = new(0, 80, 1, -10)
            subbtn.Text = name
            subbtn.TextColor3 = textcol
            subbtn.TextSize = 12
            subbtn.Font = Enum.Font.Gotham
            subbtn.Parent = lib.subtablist
            
            local subbtncorner = Instance.new("UICorner")
            subbtncorner.CornerRadius = new(0, 4)
            subbtncorner.Parent = subbtn
            
            local subpage = Instance.new("Frame")
            subpage.Name = name
            subpage.BackgroundTransparency = 1
            subpage.Size = new(1, 0, 0, 0)
            subpage.Visible = false
            subpage.Parent = tabpage
            
            local sublayout = Instance.new("UIListLayout")
            sublayout.Padding = new(0, 6)
            sublayout.Parent = subpage
            
            subbtn.MouseButton1Click:Connect(function()
                for _, sub in ipairs(tab.subtabs) do
                    sub.page.Visible = false
                    sub.btn.TextColor3 = textcol
                    sub.btn.BackgroundTransparency = 1
                end
                
                subpage.Visible = true
                subbtn.TextColor3 = accent
                subbtn.BackgroundTransparency = 0.5
                
                tween(subbtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0.5
                })
            end)
            
            subbtn.MouseEnter:Connect(function()
                tween(subbtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    TextColor3 = texthover
                })
            end)
            
            subbtn.MouseLeave:Connect(function()
                if subpage.Visible then
                    tween(subbtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = accent
                    })
                else
                    tween(subbtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = textcol
                    })
                end
            end)
            
            function subtab:addtoggle(name, callback)
                local toggle = {}
                toggle.name = name
                toggle.state = false
                toggle.callback = callback or function() end
                
                local toggleframe = Instance.new("Frame")
                toggleframe.Name = "toggle"
                toggleframe.BackgroundTransparency = 1
                toggleframe.Size = fromoffset(237, 22)
                toggleframe.Parent = subpage
                
                local toggleb = Instance.new("TextButton")
                toggleb.Name = "toggleb"
                toggleb.AnchorPoint = Vector2.new(1, 0.5)
                toggleb.AutoButtonColor = false
                toggleb.BackgroundColor3 = darker2
                toggleb.Font = Enum.Font.Gotham
                toggleb.LayoutOrder = 2
                toggleb.Position = new(0.16, -5, 0.5, 0)
                toggleb.Size = fromoffset(33, 18)
                toggleb.Text = ""
                toggleb.TextColor3 = Color3.new()
                toggleb.TextSize = 14
                toggleb.Parent = toggleframe
                
                local uicorner13 = Instance.new("UICorner")
                uicorner13.Name = "UICorner"
                uicorner13.CornerRadius = new(0, 999)
                uicorner13.Parent = toggleb
                
                local bg = Instance.new("Frame")
                bg.Name = "bg"
                bg.BackgroundTransparency = 1
                bg.BorderMode = Enum.BorderMode.Inset
                bg.Position = fromoffset(0, 1)
                bg.Size = new(1, -2, 1, -2)
                bg.Parent = toggleb
                
                local uicorner14 = Instance.new("UICorner")
                uicorner14.Name = "UICorner"
                uicorner14.CornerRadius = new(0, 999)
                uicorner14.Parent = bg
                
                local uigradient6 = Instance.new("UIGradient")
                uigradient6.Name = "UIGradient"
                uigradient6.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, fromrgb(211, 211, 211)),
                    ColorSequenceKeypoint.new(1, fromrgb(211, 211, 211)),
                })
                uigradient6.Parent = bg
                
                local ball = Instance.new("Frame")
                ball.Name = "ball"
                ball.BackgroundColor3 = Color3.new(1, 1, 1)
                ball.Position = fromoffset(3, 2)
                ball.Size = fromoffset(12, 12)
                ball.Parent = bg
                
                local uicorner15 = Instance.new("UICorner")
                uicorner15.Name = "UICorner"
                uicorner15.CornerRadius = new(0, 999)
                uicorner15.Parent = ball
                
                local uigradient7 = Instance.new("UIGradient")
                uigradient7.Name = "UIGradient"
                uigradient7.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, fromrgb(141, 141, 141)),
                })
                uigradient7.Rotation = 1230
                uigradient7.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.3),
                    NumberSequenceKeypoint.new(1, 0.3),
                })
                uigradient7.Parent = ball
                
                local title = Instance.new("TextLabel")
                title.Name = "title"
                title.AutomaticSize = Enum.AutomaticSize.XY
                title.BackgroundTransparency = 1
                title.Font = Enum.Font.GothamSemibold
                title.Position = new(0.165485, 0, 0.136364, 0)
                title.Size = new(0.133647, 0, 0.727273, 0)
                title.Text = name
                title.TextColor3 = fromrgb(245, 245, 245)
                title.TextSize = 14
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = toggleframe
                
                local uipadding3 = Instance.new("UIPadding")
                uipadding3.Name = "UIPadding"
                uipadding3.PaddingLeft = new(0, 5)
                uipadding3.PaddingRight = new(0, 5)
                uipadding3.Parent = title
                
                local list = Instance.new("Frame")
                list.Name = "list"
                list.BackgroundColor3 = Color3.new(1, 1, 1)
                list.BorderColor3 = Color3.new()
                list.BorderSizePixel = 0
                list.Position = new(1, 0, 0.25, 0)
                list.Size = new(0, 0, 1, 0)
                list.Parent = toggleframe
                
                local uilistlayout4 = Instance.new("UIListLayout")
                uilistlayout4.Name = "UIListLayout"
                uilistlayout4.FillDirection = Enum.FillDirection.Horizontal
                uilistlayout4.HorizontalAlignment = Enum.HorizontalAlignment.Right
                uilistlayout4.Padding = new(0, 9)
                uilistlayout4.SortOrder = Enum.SortOrder.LayoutOrder
                uilistlayout4.Parent = list
                
                toggleb.MouseButton1Click:Connect(function()
                    toggle.state = not toggle.state
                    toggle.callback(toggle.state)
                    
                    if toggle.state then
                        tween(toggleb, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = accent
                        })
                        tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = fromoffset(17, 3)
                        })
                        local uigradient9 = Instance.new("UIGradient")
                        uigradient9.Name = "UIGradient"
                        uigradient9.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, accent),
                            ColorSequenceKeypoint.new(1, fromrgb(200, 120, 40)),
                        })
                        uigradient9.Rotation = 90
                        uigradient9.Parent = toggleb
                    else
                        tween(toggleb, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = darker2
                        })
                        tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = fromoffset(3, 2)
                        })
                    end
                end)
                
                toggleframe.MouseEnter:Connect(function()
                    tween(title, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = texthover
                    })
                end)
                
                toggleframe.MouseLeave:Connect(function()
                    tween(title, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = fromrgb(245, 245, 245)
                    })
                end)
                
                function toggle:set(state)
                    toggle.state = state
                    toggle.callback(state)
                    
                    if state then
                        tween(toggleb, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = accent
                        })
                        tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = fromoffset(17, 3)
                        })
                    else
                        tween(toggleb, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = darker2
                        })
                        tween(ball, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Position = fromoffset(3, 2)
                        })
                    end
                end
                
                table.insert(subtab.elements, toggle)
                return toggle
            end
            
            function subtab:addbutton(name, callback)
                local button = {}
                button.name = name
                button.callback = callback or function() end
                
                local btnframe = Instance.new("TextButton")
                btnframe.Name = "Button"
                btnframe.AutoButtonColor = false
                btnframe.BackgroundColor3 = darker2
                btnframe.Font = Enum.Font.GothamSemibold
                btnframe.Size = new(1, 0, 0, 32)
                btnframe.Text = name
                btnframe.TextColor3 = Color3.new(1, 1, 1)
                btnframe.TextSize = 14
                btnframe.Parent = subpage
                
                local btncorner = Instance.new("UICorner")
                btncorner.Name = "UICorner"
                btncorner.CornerRadius = new(0, 3)
                btncorner.Parent = btnframe
                
                btnframe.MouseButton1Click:Connect(function()
                    button.callback()
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundColor3 = accent
                    })
                    task.wait(0.1)
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundColor3 = darker2
                    })
                end)
                
                btnframe.MouseEnter:Connect(function()
                    tween(btnframe, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = texthover
                    })
                end)
                
                btnframe.MouseLeave:Connect(function()
                    tween(btnframe, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = Color3.new(1, 1, 1)
                    })
                end)
                
                table.insert(subtab.elements, button)
                return button
            end
            
            table.insert(tab.subtabs, subtab)
            return subtab
        end
        
        table.insert(lib.tabs, tab)
        return tab
    end
    
    return lib
end

local function setupkeybind(lib)
    if ismobile() then
        local mobilebtn = Instance.new("ImageButton")
        mobilebtn.Name = "stellarzfun_toggle"
        mobilebtn.BackgroundColor3 = accent
        mobilebtn.Size = fromoffset(50, 50)
        mobilebtn.Position = fromoffset(20, 20)
        mobilebtn.Image = "rbxassetid://82741456353014"
        mobilebtn.Parent = coregui
        
        local btncorner = Instance.new("UICorner")
        btncorner.CornerRadius = new(0, 12)
        btncorner.Parent = mobilebtn
        
        mobilebtn.MouseButton1Click:Connect(function()
            lib:toggle()
        end)
        
        mobilebtn.MouseEnter:Connect(function()
            tween(mobilebtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                ImageColor3 = texthover
            })
        end)
        
        mobilebtn.MouseLeave:Connect(function()
            tween(mobilebtn, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                ImageColor3 = textcol
            })
        end)
    else
        uis.InputBegan:Connect(function(input, gameprocessed)
            if gameprocessed then return end
            if input.KeyCode == Enum.KeyCode.RightShift then
                lib:toggle()
            end
        end)
    end
end

function setup(lib)
    setupkeybind(lib)
end

return {
    new = new,
    setup = setup
}
