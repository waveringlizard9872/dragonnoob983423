return function(Environment)
    local RunService       = Environment.RunService;
    local UserInputService = Environment.UserInputService;
    local Theme            = Environment.Theme;
    local Library          = Environment.Library;
    local Window           = Environment.Window;
    local Tab              = Environment.Tab;
    local Dropdown         = Environment.Dropdown;
    local KeyPicker        = Environment.KeyPicker;
    local Button           = Environment.Button;
    local Layout           = Environment.Layout;
    local Util             = Environment.Util;
    local InstanceNew      = Environment.InstanceNew;
    local Color3FromRGB    = Environment.Color3FromRGB;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local Vector2New       = Environment.Vector2New;
    local MathFloor        = Environment.MathFloor;
    local MathCeil         = Environment.MathCeil;
    local MathMax          = Environment.MathMax;
    local MathAbs          = Environment.MathAbs;
    local MathExp          = Environment.MathExp;
    local TableInsert      = Environment.TableInsert;
    local TableRemove      = Environment.TableRemove;
    local TaskDefer        = Environment.TaskDefer;
    local ToString         = Environment.ToString;
    local PCall            = Environment.PCall;
    local Repository       = Environment.Repository;
    local AssetsFolder     = Environment.AssetsFolder;

-- Window
local function ResolveLoaderImage()
    if (not (isfile and writefile and readfile and makefolder and isfolder and getcustomasset)) then
        return "";
    end

    local function FetchImage(Url)
        if (request) then
            local Response = request({
                Url = Url,
                url = Url,
                Method = "GET",
                method = "GET",
            });
            local Body = Response and (Response.Body or Response.body);
            if (Body) and (#Body > 0) then
                return Body;
            end
        end

        if (http_request) then
            local Response = http_request({
                Url = Url,
                url = Url,
                Method = "GET",
                method = "GET",
            });
            local Body = Response and (Response.Body or Response.body);
            if (Body) and (#Body > 0) then
                return Body;
            end
        end

        return game:HttpGet(Url);
    end

    local Success, Result = PCall(function()
        if (not isfolder("Kyanite")) then makefolder("Kyanite"); end
        if (not isfolder(AssetsFolder)) then makefolder(AssetsFolder); end

        local ImagePath = `{AssetsFolder}/noFilter.jpg`;
        if (not isfile(ImagePath)) or (#readfile(ImagePath) < 1000) then
            local Urls = {
                "https://raw.githubusercontent.com/waveringlizard9872/dragonnoob983423/main/testbot.gg/assets/noFilter.jpg",
                "https://raw.githubusercontent.com/waveringlizard9872/dragonnoob983423/refs/heads/main/testbot.gg/assets/noFilter.jpg",
                `{Repository}/assets/noFilter.jpg`,
            };

            local ImageData = nil;
            for _, Url in ipairs(Urls) do
                local FetchSuccess, Data = PCall(function()
                    return FetchImage(Url);
                end)

                if (FetchSuccess) and (type(Data) == "string") and (#Data > 1000) then
                    ImageData = Data;
                    break;
                end
            end

            if (ImageData) and (#ImageData > 1000) then
                writefile(ImagePath, ImageData);
            end
        end

        if (isfile(ImagePath)) and (#readfile(ImagePath) > 1000) then
            return getcustomasset(ImagePath);
        end

        return "";
    end)

    return (Success and Result) or "";
end

local function DecoratePanel(Panel, ZIndex)
    Util.Line(Panel, "OuterTop",    UDim2FromOffset(0, 0),   UDim2.new(1, 0, 0, 1), Theme.GroupboxOuterBorder, ZIndex + 1);
    Util.Line(Panel, "OuterLeft",   UDim2FromOffset(0, 0),   UDim2.new(0, 1, 1, 0), Theme.GroupboxOuterBorder, ZIndex + 1);
    Util.Line(Panel, "OuterRight",  UDim2.new(1, -1, 0, 0),  UDim2.new(0, 1, 1, 0), Theme.GroupboxOuterBorder, ZIndex + 1);
    Util.Line(Panel, "OuterBottom", UDim2.new(0, 0, 1, -1),  UDim2.new(1, 0, 0, 1), Theme.GroupboxOuterBorder, ZIndex + 1);

    Util.Line(Panel, "Top",    UDim2FromOffset(1, 1),       UDim2.new(1, -2, 0, 1), Theme.Border, ZIndex + 2);
    Util.Line(Panel, "Left",   UDim2FromOffset(1, 1),       UDim2.new(0, 1, 1, -2), Theme.Border, ZIndex + 2);
    Util.Line(Panel, "Right",  UDim2.new(1, -2, 0, 1),      UDim2.new(0, 1, 1, -2), Theme.Border, ZIndex + 2);
    Util.Line(Panel, "Bottom", UDim2.new(0, 1, 1, -2),      UDim2.new(1, -2, 0, 1), Theme.Border, ZIndex + 2);
end

function Library.loader(Options)
    Options = Options or { };

    local Parent = Util.ResolveParent(Options);
    if (not Parent) then
        return nil;
    end

    local GuiName = Options.Name or Library:RandomName("KyaniteLoader");
    if (Options.RemoveExisting ~= false) then
        local Old = Parent:FindFirstChild(GuiName);
        if (Old) then Old:Destroy(); end
    end

    local ScreenGui = Util.Create("ScreenGui", {
        Name           = GuiName,
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = Parent,
    });
    ScreenGui.Archivable = false;

    if (Options.ProtectInstances ~= false) and (Library.ProtectInstance) then
        Library:ProtectInstance(ScreenGui);
    end

    local Root = Util.Frame(ScreenGui, "Loader", Options.Position or UDim2.new(0.5, -215, 0.5, -118), Options.Size or UDim2FromOffset(430, 236), Theme.Outer, 100);
    Util.Stroke(Root, Theme.OuterLight, 1);

    local OuterBlack  = Util.Frame(Root,       "OuterBlack",  UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.OuterDark, 101);
    local OuterMiddle = Util.Frame(OuterBlack, "OuterMiddle", UDim2FromOffset(2, 2), UDim2.new(1, -4, 1, -4), Theme.FramePadding, 102);
    Util.Stroke(OuterMiddle, Theme.BorderSoft, 1);

    local Body = Util.Frame(OuterMiddle, "Body", UDim2FromOffset(4, 4), UDim2.new(1, -8, 1, -8), Theme.FramePadding, 103);
    Util.Stroke(Body, Color3FromRGB(15, 14, 19), 1);
    Util.Line(Body, "TopAccent", UDim2FromOffset(1, 0), UDim2.new(1, -2, 0, 1), Theme.Accent, 105);

    local ChangeTitle = Util.Label(Body, "ChangeLogsTitle", "Change Logs:", UDim2FromOffset(18, 18), UDim2FromOffset(250, 14), Theme.Text, Enum.TextXAlignment.Center, 110);
    Util.ApplyFont(ChangeTitle, Layout.TextSize, true);

    local GameTitle = Util.Label(Body, "GameTitle", "Game:", UDim2FromOffset(290, 18), UDim2FromOffset(112, 14), Theme.Text, Enum.TextXAlignment.Center, 110);
    Util.ApplyFont(GameTitle, Layout.TextSize, true);

    local ChangeBox = Util.Frame(Body, "ChangeLogsBox", UDim2FromOffset(18, 38), UDim2FromOffset(250, 160), Theme.Groupbox, 108);
    DecoratePanel(ChangeBox, 108);

    local ChangeLabel = Util.Create("TextLabel", {
        Name                   = "ChangeLogText",
        Parent                 = ChangeBox,
        Position               = UDim2FromOffset(9, 8),
        Size                   = UDim2.new(1, -18, 1, -16),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Text                   = Options.ChangeLogText or "Initial loader layout.\nGame selection is a placeholder.",
        TextColor3             = Theme.Text,
        TextStrokeTransparency = 1,
        TextWrapped            = true,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Top,
        ZIndex                 = 112,
    });
    Util.ApplyFont(ChangeLabel, Layout.TextSize, false);

    local GameBox = Util.Frame(Body, "GameBox", UDim2FromOffset(290, 38), UDim2FromOffset(112, 124), Theme.Groupbox, 108);
    DecoratePanel(GameBox, 108);

    local GameRow = Util.Frame(GameBox, "Bloxstrike", UDim2FromOffset(6, 8), UDim2.new(1, -12, 0, 36), Theme.Groupbox, 112);
    GameRow.BackgroundTransparency = 1;

    Util.Create("ImageLabel", {
        Name                   = "Icon",
        Parent                 = GameRow,
        Position               = UDim2FromOffset(1, 2),
        Size                   = UDim2FromOffset(30, 30),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        Image                  = Options.GameImage or ResolveLoaderImage(),
        ScaleType              = Enum.ScaleType.Crop,
        ZIndex                 = 113,
    });

    local GameLabel = Util.Label(GameRow, "Text", "Bloxstrike", UDim2FromOffset(38, 0), UDim2.new(1, -38, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 113);
    Util.ApplyFont(GameLabel, Layout.TextSize, true);

    local StartButton = Util.MakeButtonControl(Body, "Start", UDim2FromOffset(290, 176), UDim2FromOffset(112, 22), 118);
    local StartLabel = Util.Label(StartButton, "Text", "Start", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 120);
    Util.ApplyFont(StartLabel, Layout.TextSize, false);

    local Loader = {
        Gui = ScreenGui,
        Root = Root,
        ChangeLogs = ChangeLabel,
        SelectedGame = "Bloxstrike",
        StartButton = StartButton,
        _Connections = { },
    };

    local function Signal(SignalObject, Callback)
        local Connection = SignalObject:Connect(Callback);
        TableInsert(Loader._Connections, Connection);
        return Connection;
    end

    Signal(StartButton.InputBegan, function(Input)
        if (Util.IsClickInput(Input)) then
            if (Options.AutoDestroy ~= false) then
                Loader:Destroy();
            end

            Util.SafeCallback(Options.Callback or Options.StartCallback, Loader.SelectedGame, Loader);
        end
    end);

    function Loader:Destroy()
        for Index = #self._Connections, 1, -1 do
            local Connection = TableRemove(self._Connections, Index);
            Connection:Disconnect();
        end
        if (self.Gui) then self.Gui:Destroy(); end
    end

    return Loader;
end

Library.CreateLoader = Library.loader;

function Library.new(Options)
    Options = Options or { };

    local Parent = Util.ResolveParent(Options);
    if (not Parent) then
        return nil;
    end

    local GuiName = Options.Name or Library:RandomName("Kyanite");
    if (Options.RemoveExisting ~= false) then
        local Old = Parent:FindFirstChild(GuiName);
        if (Old) then Old:Destroy(); end
    end

    local ScreenGui = Util.Create("ScreenGui", {
        Name             = GuiName,
        ResetOnSpawn     = false,
        IgnoreGuiInset   = true,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        Parent           = Parent,
    });
    ScreenGui.Archivable = false;

    if (Options.ProtectInstances ~= false) and (Library.ProtectInstance) then
        Library:ProtectInstance(ScreenGui);
    end

    local Root = Util.Frame(ScreenGui, "Window", Options.Position or UDim2.new(0.5, -306, 0.5, -207), Options.Size or UDim2FromOffset(612, 414), Theme.Outer, 100);
    Util.Stroke(Root, Theme.OuterLight, 1);

    local OuterBlack  = Util.Frame(Root,        "OuterBlack",  UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.OuterDark, 101);
    local OuterMiddle = Util.Frame(OuterBlack,  "OuterMiddle", UDim2FromOffset(2, 2), UDim2.new(1, -4, 1, -4), Theme.FramePadding, 102);
    Util.Stroke(OuterMiddle, Theme.BorderSoft, 1);

    local Body = Util.Frame(OuterMiddle, "Body", UDim2FromOffset(4, 4), UDim2.new(1, -8, 1, -8), Theme.FramePadding, 103);
    Util.Stroke(Body, Color3FromRGB(15, 14, 19), 1);

    local FramePadding = 12;
    local TabHeight    = Layout.TabBarHeight;

    local DragHeader = Util.Button(Body, "DragHeader", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, FramePadding), "", 104);
    DragHeader.BackgroundTransparency = 1;

    Util.Line(Body, "TopAccent", UDim2FromOffset(1, 0), UDim2.new(1, -2, 0, 1), Theme.Accent, 105);

    local TabBar = Util.Frame(Body, "TabBar", UDim2FromOffset(FramePadding - 1, FramePadding), UDim2.new(1, -(FramePadding * 2) + 2, 0, TabHeight), Theme.Tab, 105);
    Util.Line(TabBar, "TopOutline",    UDim2FromOffset(0, 0),       UDim2.new(1, 0, 0, 1),  Theme.TabOutline, 130);
    Util.Line(TabBar, "LeftOutline",   UDim2FromOffset(0, 0),       UDim2.new(0, 1, 1, 0),  Theme.TabOutline, 130);
    Util.Line(TabBar, "RightOutline",  UDim2.new(1, -1, 0, 0),      UDim2.new(0, 1, 1, 0),  Theme.TabOutline, 130);
    Util.Line(TabBar, "BottomOutline", UDim2.new(0, 0, 1, -1),      UDim2.new(1, 0, 0, 1),  Theme.TabOutline, 130);

    local Content      = Util.Frame(Body, "Content", UDim2FromOffset(FramePadding, FramePadding + TabHeight), UDim2.new(1, -FramePadding * 2, 1, -(FramePadding * 2 + TabHeight)), Theme.Workspace, 105);
    Util.Stroke(Content, Theme.WorkspaceBorder, 1);

    local ContentInner = Util.Frame(Content, "InnerShade", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.Workspace, 106);
    Util.Stroke(ContentInner, Color3FromRGB(18, 17, 23), 1);

    local PopupLayer = Util.Frame(Root, "PopupLayer", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Body, 500);
    PopupLayer.BackgroundTransparency = 1;
    PopupLayer.ClipsDescendants       = false;
    PopupLayer.Active                 = false;

    local PopupBlocker = Util.Button(PopupLayer, "PopupBlocker", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 510);
    PopupBlocker.BackgroundTransparency = 1;
    PopupBlocker.Visible                = false;

    local NotificationLayer = Util.Frame(Root, "NotificationLayer", UDim2FromOffset(0, -10), UDim2FromOffset(280, 0), Theme.Body, 650);
    NotificationLayer.BackgroundTransparency = 1;
    NotificationLayer.ClipsDescendants       = false;
    NotificationLayer.Active                 = false;

    local Self = setmetatable({
        Gui              = ScreenGui,
        Root             = Root,
        Body             = Body,
        TabBar           = TabBar,
        Content          = ContentInner,
        PopupLayer       = PopupLayer,
        PopupBlocker     = PopupBlocker,
        NotificationLayer = NotificationLayer,
        Notifications    = { },
        Tabs             = { },
        TabOrder         = { },
        Dropdowns        = { },
        ColorPickers     = { },
        OpenDropdown     = nil,
        OpenColorPicker  = nil,
        ActiveTab        = nil,
        TabBarHeight     = TabHeight,
        DragHeader       = DragHeader,
        _Connections     = { },
    }, Window);

    TableInsert(Library.Windows, Self);

    if (Options.Draggable ~= false) then
        Self:_MakeDraggable(DragHeader);
    end

    Self:_Signal(TabBar:GetPropertyChangedSignal("AbsoluteSize"), function()
        Self:_LayoutTabs();
    end)

    Self:_ConnectColorPickerDismiss();
    Self:_Signal(PopupBlocker.InputBegan, function(Input)
        if (not Util.IsClickInput(Input)) then return; end
        if (Self:_IsInputInsideOpenPopup(Input)) then return; end
        Self:_ConsumePopupInput();
        Self:_CloseDropdown(nil);
        Self:_CloseColorPickers(nil);
        Self:_RefreshPopupBlocker();
    end)

    Self:_Signal(UserInputService.InputBegan, function(Input, GameProcessed)
        if (GameProcessed) then return; end
        if (Self.MenuKeybind) and (Self.MenuKeybind:Matches(Input)) then
            Self:SetVisible(not Self.Root.Visible);
        end
    end)

    return Self;
end

-- Window Methods
function Window:_Signal(Signal, Callback)
    local Connection = Signal:Connect(Callback);
    TableInsert(self._Connections, Connection);
    return Connection;
end

function Window:_MakeDraggable(Handle)
    local Dragging     = false;
    local DragStart    = nil;
    local StartPosition = nil;
    local TargetPosition = nil;

    local function FinishDrag()
        Dragging = false;
        if (TargetPosition) and (self.Root) then
            self.Root.Position = TargetPosition;
        end
        TargetPosition = nil;
    end

    local function StopDrag()
        Dragging = false;
    end

    self:_Signal(RunService.RenderStepped, function(Delta)
        if (not TargetPosition) or (not self.Root) then return; end

        local Current = self.Root.Position;
        local Alpha   = 1 - MathExp(-Delta * 22);
        local NextX   = Current.X.Offset + (TargetPosition.X.Offset - Current.X.Offset) * Alpha;
        local NextY   = Current.Y.Offset + (TargetPosition.Y.Offset - Current.Y.Offset) * Alpha;

        self.Root.Position = UDim2.new(
            Current.X.Scale + (TargetPosition.X.Scale - Current.X.Scale) * Alpha,
            NextX,
            Current.Y.Scale + (TargetPosition.Y.Scale - Current.Y.Scale) * Alpha,
            NextY
        );

        if (not Dragging)
            and (MathAbs(TargetPosition.X.Offset - NextX) < 1)
            and (MathAbs(TargetPosition.Y.Offset - NextY) < 1) then
            FinishDrag();
        end
    end)

    self:_Signal(Handle.InputBegan, function(Input)
        if (not Util.IsDragInput(Input)) then return; end
        Dragging      = true;
        DragStart     = Input.Position;
        StartPosition = self.Root.Position;
        TargetPosition = StartPosition;

        local Changed; Changed = Input.Changed:Connect(function()
            if (Input.UserInputState == Enum.UserInputState.End) then
                StopDrag();
                if (Changed) then Changed:Disconnect(); end
            end
        end)
    end)

    self:_Signal(UserInputService.InputChanged, function(Input)
        if (not Dragging) or (not Util.IsMoveInput(Input)) then return; end
        local Delta = Input.Position - DragStart;
        TargetPosition = UDim2.new(
            StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
        );
    end)
end

function Window:_LayoutTabs()
    local Count = #self.TabOrder;
    if (Count == 0) then return; end

    local TotalWidth = self.TabBar.AbsoluteSize.X - 2;
    if (TotalWidth <= 0) then
        TotalWidth = MathMax(1, self.Root.Size.X.Offset - 40);
    end

    local BaseWidth = MathFloor(TotalWidth / Count);
    local X = 1;

    for Index, Name in ipairs(self.TabOrder) do
        local ThisTab = self.Tabs[Name];
        local Width   = (Index == Count and TotalWidth - (X - 1)) or BaseWidth;
        ThisTab.Frame.Position = UDim2FromOffset(X, 1);
        ThisTab.Frame.Size     = UDim2FromOffset(Width, Layout.TabInnerHeight);
        X = X + Width;
    end
end

function Window:_CloseDropdown(Except)
    if (self.OpenDropdown) and (self.OpenDropdown ~= Except) then
        self.OpenDropdown:SetOpen(false);
    end
end

function Window:_RefreshPopupBlocker()
    if (not self.PopupBlocker) then return; end
    self.PopupBlocker.Visible = self.OpenDropdown ~= nil or self.OpenColorPicker ~= nil;
end

function Window:_ConsumePopupInput()
    self._PopupInputBlockedUntil = os.clock() + 0.08;
end

function Window:_IsInputInsideOpenPopup(Input, Owner)
    if (not Input) then return false; end

    local OpenDropdown = self.OpenDropdown;
    if (OpenDropdown) and (OpenDropdown ~= Owner) and (Util.IsPointInside(OpenDropdown.Menu, Input.Position)) then
        return true;
    end

    local OpenColorPicker = self.OpenColorPicker;
    if (OpenColorPicker) and (OpenColorPicker ~= Owner) and (Util.IsPointInside(OpenColorPicker.Popup, Input.Position)) then
        return true;
    end

    return false;
end

function Window:_IsInputBlockedByPopup(Input, Owner)
    if (self._PopupInputBlockedUntil) and (os.clock() < self._PopupInputBlockedUntil) then
        return true;
    end

    return self:_IsInputInsideOpenPopup(Input, Owner);
end

function Window:_RegisterDropdown(Dropdown)
    TableInsert(self.Dropdowns, Dropdown);
    return Dropdown;
end

function Window:_CloseColorPickers(Except)
    for _, Picker in ipairs(self.ColorPickers) do
        if (Picker ~= Except) and (Picker.Open) then
            Picker:SetOpen(false, true);
        end
    end
    if (not Except) then
        self.OpenColorPicker = nil;
    end
end

function Window:_CloseColorPickersInColumn(Column)
    if (not Column) then return; end
    self:_CloseColorPickers(nil);
end

function Window:_ConnectColorPickerDismiss()
    if (self._ColorPickerDismissConnected) then return; end
    self._ColorPickerDismissConnected = true;

    self:_Signal(UserInputService.InputChanged, function(Input)
        if (Input.UserInputType ~= Enum.UserInputType.MouseWheel) then return; end
        for _, Picker in ipairs(self.ColorPickers) do
            if (Picker.Open) then
                self:_CloseColorPickers(nil);
                return;
            end
        end
    end)
end

function Window:_CloseColorPickersOnRow(Row, Except)
    if (not Row) then return; end
    local RowId = Row:GetAttribute("KyaniteRowId");
    for _, Picker in ipairs(self.ColorPickers) do
        if (Picker ~= Except) and (Picker.Open) then
            local SameRow = Picker.Row == Row;
            if (not SameRow) and (RowId) and (Picker.RowId == RowId) then
                SameRow = true;
            end
            if (SameRow) then
                Picker:SetOpen(false, true);
            end
        end
    end
end

function Window:_RegisterColorPicker(Picker)
    TableInsert(self.ColorPickers, Picker);
    return Picker;
end

function Window:_LayoutNotifications()
    local Gap = 6;
    local Y = 0;

    for Index = #self.Notifications, 1, -1 do
        local Notification = self.Notifications[Index];
        if (Notification) and (Notification.Frame) then
            local Height = Notification.Height or Notification.Frame.Size.Y.Offset;
            Notification.TargetY = -Y;

            if (Notification.Visible) then
                Util.Tween(Notification.Frame, {
                    Position = UDim2FromOffset(Notification.TargetX or 0, Notification.TargetY),
                }, 0.16);
            else
                Notification.Frame.Position = UDim2FromOffset(Notification.TargetX or 0, Notification.TargetY);
            end

            Y = Y + Height + Gap;
        end
    end
end

function Window:Notify(Text, Options)
    if (type(Text) == "table") then
        Options = Text;
        Text = Options.Text or Options.Message;
    else
        Options = type(Options) == "table" and Options or { Duration = Options };
    end

    local Message  = ToString(Text or "");
    local Duration = tonumber(Options.Duration or Options.Time) or 4;
    local Callback = Options.Callback;
    local Width    = Options.Width or 260;
    local TextWidth = MathMax(1, Width - 18);
    local Height   = Options.Height or MathMax(34, 24 + MathCeil(Util.MeasureText(Message, Layout.TextSize) / TextWidth) * 12);
    local WindowObject = self;

    local Frame = Util.Frame(self.NotificationLayer, `Notification_{#self.Notifications + 1}`, UDim2FromOffset(0, 0), UDim2FromOffset(0, 0), Theme.Outer, 650);
    Frame.AnchorPoint = Vector2New(0, 1);
    Frame.ClipsDescendants = true;
    Util.Stroke(Frame, Theme.OuterLight, 1);

    local OuterBlack = Util.Frame(Frame, "OuterBlack", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.OuterDark, 651);
    local Body       = Util.Frame(OuterBlack, "Body", UDim2FromOffset(2, 2), UDim2.new(1, -4, 1, -4), Theme.FramePadding, 652);
    Util.Stroke(Body, Theme.BorderSoft, 1);

    Util.Line(Body, "TopAccent", UDim2FromOffset(1, 0), UDim2.new(1, -2, 0, 1), Theme.Accent, 654);

    local Label = Util.Label(Body, "Text", Message, UDim2FromOffset(8, 4), UDim2.new(1, -16, 1, -8), Theme.Text, Enum.TextXAlignment.Left, 655);
    Label.TextWrapped = true;
    Label.TextYAlignment = Enum.TextYAlignment.Center;

    local Hitbox = Util.Button(Frame, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 660);
    Hitbox.BackgroundTransparency = 1;

    local Notification = {
        Frame = Frame,
        Label = Label,
        Height = Height,
        TargetX = 0,
        TargetY = 0,
        Visible = false,
        Closed = false,
    };

    function Notification:Close()
        if (self.Closed) then return; end
        self.Closed = true;

        for Index = #WindowObject.Notifications, 1, -1 do
            if (WindowObject.Notifications[Index] == self) then
                TableRemove(WindowObject.Notifications, Index);
                break;
            end
        end

        Util.Tween(Frame, {
            Position = UDim2FromOffset(0, self.TargetY or 0),
            Size = UDim2FromOffset(0, 0),
            BackgroundTransparency = 1,
        }, 0.18);

        task.delay(0.2, function()
            if (Frame) then Frame:Destroy(); end
        end);

        WindowObject:_LayoutNotifications();
    end

    function Notification:SetText(Value)
        Message = ToString(Value or "");
        Label.Text = Message;
    end

    self:_Signal(Hitbox.InputBegan, function(Input)
        if (not Util.IsClickInput(Input)) then return; end
        Util.SafeCallback(Callback, Notification);
        if (Options.CloseOnClick) then
            Notification:Close();
        end
    end)

    TableInsert(self.Notifications, Notification);
    self:_LayoutNotifications();

    Notification.Visible = true;
    Frame.Position = UDim2FromOffset(0, Notification.TargetY);
    Frame.Size = UDim2FromOffset(0, 0);
    Util.Tween(Frame, {
        Position = UDim2FromOffset(0, Notification.TargetY),
        Size = UDim2FromOffset(Width, Height),
    }, 0.22);

    if (Duration > 0) then
        task.delay(Duration, function()
            Notification:Close();
        end);
    end

    return Notification;
end

function Window:AddTab(Name)
    local TabFrame    = Util.Frame(self.TabBar, `Tab_{Util.CleanName(Name)}`, UDim2FromOffset(1, 1), UDim2FromOffset(1, Layout.TabInnerHeight), Color3.new(1, 1, 1), 107);
    local TabGradient = Util.Gradient(TabFrame, Theme.TabGradientTop, Theme.TabGradientBottom);
    local Divider     = Util.Line(TabFrame, "Divider", UDim2FromOffset(0, 0), UDim2FromOffset(1, Layout.TabInnerHeight), Theme.TabOutline, 130);
    Divider.Visible   = #self.TabOrder > 0;

    local TabText   = Util.Label(TabFrame, "Text", Name, UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 110);
    local ActiveLine = Util.Line(TabFrame, "ActiveLine", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), Theme.Accent, 120);
    ActiveLine.BackgroundTransparency = 1;

    local Page = Util.Frame(self.Content, `Page_{Util.CleanName(Name)}`, UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Body, 106);
    Page.BackgroundTransparency = 1;
    Page.Visible = false;

    local LeftSide = Util.Create("ScrollingFrame", {
        Name                     = "LeftSide",
        Parent                   = Page,
        Position                 = UDim2FromOffset(Layout.ColumnPadding.X, Layout.ColumnPadding.Y - Layout.ColumnTitleOverhang),
        Size                     = UDim2FromOffset(260, 331),
        BackgroundTransparency   = 1,
        BorderSizePixel          = 0,
        Active                   = true,
        CanvasPosition           = Vector2New(0, 0),
        CanvasSize               = UDim2FromOffset(0, 0),
        ClipsDescendants         = true,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness       = 0,
        ScrollingDirection       = Enum.ScrollingDirection.Y,
        ZIndex                   = 107,
    });

    local RightSide = Util.Create("ScrollingFrame", {
        Name                     = "RightSide",
        Parent                   = Page,
        Position                 = UDim2FromOffset(294, Layout.ColumnPadding.Y - Layout.ColumnTitleOverhang),
        Size                     = UDim2FromOffset(260, 331),
        BackgroundTransparency   = 1,
        BorderSizePixel          = 0,
        Active                   = true,
        CanvasPosition           = Vector2New(0, 0),
        CanvasSize               = UDim2FromOffset(0, 0),
        ClipsDescendants         = true,
        ScrollBarImageTransparency = 1,
        ScrollBarThickness       = 0,
        ScrollingDirection       = Enum.ScrollingDirection.Y,
        ZIndex                   = 107,
    });

    local LeftLayout  = Util.ListLayout(LeftSide,  Layout.GroupboxGap);
    local RightLayout = Util.ListLayout(RightSide, Layout.GroupboxGap);

    LeftLayout.VerticalAlignment  = Enum.VerticalAlignment.Top;
    RightLayout.VerticalAlignment = Enum.VerticalAlignment.Top;

    local LeftPadding = InstanceNew("UIPadding");
    LeftPadding.PaddingTop = UDim.new(0, Layout.ColumnTitleOverhang);
    LeftPadding.Parent     = LeftSide;

    local RightPadding = InstanceNew("UIPadding");
    RightPadding.PaddingTop = UDim.new(0, Layout.ColumnTitleOverhang);
    RightPadding.Parent     = RightSide;

    local ThisTab = setmetatable({
        Window      = self,
        Name        = Name,
        Frame       = TabFrame,
        Gradient    = TabGradient,
        Text        = TabText,
        ActiveLine  = ActiveLine,
        Page        = Page,
        LeftSide    = LeftSide,
        RightSide   = RightSide,
        LeftLayout  = LeftLayout,
        RightLayout = RightLayout,
        Groupboxes  = { },
    }, Tab);

    local function UpdateColumnCanvas(Column, ColumnLayout)
        Column.CanvasSize = UDim2FromOffset(0, ColumnLayout.AbsoluteContentSize.Y + Layout.ColumnTitleOverhang + 2);
    end

    self:_Signal(LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"),  function() UpdateColumnCanvas(LeftSide,  LeftLayout);  end)
    self:_Signal(RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() UpdateColumnCanvas(RightSide, RightLayout); end)

    self:_Signal(LeftSide:GetPropertyChangedSignal("CanvasPosition"),  function() self.Window:_CloseColorPickersInColumn(LeftSide);  end)
    self:_Signal(RightSide:GetPropertyChangedSignal("CanvasPosition"), function() self.Window:_CloseColorPickersInColumn(RightSide); end)

    TaskDefer(function()
        UpdateColumnCanvas(LeftSide,  LeftLayout);
        UpdateColumnCanvas(RightSide, RightLayout);
    end)

    local Hitbox = Util.Button(TabFrame, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 120);
    self:_Signal(Hitbox.InputBegan, function(Input)
        if (Util.IsClickInput(Input)) then self:SetTab(Name); end
    end)
    self:_Signal(Hitbox.MouseEnter, function()
        if (self.ActiveTab ~= Name) then
            ThisTab.Gradient.Color = ColorSequence.new(Theme.TabHoverGradientTop, Theme.TabHoverGradientBottom);
        end
    end)
    self:_Signal(Hitbox.MouseLeave, function()
        if (self.ActiveTab ~= Name) then
            ThisTab.Gradient.Color = ColorSequence.new(Theme.TabGradientTop, Theme.TabGradientBottom);
        end
    end)

    self:_Signal(Page:GetPropertyChangedSignal("AbsoluteSize"), function()
        ThisTab:_LayoutColumns();
        ThisTab:_RelayoutGroupboxes();
    end)
    TaskDefer(function()
        ThisTab:_LayoutColumns();
        ThisTab:_RelayoutGroupboxes();
    end)

    self.Tabs[Name] = ThisTab;
    TableInsert(self.TabOrder, Name);
    self:_LayoutTabs();

    if (not self.ActiveTab) then
        self:SetTab(Name, true);
    end

    return ThisTab;
end

function Window:SetTab(Name, Instant)
    self.ActiveTab = Name;
    self:_CloseDropdown(nil);
    self:_CloseColorPickers(nil);

    for TabName, ThisTab in pairs(self.Tabs) do
        local Active = TabName == Name;
        ThisTab.Page.Visible = Active;

        if (ThisTab.Gradient) then
            ThisTab.Gradient.Color = ColorSequence.new(
                Active and Theme.TabActiveGradientTop  or Theme.TabGradientTop,
                Active and Theme.TabActiveGradientBottom or Theme.TabGradientBottom
            );
        end

        if (Instant) then
            ThisTab.ActiveLine.BackgroundTransparency = Active and 0 or 1;
        else
            Util.Tween(ThisTab.ActiveLine, { BackgroundTransparency = Active and 0 or 1 }, 0.14);
        end
    end
end

function Window:Destroy()
    for Index = #self._Connections, 1, -1 do
        local Connection = TableRemove(self._Connections, Index);
        Connection:Disconnect();
    end
    if (self.Gui) then self.Gui:Destroy(); end
end

function Window:SetVisible(Value)
    self.Root.Visible = Value == true;
end

function Window:SetMenuKeybind(KeyPicker)
    self.MenuKeybind = KeyPicker;
end
end
