-- Imports
local Import = ...;

local Flags = Import("library/Flags.lua");

-- Builder
local Builder = { }; do
    local Repository = "https://raw.githubusercontent.com/dementiaenjoyer/UI-LIBRARIES/refs/heads/main/ud_linoria";

    function Builder:GetLibrary()
        if (self.Library) then
            return self.Library;
        end

        self.Library = loadstring(game:HttpGet(`{Repository}/new_font.lua`))();

        Flags:SetLibrary(self.Library);

        return self.Library;
    end

    function Builder:CreateWindow(Data)
        local Library = self:GetLibrary();
        local Window = Library:CreateWindow(Data);

        Flags.Window = Window;

        return Window;
    end
end

return Builder;
