return function(Environment)
    local UserInputService = Environment.UserInputService;
    local Theme            = Environment.Theme;
    local Window           = Environment.Window;
    local Tab              = Environment.Tab;
    local Groupbox         = Environment.Groupbox;
    local Layout           = Environment.Layout;
    local Util             = Environment.Util;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local MathFloor        = Environment.MathFloor;
    local MathMax          = Environment.MathMax;
    local MathClamp        = Environment.MathClamp;

-- Groupbox Methods
function Groupbox:_GetContentHeight()
    local LayoutHeight = self.ContentLayout and self.ContentLayout.AbsoluteContentSize.Y or 0;
    if (LayoutHeight > 0) then return LayoutHeight; end

    local ContentHeight = 0;
    for _, Child in self.Content:GetChildren() do
        if (Child:IsA("GuiObject")) and (Child.Visible) and (not Child:IsA("UIListLayout")) then
            ContentHeight = ContentHeight + Child.Size.Y.Offset;
        end
    end
    return ContentHeight;
end

function Groupbox:_GetContentViewportHeight()
    local Clip = self.ContentClip;
    if (Clip) then
        if (Clip.AbsoluteSize.Y > 0)  then return Clip.AbsoluteSize.Y; end
        if (Clip.Size.Y.Offset > 0)   then return Clip.Size.Y.Offset;  end
    end
    return MathMax(0, self.Frame.Size.Y.Offset - Layout.GroupboxContentTop);
end

function Groupbox:_ConnectContentWheel()
    if (self._ScrollWheelConnected) then return; end
    self._ScrollWheelConnected = true;

    self.Window:_Signal(UserInputService.InputChanged, function(Input)
        if (Input.UserInputType ~= Enum.UserInputType.MouseWheel) then return; end
        if (not self._ContentOverflow) then return; end

        local Clip = self.ContentClip;
        if (not Clip) or (not Clip.Visible) then return; end
        if (not Util.IsPointInside(Clip, Input.Position)) then return; end

        for _, Picker in self.Window.ColorPickers do
            if (Picker.Open) then
                self.Window:_CloseColorPickers(nil);
                return;
            end
        end

        local Step = MathMax(14, MathFloor(self:_GetContentViewportHeight() * 0.12));
        local Prev = self._ScrollY or 0;
        self._ScrollY = MathClamp(Prev - Input.Position.Z * Step, 0, self._MaxScroll or 0);

        if (self._ScrollY ~= Prev) then
            self.Content.Position = UDim2FromOffset(0, -self._ScrollY);
        end
    end)
end

function Groupbox:_UpdateContentScroll()
    local Content = self.Content;
    local Clip    = self.ContentClip;
    if (not Content) or (not Clip) then return; end

    local ContentHeight  = self:_GetContentHeight();
    local ViewportHeight = self:_GetContentViewportHeight();

    if (ContentHeight > 0) then
        Content.Size = UDim2.new(1, 0, 0, ContentHeight);
    end

    if (ViewportHeight <= 0) then
        self._ContentOverflow = false;
        self._MaxScroll       = 0;
        self._ScrollY         = 0;
        Content.Position      = UDim2FromOffset(0, 0);
        return;
    end

    local MaxScroll = MathMax(0, ContentHeight - ViewportHeight);
    local Overflow  = MaxScroll > 1;

    self._ContentOverflow = Overflow;
    self._MaxScroll       = MaxScroll;
    self._ScrollY         = MathClamp(self._ScrollY or 0, 0, MaxScroll);

    if (not Overflow) then self._ScrollY = 0; end

    Content.Position = UDim2FromOffset(0, -self._ScrollY);
    Clip.Active      = Overflow;
end

function Groupbox:_ResizeAuto()
    local ContentHeight = self:_GetContentHeight();
    local NaturalHeight = MathMax(self.MinHeight or 0, Layout.GroupboxContentTop + ContentHeight + 2);
    self._AutoHeight    = NaturalHeight;

    if (not self.Auto) then
        self:_UpdateContentScroll();
        return;
    end

    if (self.Tab) then
        self.Tab:_RelayoutGroupboxes();
    else
        self.Frame.Size = UDim2FromOffset(self.Width or 260, NaturalHeight);
        self:_UpdateContentScroll();
    end
end

function Groupbox:AddBlank(Size)
    self.LayoutOrder = self.LayoutOrder + 1;
    local Blank = Util.Frame(self.Content, "Blank", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, Size or 0), Theme.Body, Layout.GroupboxContentZ);
    Blank.BackgroundTransparency = 1;
    Blank.LayoutOrder            = self.LayoutOrder;
    return Blank;
end

function Groupbox:_LayoutHolder(Name, Height, BlankAfter, ClipDescendants)
    self.LayoutOrder = self.LayoutOrder + 1;
    self._RowSerial  = (self._RowSerial or 0) + 1;

    local Holder = Util.Frame(self.Content, Name, UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, Height), Theme.Body, Layout.GroupboxContentZ);
    Holder.BackgroundTransparency = 1;
    Holder.ClipsDescendants       = ClipDescendants == true;
    Holder.LayoutOrder            = self.LayoutOrder;
    Holder:SetAttribute("KyaniteRowId", self._RowSerial);

    self.LastAutoWrapper   = Holder;
    self.LastAutoRowOffset = 0;

    if (BlankAfter) and (BlankAfter > 0) then self:AddBlank(BlankAfter); end

    self:_UpdateContentScroll();
    return Holder;
end

function Groupbox:_FinishLayout(Kind)
    self.LastElementType = Kind;
    self:_ResizeAuto();
    self:_UpdateContentScroll();
end
end
