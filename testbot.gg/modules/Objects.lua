-- Objects
local Objects = { }; do
    function Objects:Get(Ancestor, Name, Class, Identifier)
        for _, Descendant in Ancestor:GetDescendants() do
            if (Descendant.Name ~= Name) or (Descendant.ClassName ~= Class) then
                continue;
            end

            if (Identifier or function() return true end)(Descendant) then
                return Descendant;
            end
        end
    end
end

return Objects;
