# Priorite de feedback UI : souris / clavier / manette

Cette version ajoute une priorite globale dans `Core.Gui` pour eviter que deux boutons semblent actifs en meme temps.

## Principe

`Core.Gui.inputMode` indique quel peripherique controle le feedback visuel :

```lua
Core.Gui.getInputMode() -- "mouse", "keyboard" ou "gamepad"
```

- `mouse` : le bouton survole par la souris a la priorite.
- `keyboard` / `gamepad` : la selection du groupe actif a la priorite.

Un petit delai anti-flicker est applique entre les changements de peripherique :

```lua
Core.Gui.setInputModeDelay(0.20)
```

Les evenements forts changent immediatement le mode :

- clic souris
- touche clavier
- bouton manette

Les evenements plus bruyants comme le deplacement souris ou un axe analogique respectent le delai.

## Rendu

`Gui.Button` possede maintenant un etat `visualActive`.

Le groupe choisit un seul bouton visuellement actif :

```lua
group.visualCurrent
```

Chaque bouton dessine son feedback selectionne uniquement si :

```lua
button.visualActive == true
```

Resultat : un seul contour / feedback principal au draw.
