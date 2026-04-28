# LÖVE2D Mini Engine

Un mini moteur personnel pour [LÖVE2D](https://love2d.org/), pensé pour créer rapidement des projets 2D avec une architecture simple, modulaire et proche de l’esprit LÖVE.

L’objectif n’est pas de remplacer LÖVE2D, mais d’ajouter une couche pratique pour éviter de recoder les mêmes systèmes à chaque projet.

Le moteur fournit une base prête à l’emploi pour gérer :

- les scènes ;
- les inputs clavier / souris / manette ;
- les menus GUI ;
- les pages et panels UI ;
- les options du jeu ;
- les résolutions, le fullscreen et le letterbox ;
- les volumes ;
- le remapping des touches ;
- les settings sauvegardés ;
- les assets et sprites.

---

## Documentation

La documentation complète est disponible ici :

[Lire la documentation GitHub Pages](https://cryptologiq.github.io/Base-code-love2d/)

---

## Accès rapide

- [Installation](https://cryptologiq.github.io/Base-code-love2d/installation.html)
- [Quick Start](https://cryptologiq.github.io/Base-code-love2d/quick-start.html)
- [Architecture du Core](https://cryptologiq.github.io/Base-code-love2d/architecture-core.html)
- [Scènes](https://cryptologiq.github.io/Base-code-love2d/scenes.html)
- [Inputs](https://cryptologiq.github.io/Base-code-love2d/inputs.html)
- [GUI : pages, groupes et boutons](https://cryptologiq.github.io/Base-code-love2d/gui-pages-groupes-boutons.html)
- [GUI : priorité des périphériques](https://cryptologiq.github.io/Base-code-love2d/gui-priorite-peripheriques.html)
- [Options](https://cryptologiq.github.io/Base-code-love2d/options.html)
- [Settings et sauvegarde](https://cryptologiq.github.io/Base-code-love2d/settings-sauvegarde.html)
- [Rendu virtuel et letterbox](https://cryptologiq.github.io/Base-code-love2d/rendu-virtuel-letterbox.html)
- [Assets et sprites](https://cryptologiq.github.io/Base-code-love2d/assets-sprites.html)
- [GUI : boutons](https://cryptologiq.github.io/Base-code-love2d/gui-boutons.html)
- [Conventions](https://cryptologiq.github.io/Base-code-love2d/conventions.html)
- [Référence rapide de l’API](https://cryptologiq.github.io/Base-code-love2d/api-reference.html)
- [Roadmap](https://cryptologiq.github.io/Base-code-love2d/roadmap.html)

---

## Démarrage rapide

Le point d’entrée peut rester très simple :

```lua
require("init")

Core.run()
```

`Core.run()` enregistre les callbacks LÖVE principaux et les redirige vers le moteur :

```txt
love.load
love.update
love.draw
love.keypressed / love.keyreleased
love.mousepressed / love.mousereleased / love.mousemoved
love.gamepadpressed / love.gamepadreleased / love.gamepadaxis
love.joystickadded / love.joystickremoved
love.resize / love.focus
```

---

## Structure du projet

```txt
project/
 ├─ main.lua
 ├─ conf.lua
 ├─ init.lua
 ├─ core/
 │   ├─ core_manager.lua
 │   ├─ core_scene.lua
 │   ├─ core_input.lua
 │   ├─ core_gui.lua
 │   ├─ core_options.lua
 │   ├─ core_settings.lua
 │   ├─ core_assets.lua
 │   ├─ core_sprite.lua
 │   └─ gui/
 │       └─ gui_button.lua
 │
 ├─ scenes/
 │   ├─ init_scenes.lua
 │   ├─ scene_loading.lua
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
     ├─ index.md
     ├─ installation.md
     ├─ quick-start.md
     └─ ...
```

---

## Modules principaux

### Core.Scene

Gestion des scènes avec cycle de vie :

```txt
load()   -- appelé une seule fois
enter()  -- appelé à chaque entrée dans la scène
leave()  -- appelé quand on quitte la scène
update(dt)
draw()
```

### Core.Input

Gestion unifiée des inputs :

```lua
Core.Input.pressed("validate")
Core.Input.down("left")
Core.Input.released("attack")
Core.Input.getAxis("horizontal")
```

Les actions peuvent venir du clavier, de la souris ou d’une manette.

### Core.Gui

Gestion des boutons, groupes, pages/panels et focus UI :

```txt
Core.Gui.activeGroup
Core.Gui.setActiveGroup(group)
Core.Gui.getActiveGroup()
```

Le système gère aussi la priorité de périphérique :

```txt
mouse
keyboard
gamepad
```

Cela évite d’avoir plusieurs boutons actifs visuellement en même temps.

### Core.Options

Génération d’un menu Options fonctionnel avec :

- sliders visibles pour les volumes ;
- listes déroulantes pour les résolutions ;
- récupération des résolutions supportées via LÖVE ;
- fullscreen ;
- letterbox ;
- remapping clavier / souris / manette.

### Core.Settings

Chargement et sauvegarde des réglages utilisateur :

- volume ;
- résolution ;
- fullscreen ;
- letterbox ;
- bindings d’inputs.

---

## Philosophie

Ce moteur cherche à rester :

- simple à lire ;
- simple à modifier ;
- proche du fonctionnement naturel de LÖVE2D ;
- adapté aux petits et moyens projets 2D ;
- pensé pour clavier, souris et manette dès le départ.

---

## GitHub Pages

La documentation est pensée pour être publiée depuis le dossier `docs/` du dépôt.

Dans GitHub :

```txt
Settings → Pages → Deploy from a branch → main → /docs
```

URL attendue :

```txt
https://cryptologiq.github.io/Base-code-love2d/
```

---

## Licence

Projet personnel basé sur LÖVE2D.

La licence finale reste à définir.
