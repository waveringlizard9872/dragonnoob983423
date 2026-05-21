-- Services
local CloneRef = cloneref or function(Object)
    return Object;
end

local Service = setmetatable({ }, { __index = function(Self, Index)
    return CloneRef(game.GetService(game, Index));
end })

return Service;
