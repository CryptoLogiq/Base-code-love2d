# Référence rapide de l'API

## Core

```lua
Core.run()
Core.load()
Core.update(dt)
Core.draw()

Core.setDimensions(w, h)
Core.getDimensions()
Core.setScaledDrawEnabled(enabled)
Core.setLetterbox(enabled)
Core.getLetterbox()
Core.updateRenderScale()
Core.toVirtual(x, y)
Core.toVirtualDelta(dx, dy)
Core.push()
Core.pop()
```

## Core.Scene

```lua
Core.Scene.new(name)
Core.Scene.get(name)
Core.Scene.getScene(name)
Core.Scene.getCurrent()
Core.Scene.set(sceneOrName)
Core.Scene.load(sceneOrName)
Core.Scene.setBackgroundColor(r, g, b, a, sceneOrName)
Core.Scene.getBackgroundColor(sceneOrName)
Core.Scene.syncBackgroundColor(sceneOrName)
Core.Scene.applyBackgroundColor(sceneOrName)
```

## Core.Input

```lua
Core.Input.down(action)
Core.Input.pressed(action)
Core.Input.released(action)
Core.Input.getAxis("horizontal")
Core.Input.getAxis("vertical")

Core.Input.getBindings(action)
Core.Input.getAllBindings()
Core.Input.setBindings(action, bindings)
Core.Input.setAllBindings(bindingsMap)
Core.Input.setPrimaryBinding(action, token)
Core.Input.resetBindings()
Core.Input.bindingsToLabel(action)
Core.Input.tokenToLabel(token)

Core.Input.detectKeyboardLayout()
Core.Input.getKeyboardLayout()
Core.Input.setKeyboardLayout(layout)
Core.Input.setDeadzone(value)
```

## Core.Gui

```lua
Core.Gui.newButton(text, x, y, w, h, group, callback)
Core.Gui.newButtonGroup(name, layout)
Core.Gui.newPage(name)
Core.Gui.newPanel(name)

Core.Gui.setActiveGroup(group)
Core.Gui.getActiveGroup()
Core.Gui.clearActiveGroup(group)

Core.Gui.setInputMode("mouse" | "keyboard" | "gamepad", force)
Core.Gui.getInputMode()
Core.Gui.isMouseMode()
Core.Gui.isKeyboardMode()
Core.Gui.isGamepadMode()
Core.Gui.isNavigationMode()
Core.Gui.setInputModeDelay(delay)
```

## Gui.Button

```lua
button:setVisible(visible)
button:setEnabled(enabled)
button:setText(text, font)
button:setFont(font)
button:setTextAlign("left" | "center" | "right", padding)
button:setFunction(callback)
button:onClick(callback)
button:isSelectable()
```

## Gui.Group

```lua
group:selectIndex(index)
group:selectFirstAvailable()
group:selectNext()
group:selectPrevious()
group:validate()
group:setVisible(visible)
group:setEnabled(enabled)
group:setActive(active)
group:setLayout(config)
group:layoutVertical(x, y, spacing, w, h)
group:layoutHorizontal(x, y, spacing, w, h)
group:applyLayout()
group:getHovered()
group:getVisualCurrent()
```

## Gui.Page / Panel

```lua
page:addGroup(name, group)
page:getGroup(name)
page:setActiveGroup(nameOrGroup)
page:show()
page:hide()
page:setVisible(visible)
page:setEnabled(enabled)
page:setGroupVisible(name, visible)
page:setOnlyGroupVisible(name)
page:update(dt)
page:draw()
page:mousepressed(x, y, button, istouch, presses)
```

## Core.Options

```lua
Core.Options.setup(config)
Core.Options.build()
Core.Options.show()
Core.Options.hide()
Core.Options.update(dt)
Core.Options.draw()
Core.Options.mousepressed(...)
Core.Options.keypressed(...)
Core.Options.gamepadpressed(...)
Core.Options.gamepadaxis(...)

Core.Options.newToggle(id, label, value, onChange)
Core.Options.newSlider(id, label, value, min, max, step, onChange, asPercent)
Core.Options.newChoice(id, label, choices, index, onChange)
Core.Options.newInput(action, label, onChange)
Core.Options.newAction(id, label, onAction)
Core.Options.newVolume(id, label, value)
Core.Options.newFullscreen(id, label)
Core.Options.newLetterbox(id, label)
Core.Options.newKeyboardLayout(id, label)
Core.Options.newAspectFormat(id, label)
Core.Options.newResolution(id, label)

Core.Options.loadSettings(path)
Core.Options.saveSettings(path)
Core.Options.applySettings()
Core.Options.isWaitingForInput()
Core.Options.isDropdownOpen()
Core.Options.getPage()
Core.Options.getGroup()
```

## Core.Assets

```lua
Core.Assets.newImage(path, settings)
Core.Assets.newFont(path, size)
Core.Assets.clearCache()
```

## Core.Sprite

```lua
Core.Sprite.newSprite(imageOrPath, config)
Core.Sprite.newSpriteSheet(imageOrPath, frameW, frameH, config)
Core.Sprite.newAnimation(sheet, frameIndexes, fps, config)
Core.Sprite.newAnimations(sheet, definitions)
Core.Sprite.newAnimationsFromFile(path)
```

## Core.Collision

```lua
Core.Collision.check(x1, y1, w1, h1, x2, y2, w2, h2)
Core.Collision.aabb(a, b)
Core.Collision.aabbMouse(mouse, object)
Core.Collision.checkIntersect(l1p1, l1p2, l2p1, l2p2)
Core.Collision.findIntersect(...)
```

## Core.Timer

```lua
local t = Core.Timer.new(delai)
t:update(dt)
t:draw(x, y)
t:pause()
t:play()
t:resume()
t:stop()
t:restart()
```


---

[← Accueil](index.html) · [Navigation complète](navigation.html)
