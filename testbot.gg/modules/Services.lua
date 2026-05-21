-- Services
local Service = setmetatable({ }, { __index = function(Self, Index)
    return cloneref(game.GetService(game, Index));
end })

return Service;
