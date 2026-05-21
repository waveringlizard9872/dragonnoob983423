-- Cache
local StringGSub = string.gsub;
local TableFind = table.find;

-- Flags
local Flags = { }; do
    local ShowFullData = {
        "KeyPicker",
        "ColorPicker",
        "Dropdown",
        "Slider",
    };

    function Flags:SetLibrary(Library)
        self.Library = Library;

        self.Values = setmetatable({ }, {
            __index = function(Self, Index)
                local FlagData = (Toggles[Index] or Options[Index]);
                local Value = FlagData and FlagData.Value;

                if (TableFind(ShowFullData, (FlagData and FlagData.Type) or "hello")) then
                    Value = FlagData;
                end

                return Value;
            end
        });

        self.Keybinds = setmetatable({ }, {
            __index = function(Self, Index)
                local Keybind = Flags.Values[StringGSub(Index, "/Enabled", "/Key")];

                return Flags.Values[Index] and Keybind and Keybind:GetState();
            end
        });
    end

    function Flags:Get(Index)
        return self.Values and self.Values[Index];
    end

    function Flags:GetKeybind(Index)
        return self.Keybinds and self.Keybinds[Index];
    end
end

return Flags;
