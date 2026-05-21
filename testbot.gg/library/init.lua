-- Imports
local Import = ...;

local Builder = Import("library/Builder.lua");
local Flags = Import("library/Flags.lua");
local Managers = Import("library/Managers.lua");

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
