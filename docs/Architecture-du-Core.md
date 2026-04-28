# Architecture du Core

Le moteur est organisé autour d’un objet global `Core`.

```txt
Core
├─ Input
├─ Gui
├─ Options
├─ Scene
├─ Mouse
├─ Assets
├─ Sprite
├─ Timer
├─ Collision
└─ rendu virtuel
```

## Cycle principal

`main.lua` délègue à `Core` :

```lua
function love.load()
  Core.load()
end

function love.update(dt)
  Core.update(dt)
end

function love.draw()
  Core.draw()
end
```

`Core.update(dt)` suit cet ordre :

```txt
1. Core.Input.update(dt)
2. Core.Gui.update(dt)
3. Core.Mouse.update(dt)
4. Core.Scene.update(dt)
5. Core.Input.clearFrame()
```

Cette dernière étape est importante : `pressed` et `released` doivent rester lisibles pendant toute la frame de la scène.

## Callbacks relayés

```txt
love.keypressed      -> Core.keypressed      -> Core.Input + Core.Scene
love.mousepressed    -> Core.mousepressed    -> Core.Mouse + Core.Input + Core.Scene
love.mousemoved      -> Core.mousemoved      -> Core.Mouse + Core.Scene
love.gamepadpressed  -> Core.gamepadpressed  -> Core.Input + Core.Scene
love.gamepadaxis     -> Core.gamepadaxis     -> Core.Input + Core.Scene
```

## Rendu

`Core.draw()` applique le rendu virtuel, dessine la scène, puis remet la couleur en blanc pour éviter les effets de bord :

```txt
Core.push()
  Core.Gui.draw()
  Core.Scene.draw()
  Core.Mouse.draw()
Core.pop()
```

## Convention importante

Dans tes scènes, évite de lire directement les touches :

```lua
if key == "return" then
```

Préfère :

```lua
if Core.Input.pressed("validate") then
```

Comme ça, le clavier, la souris et la manette partagent la même logique de gameplay.
