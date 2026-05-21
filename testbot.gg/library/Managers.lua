-- Imports
local Builder = require(script.Parent.Builder);

-- Managers
local Managers = { }; do
    local Repository = "https://raw.githubusercontent.com/dementiaenjoyer/homohack/refs/heads/main/storage";

    function Managers:GetThemeManager()
        if (self.ThemeManager) then
            return self.ThemeManager;
        end

        self.ThemeManager = loadstring(game:HttpGet(`{Repository}/ThemeManager.lua`))();

        return self.ThemeManager;
    end

    function Managers:GetSaveManager()
        if (self.SaveManager) then
            return self.SaveManager;
        end

        self.SaveManager = loadstring(game:HttpGet(`{Repository}/SaveManager.lua`))();

        return self.SaveManager;
    end

    function Managers:BuildSettings(Tab, Data)
        local Library = Builder:GetLibrary();
        local ThemeManager, SaveManager = self:GetThemeManager(), self:GetSaveManager();
        local MenuGroup = Tab:AddLeftGroupbox("Menu");

        Data = Data or { };

        MenuGroup:AddToggle("Settings/KeybindList", {
            Text = "Keybind List",
            Default = true,
            Callback = function(Value)
                Library.KeybindFrame.Visible = Value;
            end
        });

        MenuGroup:AddLabel("Keybind"):AddKeyPicker("Settings/MenuKeybind", {
            Default = Data.MenuKeybind or "End",
            NoUI = true,
            Text = "Menu keybind"
        });

        Library.ToggleKeybind = Options["Settings/MenuKeybind"];
        Library.KeybindFrame.Visible = true;

        ThemeManager:SetLibrary(Library);
        SaveManager:SetLibrary(Library);
        SaveManager:IgnoreThemeSettings();
        ThemeManager:SetFolder(Data.Folder or "testbot.gg");
        SaveManager:SetFolder(Data.ConfigFolder or "testbot.gg/default");
        SaveManager:BuildConfigSection(Tab);
        ThemeManager:ApplyToTab(Tab);
        SaveManager:LoadAutoloadConfig();
    end
end

return Managers;
