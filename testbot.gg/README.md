# testbot.gg

small modular luau ui framework for script executors.

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

`main.lua` is only the bootstrap now. it uses `game:HttpGet` + `loadstring` to import every file from github raw.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/waveringlizard9872/dragonnoob983423/main/testbot.gg/main.lua"))();
```

put window/tab code in `main.lua`, keep reusable ui helpers in `library/`, and keep shared roblox helpers in `modules/`.

the style is intentionally the same as the original script: tables with `do` blocks, colon methods, local caches, semicolons, and capitalized module objects.
