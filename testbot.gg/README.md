# testbot.gg

small modular luau ui framework.

## layout

```text
main.lua
library/
    init.lua
    Builder.lua
    Flags.lua
    Managers.lua
modules/
    Services.lua
    Objects.lua
assets/
    verdana.ttf
    verdana-bold.ttf
```

## notes

`main.lua` is only the bootstrap now. put window/tab code there, keep reusable ui helpers in `library/`, and keep shared roblox helpers in `modules/`.

the style is intentionally the same as the original script: tables with `do` blocks, colon methods, local caches, semicolons, and capitalized module objects.
