# LÖVE2D Mini Engine

Un mini moteur personnel pour [LÖVE2D](https://love2d.org/), pensé pour créer rapidement des projets 2D avec une architecture simple, modulaire et proche de l’esprit LÖVE.

Le moteur fournit une base prête à l’emploi pour gérer :

- les scènes ;
- les inputs clavier / souris / manette ;
- les menus GUI ;
- les pages et panels UI ;
- les options du jeu ;
- les résolutions, le fullscreen et le letterbox ;
- les volumes ;
- le remapping des touches ;
- les assets et sprites.

---

## Documentation

La documentation complète est disponible ici :

[Lire la documentation GitHub Pages](https://cryptologiq.github.io/Base-code-love2d/)

---

## Accès rapide

- [Quick Start](https://cryptologiq.github.io/Base-code-love2d/quick-start.html)
- [Installation](https://cryptologiq.github.io/Base-code-love2d/installation.html)
- [Architecture du Core](https://cryptologiq.github.io/Base-code-love2d/architecture-core.html)
- [Scènes](https://cryptologiq.github.io/Base-code-love2d/scenes.html)
- [Inputs](https://cryptologiq.github.io/Base-code-love2d/input-manager.html)
- [GUI : pages, groupes et boutons](https://cryptologiq.github.io/Base-code-love2d/gui-pages-groups-buttons.html)
- [Priorité souris / clavier / manette](https://cryptologiq.github.io/Base-code-love2d/gui-device-priority.html)
- [Options](https://cryptologiq.github.io/Base-code-love2d/options.html)
- [Settings et sauvegarde](https://cryptologiq.github.io/Base-code-love2d/settings.html)
- [Rendu virtuel et letterbox](https://cryptologiq.github.io/Base-code-love2d/virtual-rendering-letterbox.html)
- [Assets et sprites](https://cryptologiq.github.io/Base-code-love2d/assets-sprites.html)
- [Recettes](https://cryptologiq.github.io/Base-code-love2d/recipes.html)
- [Référence rapide de l’API](https://cryptologiq.github.io/Base-code-love2d/api-reference.html)
- [Roadmap](https://cryptologiq.github.io/Base-code-love2d/roadmap.html)

---

## Structure du projet

```txt
project/
 ├─ main.lua
 ├─ conf.lua
 ├─ init.lua
 ├─ core/
 │   ├─ core.lua
 │   ├─ core_scene.lua
 │   ├─ core_input.lua
 │   ├─ core_gui.lua
 │   ├─ core_options.lua
 │   ├─ core_settings.lua
 │   ├─ core_assets.lua
 │   └─ gui/
 │       └─ gui_button.lua
 │
 ├─ scenes/
 │   ├─ scene_menu.lua
 │   ├─ scene_options.lua
 │   └─ scene_game.lua
 │
 ├─ assets/
 │   ├─ images/
 │   ├─ fonts/
 │   └─ sounds/
 │
 └─ docs/
     └─ index.md