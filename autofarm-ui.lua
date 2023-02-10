local function instance(className,properties,children,funcs)
    local object = Instance.new(className)
    
    for i,v in pairs(properties or {}) do
        object[i] = v
    end
    for i, self in pairs(children or {}) do
        self.Parent = object
    end
    for i,func in pairs(funcs or {}) do
        func(object)
    end
    return object
end

local function ts(object,tweenInfo,properties)
    if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
        tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
    end
    game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
end

local function udim2(x1,x2,y1,y2)
    local t = tonumber
    return UDim2.new(t(x1), t(x2), t(y1), t(y2))
end

local function rgb(r,g,b) 
    return Color3.fromRGB(r,g,b)
end

local function fixInt(int) 
    return tonumber(string.format('%.02f', int)) 
end

local function round(exact, quantum)
    local quant, frac = math.modf(exact/quantum)
    return fixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
end







pcall(function()
    game:GetService('CoreGui')['autofarm']:Destroy()
end)

function lib(data)
    data.Title = type(data.Title) == 'string' and data.Title or 'Some'
    data.Subtitle = type(data.Subtitle) == 'string' and data.Subtitle or 'autofarm'
    data.WebhookChanged = type(data.WebhookChanged) == 'function' and data.WebhookChanged or function() end

    local library = {}

    local sgui = instance('ScreenGui', {
        Parent = game:GetService('CoreGui'),
        Name = 'autofarm',
        IgnoreGuiInset = true
    })

    local mainFrame = instance('Frame', {
        Parent = sgui,
        Size = udim2(1, 0, 1, 0),
        BackgroundColor3 = rgb(15, 15, 20)
    }, {
        instance('TextLabel', {
            Size = udim2(0, 100, 0, 30),
            TextColor3 = rgb(40, 40, 50),
            Position = udim2(0.5, -50, 1, -36),
            Text = '<i>ui made by boop71#7833 for Peace the sexy</i>',
            RichText = true,
            BackgroundTransparency = 1,
            Font = 'JosefinSans',
            TextSize = 11
        }),
        instance('TextLabel', {
            Position = udim2(0, 0, 0, 300),
            Size = udim2(1, 0, 0, 100),
            Text = ('<b><font color="#918bff">%s</font></b> %s'):format(data.Title, data.Subtitle),
            BackgroundTransparency = 1,
            TextSize = 30,
            Font = 'JosefinSans',
            TextColor3 = rgb(255, 255, 255),
            RichText = true,
            Name = 'title'
        }, {
            instance('Frame', {
                Size = udim2(0, 500, 0, 1),
                Position = udim2(0.5, -250, 1, -3),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.8
            }, {
                instance('TextLabel', {
                    Text = 'Stats',
                    Size = udim2(0, 50, 0, 24),
                    Position = udim2(0.5, -25, 0.5, -13),
                    BackgroundColor3 = rgb(15, 15, 20),
                    BorderSizePixel = 0,
                    Text = 'Stats',
                    Font = 'JosefinSans',
                    TextSize = 13,
                    TextColor3 = rgb(220, 220, 220)
                }),
                instance('Frame', {
                    Position = udim2(0, 20, 0, 20),
                    Size = udim2(1, -40, 0, 30),
                    BackgroundColor3 = rgb(25, 25, 35),
                }, {
                    instance('UICorner', {CornerRadius = UDim.new(0, 12)}),
                    instance('TextBox', {
                        Position = udim2(0, 10, 0, 2),
                        Size = udim2(1, -16, 1, -2),
                        BackgroundTransparency = 1,
                        Text = '',
                        PlaceholderText = 'Stats webhook URL',
                        Font = 'JosefinSans',
                        TextSize = 13,
                        TextColor3 = rgb(225, 225, 255),
                        PlaceholderColor3 = rgb(178, 178, 198),
                        TextXAlignment = 'Left'
                    }, {}, {
                        function(self)
                            self.FocusLost:Connect(function()
                                data.WebhookChanged(self.Text)
                            end)
                        end
                    }),
                    instance('TextLabel', {
                        Size = udim2(0, 50, 0, 20),
                        Position = udim2(0.5, -25, 1, 6),
                        Text = '<b>. . .</b>',
                        Font = 'JosefinSans',
                        TextColor3 = rgb(255, 255, 255),
                        RichText = true,
                        BackgroundTransparency = 1,
                        TextTransparency = 0.7,
                        TextSize = 16
                    })
                }),
                instance('Frame', {
                    Position = udim2(0, 50, 0, 80),
                    Name = 'container',
                    Size = udim2(1, -100, 0, 300),
                    BackgroundTransparency = 1
                }, {
                    instance('UIListLayout', {
                        Padding = UDim.new(0, 5),
                        SortOrder = 'LayoutOrder'
                    })
                })
            })
        })
    })

    function library:AddStat(data)
        data.Text = type(data.Text) == 'string' and data.Text or 'empty'
        data.Value = type(data.Value) == 'string' and data.Value or ''

        if type(data.AutoColor) ~= 'boolean' then
            data.AutoColor = true
        end

        local textFormat = data.AutoColor and '%s: <b><font color="#918bff">%s</font></b>' or '%s: %s'

        local newStat = instance('TextLabel', {
            Size = udim2(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Text = textFormat:format(data.Text, data.Value),
            RichText = true,
            TextColor3 = rgb(255, 255, 255),
            Font = 'JosefinSans',
            TextSize = 14
        })

        newStat.Parent = mainFrame.title.Frame.container
        local newText, newValue = data.Text, data.Value

        local function upd()
            newStat.Text = textFormat:format(newText, newValue)
        end

        local d = {}

        function d:UpdateText(str)
            newText = tostring(str)
            upd()
        end

        function d:UpdateValue(str)
            newValue = tostring(str)
            upd()
        end

        return d
    end

    function library:Dropdown(data)
        data.Text = type(data.Text) == 'string' and data.Text or 'empty'
        data.Options = type(data.Options) == 'table' and data.Options or {}
        data.Value = type(data.Value) == 'string' and (data.Options[table.find(data.Options, data.Value)] or 'click to select')
        data.Callback = type(data.Callback) == 'function' and data.Callback or function() end

        local value = data.Options[1]

        local startListening
        local isListening = false
        local newDropdown

        local function createDropdown()
            local function calcSize()
                return 14 + (30 * #data.Options)
            end

            local newOption

            local new = instance('Frame', {
                Parent = sgui,
                Position = udim2(0, newDropdown.AbsolutePosition.X + newDropdown.AbsoluteSize.X + 10, 0, newDropdown.AbsolutePosition.Y + 36),
                Size = udim2(0, 200, 0, 0),
                BackgroundColor3 = rgb(35, 35, 45),
                BackgroundTransparency = 1,
                ClipsDescendants = true
            }, {
                instance('UICorner', {
                    CornerRadius = UDim.new(0, 10)
                }),
                instance('Frame', {
                    Position = udim2(0, 0, 0, 7),
                    Size = udim2(1, 0, 1, -14),
                    BackgroundTransparency = 1
                }, {
                    instance('UIListLayout')
                })
            })

            delay(0.1, function()
                ts(new, {0.3, 'Exponential'}, {
                    Size = udim2(0, 200, 0, calcSize()),
                    BackgroundTransparency = 0
                })

                delay(0.15, function()
                    for a,v in ipairs(data.Options) do
                        local newOption = instance('TextButton', {
                            Parent = new.Frame,
                            Size = udim2(1, 0, 0, 30),
                            TextTransparency = 1,
                            TextSize = (value == v and 12 or 10),
                            BackgroundTransparency = 1,
                            TextColor3 = rgb(220, 220, 255),
                            Font = 'JosefinSans',
                            Text = (value ~= v and v or ('<b>%s</b>'):format(v)),
                            RichText = true,
                            BorderSizePixel = 0,
                            BackgroundColor3 = rgb(255, 255, 255)
                        }, {}, {
                            function(self)
                                self.MouseEnter:Connect(function()
                                    ts(self, {0.3, 'Exponential'}, {
                                        BackgroundTransparency = 0.96
                                    })
                                end)

                                self.MouseLeave:Connect(function()
                                    ts(self, {0.3, 'Exponential'}, {
                                        BackgroundTransparency = 1
                                    })
                                end)

                                self.MouseButton1Up:Connect(function()
                                    newOption = v
                                end)
                            end
                        })

                        ts(newOption, {0.3, 'Exponential'}, {
                            TextTransparency = (value == v and 0 or 0.3)
                        })

                        wait(0.05)
                    end
                end)
            end)

            repeat
                wait()
            until newOption

            spawn(function()
                for a,v in next, new.Frame:GetChildren() do
                    if v:IsA('TextButton') then
                        ts(v, {0.3, 'Exponential'}, {
                            TextTransparency = 1,
                            BackgroundTransparency = 1
                        })
                        wait(0.05)
                    end
                end

                ts(new, {0.45, 'Exponential'}, {
                    Size = udim2(0, 200, 0, 0),
                    BackgroundTransparency = 1
                })

                delay(0.3, function()
                    new:Destroy()
                end)
            end)
            
            return newOption
        end

        newDropdown = instance('Frame', {
            Size = udim2(1, 0, 0, 32),
            BackgroundColor3 = rgb(30, 30, 40),
        }, {
            instance('UICorner', {
                CornerRadius = UDim.new(0, 10)
            }),
            instance('TextLabel', {
                Position = udim2(0, 10, 0, 2),
                Size = udim2(1, -10, 1, -2),
                BackgroundTransparency = 1,
                Text = data.Text,
                RichText = true,
                Font = 'JosefinSans',
                TextSize = 12,
                TextColor3 = rgb(255, 255, 255),
                TextXAlignment = 'Left'
            }),
            instance('TextLabel', {
                Position = udim2(0, 0, 0, 2),
                Size = udim2(1, -12, 1, -2),
                BackgroundTransparency = 1,
                Text = ('<b>%s</b>'):format(data.Value),
                RichText = true,
                TextColor3 = rgb(145, 139, 255),
                TextSize = 12,
                TextXAlignment = 'Right',
                Font = 'JosefinSans',
                Name = 'value'
            }),
            instance('TextButton', {
                Size = udim2(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ''
            }, {}, {
                function(self)
                    self.MouseButton1Up:Connect(function()
                        startListening()
                    end)
                end
            })
        })

        startListening = function()
            if isListening then
                return
            end
            isListening = true

            ts(newDropdown.value, {0.25, 'Exponential'}, {
                TextTransparency = 0.9
            })

            local drop = createDropdown()

            spawn(function()
                repeat
                    wait()
                until drop

                data.Callback(drop)

                value = drop

                ts(newDropdown.value, {0.1, 'Exponential'}, {
                    TextTransparency = 1
                })
                delay(0.1, function()
                    newDropdown.value.Text = drop

                    ts(newDropdown.value, {0.25, 'Exponential'}, {
                        TextTransparency = 0
                    })
                end)

                isListening = false
            end)
        end

        newDropdown.Parent = mainFrame.title.Frame.container

        local d = {}

        function d:SetOptions(opt)
            data.Options = type(opt) == 'table' and opt or data.Options
        end

        return d
    end

    return library
end



return lib
