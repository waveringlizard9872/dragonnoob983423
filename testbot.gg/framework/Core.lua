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
local ContentProvider = Service.ContentProvider;
local RunService = Service.RunService;

-- Theme
local Theme = {
    Accent                  = Color3.fromRGB(206, 115, 136),
    AccentDim               = Color3.fromRGB(161, 75, 86),
    Outer                   = Color3.fromRGB(23, 23, 30),
    OuterDark               = Color3.fromRGB(14, 14, 22),
    OuterLight              = Color3.fromRGB(62, 62, 72),
    Background              = Color3.fromRGB(23, 23, 30),
    Body                    = Color3.fromRGB(23, 23, 30),
    Groupbox                = Color3.fromRGB(27, 27, 34),
    Workspace               = Color3.fromRGB(32, 32, 38),
    WorkspaceBorder         = Color3.fromRGB(39, 39, 47),
    FramePadding            = Color3.fromRGB(23, 23, 30),
    BodyDark                = Color3.fromRGB(6, 6, 9),
    Tab                     = Color3.fromRGB(56, 56, 69),
    TabActive               = Color3.fromRGB(43, 41, 52),
    TabHover                = Color3.fromRGB(52, 52, 63),
    TabGradientTop          = Color3.fromRGB(47, 47, 56),
    TabGradientBottom       = Color3.fromRGB(24, 24, 28),
    TabActiveGradientTop    = Color3.fromRGB(55, 55, 64),
    TabActiveGradientBottom = Color3.fromRGB(36, 36, 43),
    TabHoverGradientTop     = Color3.fromRGB(47, 47, 56),
    TabHoverGradientBottom  = Color3.fromRGB(24, 24, 28),
    TabBorder               = Color3.fromRGB(56, 56, 69),
    TabOutline              = Color3.fromRGB(56, 56, 69),
    Border                  = Color3.fromRGB(51, 51, 58),
    GroupboxOuterBorder     = Color3.fromRGB(18, 18, 26),
    BorderSoft              = Color3.fromRGB(39, 39, 47),
    BorderDark              = Color3.fromRGB(18, 18, 24),
    Text                    = Color3.fromRGB(205, 205, 205),
    TextDim                 = Color3.fromRGB(201, 201, 218),
    ControlOuter            = Color3.fromRGB(18, 18, 24),
    ControlTop              = Color3.fromRGB(41, 41, 51),
    ControlBottom           = Color3.fromRGB(36, 36, 44),
    ControlHoverTop         = Color3.fromRGB(46, 46, 55),
    ControlPressedTop       = Color3.fromRGB(56, 56, 64),
    ButtonTop               = Color3.fromRGB(41, 41, 49),
    ButtonBottom            = Color3.fromRGB(36, 36, 43),
    ButtonHoverTop          = Color3.fromRGB(46, 46, 54),
    ButtonPressedTop        = Color3.fromRGB(56, 56, 64),
    ControlOpen             = Color3.fromRGB(72, 70, 78),
    DropdownMenu            = Color3.fromRGB(40, 40, 50),
    DropdownOutline         = Color3.fromRGB(18, 18, 24),
    DropdownArrow           = Color3.fromRGB(156, 156, 168),
    DropdownHover           = Color3.fromRGB(54, 54, 64),
    ColorPickerPopup        = Color3.fromRGB(40, 40, 50),
    ColorPickerPopupBorder  = Color3.fromRGB(18, 18, 24),
    ColorPickerOuter        = Color3.fromRGB(18, 18, 26),
    Track                   = Color3.fromRGB(18, 18, 24),
    TrackTop                = Color3.fromRGB(36, 36, 46),
    TrackHoverTop           = Color3.fromRGB(46, 46, 56),
    TrackBottom             = Color3.fromRGB(55, 55, 62),
    CheckboxOff             = Color3.fromRGB(75, 75, 86),
    White                   = Color3.fromRGB(255, 255, 255),
};

-- Library
local Library = { };

Library.Theme = Theme;
Library.Windows = { };
Library.Options = { };
Library.Toggles = { };
Library.Flags = setmetatable({ }, {
    __index = function(Self, Index)
        local Flag = Library.Toggles[Index] or Library.Options[Index];
        return Flag and Flag:Get();
    end
});
Library._ConfigEntries = { };
Library.ConfigManager = {
    EXTENSION = ".cfg",
    Directory = "Graphite/configs",
    Autoload = "Graphite/configs/autoload.txt",
    Configs = { },
    CurrentlyLoadedConfig = nil,
    CurrentData = nil,
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
local MathExp          = math.exp;
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

-- Instance Protection
Library._ProtectedInstances = setmetatable({ }, { __mode = "k" });
Library._ProtectionConnections = setmetatable({ }, { __mode = "k" });

local function IsProtectedInstance(Object)
    return Library._ProtectedInstances[Object] == true;
end

local function FilterProtectedList(List)
    if (type(List) ~= "table") then
        return List;
    end

    local Filtered = { };
    for _, Object in ipairs(List) do
        if (not IsProtectedInstance(Object)) then
            TableInsert(Filtered, Object);
        end
    end

    return Filtered;
end

local function HookInstanceDiscovery()
    if (Library._InstanceDiscoveryHooked) then
        return true;
    end

    if (not getrawmetatable) or (not setrawmetatable) or (not newcclosure) or (not getnamecallmethod) or (not checkcaller) then
        return false;
    end

    local Success, Hooks = PCall(function()
        local Metatable = getrawmetatable(game);
        if (type(Metatable) ~= "table") then return nil; end

        local ClonedMetatable = TableClone(Metatable);
        local OriginalNamecall = ClonedMetatable.__namecall;
        local OriginalIndex    = ClonedMetatable.__index;
        if (type(OriginalNamecall) ~= "function") then return nil; end
        if (type(OriginalIndex) ~= "function") and (type(OriginalIndex) ~= "table") then return nil; end

        ClonedMetatable.__namecall = newcclosure(function(Self, ...)
            if (checkcaller()) then
                return OriginalNamecall(Self, ...);
            end

            local Method = getnamecallmethod();

            if (IsProtectedInstance(Self)) then
                if (Method == "GetFullName") then
                    return "";
                elseif (Method == "IsDescendantOf") then
                    return false;
                elseif (Method == "FindFirstAncestor")
                    or (Method == "FindFirstAncestorOfClass")
                    or (Method == "FindFirstAncestorWhichIsA") then
                    return nil;
                end
            end

            local Result = OriginalNamecall(Self, ...);

            if (Method == "FindFirstChild") or (Method == "WaitForChild") then
                if (IsProtectedInstance(Result)) then
                    return nil;
                end
            elseif (Method == "GetChildren") or (Method == "GetDescendants") then
                return FilterProtectedList(Result);
            end

            return Result;
        end);

        ClonedMetatable.__index = newcclosure(function(Self, Index)
            if (checkcaller()) then
                if (type(OriginalIndex) == "function") then
                    return OriginalIndex(Self, Index);
                end
                return OriginalIndex[Index];
            end

            if (IsProtectedInstance(Self)) then
                if (Index == "Parent") then
                    return nil;
                elseif (Index == "Name") then
                    return "";
                end
            end

            local Result;
            if (type(OriginalIndex) == "function") then
                Result = OriginalIndex(Self, Index);
            else
                Result = OriginalIndex[Index];
            end

            if (IsProtectedInstance(Result)) then
                return nil;
            end

            return Result;
        end);

        setrawmetatable(game, ClonedMetatable);
        return {
            Namecall = OriginalNamecall,
            Index    = OriginalIndex,
        };
    end)

    if (Success) and (type(Hooks) == "table") then
        Library._InstanceDiscoveryNamecall = Hooks.Namecall;
        Library._InstanceDiscoveryIndex = Hooks.Index;
        Library._InstanceDiscoveryHooked = true;
        return true;
    end

    return false;
end

function Library:ProtectInstance(Object)
    if (typeof(Object) ~= "Instance") then
        return false;
    end

    self._ProtectedInstances[Object] = true;

    for _, Descendant in ipairs(Object:GetDescendants()) do
        self._ProtectedInstances[Descendant] = true;
    end

    if (not self._ProtectionConnections[Object]) then
        self._ProtectionConnections[Object] = Object.DescendantAdded:Connect(function(Descendant)
            self._ProtectedInstances[Descendant] = true;
        end);
    end

    return HookInstanceDiscovery();
end

function Library:UnprotectInstance(Object)
    self._ProtectedInstances[Object] = nil;

    for _, Descendant in ipairs(Object:GetDescendants()) do
        self._ProtectedInstances[Descendant] = nil;
    end

    local Connection = self._ProtectionConnections[Object];
    if (Connection) then
        Connection:Disconnect();
        self._ProtectionConnections[Object] = nil;
    end
end

function Library:RandomName(Prefix)
    local Success, Guid = PCall(function()
        return HttpService:GenerateGUID(false);
    end)

    Guid = Success and Guid or ToString(MathFloor(os.clock() * 1000000));
    return `{Prefix or "Gui"}_{StringGSub(Guid, "%W+", "")}`;
end

-- Asset Fixes
local function HookContentProviderAssetStatus()
    if (Library._ContentProviderAssetStatusHooked) then
        return true;
    end

    if (not getrawmetatable) or (not setrawmetatable) or (not newcclosure) or (not getnamecallmethod) then
        return false;
    end

    local Success, OldNamecall = PCall(function()
        local Metatable = getrawmetatable(ContentProvider);
        if (type(Metatable) ~= "table") then return nil; end

        local ClonedMetatable = TableClone(Metatable);
        local OriginalNamecall = ClonedMetatable.__namecall;
        if (type(OriginalNamecall) ~= "function") then return nil; end

        ClonedMetatable.__namecall = newcclosure(function(Self, ...)
            if (getnamecallmethod() == "GetAssetFetchStatus") then
                return Enum.AssetFetchStatus.None;
            end

            return OriginalNamecall(Self, ...);
        end);

        setrawmetatable(ContentProvider, ClonedMetatable);
        return OriginalNamecall;
    end)

    if (Success) and (type(OldNamecall) == "function") then
        Library._ContentProviderNamecall = OldNamecall;
        Library._ContentProviderAssetStatusHooked = true;
        return true;
    end

    return false;
end

Library.FixContentProviderAssetStatus = HookContentProviderAssetStatus;
HookContentProviderAssetStatus();

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
    TabBarHeight        = 25,
    TabInnerHeight      = 24,
    SubTabTopPadding    = 0,
    GroupboxContentTop  = 10,
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
    ContentProvider  = ContentProvider,
    RunService       = RunService,

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
    MathExp          = MathExp,
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
