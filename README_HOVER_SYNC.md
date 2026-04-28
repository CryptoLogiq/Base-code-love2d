# Hover -> navigation sync

Cette version synchronise la navigation clavier/manette avec le bouton survole par la souris.

Regle appliquee :

- si `Core.Gui.inputMode == "mouse"` et qu'un bouton est survole :
  - le groupe devient le `Core.Gui.activeGroup`,
  - `group.selectedIndex` et `group.current` sont synchronises sur le bouton survole,
  - le feedback visuel reste unique via `visualActive`.

- si `Core.Gui.inputMode == "keyboard"` ou `"gamepad"` :
  - le hover souris ne vole pas la selection,
  - la navigation continue depuis `group.selectedIndex`.

Consequence : si tu survoles `Options`, puis que tu appuies sur bas au clavier/manette, la navigation partira de `Options`, pas de l'ancien bouton selectionne.
