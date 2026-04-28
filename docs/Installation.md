# Installation

## Pré-requis

- LÖVE 11.x ou plus récent.
- Un projet avec une structure proche de celle-ci :

```txt
project/
├─ main.lua
├─ init.lua
├─ conf.lua
├─ core/
│  ├─ init_core.lua
│  ├─ core_manager.lua
│  ├─ core_scene.lua
│  ├─ core_input.lua
│  ├─ core_gui.lua
│  ├─ core_options.lua
│  ├─ core_assets.lua
│  ├─ core_sprite.lua
│  ├─ core_mouse.lua
│  ├─ core_collisions.lua
│  ├─ core_maths.lua
│  └─ gui/
│     ├─ gui_button.lua
│     └─ gui_page.lua
├─ scenes/
│  ├─ init_scenes.lua
│  ├─ scene_menu.lua
│  ├─ scene_game.lua
│  └─ scene_options.lua
└─ assets/
```

## Chargement du moteur

Dans `init.lua` :

```lua
require("core/init_core")
require("scenes/init_scenes")
```

Dans `main.lua`, tu gardes seulement les callbacks LÖVE qui relaient vers `Core` :

```lua
require("init")

function love.load()
  Core.load()
end

function love.update(dt)
  Core.update(dt)
end

function love.draw()
  Core.draw()
end

function love.keypressed(key, scancode, isrepeat)
  Core.keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
  Core.mousepressed(x, y, button, istouch, presses)
end

function love.gamepadpressed(joystick, button)
  Core.gamepadpressed(joystick, button)
end
```

Tu peux relayer aussi `keyreleased`, `mousereleased`, `mousemoved`, `gamepadaxis`, `joystickadded` et `joystickremoved`.

## Lancement

Depuis le dossier du projet :

```bash
love .
```

## `.gitignore` conseillé

```gitignore
*.zip
.love

# IDE
.idea/
.vscode/

# Local / temporary files
.codex
test.txt

# OS
.DS_Store
Thumbs.db
```
