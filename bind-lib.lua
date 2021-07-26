local function bind(key, callback)
	local uis = game:service('UserInputService')
	uis.InputBegan:connect(function(k, t)
		if t then
			return
		end
		if k.KeyCode == Enum.KeyCode[key] then
			spawn(callback)
		end
	end)
end

return bind
