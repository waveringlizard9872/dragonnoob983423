return function(Environment)
    local HttpService      = Environment.HttpService;
    local Library          = Environment.Library;
    local Groupbox         = Environment.Groupbox;
    local Checkbox         = Environment.Checkbox;
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

-- Config Manager Methods
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

    writefile(ConfigUtil.Path(Config), HttpService:JSONEncode(Base));

    self.CurrentlyLoadedConfig = { Name = Config, File = ConfigUtil.Path(Config) };
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
