return function(Environment)
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
    local MathMax          = Environment.MathMax;
    local TableInsert      = Environment.TableInsert;
    local TableRemove      = Environment.TableRemove;
    local TaskDefer        = Environment.TaskDefer;

-- Window
function Library.new(Options)
    Options = Options or { };

    local Parent = Util.ResolveParent(Options);
    if (not Parent) then
        warn("KyaniteUI requires a LocalScript/client context or an explicit Parent.");
        return nil;
    end

    local GuiName = Options.Name or "KyaniteUI";
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

    local Root = Util.Frame(ScreenGui, "Window", Options.Position or UDim2.new(0.5, -306, 0.5, -207), Options.Size or UDim2FromOffset(612, 414), Theme.Outer, 100);
    Util.Stroke(Root, Theme.OuterLight, 1);

    local OuterBlack  = Util.Frame(Root,        "OuterBlack",  UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.OuterDark, 101);
    local OuterMiddle = Util.Frame(OuterBlack,  "OuterMiddle", UDim2FromOffset(2, 2), UDim2.new(1, -4, 1, -4), Theme.Outer,     102);
    Util.Stroke(OuterMiddle, Theme.BorderSoft, 1);

    local Body = Util.Frame(OuterMiddle, "Body", UDim2FromOffset(4, 4), UDim2.new(1, -8, 1, -8), Theme.FramePadding, 103);
    Util.Stroke(Body, Color3FromRGB(15, 14, 19), 1);

    local FramePadding = 12;
    local TabHeight    = Layout.TabBarHeight;

    local DragHeader = Util.Button(Body, "DragHeader", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, FramePadding), "", 104);
    DragHeader.BackgroundTransparency = 1;
    DragHeader.AutoButtonColor        = false;

    Util.Line(Body, "TopAccent", UDim2FromOffset(1, 0), UDim2.new(1, -2, 0, 1), Theme.Accent, 105);

    local TabBar = Util.Frame(Body, "TabBar", UDim2FromOffset(FramePadding - 1, FramePadding), UDim2.new(1, -(FramePadding * 2) + 2, 0, TabHeight), Theme.Tab, 105);
    Util.Line(TabBar, "TopOutline",    UDim2FromOffset(0, 0),       UDim2.new(1, 0, 0, 1),  Theme.TabOutline, 130);
    Util.Line(TabBar, "LeftOutline",   UDim2FromOffset(0, 0),       UDim2.new(0, 1, 1, 0),  Theme.TabOutline, 130);
    Util.Line(TabBar, "RightOutline",  UDim2.new(1, -1, 0, 0),      UDim2.new(0, 1, 1, 0),  Theme.TabOutline, 130);
    Util.Line(TabBar, "BottomOutline", UDim2.new(0, 0, 1, -1),      UDim2.new(1, 0, 0, 1),  Theme.TabOutline, 130);

    local Content      = Util.Frame(Body, "Content", UDim2FromOffset(FramePadding, FramePadding + TabHeight), UDim2.new(1, -FramePadding * 2, 1, -(FramePadding * 2 + TabHeight)), Theme.Workspace, 105);
    Util.Stroke(Content, Theme.BorderSoft, 1);

    local ContentInner = Util.Frame(Content, "InnerShade", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.Workspace, 106);
    Util.Stroke(ContentInner, Color3FromRGB(18, 17, 23), 1);

    local PopupLayer = Util.Frame(Root, "PopupLayer", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Body, 500);
    PopupLayer.BackgroundTransparency = 1;
    PopupLayer.ClipsDescendants       = false;
    PopupLayer.Active                 = false;

    local Self = setmetatable({
        Gui              = ScreenGui,
        Root             = Root,
        Body             = Body,
        TabBar           = TabBar,
        Content          = ContentInner,
        PopupLayer       = PopupLayer,
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

    self:_Signal(Handle.InputBegan, function(Input)
        if (not Util.IsDragInput(Input)) then return; end
        Dragging      = true;
        DragStart     = Input.Position;
        StartPosition = self.Root.Position;

        local Changed; Changed = Input.Changed:Connect(function()
            if (Input.UserInputState == Enum.UserInputState.End) then
                Dragging = false;
                if (Changed) then Changed:Disconnect(); end
            end
        end)
    end)

    self:_Signal(UserInputService.InputChanged, function(Input)
        if (not Dragging) or (not Util.IsMoveInput(Input)) then return; end
        local Delta = Input.Position - DragStart;
        self.Root.Position = UDim2.new(
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

function Window:AddTab(Name)
    local TabFrame = Util.Frame(self.TabBar, `Tab_{Util.CleanName(Name)}`, UDim2FromOffset(1, 1), UDim2FromOffset(1, Layout.TabInnerHeight), Color3.new(1, 1, 1), 107);
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
    self:_Signal(Hitbox.MouseButton1Click, function() self:SetTab(Name); end)
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
