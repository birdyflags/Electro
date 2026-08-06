local stellar = {}
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local run = game:GetService("RunService")
local http = game:GetService("HttpService")
local coregui = game:GetService("CoreGui")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

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

local screens = {}
local toggles = {}
local tabs = {}
local currenttab = nil

function stellar.new(name)
    local self = {}
    self.name = name or "stellarzfun"
    self.open = false
    self.tabs = {}
    
    local screensize = workspace.CurrentCamera.ViewportSize
    local ismob = ismobile()
    
    local uisize = ismob and fromoffset(math.min(screensize.X * 0.8, 400), math.min(screensize.Y * 0.6, 300)) or fromoffset(681, 480)
    
    local screen = Instance.new("ScreenGui")
    screen.Name = self.name
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
    
    self.screen = screen
    self.main = main
    self.tablist = tablist
    self.subtablist = subtablist
    self.pagelist = pagelist
    self.tabcontainer = tabcontainer
    self.content = content
    self.subtabbar = subtabbar
    self.pagecontainer = pagecontainer
    
    screen.Enabled = false
    
    function self:toggle()
        self.open = not self.open
        self.screen.Enabled = self.open
        
        if self.open then
            tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = uisize
            })
        else
            tween(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = new(0, 0, 0, 0)
            })
        end
    end
    
    function self:addtab(name)
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
        btn.Parent = self.tablist
        
        local btncorner = Instance.new("UICorner")
        btncorner.CornerRadius = new(0, 6)
        btncorner.Parent = btn
        
        local tabpage = Instance.new("Frame")
        tabpage.Name = name
        tabpage.BackgroundTransparency = 1
        tabpage.Size = new(1, 0, 1, 0)
        tabpage.Visible = false
        tabpage.Parent = self.pagelist
        
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
            subbtn.Parent = self.subtablist
            
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
                toggleframe.Name = name
                toggleframe.BackgroundColor3 = darker
                toggleframe.Size = new(1, 0, 0, 30)
                toggleframe.Parent = subpage
                
                local togglecorner = Instance.new("UICorner")
                togglecorner.CornerRadius = new(0, 4)
                togglecorner.Parent = toggleframe
                
                local togglebtn = Instance.new("TextButton")
                togglebtn.Name = "togglebtn"
                togglebtn.BackgroundColor3 = accent
                togglebtn.Size = new(0, 20, 0, 20)
                togglebtn.Position = new(0, 8, 0.5, -10)
                togglebtn.Text = ""
                togglebtn.Parent = toggleframe
                
                local btnouter = Instance.new("UICorner")
                btnouter.CornerRadius = new(0, 4)
                btnouter.Parent = togglebtn
                
                local togglelabel = Instance.new("TextLabel")
                togglelabel.Name = "label"
                togglelabel.BackgroundTransparency = 1
                togglelabel.Position = new(0, 35, 0, 0)
                togglelabel.Size = new(1, -40, 1, 0)
                togglelabel.Text = name
                togglelabel.TextColor3 = textcol
                togglelabel.TextSize = 13
                togglelabel.Font = Enum.Font.Gotham
                togglelabel.TextXAlignment = Enum.TextXAlignment.Left
                togglelabel.Parent = toggleframe
                
                togglebtn.MouseButton1Click:Connect(function()
                    toggle.state = not toggle.state
                    toggle.callback(toggle.state)
                    
                    if toggle.state then
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = accent
                        })
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = new(0, 20, 0, 20)
                        })
                    else
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = darker
                        })
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = new(0, 18, 0, 18)
                        })
                    end
                end)
                
                toggleframe.MouseEnter:Connect(function()
                    tween(togglelabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = texthover
                    })
                end)
                
                toggleframe.MouseLeave:Connect(function()
                    tween(togglelabel, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = textcol
                    })
                end)
                
                function toggle:set(state)
                    toggle.state = state
                    toggle.callback(state)
                    
                    if state then
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = accent
                        })
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = new(0, 20, 0, 20)
                        })
                    else
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            BackgroundColor3 = darker
                        })
                        tween(togglebtn, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Size = new(0, 18, 0, 18)
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
                btnframe.Name = name
                btnframe.BackgroundColor3 = darker
                btnframe.Size = new(1, 0, 0, 30)
                btnframe.Text = name
                btnframe.TextColor3 = textcol
                btnframe.TextSize = 13
                btnframe.Font = Enum.Font.Gotham
                btnframe.Parent = subpage
                
                local btncorner = Instance.new("UICorner")
                btncorner.CornerRadius = new(0, 4)
                btncorner.Parent = btnframe
                
                btnframe.MouseButton1Click:Connect(function()
                    button.callback()
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundColor3 = accent
                    })
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = dark
                    })
                    task.wait(0.1)
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        BackgroundColor3 = darker
                    })
                    tween(btnframe, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = textcol
                    })
                end)
                
                btnframe.MouseEnter:Connect(function()
                    tween(btnframe, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = texthover
                    })
                end)
                
                btnframe.MouseLeave:Connect(function()
                    tween(btnframe, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        TextColor3 = textcol
                    })
                end)
                
                table.insert(subtab.elements, button)
                return button
            end
            
            table.insert(tab.subtabs, subtab)
            return subtab
        end
        
        table.insert(self.tabs, tab)
        return tab
    end
    
    table.insert(screens, self)
    return self
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

function stellar.setup(lib)
    setupkeybind(lib)
end

return stellar
