getgenv().instance = function(className,properties,children,funcs)
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

getgenv().ts = function(object,tweenInfo,properties)
    if tweenInfo[2] and typeof(tweenInfo[2]) == 'string' then
        tweenInfo[2] = Enum.EasingStyle[ tweenInfo[2] ]
    end
    game:service('TweenService'):create(object, TweenInfo.new(unpack(tweenInfo)), properties):Play()
end

getgenv().udim2 = function(x1,x2,y1,y2)
    local t = tonumber
    return UDim2.new(t(x1), t(x2), t(y1), t(y2))
end

getgenv().rgb = function(r,g,b) 
    return Color3.fromRGB(r,g,b)
end

getgenv().fixInt = function(int) 
    return tonumber(string.format('%.02f', int)) 
end

getgenv().round = function(exact, quantum)
    local quant, frac = math.modf(exact/quantum)
    return fixInt(quantum * (quant + (frac > 0.5 and 1 or 0)))
end

getgenv().scale = function(unscaled, minAllowed, maxAllowed, min, max)
    return (maxAllowed - minAllowed) * (unscaled - min) / (max - min) + minAllowed
end

getgenv().glow = function(frame, radius, step, color)
    local instances = {}

    local folder = instance('Folder', {
        Parent = frame,
        Name = 'glow'
    })
    
    local function newInstance(thick)
        local new = instance('Frame', {
            Parent = folder,
            BackgroundTransparency = 1,
            Size = udim2(1, 0, 1, 0)
        }, {
            (function()
                local d, c = nil, frame:FindFirstChildWhichIsA('UICorner')
                if c then
                    d = instance('UICorner', {
                        CornerRadius = c.CornerRadius
                    })

                    c:GetPropertyChangedSignal('CornerRadius'):Connect(function()
                        d.CornerRadius = c.CornerRadius
                    end)
                end
                return d
            end)(),
            instance('UIStroke', {
                Transparency = 0.95,
                Thickness = thick,
                Color = typeof(color) == 'Color3' and color or Color3.new(0, 0, 0)
            })
        })
        
        table.insert(instances, new.UIStroke)
    end

    for a=1,radius,step do
        newInstance(a)
    end

    local function change(func)
        for a,v in next, instances do
            func(v)
        end
    end

    return {
        setColor = function(c)
            change(function(v)
                ts(v, {0.3, 'Exponential'}, {
                    Color = c
                })
            end)
        end,
        hide = function()
            change(function(v)
                ts(v, {0.2, 'Exponential'}, {
                    Transparency = 1
                })
            end)
        end,
        show = function()
            change(function(v)
                ts(v, {0.2, 'Exponential'}, {
                    Transparency = 0.95
                })
            end)
        end
    }
end

local mouse = game:service('Players').LocalPlayer:GetMouse()

getgenv().checkPos = function(obj)
    local x, y = mouse.X, mouse.Y
    local abs, abp = obj.AbsoluteSize, obj.AbsolutePosition

    if x > abp.X and x < (abp.X + abs.X) and y > abp.Y and y < (abp.Y + abs.Y) then
        return true
    end
    return nil
end

getgenv().dragify = function(frame) 
    local connection, move, kill
    local function connect()
        connection = frame.InputBegan:Connect(function(inp) 
            pcall(function() 
                if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then 
                    local mx, my = mouse.X, mouse.Y 
                    move = mouse.Move:Connect(function() 
                        local nmx, nmy = mouse.X, mouse.Y 
                        local dx, dy = nmx - mx, nmy - my 
                        frame.Position = frame.Position + UDim2.fromOffset(dx, dy)
                        mx, my = nmx, nmy 
                    end) 
                    kill = frame.InputEnded:Connect(function(inputType) 
                        if inputType.UserInputType == Enum.UserInputType.MouseButton1 then 
                            move:Disconnect() 
                            kill:Disconnect() 
                        end 
                    end) 
                end 
            end) 
        end) 
    end
    connect()
    return {
        disconnect = function()
            connection:Disconnect()
        end,
        reconnect = connect,
        killConnection = function()
            move:Disconnect()
            kill:Disconnect()
        end
    }
end

getgenv().getRel = function(object)
    return {
        X = (mouse.X - object.AbsolutePosition.X),
        Y = (mouse.Y - object.AbsolutePosition.Y)
    }
end

getgenv().makeBetter = function(obj, maxSize)
    local drag = dragify(obj)

    local button = instance('TextButton', {
        Parent = obj,
        Size = udim2(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = '',
        Position = udim2(1, -10, 1, -10)
    })

    local holding = false
    button.MouseButton1Down:Connect(function()
        holding = true
        drag.disconnect()

        spawn(function()
            repeat
                local sX, sY = (getRel(obj).X - obj.AbsoluteSize.X), (getRel(obj).Y - obj.AbsoluteSize.Y)
                wait()
                ts(obj, {0.5, 'Exponential'}, {
                    Size = udim2(0, (obj.AbsoluteSize.X + sX > maxSize.X and obj.AbsoluteSize.X + sX or maxSize.X), 0, (obj.AbsoluteSize.Y + sY > maxSize.Y and obj.AbsoluteSize.Y + sY or maxSize.Y))
                })
            until not holding
        end)
    end)

    local function unhold()
        if holding then
            holding = false
            drag.reconnect()
        end
    end

    button.MouseButton1Up:Connect(unhold)
    mouse.Button1Up:Connect(unhold)
end

getgenv().corner = function(r, r2)
    return instance('UICorner', {
        CornerRadius = UDim.new(r, r2)
    })
end

local uis = game:service('UserInputService')

getgenv().addBind = function(key, callback)
    local key2 = key

    uis.InputBegan:Connect(function(k, t)
        if t then
            return
        end

        pcall(function()
            if k.KeyCode == Enum.KeyCode[key2] then
                callback()
            end
        end)
    end)

    return {
        setKey = function(s)
            key2 = s
        end
    }
end
