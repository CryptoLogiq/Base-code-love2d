# Inputs

`Core.Input` transforme les périphériques en actions de jeu.

Au lieu de tester directement une touche :

```lua
if love.keyboard.isDown("z") then
```

on teste une action :

```lua
if Core.Input.down("up") then
```

## Actions par défaut

```lua
validate = { "key:return", "key:space", "pad:a" }
cancel   = { "key:escape", "pad:b" }
up       = { "key:up", "key:z", "pad:dpup", "axis:lefty-" }
down     = { "key:down", "key:s", "pad:dpdown", "axis:lefty+" }
left     = { "key:left", "key:q", "pad:dpleft", "axis:leftx-" }
right    = { "key:right", "key:d", "pad:dpright", "axis:leftx+" }
attack   = { "key:x", "mouse:1", "pad:x", "pad:rightshoulder" }
```

Les tokens suivent cette convention :

| Token | Exemple | Signification |
|---|---|---|
| `key:` | `key:return` | touche clavier |
| `mouse:` | `mouse:1` | bouton souris |
| `pad:` | `pad:a` | bouton gamepad LÖVE |
| `axis:` | `axis:leftx+` | axe analogique |

## Lire une action

```lua
if Core.Input.pressed("validate") then
  print("validé une fois")
end

if Core.Input.down("left") then
  print("gauche maintenu")
end

if Core.Input.released("attack") then
  print("attaque relâchée")
end
```

Aliases compatibles :

```lua
Core.Input.isPressed("validate")
Core.Input.isDown("left")
Core.Input.isReleased("attack")
```

## Axes de déplacement

```lua
local x = Core.Input.getAxis("horizontal")
local y = Core.Input.getAxis("vertical")

player.x = player.x + x * speed * dt
player.y = player.y + y * speed * dt
```

## Remapper une action

```lua
Core.Input.setPrimaryBinding("attack", "key:x")
Core.Input.setPrimaryBinding("attack", "pad:x")
Core.Input.setPrimaryBinding("attack", "mouse:1")
```

Le binding remplace le binding principal du même type et retire le même token des autres actions.

## Lire les bindings

```lua
local bindings = Core.Input.getBindings("validate")
print(Core.Input.bindingsToLabel("validate"))
```

## Réinitialiser

```lua
Core.Input.resetBindings()
```

## Layout clavier

Le moteur détecte AZERTY / QWERTY et adapte les actions `up` et `left`.

```lua
Core.Input.detectKeyboardLayout()
Core.Input.setKeyboardLayout("azerty")
Core.Input.setKeyboardLayout("qwerty")
Core.Input.getKeyboardLayout()
```

## Deadzone manette

```lua
Core.Input.setDeadzone(0.25)
```

## Règle importante

`pressed` et `released` ne sont valides que pendant une frame. C’est pourquoi `Core.update(dt)` appelle `Core.Input.clearFrame()` seulement après `Core.Scene.update(dt)`.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
