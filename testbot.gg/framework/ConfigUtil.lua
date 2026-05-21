return function(Environment)
    local Library          = Environment.Library;
    local Slider           = Environment.Slider;
    local ColorPicker      = Environment.ColorPicker;
    local Color3FromRGB    = Environment.Color3FromRGB;
    local MathFloor        = Environment.MathFloor;
    local ToString         = Environment.ToString;

-- Config Utilities
local ConfigUtil = { }; do
    function ConfigUtil.CanUseFiles()
        return isfolder and makefolder and isfile and writefile and readfile and listfiles;
    end

    function ConfigUtil.EnsureDirectory()
        if (not ConfigUtil.CanUseFiles()) then return false; end
        if (not isfolder("Graphite"))                          then makefolder("Graphite");                          end
        if (not isfolder(Library.ConfigManager.Directory))    then makefolder(Library.ConfigManager.Directory);    end
        return true;
    end

    function ConfigUtil.Path(Name)
        return `{Library.ConfigManager.Directory}/{ToString(Name)}{Library.ConfigManager.EXTENSION}`;
    end

    function ConfigUtil.ColorToInt(Color)
        local R = MathFloor(Color.R * 255 + 0.5);
        local G = MathFloor(Color.G * 255 + 0.5);
        local B = MathFloor(Color.B * 255 + 0.5);
        return 4278190080 + R * 65536 + G * 256 + B;
    end

    function ConfigUtil.IntToColor(Value)
        local Color = tonumber(Value) or 0;
        if (Color >= 16777216) then Color = Color % 16777216; end
        return Color3FromRGB(MathFloor(Color / 65536) % 256, MathFloor(Color / 256) % 256, Color % 256);
    end

    function ConfigUtil.GetValue(Option)
        if (Option.Type == "ColorPicker") then return ConfigUtil.ColorToInt(Option:Get()); end
        return Option:Get();
    end

    function ConfigUtil.SetValue(Option, Value)
        if (Option.Type == "ColorPicker") then
            Option:Set(ConfigUtil.IntToColor(Value));
        elseif (Option.Type == "Slider") then
            Option:Set(tonumber(Value) or Option:Get());
        else
            Option:Set(Value);
        end
    end
end
    Environment.ConfigUtil = ConfigUtil;
end
