# GUI - Priorité des périphériques

Le moteur gère une priorité globale pour éviter deux feedbacks visuels en même temps.

## Modes disponibles

```lua
Core.Gui.getInputMode()
```

Retourne :

```txt
"mouse"
"keyboard"
"gamepad"
```

## Règle de feedback

| Mode | Feedback visuel |
|---|---|
| `mouse` | bouton survolé du groupe actif |
| `keyboard` | bouton sélectionné du groupe actif |
| `gamepad` | bouton sélectionné du groupe actif |

## Changer de mode

Le Core le fait automatiquement :

```txt
clavier pressé   -> keyboard
clic souris      -> mouse
bouton manette   -> gamepad
axe manette      -> gamepad si deadzone dépassée
mouvement souris -> mouse si délai autorisé
```

Tu peux aussi forcer :

```lua
Core.Gui.setInputMode("mouse", true)
Core.Gui.setInputMode("keyboard", true)
Core.Gui.setInputMode("gamepad", true)
```

## Délai anti-flicker

Pour éviter qu’une souris posée sur un bouton vole le feedback pendant une navigation manette :

```lua
Core.Gui.setInputModeDelay(0.20)
```

## Hover sync

En mode souris, quand un bouton est survolé :

```txt
1. son groupe devient le groupe actif ;
2. group.selectedIndex est synchronisé ;
3. group.current devient le bouton survolé.
```

Conséquence : si tu survoles `Options`, puis que tu appuies sur bas au clavier/manette, la navigation continue depuis `Options`, pas depuis l’ancien bouton sélectionné.

## Cacher la souris en mode manette

`Core.Gui` cache automatiquement le curseur quand `inputMode == "gamepad"`.

## Bonne pratique

Ne teste pas `button.hovered` dans une scène pour décider du feedback. Utilise seulement :

```lua
page:update(dt)
page:draw()
```

Le moteur s’occupe de décider quel bouton est `visualActive`.
