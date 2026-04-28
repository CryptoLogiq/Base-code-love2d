# Assets et sprites

Le moteur fournit deux modules simples :

```txt
Core.Assets
Core.Sprite
```

## Assets

`Core.Assets` met en cache les images et les fonts.

### Charger une image

```lua
local img = Core.Assets.newImage("assets/player.png", {
  filter = { min = "nearest", mag = "nearest" }
})
```

Si l’image est déjà chargée, le même objet est renvoyé.

### Charger une font

```lua
local font = Core.Assets.newFont(nil, 24)
local custom = Core.Assets.newFont("assets/font.ttf", 18)
```

### Vider le cache

```lua
Core.Assets.clearCache()
```

## Sprite simple

```lua
local player = Core.Sprite.newSprite("assets/player.png", {
  x = 100,
  y = 100,
  scale = 2,
  centerOrigin = true,
})

function game.draw()
  player:draw()
end
```

## Spritesheet

```lua
local sheet = Core.Sprite.newSpriteSheet("assets/sheet.png", 32, 32, {
  spacing = 0,
  margin = 0,
})

local sprite = sheet:newSprite(1, {
  x = 100,
  y = 100,
  scale = 2,
})
```

## Accéder aux frames

```lua
local quad = sheet:getQuad(1)
local frame = sheet:getFrame(1)
local count = sheet:getFrameCount()
```

## Animation

```lua
local walk = Core.Sprite.newAnimation(sheet, {1, 2, 3, 4}, 8, {
  loop = true,
  x = 100,
  y = 100,
  scale = 2,
})

function game.update(dt)
  walk:update(dt)
end

function game.draw()
  walk:draw()
end
```

## Plusieurs animations depuis une table

```lua
local animations = Core.Sprite.newAnimations(sheet, {
  idle = { frames = {1, 2}, fps = 4 },
  walk = { frames = {3, 4, 5, 6}, fps = 8 },
})
```

## Depuis un fichier Lua

```lua
local animations, sheet, data = Core.Sprite.newAnimationsFromFile("assets/player_animations.lua")
```

Le fichier doit retourner une table avec :

```lua
return {
  image = "assets/spritesheet.png",
  frameW = 32,
  frameH = 32,
  animations = {
    idle = { frames = {1, 2, 3}, fps = 6 },
    walk = { frames = {4, 5, 6, 7}, fps = 10 },
  }
}
```

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
