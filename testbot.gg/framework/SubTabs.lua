return function(Environment)
    local Theme            = Environment.Theme;
    local Window           = Environment.Window;
    local Tab              = Environment.Tab;
    local Groupbox         = Environment.Groupbox;
    local SubTabs          = Environment.SubTabs;
    local SubTabPage       = Environment.SubTabPage;
    local Button           = Environment.Button;
    local Layout           = Environment.Layout;
    local Util             = Environment.Util;
    local UDim2FromOffset  = Environment.UDim2FromOffset;
    local MathFloor        = Environment.MathFloor;
    local MathMax          = Environment.MathMax;
    local TableInsert      = Environment.TableInsert;
    local ToString         = Environment.ToString;

-- SubTabs
function Groupbox:AddSubTabs(Names, ActiveIndex, Position, Size, Callback)
    if (type(ActiveIndex) == "function") then
        Callback    = ActiveIndex;
        ActiveIndex = 1;
    elseif (type(Position) == "function") then
        Callback  = Position;
        Position  = nil;
        Size      = nil;
    elseif (type(Size) == "function") then
        Callback = Size;
        Size     = nil;
    end

    ActiveIndex = ActiveIndex or 1;
    Names       = type(Names) == "table" and Names or { };

    local Auto       = not Util.IsUDim2(Position);
    local StripParent = self.Frame;

    if (Auto) then
        StripParent = self:_LayoutHolder("LayoutSubTabs", Layout.TabBarHeight + Layout.SubTabTopPadding, Layout.ElementGap);
        Position    = UDim2FromOffset(Layout.ElementInset, Layout.SubTabTopPadding);
        Size        = UDim2FromOffset(240, Layout.TabBarHeight);
    else
        Size = Size or UDim2FromOffset(240, Layout.TabBarHeight);
    end

    local Holder         = Util.Frame(StripParent, "SubTabs", Position, Size, Theme.Tab, 116);
    local SubTabBorder   = Theme.TabOutline;

    local SubTabsObject = setmetatable({
        Groupbox     = self,
        Frame        = Holder,
        Items        = { },
        Pages        = { },
        PagesByName  = { },
        ActiveIndex  = nil,
        Callback     = Callback,
    }, SubTabs);

    local Count     = #Names;
    local BaseWidth = MathFloor(Size.X.Offset / Count);

    for Index, Name in ipairs(Names) do
        local Width     = (Index == Count and Size.X.Offset - (Index - 1) * BaseWidth) or BaseWidth;
        local ItemFrame = Util.Frame(Holder, `SubTab_{Util.CleanName(Name)}`,
            UDim2FromOffset((Index - 1) * BaseWidth + 1, 1),
            UDim2FromOffset(Width - (Index == Count and 2 or 1), Size.Y.Offset - 2),
            Color3.new(1, 1, 1), 117);
        local ItemGradient = Util.Gradient(ItemFrame, Theme.TabGradientTop, Theme.TabGradientBottom);

        if (Index > 1) then
            Util.Line(Holder, `Divider_{Index}`, UDim2FromOffset((Index - 1) * BaseWidth, 1), UDim2FromOffset(1, Size.Y.Offset - 2), SubTabBorder, 130);
        end

        local ActiveLine = Util.Line(ItemFrame, "ActiveLine", UDim2.new(0, 0, 1, -1), UDim2.new(1, 0, 0, 1), Theme.Accent, 120);
        ActiveLine.BackgroundTransparency = 1;

        Util.Label(ItemFrame, "Text", Name, UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), Theme.Text, Enum.TextXAlignment.Center, 121);

        local Hitbox = Util.Button(ItemFrame, "Hitbox", UDim2FromOffset(0, 0), UDim2.new(1, 0, 1, 0), "", 125);
        self.Window:_Signal(Hitbox.MouseButton1Click, function() SubTabsObject:Set(Index); end)

        TableInsert(SubTabsObject.Items, {
            Name       = Name,
            Frame      = ItemFrame,
            Gradient   = ItemGradient,
            ActiveLine = ActiveLine,
        });
    end

    Util.Line(Holder, "TopOutline",    UDim2FromOffset(0, 0),   UDim2.new(1, 0, 0, 1), SubTabBorder, 130);
    Util.Line(Holder, "LeftOutline",   UDim2FromOffset(0, 0),   UDim2.new(0, 1, 1, 0), SubTabBorder, 130);
    Util.Line(Holder, "RightOutline",  UDim2.new(1, -1, 0, 0),  UDim2.new(0, 1, 1, 0), SubTabBorder, 130);
    Util.Line(Holder, "BottomOutline", UDim2.new(0, 0, 1, -1),  UDim2.new(1, 0, 0, 1), SubTabBorder, 130);

    local PagesParent   = self.Content;
    local PagesPosition = UDim2FromOffset(0, 0);
    local PagesWidth    = UDim2.new(1, 0, 0, 0);

    if (not Auto) then
        PagesParent   = self.Frame;
        PagesPosition = UDim2FromOffset(Position.X.Offset, Position.Y.Offset + Size.Y.Offset);
        PagesWidth    = UDim2FromOffset(Size.X.Offset, 0);
    end

    self.LayoutOrder = self.LayoutOrder + 1;

    local PagesContainer = Util.Frame(PagesParent, "SubTabPages", PagesPosition, PagesWidth, Theme.Body, Layout.GroupboxContentZ);
    PagesContainer.BackgroundTransparency = 1;
    PagesContainer.ClipsDescendants       = true;
    PagesContainer.LayoutOrder            = self.LayoutOrder;

    SubTabsObject.PagesContainer = PagesContainer;

    for Index, Name in ipairs(Names) do
        local PageFrame = Util.Frame(PagesContainer, `Page_{Util.CleanName(Name)}`, UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, 0), Theme.Body, Layout.GroupboxContentZ);
        PageFrame.BackgroundTransparency = 1;
        PageFrame.Visible                = false;

        local PageLayout = Util.ListLayout(PageFrame, 0);
        local PageObject = setmetatable({
            Groupbox      = self,
            SubTabs       = SubTabsObject,
            Name          = Name,
            Index         = Index,
            Frame         = PageFrame,
            ContentLayout = PageLayout,
            LayoutOrder   = 0,
        }, SubTabPage);

        SubTabsObject.Items[Index].Page   = PageObject;
        SubTabsObject.Pages[Index]        = PageObject;
        SubTabsObject.PagesByName[Name]   = PageObject;

        self.Window:_Signal(PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            if (SubTabsObject.ActiveIndex == Index) then
                SubTabsObject:_UpdatePagesContainerHeight();
            end
        end)

        local PageTopPad = Util.Frame(PageFrame, "TopPad", UDim2FromOffset(0, 0), UDim2.new(1, 0, 0, 0), Theme.Body, Layout.GroupboxContentZ);
        PageTopPad.BackgroundTransparency = 1;
        PageTopPad.LayoutOrder            = -999;
    end

    SubTabsObject:Set(ActiveIndex, true);

    if (Auto) then
        self:_FinishLayout("subtabs");
    else
        self:_ResizeAuto();
    end

    return SubTabsObject;
end

function SubTabs:_UpdatePagesContainerHeight()
    local ActivePage = self.Pages[self.ActiveIndex];
    if (not ActivePage) or (not self.PagesContainer) then return; end

    local Height = MathMax(0, ActivePage.ContentLayout.AbsoluteContentSize.Y);
    self.PagesContainer.Size = UDim2.new(self.PagesContainer.Size.X.Scale, self.PagesContainer.Size.X.Offset, 0, Height);

    for _, Page in ipairs(self.Pages) do
        Page.Frame.Size = UDim2.new(1, 0, 0, Height);
    end

    self.Groupbox:_ResizeAuto();
    self.Groupbox:_UpdateContentScroll();
end

function SubTabs:Set(Index, Instant)
    if (Index < 1) or (Index > #self.Pages) then return; end

    local PreviousIndex = self.ActiveIndex;
    self.ActiveIndex    = Index;

    for ItemIndex, Item in ipairs(self.Items) do
        local Active = ItemIndex == Index;
        if (Item.Page) then Item.Page.Frame.Visible = Active; end

        if (Item.Gradient) then
            Item.Gradient.Color = ColorSequence.new(
                Active and Theme.TabActiveGradientTop  or Theme.TabGradientTop,
                Active and Theme.TabActiveGradientBottom or Theme.TabGradientBottom
            );
        end

        if (Instant) then
            Item.ActiveLine.BackgroundTransparency = Active and 0 or 1;
        else
            Util.Tween(Item.ActiveLine, { BackgroundTransparency = Active and 0 or 1 }, 0.12);
        end
    end

    self:_UpdatePagesContainerHeight();

    if (self.Groupbox) and (self.Groupbox.Window) then
        self.Groupbox.Window:_CloseColorPickers(nil);
    end

    if (PreviousIndex ~= Index) and (not Instant) then
        local ActivePage = self.Pages[Index];
        Util.SafeCallback(self.Callback, Index, ActivePage and ActivePage.Name, ActivePage);
    end
end

function SubTabs:Get(Index) return self.Pages[Index]; end

function SubTabs:GetPage(IndexOrName)
    if (type(IndexOrName) == "number") then return self.Pages[IndexOrName]; end
    return self.PagesByName[ToString(IndexOrName)];
end

function SubTabs:GetName(Index)
    local Item = self.Items[Index];
    return Item and Item.Name or nil;
end

function SubTabs:GetIndex(Name)
    local Page = self.PagesByName[ToString(Name)];
    return Page and Page.Index or nil;
end

function SubTabs:OnChanged(Callback) self.Callback = Callback; end

-- SubTabPage
function SubTabPage:_RunOnPage(Method, ...)
    local GroupboxObject  = self.Groupbox;
    local RestoreContent  = GroupboxObject.Content;
    local RestoreLayout   = GroupboxObject.LayoutOrder;

    GroupboxObject.Content     = self.Frame;
    GroupboxObject.LayoutOrder = self.LayoutOrder;

    local Result = Groupbox[Method](GroupboxObject, ...);

    self.LayoutOrder           = GroupboxObject.LayoutOrder;
    GroupboxObject.Content     = RestoreContent;
    GroupboxObject.LayoutOrder = RestoreLayout;

    return Result;
end

function SubTabPage:AddBlank(Size)             return self:_RunOnPage("AddBlank", Size);                                        end
function SubTabPage:AddText(Text, X, Y, Width) return self:_RunOnPage("AddText", Text, X, Y, Width);                           end
function SubTabPage:AddCheckbox(...)           return self:_RunOnPage("AddCheckbox", ...);                                      end
function SubTabPage:AddDropdown(...)           return self:_RunOnPage("AddDropdown", ...);                                      end
function SubTabPage:AddKeyPicker(...)          return self:_RunOnPage("AddKeyPicker", ...);                                     end
SubTabPage.AddKeybind = SubTabPage.AddKeyPicker;
function SubTabPage:AddSlider(...)             return self:_RunOnPage("AddSlider", ...);                                        end
function SubTabPage:AddButton(...)             return self:_RunOnPage("AddButton", ...);                                        end
function SubTabPage:AddColorPicker(...)        return self:_RunOnPage("AddColorPicker", ...);                                   end
function SubTabPage:AddTextBox(Text, Options)  return self:_RunOnPage("AddTextBox", Text, Options);                             end
function SubTabPage:AddListBox(Text, Options)  return self:_RunOnPage("AddListBox", Text, Options);                             end
end
