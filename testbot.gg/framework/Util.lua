return function(Environment)
    local Players          = Environment.Players;
    local TextService      = Environment.TextService;
    local TweenService     = Environment.TweenService;
    local Theme            = Environment.Theme;
    local Window           = Environment.Window;
    local Button           = Environment.Button;
    local Layout           = Environment.Layout;
    local Verdana          = Environment.Verdana;
    local VerdanaBold      = Environment.VerdanaBold;
    local InstanceNew      = Environment.InstanceNew;
    local Color3FromRGB    = Environment.Color3FromRGB;
    local Color3FromHSV    = Environment.Color3FromHSV;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local Vector2New       = Environment.Vector2New;
    local MathMax          = Environment.MathMax;
    local MathClamp        = Environment.MathClamp;
    local StringFind       = Environment.StringFind;
    local ToString         = Environment.ToString;
    local TypeOf           = Environment.TypeOf;
    local PCall            = Environment.PCall;
    local BaseMeasureFont  = Environment.BaseMeasureFont;

-- Utility Functions
local Util = { }; do
    function Util.Create(ClassName, Props)
        local Object = InstanceNew(ClassName);
        for Key, Value in Props do
            Object[Key] = Value;
        end
        return Object;
    end

    function Util.ApplyFont(Object, Size, Bold)
        Object.TextSize = Size or Layout.TextSize;
        local Success = PCall(function()
            Object.FontFace = Bold and VerdanaBold or Verdana;
        end)
        if (not Success) then
            Object.Font = Bold and Enum.Font.ArialBold or Enum.Font.Arial;
        end
    end

    function Util.Frame(Parent, Name, Position, Size, Color, ZIndex)
        return Util.Create("Frame", {
            Name                = Name,
            Parent              = Parent,
            Position            = Position,
            Size                = Size,
            BackgroundColor3    = Color,
            BorderSizePixel     = 0,
            ZIndex              = ZIndex or 1,
        });
    end

    function Util.Line(Parent, Name, Position, Size, Color, ZIndex)
        local Object = Util.Frame(Parent, Name, Position, Size, Color, ZIndex);
        Object.BorderSizePixel = 0;
        return Object;
    end

    function Util.Label(Parent, Name, Text, Position, Size, Color, Align, ZIndex)
        local Object = Util.Create("TextLabel", {
            Name                 = Name,
            Parent               = Parent,
            Position             = Position,
            Size                 = Size,
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            Text                 = Text or "",
            TextColor3           = Color or Theme.Text,
            TextStrokeTransparency = 1,
            TextWrapped          = false,
            TextXAlignment       = Align or Enum.TextXAlignment.Left,
            TextYAlignment       = Enum.TextYAlignment.Center,
            ZIndex               = ZIndex or 10,
        });
        Util.ApplyFont(Object, nil, false);
        return Object;
    end

    function Util.Button(Parent, Name, Position, Size, Text, ZIndex)
        local Object = Util.Create("TextButton", {
            Name                 = Name,
            Parent               = Parent,
            Position             = Position,
            Size                 = Size,
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            AutoButtonColor      = false,
            Text                 = Text or "",
            TextColor3           = Theme.Text,
            TextStrokeTransparency = 1,
            TextWrapped          = false,
            TextXAlignment       = Enum.TextXAlignment.Center,
            TextYAlignment       = Enum.TextYAlignment.Center,
            ZIndex               = ZIndex or 20,
        });
        Util.ApplyFont(Object, nil, false);
        return Object;
    end

    function Util.Stroke(Parent, Color, Thickness)
        local Object = InstanceNew("UIStroke");
        Object.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
        Object.Color     = Color;
        Object.Thickness = Thickness or 1;
        Object.Parent    = Parent;
        return Object;
    end

    function Util.Gradient(Parent, TopColor, BottomColor)
        local Object = InstanceNew("UIGradient");
        Object.Color    = ColorSequence.new(TopColor, BottomColor);
        Object.Rotation = 90;
        Object.Parent   = Parent;
        return Object;
    end

    function Util.Tween(Object, Props, Duration)
        local Info   = TweenInfo.new(Duration or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out);
        local Active = TweenService:Create(Object, Info, Props);
        Active:Play();
        return Active;
    end

    function Util.MeasureText(Text, Size)
        local Ok, Result = PCall(function()
            return TextService:GetTextSize(ToString(Text), Size or Layout.TextSize, BaseMeasureFont, Vector2New(1000, 32)).X;
        end)
        return Ok and Result or (#ToString(Text) * 6);
    end

    function Util.ListLayout(Parent, Padding)
        local Layout = InstanceNew("UIListLayout");
        Layout.FillDirection       = Enum.FillDirection.Vertical;
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left;
        Layout.SortOrder           = Enum.SortOrder.LayoutOrder;
        Layout.Padding             = UDim.new(0, Padding or 0);
        Layout.Parent              = Parent;
        return Layout;
    end

    function Util.SafeCallback(Callback, ...)
        if (not Callback) then
            return;
        end
        local Ok, Err = PCall(Callback, ...);
        if (not Ok) then
            warn(Err);
        end
    end

    function Util.CleanName(Text)
        return ToString(Text):gsub("%W+", "_");
    end

    function Util.IsUDim2(Value)
        return TypeOf(Value) == "UDim2";
    end

    function Util.IsColor3(Value)
        return TypeOf(Value) == "Color3";
    end

    function Util.IsManualXY(X, Y)
        return type(X) == "number" and type(Y) == "number";
    end

    function Util.ListValueOrEmpty(Value)
        return type(Value) == "table" and Value or { };
    end

    function Util.IsDragInput(Input)
        return Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch;
    end

    function Util.IsMoveInput(Input)
        return Input.UserInputType == Enum.UserInputType.MouseMovement
            or Input.UserInputType == Enum.UserInputType.Touch;
    end

    function Util.FormatInput(Input)
        if (Input.UserInputType == Enum.UserInputType.Keyboard) then
            return Input.KeyCode.Name;
        end
        if (Input.UserInputType == Enum.UserInputType.MouseButton1) then return "Mouse 1"; end
        if (Input.UserInputType == Enum.UserInputType.MouseButton2) then return "Mouse 2"; end
        if (Input.UserInputType == Enum.UserInputType.MouseButton3) then return "Mouse 3"; end
        return Input.UserInputType.Name;
    end

    function Util.ScreenPoint(Point)
        if (TypeOf(Point) == "Vector3") then
            return Vector2New(Point.X, Point.Y);
        end
        return Point;
    end

    function Util.IsPointInside(Object, Point)
        if (not Object) or (not Object.Parent) or (not Object.Visible) then
            return false;
        end
        Point = Util.ScreenPoint(Point);
        local Position = Object.AbsolutePosition;
        local Size     = Object.AbsoluteSize;
        return Point.X >= Position.X
            and Point.X <= Position.X + Size.X
            and Point.Y >= Position.Y
            and Point.Y <= Position.Y + Size.Y;
    end

    function Util.HueSequence()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3FromHSV(0.00, 1, 1)),
            ColorSequenceKeypoint.new(0.17, Color3FromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3FromHSV(0.33, 1, 1)),
            ColorSequenceKeypoint.new(0.50, Color3FromHSV(0.50, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3FromHSV(0.67, 1, 1)),
            ColorSequenceKeypoint.new(0.83, Color3FromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1.00, Color3FromHSV(1.00, 1, 1)),
        });
    end

    function Util.MakeControl(Parent, Name, Position, Size, ZIndex)
        local Control = Util.Frame(Parent, Name, Position, Size, Theme.ControlOuter, ZIndex or 120);
        local Inner   = Util.Frame(Control, "Inner", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.ControlTop, (ZIndex or 120) + 1);
        Util.Gradient(Inner, Theme.ControlTop, Theme.ControlBottom);
        return Control, Inner;
    end

    function Util.MakeButtonControl(Parent, Name, Position, Size, ZIndex)
        local Control = Util.Frame(Parent, Name, Position, Size, Theme.ControlOuter, ZIndex or 120);
        local Inner   = Util.Frame(Control, "Inner", UDim2FromOffset(1, 1), UDim2.new(1, -2, 1, -2), Theme.ButtonTop, (ZIndex or 120) + 1);
        Util.Gradient(Inner, Theme.ButtonTop, Theme.ButtonBottom);
        return Control, Inner;
    end

    function Util.SetDropdownArrow(Icon, Open)
        local Widths  = Open and { 7, 5, 3 } or { 3, 5, 7 };
        local Offsets = Open and { 0, 1, 2 } or { 2, 1, 0 };
        for Index = 1, 3 do
            local Row = Icon:FindFirstChild("Row" .. ToString(Index));
            if (Row) then
                Row.Position = UDim2FromOffset(Offsets[Index], Index - 1);
                Row.Size     = UDim2FromOffset(Widths[Index], 1);
            end
        end
    end

    function Util.MakeDropdownArrow(Parent, Name, Position, ZIndex)
        local Icon = Util.Frame(Parent, Name, Position, UDim2FromOffset(7, 4), Theme.DropdownMenu, ZIndex or 121);
        Icon.BackgroundTransparency = 1;
        Util.Line(Icon, "Shadow", UDim2FromOffset(0, -1), UDim2FromOffset(7, 1), Color3FromRGB(0, 0, 0), (ZIndex or 121) + 1);
        for Index = 1, 3 do
            Util.Line(Icon, "Row" .. ToString(Index), UDim2FromOffset(0, Index - 1), UDim2FromOffset(7, 1), Theme.DropdownArrow, (ZIndex or 121) + 2);
        end
        Util.SetDropdownArrow(Icon, false);
        return Icon;
    end

    function Util.SetCheckboxVisual(Square, Value)
        local Gradient = Square:FindFirstChild("CheckedGradient");
        if (not Gradient) then
            Gradient       = InstanceNew("UIGradient");
            Gradient.Name  = "CheckedGradient";
            Gradient.Parent = Square;
        end

        Gradient.Enabled = Value == true;
        Gradient.Color   = ColorSequence.new(Theme.Accent, Theme.AccentDim);

        Square.BackgroundColor3 = Value and Theme.Accent or Theme.CheckboxOff;
    end

    function Util.PositionPopup(Window, Popup, Anchor, YOffset)
        local AnchorPosition = Anchor.AbsolutePosition;
        local AnchorSize     = Anchor.AbsoluteSize;
        local RootPosition   = Window.Root.AbsolutePosition;
        local RootSize       = Window.Root.AbsoluteSize;
        local PopupSize      = Popup.AbsoluteSize;

        if (PopupSize.X <= 0) or (PopupSize.Y <= 0) then
            PopupSize = Vector2New(Popup.Size.X.Offset, Popup.Size.Y.Offset);
        end

        local MaxX = MathMax(4, RootSize.X - PopupSize.X - 4);
        local MaxY = MathMax(4, RootSize.Y - PopupSize.Y - 4);
        local X    = AnchorPosition.X - RootPosition.X;
        local Y    = AnchorPosition.Y - RootPosition.Y + AnchorSize.Y + (YOffset or 2);

        if (Y + PopupSize.Y > RootSize.Y - 4) then
            Y = AnchorPosition.Y - RootPosition.Y - PopupSize.Y - (YOffset or 2);
        end

        Popup.Position = UDim2FromOffset(MathClamp(X, 4, MaxX), MathClamp(Y, 4, MaxY));
    end

    function Util.ResolveParent(Options)
        if (Options and Options.Parent) then
            return Options.Parent;
        end
        local Player = Players.LocalPlayer;
        if (not Player) then return nil; end
        return Player:WaitForChild("PlayerGui");
    end

    function Util.ResolvePickerRow(Parent)
        local Current = Parent;
        while (Current) do
            local Name = Current.Name;
            if (type(Name) == "string") then
                if (StringFind(Name, "^Layout") and Name:sub(1, 6) == "Layout") then
                    return Current;
                end
                if (Name:sub(1, 9) == "Checkbox_") then
                    if (Current.Parent and Current.Parent.Name:sub(1, 6) == "Layout") then
                        return Current.Parent;
                    end
                end
            end
            Current = Current.Parent;
        end
        return Parent;
    end
end
    Environment.Util = Util;
end
