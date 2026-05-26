return function(Environment)
    local UserInputService = Environment.UserInputService;
    local Theme            = Environment.Theme;
    local Library          = Environment.Library;
    local Window           = Environment.Window;
    local Groupbox         = Environment.Groupbox;
    local Checkbox         = Environment.Checkbox;
    local Dropdown         = Environment.Dropdown;
    local KeyPicker        = Environment.KeyPicker;
    local TextBox          = Environment.TextBox;
    local ListBox          = Environment.ListBox;
    local Slider           = Environment.Slider;
    local Button           = Environment.Button;
    local ColorPicker      = Environment.ColorPicker;
    local Layout           = Environment.Layout;
    local Util             = Environment.Util;
    local InstanceNew      = Environment.InstanceNew;
    local Color3FromRGB    = Environment.Color3FromRGB;
    local Color3FromHSV    = Environment.Color3FromHSV;
    local Color3ToHSV      = Environment.Color3ToHSV;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local UDim2FromScale   = Environment.UDim2FromScale;
    local Vector2New       = Environment.Vector2New;
    local MathFloor        = Environment.MathFloor;
    local MathCeil         = Environment.MathCeil;
    local MathMax          = Environment.MathMax;
    local MathClamp        = Environment.MathClamp;
    local StringFormat     = Environment.StringFormat;
    local TableInsert      = Environment.TableInsert;
    local TaskDefer        = Environment.TaskDefer;
    local ToString         = Environment.ToString;

-- Controls
function Groupbox:AddText(Text, X, Y, Width)
    local Auto   = not Util.IsManualXY(X, Y);
    local Parent = self.Frame;

    if (Auto) then
        Width  = type(X) == "number" and X or Width or 210;
        Parent = self:_LayoutHolder(`LayoutText_{Util.CleanName(Text)}`, 14, 4);
        X      = 31;
        Y      = 0;
    end

    local TextLabel = Util.Label(Parent, `Text_{Util.CleanName(Text)}`, Text, UDim2FromOffset(X, Y), UDim2FromOffset(Width or 180, 14), Theme.Text, Enum.TextXAlignment.Left, 118);

    if (Auto) then self:_FinishLayout("text"); else self:_ResizeAuto(); end
    return TextLabel;
end

local function ParseCheckboxArgs(X, Y, Checked, ColorBox, Callback)
    if (Util.IsManualXY(X, Y)) then
        return false, X, Y, Checked == true, ColorBox, Callback, nil;
    end

    if (type(X) == "table") then
        local Info = X;
        return true, Info.X, Info.Y, Info.Default == true or Info.Value == true or Info.Checked == true, Info.ColorBox or Info.Color, Info.Callback, Info.Flag;
    end

    local Value = X == true;
    local Color = nil;
    local Cb    = Callback;

    if (Util.IsColor3(Y)) then
        Color = Y; Cb = Checked;
    elseif (type(Y) == "function") then
        Cb = Y;
    else
        Color = Y; Cb = Checked;
    end

    return true, nil, nil, Value, Color, Cb, nil;
end

function Groupbox:AddCheckbox(Text, X, Y, Checked, ColorBox, Callback)
    local Auto, Flag;
    Auto, X, Y, Checked, ColorBox, Callback, Flag = ParseCheckboxArgs(X, Y, Checked, ColorBox, Callback);

    local Parent = self.Frame;
    if (Auto) then
        Parent = self:_LayoutHolder(`LayoutCheckbox_{Util.CleanName(Text)}`, 14, 4);
        X      = X or 31;
        Y      = Y or 0;
    end

    local Row = Util.Frame(Parent, `Checkbox_{Util.CleanName(Text)}`, UDim2FromOffset(X, Y), UDim2FromOffset(210, 14), Theme.Body, 118);
    Row.BackgroundTransparency = 1;

    local Square = Util.Frame(Row, "Square", UDim2FromOffset(1, 2), UDim2FromOffset(8, 8), Theme.DropdownOutline, 119);
    local SquareFill = Util.Frame(Square, "Fill", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.CheckboxOff, 120);
    Util.Gradient(SquareFill, Theme.CheckboxOff, Color3FromRGB(65, 65, 76));
    local TextLabel = Util.Label(Row, "Text", Text, UDim2FromOffset(20, -1), UDim2FromOffset(ColorBox and 154 or 182, 14), Theme.Text, Enum.TextXAlignment.Left, 119);
    local Swatch;

    if (ColorBox) then
        ColorBox = Util.IsColor3(ColorBox) and ColorBox or Theme.Accent;
        Swatch = Util.Frame(Row, "Color", UDim2FromOffset(181, 4), UDim2FromOffset(14, 7), ColorBox, 120);
        Util.Gradient(Swatch, ColorBox, Color3.new(ColorBox.R * 0.65, ColorBox.G * 0.65, ColorBox.B * 0.65));
        Util.Stroke(Swatch, Theme.ColorPickerOuter, 1);
    end

    local CheckboxObject = setmetatable({
        Groupbox  = self,
        Instance  = Row,
        Square    = Square,
        TextLabel = TextLabel,
        Swatch    = Swatch,
        Value     = Checked == true,
        Callback  = Callback,
    }, Checkbox);

    CheckboxObject:Set(CheckboxObject.Value, true);

    local Hitbox = Util.Button(Row, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
        if (Util.IsClickInput(Input)) then CheckboxObject:Set(not CheckboxObject.Value); end
    end)

    if (Auto) then self:_FinishLayout("checkbox"); else self:_ResizeAuto(); end

    return Library:_RegisterOption(self, Text, CheckboxObject, "Checkbox", Flag);
end

function Checkbox:Set(Value, Silent)
    self.Value = Value == true;
    Util.SetCheckboxVisual(self.Square, self.Value);
    if (not Silent) then Util.SafeCallback(self.Callback, self.Value); end
end

function Checkbox:Get() return self.Value; end

function Checkbox:AddColorPicker(Text, Options)
    Options         = type(Options) == "table" and Options or { Default = Options };
    Options.Compact = Options.Compact ~= false;
    Options.Parent  = Options.Parent or self.Instance;
    Options.Y       = Options.Y or 3;
    Options.X       = Options.X or 181;
    return self.Groupbox:AddColorPicker(Text or self.TextLabel.Text, Options);
end

local function ParseDropdownArgs(X, Y, Width, Values, Default, Callback)
    if (Util.IsManualXY(X, Y)) then
        return false, X, Y, Width, Util.ListValueOrEmpty(Values), Default, Callback, nil;
    end

    if (type(X) == "table") and (X.Values or X.Default or X.Callback or X.Width) then
        local Info = X;
        return true, Info.X, Info.Y, Info.Width or 160, Util.ListValueOrEmpty(Info.Values), Info.Default, Info.Callback, Info.Flag;
    end

    return true, nil, nil, 160, Util.ListValueOrEmpty(X), Y, Width, nil;
end

function Groupbox:AddDropdown(Text, X, Y, Width, Values, Default, Callback)
    local Auto, Flag;
    Auto, X, Y, Width, Values, Default, Callback, Flag = ParseDropdownArgs(X, Y, Width, Values, Default, Callback);
    Values  = Values or { };
    Default = Default or Values[1] or "";

    local Parent   = self.Frame;
    local ElementY = 0;

    if (Auto) then
        Parent   = self:_LayoutHolder(`LayoutDropdown_{Util.CleanName(Text)}`, 34, 5);
        X        = X or 50;
        Y        = Y or 0;
        Width    = Width or 160;
        ElementY = Y;
    else
        ElementY = Y;
    end

    Util.Label(Parent, `Text_{Util.CleanName(Text)}`, Text, UDim2FromOffset(X, ElementY), UDim2FromOffset(Width, 14), Theme.Text, Enum.TextXAlignment.Left, 118);

    local Control = Util.MakeControl(Parent, `Dropdown_{Util.CleanName(Text)}`, UDim2FromOffset(X, ElementY + 14), UDim2FromOffset(Width, 20), 118);

    local ValueLabel = Util.Label(Control, "Value", Default, UDim2FromOffset(6, 0), UDim2.new(1, -24, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 120);
    local Arrow      = Util.MakeDropdownArrow(Control, "Arrow", UDim2.new(1, -12, 0, 8), 122);

    local MenuGap    = 1;
    local MenuHeight = MathMax(1, #Values) * 18 + 4;
    local Menu       = Util.Frame(self.Window.PopupLayer, `Menu_{Util.CleanName(Text)}`, UDim2FromOffset(0, 0), UDim2FromOffset(Width, MenuHeight), Theme.DropdownOutline, 520);
    Menu.Visible     = false;

    local DropdownObject = setmetatable({
        Window     = self.Window,
        Frame      = Control,
        Menu       = Menu,
        Arrow      = Arrow,
        ValueLabel = ValueLabel,
        Values     = Values,
        Value      = Default,
        Callback   = Callback,
        MenuGap    = MenuGap,
        MenuHeight = MenuHeight,
        Open       = false,
    }, Dropdown);

    for Index, Value in ipairs(Values) do
        DropdownObject:_AddOption(Index, Value);
    end

    local Hitbox = Util.Button(Control, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, 20), "", 145);
    self.Window:_Signal(Hitbox.MouseEnter, function() Util.SetControlState(Control, "hover"); end)
    self.Window:_Signal(Hitbox.MouseLeave, function()
        Util.SetControlState(Control, DropdownObject.Open and "hover" or "normal");
    end)
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input, DropdownObject)) then return; end
        if (Util.IsClickInput(Input)) then DropdownObject:SetOpen(not DropdownObject.Open); end
    end)

    if (Auto) then self:_FinishLayout("dropdown"); else self:_ResizeAuto(); end

    self.Window:_RegisterDropdown(DropdownObject);
    return Library:_RegisterOption(self, Text, DropdownObject, "Dropdown", Flag);
end

function Dropdown:_AddOption(Index, Value)
    local Option = Util.Button(self.Menu, `Option_{Index}`, UDim2FromOffset(1, 2 + (Index - 1) * 18), UDim2.new(1, -2, 0, 18), `  {ToString(Value)}`, 525);
    Option.BackgroundTransparency = 0;
    Option.BackgroundColor3       = Theme.DropdownMenu;
    Option.TextXAlignment         = Enum.TextXAlignment.Left;

    self.Window:_Signal(Option.MouseEnter,        function() Option.BackgroundColor3 = Theme.DropdownHover; end)
    self.Window:_Signal(Option.MouseLeave,        function() Option.BackgroundColor3 = Theme.DropdownMenu;  end)
    self.Window:_Signal(Option.InputBegan, function(Input)
        if (Util.IsClickInput(Input)) then
            self.Window:_ConsumePopupInput();
            self.Window:_CloseColorPickers(nil);
            self:Set(Value);
            self:SetOpen(false);
        end
    end)
end

function Dropdown:Set(Value, Silent)
    self.Value            = Value;
    self.ValueLabel.Text  = ToString(Value);
    if (not Silent) then Util.SafeCallback(self.Callback, Value); end
end

function Dropdown:Get() return self.Value; end

function Dropdown:SetOpen(Open)
    Open = Open == true;

    if (Open) then
        self.Window:_CloseDropdown(self);
        self.Window.OpenDropdown = self;
        Util.PositionPopup(self.Window, self.Menu, self.Frame, self.MenuGap);
        self.Menu.Size = UDim2FromOffset(self.Frame.AbsoluteSize.X, self.MenuHeight);
    elseif (self.Window.OpenDropdown == self) then
        self.Window.OpenDropdown = nil;
    end

    self.Open          = Open;
    self.Menu.Visible  = Open;
    Util.SetDropdownArrow(self.Arrow, Open);
    self.Frame.BackgroundColor3 = Theme.ControlOuter;
    Util.SetControlState(self.Frame, Open and "hover" or "normal");
    self.Window:_RefreshPopupBlocker();
end

local function ParseKeyPickerArgs(X, Y, Width, Default, Callback)
    if (Util.IsManualXY(X, Y)) then return false, X, Y, Width, Default, Callback, nil; end
    if (type(X) == "table") then
        local Info = X;
        return true, Info.X, Info.Y, Info.Width or 160, Info.Default or Info.Value or "None", Info.Callback, Info.Flag;
    end
    return true, nil, nil, 160, X or "None", Y, nil;
end

function Groupbox:AddKeyPicker(Text, X, Y, Width, Default, Callback)
    local Auto, Flag;
    Auto, X, Y, Width, Default, Callback, Flag = ParseKeyPickerArgs(X, Y, Width, Default, Callback);

    local Parent   = self.Frame;
    local ElementY = Y;

    if (Auto) then
        Parent   = self:_LayoutHolder(`LayoutKeyPicker_{Util.CleanName(Text)}`, 38, 5);
        X        = X or 50;
        Y        = Y or 0;
        Width    = Width or 160;
        ElementY = Y;
    end

    Util.Label(Parent, `Text_{Util.CleanName(Text)}`, Text, UDim2FromOffset(X, ElementY), UDim2FromOffset(Width, 14), Theme.Text, Enum.TextXAlignment.Left, 118);

    local Control = Util.MakeControl(Parent, `KeyPicker_{Util.CleanName(Text)}`, UDim2FromOffset(X, ElementY + 14), UDim2FromOffset(Width, 24), 118);

    local ValueLabel = Util.Label(Control, "Value", Default or "None", UDim2FromOffset(6, 0), UDim2.new(1, -26, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 120);
    local Clear      = Util.Frame(Control, "Clear", UDim2.new(1, -19, 0, 0), UDim2FromOffset(18, 24), Theme.ControlOuter, 123);
    Clear.BackgroundTransparency = 1;
    Clear.Active                 = true;

    local ClearLineA = Util.Line(Clear, "LineA", UDim2FromOffset(5, 11), UDim2FromOffset(8, 1), Theme.DropdownArrow, 124);
    ClearLineA.Rotation = 45;

    local ClearLineB = Util.Line(Clear, "LineB", UDim2FromOffset(5, 11), UDim2FromOffset(8, 1), Theme.DropdownArrow, 124);
    ClearLineB.Rotation = -45;

    local KeyPickerObject = setmetatable({
        Instance   = Control,
        ValueLabel = ValueLabel,
        Value      = Default or "None",
        Callback   = Callback,
        Listening  = false,
    }, KeyPicker);

    local Hitbox = Util.Button(Control, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, -20, 1, 0), "", 122);
    self.Window:_Signal(Hitbox.MouseEnter, function() Util.SetControlState(Control, "hover"); end)
    self.Window:_Signal(Hitbox.MouseLeave, function() Util.SetControlState(Control, "normal"); end)
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
        if (not Util.IsClickInput(Input)) then return; end
        TaskDefer(function()
            KeyPickerObject.Listening = true;
            ValueLabel.Text = "...";
        end)
    end)
    self.Window:_Signal(Clear.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
        if (not Util.IsClickInput(Input)) then return; end
        KeyPickerObject.Listening = false;
        KeyPickerObject:Set("None");
    end)
    self.Window:_Signal(UserInputService.InputBegan, function(Input, GameProcessed)
        if (GameProcessed) or (not KeyPickerObject.Listening) then return; end
        KeyPickerObject.Listening = false;
        KeyPickerObject:Set(Util.FormatInput(Input));
    end)

    if (Auto) then self:_FinishLayout("keypicker"); else self:_ResizeAuto(); end

    return Library:_RegisterOption(self, Text, KeyPickerObject, "KeyPicker", Flag);
end

Groupbox.AddKeybind = Groupbox.AddKeyPicker;

function KeyPicker:Set(Value, Silent)
    self.Value           = ToString(Value);
    self.ValueLabel.Text = self.Value;
    if (not Silent) then Util.SafeCallback(self.Callback, self.Value); end
end

function KeyPicker:Get() return self.Value; end

function KeyPicker:Matches(Input)
    return self.Value ~= "None" and Util.FormatInput(Input) == self.Value;
end

function KeyPicker:GetState()
    local Key = self.Value;
    if (Key == "None") then return false; end

    local Success, KeyCode = pcall(function()
        return Enum.KeyCode[Key];
    end)

    if (Success) and (KeyCode) then
        return UserInputService:IsKeyDown(KeyCode);
    end

    if (Key == "Mouse 1") then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1); end
    if (Key == "Mouse 2") then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2); end
    if (Key == "Mouse 3") then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3); end

    return false;
end

function Groupbox:AddTextBox(Text, Options)
    Options = type(Text) == "table" and Text or (type(Options) == "table" and Options or { Text = Text });

    local Name     = Options.Text or "Input";
    local Width    = Options.Width   or 160;
    local Height   = Options.Height  or 24;
    local Default  = Options.Default or "";
    local Callback = Options.Callback;
    local Parent   = self:_LayoutHolder(`LayoutTextBox_{Util.CleanName(Name)}`, Height + (Options.Y or 0), Options.BlankAfter or 5);
    local Inset    = 7;

    local Control = Util.MakeControl(Parent, `TextBox_{Util.CleanName(Name)}`, UDim2FromOffset(Options.X or 50, Options.Y or 0), UDim2FromOffset(Width, Height), Layout.GroupboxContentZ);

    local Input = Util.Create("TextBox", {
        Name                 = "Input",
        Parent               = Control,
        Position             = UDim2FromOffset(Inset, 0),
        Size                 = UDim2.new(1, -Inset * 2, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ClearTextOnFocus     = false,
        Text                 = Default,
        TextColor3           = Theme.Text,
        TextStrokeTransparency = 1,
        TextXAlignment       = Enum.TextXAlignment.Left,
        TextYAlignment       = Enum.TextYAlignment.Center,
        ZIndex               = Layout.GroupboxContentZ + 2,
    });
    Util.ApplyFont(Input, Layout.TextSize, false);

    local TextBoxObject = setmetatable({
        Instance = Control,
        Input    = Input,
        Callback = Callback,
        Value    = Default,
    }, TextBox);

    self.Window:_Signal(Input.FocusLost, function()
        Util.SetControlState(Control, "normal");
        TextBoxObject:Set(Input.Text);
    end)
    self.Window:_Signal(Input.Focused, function()
        Util.SetControlState(Control, "hover");
    end)

    self:_FinishLayout("textbox");
    if (Options.NoSave) then
        return TextBoxObject;
    end

    return Library:_RegisterOption(self, Name, TextBoxObject, "TextBox", Options.Flag);
end

function TextBox:Set(Value, Silent)
    self.Value      = ToString(Value or "");
    self.Input.Text = self.Value;
    if (not Silent) then Util.SafeCallback(self.Callback, self.Value); end
end

function TextBox:Get() return self.Value; end

function Groupbox:AddListBox(Text, Options)
    Options = type(Text) == "table" and Text or (type(Options) == "table" and Options or { Text = Text });

    local Width    = Options.Width  or 160;
    local Height   = Options.Height or 120;
    local Getter   = Options.Values or Options.Getter or function() return { }; end;
    local Callback = Options.Callback;
    local Parent   = self:_LayoutHolder(`LayoutListBox_{Util.CleanName(Options.Text or "Profiles")}`, Height + (Options.Y or 0), Options.BlankAfter or 5);
    local Inset    = 8;
    local RowHeight = 15;

    local Box = Util.Frame(Parent, `ListBox_{Util.CleanName(Options.Text or "Profiles")}`, UDim2FromOffset(Options.X or 50, Options.Y or 0), UDim2FromOffset(Width, Height), Theme.DropdownMenu, Layout.GroupboxContentZ);
    Util.Stroke(Box, Theme.DropdownOutline, 1);

    local Container = Util.Create("ScrollingFrame", {
        Name                   = "Container",
        Parent                 = Box,
        Position               = UDim2FromOffset(Inset, Inset),
        Size                   = UDim2.new(1, -Inset * 2, 1, -Inset * 2),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        CanvasPosition         = Vector2New(0, 0),
        CanvasSize             = UDim2FromOffset(0, 0),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness     = 0,
        ScrollingDirection     = Enum.ScrollingDirection.Y,
        ZIndex                 = Layout.GroupboxContentZ + 1,
    });

    local ListBoxObject = setmetatable({
        Window    = self.Window,
        Instance  = Box,
        Container = Container,
        Getter    = Getter,
        Callback  = Callback,
        Value     = nil,
        Rows      = { },
        RowHeight = RowHeight,
    }, ListBox);

    ListBoxObject:Refresh();
    self:_FinishLayout("listbox");
    return ListBoxObject;
end

function ListBox:Refresh()
    for _, Row in ipairs(self.Rows) do Row:Destroy(); end
    self.Rows = { };

    local Values    = type(self.Getter) == "function" and self.Getter() or self.Getter;
    local RowHeight = self.RowHeight or 15;
    local Y         = 0;

    for _, Value in ipairs(Values or { }) do
        local Name = ToString(Value);
        local Row  = Util.Button(self.Container, `Option_{Util.CleanName(Name)}`, UDim2FromOffset(0, Y), UDim2.new(1, 0, 0, RowHeight), Name, Layout.GroupboxContentZ + 3);
        Row.BackgroundTransparency = 0;
        Row.BackgroundColor3       = Theme.DropdownMenu;
        Row.TextColor3             = (Name == self.Value) and Theme.Accent or Theme.Text;
        Row.TextXAlignment         = Enum.TextXAlignment.Center;

        self.Window:_Signal(Row.MouseEnter,        function() if (self.Value ~= Name) then Row.BackgroundColor3 = Theme.DropdownHover; end end)
        self.Window:_Signal(Row.MouseLeave,        function() Row.BackgroundColor3 = Theme.DropdownMenu; end)
        self.Window:_Signal(Row.InputBegan, function(Input)
            if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
            if (Util.IsClickInput(Input)) then self:Set(Name); end
        end)

        TableInsert(self.Rows, Row);
        Y = Y + RowHeight;
    end

    self.Container.CanvasSize = UDim2FromOffset(0, Y);
end

function ListBox:Set(Value, Silent)
    self.Value = ToString(Value or "");
    for _, Row in ipairs(self.Rows) do
        Row.TextColor3       = (Row.Text == self.Value) and Theme.Accent or Theme.Text;
        Row.BackgroundColor3 = Theme.DropdownMenu;
    end
    if (not Silent) then Util.SafeCallback(self.Callback, self.Value); end
end

function ListBox:Get() return self.Value; end

local function ParseSliderArgs(X, Y, Width, Ratio, ValueText, Callback)
    if (Util.IsManualXY(X, Y)) then return false, X, Y, Width, Ratio, ValueText, Callback, nil; end
    if (type(X) == "table") then
        local Info = X;
        return true, Info.X, Info.Y, Info.Width or 166, Info.Ratio or Info.Default or 0, Info.Text or Info.ValueText or Info.Value, Info.Callback, Info.Flag;
    end
    return true, nil, nil, 166, X or 0, Y, Width, nil;
end

function Groupbox:AddSlider(Text, X, Y, Width, Ratio, ValueText, Callback)
    local Auto, Flag;
    Auto, X, Y, Width, Ratio, ValueText, Callback, Flag = ParseSliderArgs(X, Y, Width, Ratio, ValueText, Callback);

    local Parent = self.Frame;
    if (Auto) then
        Parent = self:_LayoutHolder(`LayoutSlider_{Util.CleanName(Text)}`, 18, 4);
        X      = X or 47;
        Y      = Y or 0;
        Width  = Width or 166;
    end

    local Holder = Util.Frame(Parent, `Slider_{Util.CleanName(Text)}`, UDim2FromOffset(X, Y), UDim2FromOffset(Width, 18), Theme.Body, 118);
    Holder.BackgroundTransparency = 1;

    Util.Label(Holder, "Text", Text, UDim2FromOffset(4, -5), UDim2FromOffset(Width, 13), Theme.Text, Enum.TextXAlignment.Left, 119);

    local TrackWidth = MathMax(8, Width - 6);
    local FillWidth  = MathMax(1, TrackWidth - 2);
    local Track      = Util.Frame(Holder, "Track", UDim2FromOffset(4, 7), UDim2FromOffset(TrackWidth, 7), Theme.Track, 119);
    Util.Stroke(Track, Theme.DropdownOutline, 1);
    Util.Gradient(Track, Theme.TrackTop, Theme.TrackBottom);
    local Fill       = Util.Frame(Track, "Fill", UDim2FromOffset(1, 1), UDim2FromOffset(1, 5), Theme.Accent, 120);
    Util.Gradient(Fill, Theme.Accent, Theme.AccentDim);
    Util.Line(Holder, "LeftTick", UDim2FromOffset(-3, 10), UDim2FromOffset(5, 1), Theme.TrackEnd, 120);
    Util.Line(Holder, "RightTickV", UDim2FromOffset(Width + 2, 8), UDim2FromOffset(1, 5), Theme.TrackEnd, 120);
    Util.Line(Holder, "RightTickH", UDim2FromOffset(Width, 10), UDim2FromOffset(5, 1), Theme.TrackEnd, 120);
    local ValueLabel = Util.Label(Holder, "Value", ValueText == nil and "" or ToString(ValueText), UDim2FromOffset(0, 8), UDim2FromOffset(32, 12), Theme.Text, Enum.TextXAlignment.Center, 130);
    Util.ApplyFont(ValueLabel, Layout.TextSize, true);

    local SliderObject = setmetatable({
        Window     = self.Window,
        Instance   = Holder,
        Track      = Track,
        Fill       = Fill,
        ValueLabel = ValueLabel,
        Width      = FillWidth,
        Ratio      = MathClamp(Ratio or 0, 0, 1),
        Callback   = Callback,
        Dragging   = false,
    }, Slider);

    SliderObject:_CacheNumberScale();
    SliderObject:Set(SliderObject.Ratio, nil, true);

    local Hitbox = Util.Button(Track, "Hitbox", UDim2FromOffset(0, -8), UDim2.new(1, 0, 1, 16), "", 126);
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
        if (Util.IsDragInput(Input)) then
            SliderObject.Dragging = true;
            SliderObject:_SetFromInput(Input);
        end
    end)
    self.Window:_Signal(Hitbox.InputEnded, function(Input)
        if (Util.IsDragInput(Input)) then SliderObject.Dragging = false; end
    end)
    self.Window:_Signal(UserInputService.InputChanged, function(Input)
        if (SliderObject.Dragging) and (self.Window:_IsInputBlockedByPopup(Input)) then
            SliderObject.Dragging = false;
            return;
        end
        if (SliderObject.Dragging) and (Util.IsMoveInput(Input)) then
            SliderObject:_SetFromInput(Input);
        end
    end)

    if (Auto) then self:_FinishLayout("slider"); else self:_ResizeAuto(); end

    return Library:_RegisterOption(self, Text, SliderObject, "Slider", Flag);
end

function Slider:_CacheNumberScale()
    local Numeric = tonumber(self.ValueLabel.Text);
    self._Decimals = 0;

    local DecimalText = self.ValueLabel.Text:match("%.(%d+)$");
    if (DecimalText) then self._Decimals = #DecimalText; end

    self._ValueScale = Numeric and self.Ratio > 0 and Numeric / self.Ratio or nil;
end

function Slider:_SyncLabelToRatio()
    if (not self._ValueScale) then return; end
    local Value = self.Ratio * self._ValueScale;
    self.ValueLabel.Text = self._Decimals > 0
        and StringFormat(`%.{self._Decimals}f`, Value)
        or ToString(MathFloor(Value + 0.5));
end

function Slider:_PositionLabel()
    local FillWidth  = MathFloor(self.Width * self.Ratio);
    local ValueWidth = MathMax(20, MathCeil(Util.MeasureText(self.ValueLabel.Text, Layout.TextSize)) + 4);
    self.ValueLabel.Size     = UDim2FromOffset(ValueWidth, 12);
    self.ValueLabel.Position = UDim2FromOffset(5 + FillWidth - MathFloor(ValueWidth / 2), 8);
end

function Slider:_SetFromInput(Input)
    local LocalX = MathClamp(Input.Position.X - self.Track.AbsolutePosition.X, 0, self.Track.AbsoluteSize.X);
    self:Set(LocalX / self.Track.AbsoluteSize.X);
end

function Slider:Set(Ratio, Text, Silent)
    if (Text ~= nil) then
        self.ValueLabel.Text = ToString(Text);
        self.Ratio           = MathClamp(Ratio or self.Ratio, 0, 1);
        self:_CacheNumberScale();
    else
        self.Ratio = MathClamp(Ratio or self.Ratio, 0, 1);
        self:_SyncLabelToRatio();
    end

    self.Fill.Size = UDim2FromOffset(MathFloor(self.Width * self.Ratio), 5);
    self:_PositionLabel();
    if (not Silent) then Util.SafeCallback(self.Callback, self.Ratio); end
end

function Slider:Get() return self.Ratio; end

local function ParseButtonArgs(X, Y, Width, Height, Callback)
    if (Util.IsManualXY(X, Y)) then return false, X, Y, Width, Height, Callback; end
    if (type(X) == "table") then
        local Info = X;
        return true, Info.X, Info.Y, Info.Width or 160, Info.Height or 24, Info.Callback or Info.Func;
    end
    return true, nil, nil, 160, 24, X;
end

function Groupbox:AddButton(Text, X, Y, Width, Height, Callback)
    local Auto;
    Auto, X, Y, Width, Height, Callback = ParseButtonArgs(X, Y, Width, Height, Callback);

    local Parent = self.Frame;
    if (Auto) then
        Parent = self:_LayoutHolder(`LayoutButton_{Util.CleanName(Text)}`, Height or 24, 5);
        X      = X or 50;
        Y      = Y or 0;
        Width  = Width or 160;
        Height = Height or 24;
    end

    local Control = Util.MakeButtonControl(Parent, `Button_{Util.CleanName(Text)}`, UDim2FromOffset(X, Y), UDim2FromOffset(Width, Height or 24), 118);
    Util.Label(Control, "Text", Text, UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 120);

    local ButtonObject = setmetatable({
        Instance = Control,
        Callback = Callback,
    }, Button);

    local Hitbox = Util.Button(Control, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
    local Hovering = false;
    self.Window:_Signal(Hitbox.MouseEnter, function()
        Hovering = true;
        Util.SetControlState(Control, "hover");
    end)
    self.Window:_Signal(Hitbox.MouseLeave, function()
        Hovering = false;
        Util.SetControlState(Control, "normal");
    end)
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input)) then return; end
        if (Util.IsClickInput(Input)) then
            Util.SetControlState(Control, "pressed");
            ButtonObject:Press();
            task.delay(0.08, function()
                if (Control) and (Control.Parent) then
                    Util.SetControlState(Control, Hovering and "hover" or "normal");
                end
            end)
        end
    end)

    if (Auto) then self:_FinishLayout("button"); else self:_ResizeAuto(); end

    return ButtonObject;
end

function Button:Press() Util.SafeCallback(self.Callback); end

local function ParseColorPickerArgs(Text, X, Y, Width, Default, Callback)
    local Flag, Compact, Auto, Parent;
    Auto = not Util.IsManualXY(X, Y);

    if (type(X) == "table") then
        local Info = X;
        Flag     = Text;
        Text     = Info.Text or Info.Title or Text;
        X        = Info.X;
        Y        = Info.Y;
        Parent   = Info.Parent;
        Compact  = Info.Compact == true;
        Width    = Info.Width or (Compact and 15 or 180);
        Default  = Info.Default or Info.Value or Default or Theme.Accent;
        Callback = Info.Callback or Callback;
        Auto     = X == nil or Y == nil;
    elseif (Auto) then
        if (Util.IsColor3(X)) then Default = X; Callback = Y;
        else Default = Default or Theme.Accent; end
        X = nil; Y = nil; Width = Width or 180;
    else
        Default = Default or Theme.Accent;
    end

    if (not Util.IsColor3(Default)) then Default = Theme.Accent; end

    Width   = Width or 180;
    Compact = Compact or Width <= 24;

    return ToString(Text), X, Y, Width, Default, Callback, Flag, Compact, Auto, Parent;
end

function Groupbox:AddColorPicker(Text, X, Y, Width, Default, Callback)
    local Flag, Compact, Auto, PickerParent;
    Text, X, Y, Width, Default, Callback, Flag, Compact, Auto, PickerParent = ParseColorPickerArgs(Text, X, Y, Width, Default, Callback);

    local Parent = PickerParent or self.Frame;
    if (Auto) then
        if (Compact) then
            Parent = PickerParent or self.LastAutoWrapper or self.Frame;
            X      = X or 214;
            Y      = Y or ((self.LastAutoRowOffset or 0) + 4);
            Width  = Width or 15;
        else
            Parent = self:_LayoutHolder(`LayoutColorPicker_{Util.CleanName(Text)}`, 16, 4);
            X      = X or 50;
            Y      = Y or 0;
            Width  = Width or 180;
        end
    end

    local SwatchWidth  = 14;
    local SwatchHeight = 7;
    local HolderHeight = Compact and 9 or 16;
    local Holder       = Util.Frame(Parent, `ColorPicker_{Util.CleanName(Text)}`, UDim2FromOffset(X, Y), UDim2FromOffset(Compact and 15 or Width, HolderHeight), Theme.Body, Compact and 126 or 118);
    Holder.BackgroundTransparency = 1;

    local Title;
    if (not Compact) then
        Title = Util.Label(Holder, "Title", Text, UDim2FromOffset(0, 0), UDim2.new(1, -SwatchWidth - 8, 1, 0), Theme.Text, Enum.TextXAlignment.Left, 119);
    end

    local SwatchPosition = Compact and UDim2FromOffset(0, 0) or UDim2.new(1, -SwatchWidth - 4, 0, 4);
    local Swatch         = Util.Frame(Holder, "Swatch", SwatchPosition, UDim2FromOffset(SwatchWidth, SwatchHeight), Default, Compact and 127 or 120);
    local SwatchGradient = Util.Gradient(Swatch, Default, Color3.new(Default.R * 0.65, Default.G * 0.65, Default.B * 0.65));
    Util.Stroke(Swatch, Theme.ColorPickerOuter, 1);

    local MapSize   = 185;
    local PopupSize = MapSize + 2;

    local Popup = Util.Frame(self.Window.PopupLayer, `ColorMenu_{Util.CleanName(Text)}`, UDim2FromOffset(0, 0), UDim2FromOffset(PopupSize, PopupSize), Theme.ColorPickerOuter, 540);
    Popup.Visible = false;
    Util.Stroke(Popup, Theme.ColorPickerPopupBorder, 1);

    local Map = Util.Frame(Popup, "ColorMap", UDim2FromOffset(1, 1), UDim2FromOffset(MapSize, MapSize), Theme.White, 545);
    Map.ClipsDescendants = true;

    for Index = 0, 5 do
        local Segment = Util.Frame(Map, `Hue_{Index}`, UDim2.new(Index / 6, 0, 0, 0), UDim2.new(1 / 6, 1, 1, 0), Theme.White, 546);
        Util.SideGradient(Segment, Color3FromHSV(Index / 6, 1, 1), Color3FromHSV((Index + 1) / 6, 1, 1));
    end

    local WhiteLayer   = Util.Frame(Map, "White", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0.5, 0), Theme.White, 547);
    local WhiteGradient = InstanceNew("UIGradient");
    WhiteGradient.Color        = ColorSequence.new(Theme.White, Theme.White);
    WhiteGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) });
    WhiteGradient.Rotation     = 90;
    WhiteGradient.Parent       = WhiteLayer;

    local BlackLayer   = Util.Frame(Map, "Black", UDim2.new(0, 0, 0.5, 0), UDim2.new(1, 0, 0.5, 0), Color3.new(0, 0, 0), 548);
    local BlackGradient = InstanceNew("UIGradient");
    BlackGradient.Color        = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0));
    BlackGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) });
    BlackGradient.Rotation     = 90;
    BlackGradient.Parent       = BlackLayer;

    local Cursor = Util.Frame(Map, "Cursor", UDim2FromOffset(0, 0), UDim2FromOffset(4, 4), Color3.new(0, 0, 0), 550);
    Cursor.AnchorPoint = Vector2New(0.5, 0.5);
    Util.Frame(Cursor, "Inner", UDim2FromOffset(1, 1), UDim2FromOffset(2, 2), Theme.White, 551);

    local MapHitbox = Util.Button(Map, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 552);

    local PickerRow = Util.ResolvePickerRow(Parent);

    local ColorPickerObject = setmetatable({
        Type           = "ColorPicker",
        Window         = self.Window,
        Groupbox       = self,
        Instance       = Holder,
        Row            = PickerRow,
        RowId          = PickerRow:GetAttribute("KyaniteRowId"),
        Compact        = Compact,
        Title          = Title,
        Swatch         = Swatch,
        SwatchGradient = SwatchGradient,
        Popup          = Popup,
        Map            = Map,
        MapSize        = MapSize,
        Cursor         = Cursor,
        Hue            = 0,
        Sat            = 0,
        Val            = 1,
        Value          = Default,
        Callback       = Callback,
        Open           = false,
        DraggingMap    = false,
    }, ColorPicker);

    ColorPickerObject:Set(Default, true);

    local Hitbox = Util.Button(Holder, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", Compact and 130 or 125);
    self.Window:_Signal(Hitbox.InputBegan, function(Input)
        if (self.Window:_IsInputBlockedByPopup(Input, ColorPickerObject)) then return; end
        if (Util.IsClickInput(Input)) then ColorPickerObject:SetOpen(not ColorPickerObject.Open); end
    end)

    self.Window:_Signal(MapHitbox.InputBegan, function(Input)
        if (Util.IsDragInput(Input)) then
            ColorPickerObject.DraggingMap = true;
            ColorPickerObject:_SetMapFromInput(Input);
        end
    end)

    self.Window:_Signal(UserInputService.InputChanged, function(Input)
        if (not Util.IsMoveInput(Input)) then return; end
        if (ColorPickerObject.DraggingMap) then ColorPickerObject:_SetMapFromInput(Input); end
    end)

    self.Window:_Signal(UserInputService.InputEnded, function(Input)
        if (Util.IsDragInput(Input)) then
            ColorPickerObject.DraggingMap = false;
        end
    end)

    self.Window:_Signal(UserInputService.InputBegan, function(Input, GameProcessed)
        if (GameProcessed) or (Input.UserInputType ~= Enum.UserInputType.MouseButton1) or (not ColorPickerObject.Open) then return; end
        if (not Util.IsPointInside(ColorPickerObject.Instance, Input.Position)) and (not Util.IsPointInside(ColorPickerObject.Popup, Input.Position)) then
            ColorPickerObject:SetOpen(false);
        end
    end)

    if (Auto) then
        if (Compact) then self:_ResizeAuto(); else self:_FinishLayout("colorpicker"); end
    else
        self:_ResizeAuto();
    end

    local Picker = self.Window:_RegisterColorPicker(ColorPickerObject);
    Library:_RegisterOption(self, Text, Picker, "ColorPicker", Flag);
    return Picker;
end

function ColorPicker:_SetHSVFromRGB(Color)
    self.Hue, self.Sat, self.Val = Color3ToHSV(Color);
end

function ColorPicker:_Display(Fire)
    self.Value                  = Color3FromHSV(self.Hue, self.Sat, self.Val);
    self.Swatch.BackgroundColor3 = self.Value;
    self.SwatchGradient.Color   = ColorSequence.new(self.Value, Color3.new(self.Value.R * 0.65, self.Value.G * 0.65, self.Value.B * 0.65));

    local CursorY = (self.Val >= 0.999) and (self.Sat * 0.5) or (1 / (self.Val + 1));

    self.Cursor.Position = UDim2FromScale(self.Hue, MathClamp(CursorY, 0, 1));

    if (Fire) then
        Util.SafeCallback(self.Callback, self.Value);
        Util.SafeCallback(self.Changed,  self.Value);
    end
end

function ColorPicker:_SetMapFromInput(Input)
    if (self.Map.AbsoluteSize.X <= 0) or (self.Map.AbsoluteSize.Y <= 0) then return; end
    local LocalX = MathClamp(Input.Position.X - self.Map.AbsolutePosition.X, 0, self.Map.AbsoluteSize.X);
    local LocalY = MathClamp(Input.Position.Y - self.Map.AbsolutePosition.Y, 0, self.Map.AbsoluteSize.Y);

    local XRatio = LocalX / self.Map.AbsoluteSize.X;
    local YRatio = MathClamp(LocalY / self.Map.AbsoluteSize.Y, 0, 1);

    self.Hue = XRatio;

    if (YRatio <= 0.5) then
        self.Sat = YRatio / 0.5;
        self.Val = 1;
    else
        self.Sat = MathClamp(0.5 / YRatio, 0, 1);
        self.Val = MathClamp((1 - YRatio) / YRatio, 0, 1);
    end

    self:_Display(true);
end

function ColorPicker:SetOpen(Open, Silent)
    Open = Open == true;

    if (Open) then
        self.Window:_CloseColorPickers(self);
        self.Window.OpenColorPicker = self;
        self.Popup.Visible = true;
        Util.PositionPopup(self.Window, self.Popup, self.Swatch, 3);
    elseif (self.Window.OpenColorPicker == self) then
        self.Window.OpenColorPicker = nil;
    end

    if (not Open) and (self.DraggingMap) then
        self.DraggingMap = false;
    end

    self.Open          = Open;
    self.Popup.Visible = Open;
    self.Window:_RefreshPopupBlocker();
end

function ColorPicker:Set(Color, Silent)
    if (type(Color) == "table") then
        Color = Color3FromHSV(Color[1] or self.Hue, Color[2] or self.Sat, Color[3] or self.Val);
    end
    if (not Util.IsColor3(Color)) then return; end
    self:_SetHSVFromRGB(Color);
    self:_Display(not Silent);
end

function ColorPicker:SetValueRGB(Color, Silent) self:Set(Color, Silent); end
function ColorPicker:SetValue(HSV, Silent)       self:Set(HSV, Silent);  end

function ColorPicker:OnChanged(Callback)
    self.Changed = Callback;
    Callback(self.Value);
end

function ColorPicker:Get() return self.Value; end

function ColorPicker:GetHSV() return self.Hue, self.Sat, self.Val; end
end
