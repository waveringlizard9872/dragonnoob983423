-- Kyanite UI

-- Services
local Service = setmetatable({ }, { __index = function(Self, Index)
    local Result = game:GetService(Index);
    return (cloneref and cloneref(Result)) or Result;
end });

local Players = Service.Players;
local TextService = Service.TextService;
local TweenService = Service.TweenService;
local UserInputService = Service.UserInputService;
local HttpService = Service.HttpService;

-- Theme
local Theme = {
    Accent                  = Color3.fromRGB(126, 105, 217),
    AccentDim               = Color3.fromRGB(78, 84, 165),
    Outer                   = Color3.fromRGB(27, 27, 34),
    OuterDark               = Color3.fromRGB(5, 5, 8),
    OuterLight              = Color3.fromRGB(74, 72, 82),
    Background              = Color3.fromRGB(25, 24, 31),
    Body                    = Color3.fromRGB(26, 25, 33),
    Groupbox                = Color3.fromRGB(27, 27, 34),
    Workspace               = Color3.fromRGB(32, 32, 38),
    FramePadding            = Color3.fromRGB(23, 23, 30),
    BodyDark                = Color3.fromRGB(6, 6, 9),
    Tab                     = Color3.fromRGB(56, 56, 69),
    TabActive               = Color3.fromRGB(43, 41, 52),
    TabHover                = Color3.fromRGB(35, 33, 42),
    TabGradientTop          = Color3.fromRGB(47, 47, 56),
    TabGradientBottom       = Color3.fromRGB(24, 24, 28),
    TabActiveGradientTop    = Color3.fromRGB(55, 55, 64),
    TabActiveGradientBottom = Color3.fromRGB(36, 36, 43),
    TabHoverGradientTop     = Color3.fromRGB(47, 47, 56),
    TabHoverGradientBottom  = Color3.fromRGB(24, 24, 28),
    TabBorder               = Color3.fromRGB(32, 30, 39),
    TabOutline              = Color3.fromRGB(32, 30, 39),
    Border                  = Color3.fromRGB(61, 59, 70),
    GroupboxOuterBorder     = Color3.fromRGB(15, 15, 22),
    BorderSoft              = Color3.fromRGB(45, 43, 53),
    BorderDark              = Color3.fromRGB(3, 3, 5),
    Text                    = Color3.fromRGB(238, 238, 238),
    TextDim                 = Color3.fromRGB(185, 183, 190),
    ControlTop              = Color3.fromRGB(66, 65, 72),
    ControlBottom           = Color3.fromRGB(45, 44, 52),
    ControlOpen             = Color3.fromRGB(72, 70, 78),
    DropdownMenu            = Color3.fromRGB(38, 38, 46),
    DropdownOutline         = Color3.fromRGB(14, 13, 0),
    DropdownArrow           = Color3.fromRGB(156, 156, 168),
    DropdownHover           = Color3.fromRGB(64, 62, 70),
    ColorPickerPopup        = Color3.fromRGB(40, 40, 50),
    ColorPickerPopupBorder  = Color3.fromRGB(18, 18, 24),
    Track                   = Color3.fromRGB(38, 38, 47),
    CheckboxOff             = Color3.fromRGB(73, 73, 84),
    White                   = Color3.fromRGB(255, 255, 255),
};

-- Library
local Library = { };

Library.Theme = Theme;
Library.Windows = { };
Library.Options = { };
Library.Toggles = { };
Library._ConfigEntries = { };
Library.ConfigManager = {
    EXTENSION = ".cfg",
    Directory = "Graphite/configs",
    Configs = { },
    CurrentlyLoadedConfig = nil,
};

-- Cached Globals
local InstanceNew      = Instance.new;
local Color3FromRGB    = Color3.fromRGB;
local Color3FromHSV    = Color3.fromHSV;
local Color3ToHSV      = Color3.toHSV;
local UDim2FromOffset  = UDim2.fromOffset;
local UDim2FromScale   = UDim2.fromScale;
local Vector2New       = Vector2.new;
local MathFloor        = math.floor;
local MathCeil         = math.ceil;
local MathMax          = math.max;
local MathMin          = math.min;
local MathClamp        = math.clamp;
local MathAbs          = math.abs;
local StringGSub       = string.gsub;
local StringMatch      = string.match;
local StringFind       = string.find;
local StringFormat     = string.format;
local TableInsert      = table.insert;
local TableRemove      = table.remove;
local TableClone       = table.clone;
local TaskDefer        = task.defer;
local ToString         = tostring;
local TypeOf           = typeof;
local PCall            = pcall;

-- Font URLs
local Repository        = (...);
local VerdanaRegularUrl = `{Repository}/assets/verdana.ttf`;
local VerdanaBoldUrl    = `{Repository}/assets/verdana-bold.ttf`;
local AssetsFolder      = "Kyanite/Assets";
local BaseMeasureFont   = Enum.Font.Arial;

-- Classes
local Window      = { }; Window.__index      = Window;
local Tab         = { }; Tab.__index         = Tab;
local Groupbox    = { }; Groupbox.__index    = Groupbox;
local SubTabs     = { }; SubTabs.__index     = SubTabs;
local SubTabPage  = { }; SubTabPage.__index  = SubTabPage;
local Checkbox    = { }; Checkbox.__index    = Checkbox;
local Dropdown    = { }; Dropdown.__index    = Dropdown;
local KeyPicker   = { }; KeyPicker.__index   = KeyPicker;
local TextBox     = { }; TextBox.__index     = TextBox;
local ListBox     = { }; ListBox.__index     = ListBox;
local Slider      = { }; Slider.__index      = Slider;
local Button      = { }; Button.__index      = Button;
local ColorPicker = { }; ColorPicker.__index = ColorPicker;

-- Layout
local Layout = {
    ColumnPadding       = Vector2New(18, 10),
    GroupboxGap         = 12,
    ColumnTitleOverhang = 8,
    TextSize            = 11,
    TabBarHeight        = 28,
    TabInnerHeight      = 26,
    SubTabTopPadding    = 0,
    GroupboxContentTop  = 6,
    GroupboxContentZ    = 109,
};

-- Fonts
local Verdana, VerdanaBold; do
    local function EnsureFolder(Path)
        if (not isfolder(Path)) then
            makefolder(Path);
        end
    end

    local function ResolveFont(Name, Url, Weight, Fallback)
        if (not (isfile and writefile and readfile and makefolder and isfolder and getcustomasset)) then
            return Font.fromEnum(Fallback);
        end

        local Success, Result = PCall(function()
            EnsureFolder("Kyanite");
            EnsureFolder(AssetsFolder);

            local FontPath     = `{AssetsFolder}/{Name}.ttf`;
            local FontDataPath = `{AssetsFolder}/{Name}.json`;

            if (not isfile(FontPath)) or (#readfile(FontPath) < 1000) then
                writefile(FontPath, game:HttpGet(Url));
            end

            local FontData = {
                name = Name,
                faces = {
                    {
                        name    = (Weight == Enum.FontWeight.Bold and "Bold") or "Regular",
                        weight  = (Weight == Enum.FontWeight.Bold and 700) or 400,
                        style   = "normal",
                        assetId = getcustomasset(FontPath),
                    },
                },
            };

            writefile(FontDataPath, HttpService:JSONEncode(FontData));
            return Font.new(getcustomasset(FontDataPath), Weight, Enum.FontStyle.Normal);
        end)

        return (Success and Result) or Font.fromEnum(Fallback);
    end

    Verdana     = ResolveFont("Verdana",      VerdanaRegularUrl, Enum.FontWeight.Regular, Enum.Font.Arial);
    VerdanaBold = ResolveFont("Verdana-Bold", VerdanaBoldUrl,    Enum.FontWeight.Bold,    Enum.Font.ArialBold);
end

local Environment = {
    Service          = Service,
    Players          = Players,
    TextService      = TextService,
    TweenService     = TweenService,
    UserInputService = UserInputService,
    HttpService      = HttpService,

    Theme       = Theme,
    Library     = Library,
    Window      = Window,
    Tab         = Tab,
    Groupbox    = Groupbox,
    SubTabs     = SubTabs,
    SubTabPage  = SubTabPage,
    Checkbox    = Checkbox,
    Dropdown    = Dropdown,
    KeyPicker   = KeyPicker,
    TextBox     = TextBox,
    ListBox     = ListBox,
    Slider      = Slider,
    Button      = Button,
    ColorPicker = ColorPicker,
    Layout      = Layout,
    Verdana     = Verdana,
    VerdanaBold = VerdanaBold,

    InstanceNew      = InstanceNew,
    Color3FromRGB    = Color3FromRGB,
    Color3FromHSV    = Color3FromHSV,
    Color3ToHSV      = Color3ToHSV,
    UDim2FromOffset  = UDim2FromOffset,
    UDim2FromScale   = UDim2FromScale,
    Vector2New       = Vector2New,
    MathFloor        = MathFloor,
    MathCeil         = MathCeil,
    MathMax          = MathMax,
    MathMin          = MathMin,
    MathClamp        = MathClamp,
    MathAbs          = MathAbs,
    StringGSub       = StringGSub,
    StringMatch      = StringMatch,
    StringFind       = StringFind,
    StringFormat     = StringFormat,
    TableInsert      = TableInsert,
    TableRemove      = TableRemove,
    TableClone       = TableClone,
    TaskDefer        = TaskDefer,
    ToString         = ToString,
    TypeOf           = TypeOf,
    PCall            = PCall,

    Repository        = Repository,
    VerdanaRegularUrl = VerdanaRegularUrl,
    VerdanaBoldUrl    = VerdanaBoldUrl,
    AssetsFolder      = AssetsFolder,
    BaseMeasureFont   = BaseMeasureFont,
};

return Environment;
