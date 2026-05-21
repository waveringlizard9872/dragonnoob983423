-- Loader
local Repository = "https://raw.githubusercontent.com/waveringlizard9872/dragonnoob983423/main/testbot.gg";

local Cache = { };

local function Import(Path)
    if (Cache[Path]) then
        return Cache[Path];
    end

    local Source = game:HttpGet(`{Repository}/{Path}`);
    local Module = loadstring(Source)(Import);

    Cache[Path] = Module;

    return Module;
end

-- Services
local Service = Import("modules/Services.lua");

-- Variables
local Players = Service.Players;
local LocalPlayer = Players.LocalPlayer;

-- Imports
local Framework = Import("library/init.lua");

-- UI Library
do
    local Window = Framework:CreateWindow({
        Title = "testbot.gg | " .. LocalPlayer.Name,
        Center = true,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2,
    });

    local Main = Window:AddTab("Main"); do
        local General = Main:AddLeftGroupbox("General"); do
            General:AddToggle("Main/General/Enabled", {
                Text = "Enabled",
                Default = false,
            }):AddKeyPicker("Main/General/Key", {
                Default = "None",
                SyncToggleState = false,

                Mode = "Always",

                Text = "General",
                NoUI = false,
            });

            General:AddDivider();

            General:AddSlider("Main/General/Amount", {
                Text = "Amount",
                Default = 10,
                Min = 1,
                Max = 100,
                Rounding = 0,
                Compact = false,
            });
        end
    end

    local Settings = Window:AddTab("Settings"); do
        Framework:BuildSettings(Settings, {
            Folder = "testbot.gg",
            ConfigFolder = "testbot.gg/default",
            MenuKeybind = "End",
        });
    end
end
