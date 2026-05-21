return function(Environment)
    local HttpService      = Environment.HttpService;
    local Theme            = Environment.Theme;
    local Library          = Environment.Library;
    local Groupbox         = Environment.Groupbox;
    local Checkbox         = Environment.Checkbox;
    local TextBox          = Environment.TextBox;
    local ConfigUtil       = Environment.ConfigUtil;
    local TableInsert      = Environment.TableInsert;
    local ToString         = Environment.ToString;
    local PCall            = Environment.PCall;

-- Library Methods
function Library:_RegisterOption(GroupboxObject, Name, Option, OptionType, Flag)
    Option.Type      = OptionType;
    Option.Name      = Name;
    Option.ConfigKey = Flag or Name;
    Option.Groupbox  = GroupboxObject;

    TableInsert(self._ConfigEntries, Option);

    if (OptionType == "Checkbox") then
        self.Toggles[Option.ConfigKey] = Option;
    else
        self.Options[Option.ConfigKey] = Option;
    end

    return Option;
end

function Library:SetThemeColor(Key, Value)
    if (not self.Theme[Key]) or (typeof(Value) ~= "Color3") then return false; end

    local Old = self.Theme[Key];
    self.Theme[Key] = Value;

    local function ReplaceSequence(Sequence)
        local Changed = false;
        local Points  = { };

        for _, Point in ipairs(Sequence.Keypoints) do
            local Color = Point.Value;
            if (Color == Old) then
                Color   = Value;
                Changed = true;
            end
            TableInsert(Points, ColorSequenceKeypoint.new(Point.Time, Color));
        end

        return Changed and ColorSequence.new(Points) or Sequence;
    end

    for _, WindowObject in ipairs(self.Windows) do
        if (not WindowObject.Gui) then continue; end

        for _, Object in ipairs(WindowObject.Gui:GetDescendants()) do
            if (Object:IsA("GuiObject")) then
                if (Object.BackgroundColor3 == Old) then Object.BackgroundColor3 = Value; end
                if (Object:IsA("TextLabel") or Object:IsA("TextButton") or Object:IsA("TextBox")) and (Object.TextColor3 == Old) then
                    Object.TextColor3 = Value;
                end
            elseif (Object:IsA("UIStroke")) then
                if (Object.Color == Old) then Object.Color = Value; end
            elseif (Object:IsA("UIGradient")) then
                Object.Color = ReplaceSequence(Object.Color);
            end
        end
    end

    return true;
end

-- Config Manager Methods
function Library.ConfigManager:Encode()
    local Base = { modules = { } };

    for _, Option in ipairs(Library._ConfigEntries) do
        local GroupboxObject = Option.Groupbox;
        local ModuleName     = (GroupboxObject and GroupboxObject.Title) or "Global";
        local Module         = Base.modules[ModuleName];

        if (not Module) then
            Module = { enabled = true, hidden = false, properties = { } };
            Base.modules[ModuleName] = Module;
        end

        Module.properties[Option.ConfigKey] = ConfigUtil.GetValue(Option);
    end

    return HttpService:JSONEncode(Base);
end

function Library.ConfigManager:IsDirty()
    return self.CurrentData ~= self:Encode();
end

function Library.ConfigManager:Refresh()
    self.Configs = { };

    if (not ConfigUtil.EnsureDirectory()) then return self.Configs; end

    for _, File in ipairs(listfiles(self.Directory)) do
        local Name = ToString(File):match("([^/\\]+)%.cfg$");
        if (Name) then
            self.Configs[Name] = { Name = Name, File = File };
        end
    end

    return self.Configs;
end

function Library.ConfigManager:Find(Config)
    self:Refresh();

    if (self.Configs[Config]) then return self.Configs[Config]; end

    local Path = ConfigUtil.Path(Config);
    if (ConfigUtil.CanUseFiles() and isfile(Path)) then
        return { Name = Config, File = Path };
    end

    return nil;
end

function Library.ConfigManager:Save(Config)
    if (not Config) or (ToString(Config) == "") then return false; end
    if (not ConfigUtil.EnsureDirectory())         then return false; end

    if (self.CurrentlyLoadedConfig) and (self.CurrentlyLoadedConfig.Name ~= Config) and (not self:IsDirty()) then
        writefile(ConfigUtil.Path(Config), self.CurrentData);
        if (delfile) then delfile(self.CurrentlyLoadedConfig.File); end
        self.CurrentlyLoadedConfig = { Name = Config, File = ConfigUtil.Path(Config) };
        self:Refresh();
        return true;
    end

    local Data = self:Encode();
    writefile(ConfigUtil.Path(Config), Data);

    self.CurrentlyLoadedConfig = { Name = Config, File = ConfigUtil.Path(Config) };
    self.CurrentData = Data;
    self:Refresh();

    return true;
end

function Library.ConfigManager:Load(Config)
    local Found = self:Find(Config);
    if (not Found) then return false; end

    local Success, Data = PCall(function()
        return HttpService:JSONDecode(readfile(Found.File));
    end)

    if (not Success) or (type(Data) ~= "table") or (type(Data.modules) ~= "table") then
        return false;
    end

    for _, Option in ipairs(Library._ConfigEntries) do
        local GroupboxObject = Option.Groupbox;
        local ModuleName     = (GroupboxObject and GroupboxObject.Title) or "Global";
        local Module         = Data.modules[ModuleName];

        if (Module) and (Module.properties) and (Module.properties[Option.ConfigKey] ~= nil) then
            ConfigUtil.SetValue(Option, Module.properties[Option.ConfigKey]);
        end
    end

    self.CurrentlyLoadedConfig = Found;
    self.CurrentData = readfile(Found.File);
    return true;
end

function Library.ConfigManager:Delete(Config)
    local Found = self:Find(Config);
    if (not Found) or (not delfile) then return false; end
    delfile(Found.File);
    self:Refresh();
    return true;
end

function Library.ConfigManager:Export(Config)
    local Found = self:Find(Config);
    if (not Found) then return nil; end
    return readfile(Found.File);
end

function Library.ConfigManager:Import(Config, Data)
    if (not Config) or (ToString(Config) == "") or (type(Data) ~= "string") then return false; end
    if (not ConfigUtil.EnsureDirectory()) then return false; end

    local Success = PCall(function() HttpService:JSONDecode(Data); end)
    if (not Success) then return false; end

    writefile(ConfigUtil.Path(Config), Data);
    self:Refresh();
    return true;
end

function Library.ConfigManager:SaveCurrent()
    return self.CurrentlyLoadedConfig and self:Save(self.CurrentlyLoadedConfig.Name) or false;
end

function Library.ConfigManager:ReloadCurrent()
    return self.CurrentlyLoadedConfig and self:Load(self.CurrentlyLoadedConfig.Name) or false;
end

function Library.ConfigManager:SetAutoload(Config)
    local Found = self:Find(Config);
    if (not Found) or (not ConfigUtil.EnsureDirectory()) then return false; end
    writefile(self.Autoload, Found.Name);
    return true;
end

function Library.ConfigManager:LoadAutoload()
    if (not ConfigUtil.CanUseFiles()) or (not isfile(self.Autoload)) then return false; end
    return self:Load(readfile(self.Autoload));
end

function Library.ConfigManager:GetConfigs()
    local Packed  = { };
    local Configs = self:Refresh();
    for Name in pairs(Configs) do
        TableInsert(Packed, Name);
    end
    table.sort(Packed);
    return Packed;
end
end
