-- Imports
local Builder = require(script.Builder);
local Flags = require(script.Flags);
local Managers = require(script.Managers);

-- Library
local Framework = { }; do
    Framework.Builder = Builder;
    Framework.Flags = Flags;
    Framework.Managers = Managers;

    function Framework:CreateWindow(Data)
        return self.Builder:CreateWindow(Data);
    end

    function Framework:BuildSettings(Tab, Data)
        return self.Managers:BuildSettings(Tab, Data);
    end
end

return Framework;
