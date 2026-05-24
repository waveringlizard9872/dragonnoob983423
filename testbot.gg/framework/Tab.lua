return function(Environment)
    local Theme            = Environment.Theme;
    local Library          = Environment.Library;
    local Window           = Environment.Window;
    local Tab              = Environment.Tab;
    local Groupbox         = Environment.Groupbox;
    local Layout           = Environment.Layout;
    local Util             = Environment.Util;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local Vector2New       = Environment.Vector2New;
    local MathFloor        = Environment.MathFloor;
    local MathCeil         = Environment.MathCeil;
    local MathMax          = Environment.MathMax;
    local MathMin          = Environment.MathMin;
    local TableInsert      = Environment.TableInsert;
    local TaskDefer        = Environment.TaskDefer;

-- Tab Methods
function Tab:_LayoutColumns()
    local PageWidth  = self.Page.AbsoluteSize.X;
    local PageHeight = self.Page.AbsoluteSize.Y;

    if (PageWidth  <= 0) then PageWidth  = self.Page.Size.X.Offset; end
    if (PageHeight <= 0) then PageHeight = self.Page.Size.Y.Offset; end

    local Width  = 260;
    local Height = MathMax(145, PageHeight - Layout.ColumnPadding.Y * 2 + Layout.ColumnTitleOverhang);
    local RightX = MathMax(Layout.ColumnPadding.X, PageWidth - Layout.ColumnPadding.X - Width);

    self.LeftSide.Position  = UDim2FromOffset(Layout.ColumnPadding.X, Layout.ColumnPadding.Y - Layout.ColumnTitleOverhang);
    self.LeftSide.Size      = UDim2FromOffset(Width, Height);
    self.RightSide.Position = UDim2FromOffset(RightX, Layout.ColumnPadding.Y - Layout.ColumnTitleOverhang);
    self.RightSide.Size     = UDim2FromOffset(Width, Height);
end

function Tab:_RelayoutGroupboxes()
    self:_LayoutColumns();

    local LeftHeight  = 0;
    local RightHeight = 0;
    local LeftEntries  = { };
    local RightEntries = { };

    for _, GroupboxObject in ipairs(self.Groupboxes) do
        if (not GroupboxObject.Auto) then continue; end

        local Height = MathMax(145, GroupboxObject._AutoHeight or GroupboxObject.Frame.Size.Y.Offset);
        local Side   = GroupboxObject.Side;

        if (not Side) or (Side == "auto") then
            Side = LeftHeight <= RightHeight and "left" or "right";
        end

        if (Side == "right") then
            TableInsert(RightEntries, { Groupbox = GroupboxObject, Height = Height });
            RightHeight = RightHeight + Height + Layout.GroupboxGap;
        else
            TableInsert(LeftEntries, { Groupbox = GroupboxObject, Height = Height });
            LeftHeight = LeftHeight + Height + Layout.GroupboxGap;
        end
    end

    if (#LeftEntries == 1) then
        local ColumnHeight = MathMax(145, self.LeftSide.AbsoluteSize.Y - Layout.ColumnTitleOverhang);
        LeftEntries[1].Height = MathMin(LeftEntries[1].Height, ColumnHeight);
        LeftEntries[1].Height = MathMax(LeftEntries[1].Height, ColumnHeight);
    end

    if (#RightEntries == 1) then
        local ColumnHeight = MathMax(145, self.RightSide.AbsoluteSize.Y - Layout.ColumnTitleOverhang);
        RightEntries[1].Height = MathMin(RightEntries[1].Height, ColumnHeight);
        RightEntries[1].Height = MathMax(RightEntries[1].Height, ColumnHeight);
    end

    local function SetColumnScroll(Column, EntryCount)
        local Scrollable = EntryCount > 1;
        Column.ScrollingEnabled = Scrollable;
        Column.Active           = Scrollable;
        if (not Scrollable) then Column.CanvasPosition = Vector2New(0, 0); end
    end

    SetColumnScroll(self.LeftSide,  #LeftEntries);
    SetColumnScroll(self.RightSide, #RightEntries);

    for Index, Entry in ipairs(LeftEntries) do
        Entry.Groupbox.Frame.Parent      = self.LeftSide;
        Entry.Groupbox.Frame.LayoutOrder = Index;
        Entry.Groupbox.Frame.Position    = UDim2FromOffset(0, 0);
        Entry.Groupbox.Frame.Size        = UDim2FromOffset(Entry.Groupbox.Width or 260, Entry.Height);
        TaskDefer(function() Entry.Groupbox:_UpdateContentScroll(); end)
    end

    for Index, Entry in ipairs(RightEntries) do
        Entry.Groupbox.Frame.Parent      = self.RightSide;
        Entry.Groupbox.Frame.LayoutOrder = Index;
        Entry.Groupbox.Frame.Position    = UDim2FromOffset(0, 0);
        Entry.Groupbox.Frame.Size        = UDim2FromOffset(Entry.Groupbox.Width or 260, Entry.Height);
        TaskDefer(function() Entry.Groupbox:_UpdateContentScroll(); end)
    end

    for _, GroupboxObject in ipairs(self.Groupboxes) do
        GroupboxObject:_UpdateContentScroll();
    end
end

function Tab:AddFillGroupbox(Title, X, TopY, Width, BottomY)
    BottomY = BottomY or TopY;
    local GroupboxObject = self:AddGroupbox(Title, UDim2FromOffset(X, TopY), UDim2FromOffset(Width, 1));

    local function UpdateHeight()
        local ParentHeight = self.Page.AbsoluteSize.Y;
        if (ParentHeight <= 0) then return; end
        GroupboxObject.Frame.Size = UDim2FromOffset(Width, MathMax(1, MathFloor(ParentHeight - TopY - BottomY)));
        GroupboxObject:_UpdateContentScroll();
    end

    self.Window:_Signal(self.Page:GetPropertyChangedSignal("AbsoluteSize"), UpdateHeight);
    TaskDefer(UpdateHeight);

    return GroupboxObject;
end

function Tab:AddGroupbox(Title, Position, Size)
    local Auto  = not Util.IsUDim2(Position);
    local Side  = "auto";
    local Width = 260;
    local Height = 145;

    if (Auto) then
        if (type(Position) == "table") then
            Side   = Position.Side or Position.Column or "auto";
            Width  = Position.Width or Width;
            Height = Position.Height or Position.MinHeight or Height;
        elseif (type(Position) == "string") then
            Side = Position;
        end
        Position = UDim2FromOffset(0, 0);
        Size     = UDim2FromOffset(Width, Height);
    else
        Width  = Size and Size.X.Offset or Width;
        Height = Size and Size.Y.Offset or Height;
    end

    local Parent = Auto and self.LeftSide or self.Page;
    local Box    = Util.Frame(Parent, `Groupbox_{Util.CleanName(Title)}`, Position, Size, Theme.Groupbox, 108);

    Util.Line(Box, "OuterTop",    UDim2FromOffset(0, 0),        UDim2.new(1, 0, 0, 1),  Theme.GroupboxOuterBorder, 110);
    Util.Line(Box, "OuterLeft",   UDim2FromOffset(0, 0),        UDim2.new(0, 1, 1, 0),  Theme.GroupboxOuterBorder, 110);
    Util.Line(Box, "OuterRight",  UDim2.new(1, -1, 0, 0),       UDim2.new(0, 1, 1, 0),  Theme.GroupboxOuterBorder, 110);
    Util.Line(Box, "OuterBottom", UDim2.new(0, 0, 1, -1),       UDim2.new(1, 0, 0, 1),  Theme.GroupboxOuterBorder, 110);

    local TitleX         = 12;
    local TitlePadding   = 1;
    local TitleTextWidth = MathMax(1, MathCeil(Util.MeasureText(Title, Layout.TextSize)) - 4);
    local TitleWidth     = TitleTextWidth + TitlePadding * 2;
    local RightLineX     = TitleX + TitleWidth + 1;

    local TopLeft  = Util.Line(Box, "TopLeft",  UDim2FromOffset(1, 1),           UDim2FromOffset(TitleX - 1, 1),                  Theme.Border, 111);
    local TopRight = Util.Line(Box, "TopRight", UDim2FromOffset(RightLineX, 1),   UDim2.new(1, -(RightLineX + 1), 0, 1),           Theme.Border, 111);
    Util.Line(Box, "Left",   UDim2FromOffset(1, 1),           UDim2.new(0, 1, 1, -2), Theme.Border, 111);
    Util.Line(Box, "Right",  UDim2.new(1, -2, 0, 1),          UDim2.new(0, 1, 1, -2), Theme.Border, 111);
    Util.Line(Box, "Bottom", UDim2.new(0, 1, 1, -2),          UDim2.new(1, -2, 0, 1), Theme.Border, 111);

    local TitleBack  = Util.Frame(Box, "TitleBack", UDim2FromOffset(TitleX, -7), UDim2FromOffset(TitleWidth, 14), Theme.Groupbox, 112);
    TitleBack.BackgroundTransparency = 1;
    local TitleLabel = Util.Label(TitleBack, "Title", Title, UDim2FromOffset(TitlePadding, 0), UDim2FromOffset(TitleTextWidth, 14), Theme.Text, Enum.TextXAlignment.Left, 113);
    Util.ApplyFont(TitleLabel, Layout.TextSize, true);

    local function UpdateTitleCutout()
        local Measured = MathCeil(TitleLabel.TextBounds.X);
        if (Measured <= 0) then return; end
        local NextTitleWidth = Measured + TitlePadding * 2;
        local NextRightLineX = TitleX + NextTitleWidth + 1;
        TopLeft.Size        = UDim2FromOffset(TitleX - 1, 1);
        TopRight.Position   = UDim2FromOffset(NextRightLineX, 1);
        TopRight.Size       = UDim2.new(1, -(NextRightLineX + 1), 0, 1);
        TitleBack.Size      = UDim2FromOffset(NextTitleWidth, 14);
        TitleLabel.Size     = UDim2FromOffset(Measured, 14);
    end

    self.Window:_Signal(TitleLabel:GetPropertyChangedSignal("TextBounds"), UpdateTitleCutout);
    TaskDefer(UpdateTitleCutout);

    local ContentTop  = Layout.GroupboxContentTop;
    local ContentZ    = Layout.GroupboxContentZ;
    local ContentClip = Util.Frame(Box, "ContentClip", UDim2FromOffset(0, ContentTop), UDim2.new(1, 0, 1, -ContentTop), Theme.Groupbox, ContentZ);
    ContentClip.BackgroundTransparency = 1;
    ContentClip.ClipsDescendants       = true;

    local ContentFrame = Util.Create("Frame", {
        Name                 = "Content",
        Parent               = ContentClip,
        Position             = UDim2FromOffset(0, 0),
        Size                 = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ZIndex               = ContentZ,
    });
    ContentFrame.BackgroundTransparency = 1;
    local ContentLayout = Util.ListLayout(ContentFrame, 0);

    local TopPad = Util.Frame(ContentFrame, "TopPad", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, 4), Theme.Groupbox, Layout.GroupboxContentZ);
    TopPad.BackgroundTransparency = 1;
    TopPad.LayoutOrder            = -999;

    local GroupboxObject = setmetatable({
        Tab               = self,
        Window            = self.Window,
        Frame             = Box,
        ContentClip       = ContentClip,
        Content           = ContentFrame,
        ContentLayout     = ContentLayout,
        Title             = Title,
        Auto              = Auto,
        Side              = Side,
        Width             = Width,
        LastElementType   = nil,
        LastAutoWrapper   = nil,
        LastAutoRowOffset = 0,
        LayoutOrder       = 0,
        _AutoHeight       = Height,
        _ScrollY          = 0,
        _MaxScroll        = 0,
        _ContentOverflow  = false,
    }, Groupbox);

    TableInsert(self.Groupboxes, GroupboxObject);
    GroupboxObject:_ConnectContentWheel();

    self.Window:_Signal(ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        GroupboxObject:_ResizeAuto();
    end)
    self.Window:_Signal(Box:GetPropertyChangedSignal("AbsoluteSize"), function()
        GroupboxObject:_UpdateContentScroll();
    end)
    self.Window:_Signal(ContentClip:GetPropertyChangedSignal("AbsoluteSize"), function()
        GroupboxObject:_UpdateContentScroll();
    end)

    if (Auto) then self:_RelayoutGroupboxes(); end

    TaskDefer(function()
        GroupboxObject:_UpdateContentScroll();
        TaskDefer(function() GroupboxObject:_UpdateContentScroll(); end)
    end)

    return GroupboxObject;
end

function Tab:AddLeftGroupbox(Title, Options)
    Options = type(Options) == "table" and Options or { };
    Options.Side = "left";
    return self:AddGroupbox(Title, Options);
end

function Tab:AddRightGroupbox(Title, Options)
    Options = type(Options) == "table" and Options or { };
    Options.Side = "right";
    return self:AddGroupbox(Title, Options);
end

function Tab:AddConfigSystem()
    local Manager        = Library.ConfigManager;
    local SelectedConfig = nil;

    local Profiles       = self:AddLeftGroupbox("Profiles");
    local Configurations = self:AddRightGroupbox("Configurations", { Height = 190 });
    local Settings       = self:AddRightGroupbox("Settings");

    local ConfigInset = 10;
    local ConfigWidth = 240;

    local function Notify(Text, IsError)
        self.Window:Notify({
            Text = Text,
            Duration = IsError and 4 or 3,
            CloseOnClick = true,
        });
    end

    local function HasName(Name, Action)
        if (Name) and (Name ~= "") then
            return true;
        end

        Notify(`Enter a config name to {Action}.`, true);
        return false;
    end

    local NameBox = Configurations:AddTextBox({
        X       = ConfigInset,
        Y       = 6,
        Width   = ConfigWidth,
        Height  = 19,
        Default = "default",
        NoSave  = true,
    });

    local ConfigList = Profiles:AddListBox({
        X          = ConfigInset,
        Y          = 6,
        Width      = ConfigWidth,
        Height     = 300,
        BlankAfter = 6,
        Getter     = function() return Manager:GetConfigs(); end,
        Callback   = function(Name)
            SelectedConfig = Name;
            NameBox:Set(Name, true);
        end,
    });

    local function Refresh() ConfigList:Refresh(); end

    local function AddConfigButton(Label, Callback)
        Configurations:AddButton(Label, {
            X        = ConfigInset,
            Width    = ConfigWidth,
            Height   = 20,
            Callback = Callback,
        });
    end

    AddConfigButton("New", function()
        local Name = NameBox:Get();
        if HasName(Name, "create") then
            local Created = Manager:Create(Name);
            if (not Created) then
                Notify(`Failed to create config "{Name}".`, true);
                return;
            end

            SelectedConfig = Name;
            Refresh();
            ConfigList:Set(Name, true);
            Notify(`Created config "{Name}".`);
        end
    end)

    AddConfigButton("Save", function()
        local Name = NameBox:Get();
        if HasName(Name, "save") then
            if (not Manager:Save(Name)) then
                Notify(`Failed to save config "{Name}".`, true);
                return;
            end

            SelectedConfig = Name;
            Refresh();
            ConfigList:Set(Name, true);
            Notify(`Saved config "{Name}".`);
        end
    end)

    AddConfigButton("Load", function()
        local Name = SelectedConfig or NameBox:Get();
        if HasName(Name, "load") then
            if (not Manager:Load(Name)) then
                Notify(`Failed to load config "{Name}".`, true);
                return;
            end

            NameBox:Set(Name, true);
            SelectedConfig = Name;
            ConfigList:Set(Name, true);
            Notify(`Loaded config "{Name}".`);
        end
    end)

    AddConfigButton("Reset", function()
        local Name = SelectedConfig or (Manager.CurrentlyLoadedConfig and Manager.CurrentlyLoadedConfig.Name);
        if HasName(Name, "reset") then
            if (not Manager:Load(Name)) then
                Notify(`Failed to reset config "{Name}".`, true);
                return;
            end

            NameBox:Set(Name, true);
            SelectedConfig = Name;
            ConfigList:Set(Name, true);
            Notify(`Reset config "{Name}".`);
        end
    end)

    AddConfigButton("Delete", function()
        local Name = SelectedConfig or NameBox:Get();
        if HasName(Name, "delete") then
            if (not Manager:Delete(Name)) then
                Notify(`Failed to delete config "{Name}".`, true);
                return;
            end

            SelectedConfig = nil;
            Refresh();
            Notify(`Deleted config "{Name}".`);
        end
    end)

    AddConfigButton("Set as Autoload", function()
        local Name = NameBox:Get() or SelectedConfig;
        if HasName(Name, "set as autoload") then
            if (Manager:SetAutoload(Name)) then
                SelectedConfig = Name;
                Refresh();
                ConfigList:Set(Name, true);
                NameBox:Set(Name, true);
                Notify(`Set "{Name}" as autoload.`);
            else
                Notify(`Failed to set "{Name}" as autoload.`, true);
            end
        end
    end)

    local MenuKey = Settings:AddKeyPicker("Menu Key", {
        Flag    = "Settings/MenuKey",
        Default = "End",
    });

    self.Window:SetMenuKeybind(MenuKey);

    Settings:AddColorPicker("Settings/Accent", {
        Text     = "Accent",
        Default  = Theme.Accent,
        Callback = function(Value)
            Library:SetThemeColor("Accent", Value);
        end,
    });

    Settings:AddColorPicker("Settings/AccentDim", {
        Text     = "Accent Dim",
        Default  = Theme.AccentDim,
        Callback = function(Value)
            Library:SetThemeColor("AccentDim", Value);
        end,
    });

    Settings:AddButton("Unload", {
        X        = ConfigInset,
        Width    = ConfigWidth,
        Height   = 20,
        Callback = function()
            self.Window:Destroy();
        end,
    });

    Refresh();
    if (Manager:LoadAutoload()) and (Manager.CurrentlyLoadedConfig) then
        SelectedConfig = Manager.CurrentlyLoadedConfig.Name;
        NameBox:Set(SelectedConfig, true);
        ConfigList:Set(SelectedConfig, true);
        Notify(`Autoloaded config "{SelectedConfig}".`);
    end

    return {
        Profiles       = Profiles,
        Configurations = Configurations,
        Settings       = Settings,
        List           = ConfigList,
        Input          = NameBox,
        Manager        = Manager,
    };
end
end
