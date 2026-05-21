-- Kyanite UI

local Repository = (...) or "https://raw.githubusercontent.com/waveringlizard9872/dragonnoob983423/refs/heads/main/testbot.gg";

local Framework = { }; do
    Framework.Modules = {
        "framework/Core.lua",
        "framework/Util.lua",
        "framework/ConfigUtil.lua",
        "framework/Library.lua",
        "framework/Window.lua",
        "framework/Tab.lua",
        "framework/Groupbox.lua",
        "framework/SubTabs.lua",
        "framework/Controls.lua",
    };

    function Framework:Get(Path)
        return game:HttpGet(`{Repository}/{Path}`);
    end

    function Framework:Load(Path, ...)
        return loadstring(self:Get(Path))(...);
    end

    function Framework:Boot()
        local Environment = self:Load(self.Modules[1], Repository);

        for Index = 2, #self.Modules do
            self:Load(self.Modules[Index])(Environment);
        end

        return Environment.Library;
    end
end

return Framework:Boot();
