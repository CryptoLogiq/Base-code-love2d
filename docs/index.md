# Mini Engine LÖVE2D

Bienvenue dans la documentation du mini-engine.

L’objectif du moteur est de garder un esprit **LÖVE2D-like** : simple, direct, lisible, basé sur des callbacks, avec une petite couche `Core` qui évite de répéter la même plomberie dans chaque projet.

```lua
require("init")

Core.run()
```

Le moteur ne cherche pas à remplacer LÖVE. Il sert surtout à fournir une base réutilisable pour :

- les scènes ;
- les inputs clavier / souris / manette ;
- les menus et pages GUI ;
- les options de jeu ;
- le rendu virtuel avec letterbox ;
- les assets, spritesheets et animations simples.

## Philosophie

1. **LÖVE reste visible** : on utilise toujours `love.graphics`, `love.audio`, `love.window`, etc.
2. **Les scènes restent simples** : `load`, `enter`, `leave`, `update`, `draw`.
3. **Les inputs sont abstraits** : le gameplay lit des actions comme `validate`, `cancel`, `left`, `attack`, pas des touches brutes.

## Pages principales

- [Installation](installation.html)
- [Quick Start](quick-start.html)
- [Architecture du Core](architecture-core.html)
- [Scènes](scenes.html)
- [Inputs](inputs.html)
- [GUI - Pages, groupes et boutons](gui-pages-groupes-boutons.html)
- [GUI - Priorité des périphériques](gui-priorite-peripheriques.html)
- [Options](options.html)
- [Settings et sauvegarde](settings-sauvegarde.html)
- [Rendu virtuel et letterbox](rendu-virtuel-letterbox.html)
- [Assets et sprites](assets-sprites.html)
- [GUI - Boutons](gui-boutons.html)
- [Référence rapide de l'API](api-reference.html)

## Exemple minimal

```lua
local menu = Core.Scene.new("Menu")

function menu.enter()
  print("Entrée dans le menu")
end

function menu.update(dt)
  if Core.Input.pressed("validate") then
    Core.Scene.set(Game)
  end
end

function menu.draw()
  love.graphics.print("Appuie sur Entrée / A", 100, 100)
end

return menu
```

---

[Navigation complète](navigation.html) · [Référence rapide de l'API](api-reference.html)
