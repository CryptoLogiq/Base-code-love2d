# Mini Engine LÖVE2D

Bienvenue dans le wiki du mini-engine.

L’objectif du moteur est de garder un esprit **LÖVE2D-like** : simple, direct, lisible, basé sur des callbacks, avec une petite couche `Core` qui évite de répéter la même plomberie dans chaque projet.

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

- [[Installation]]
- [[Quick Start]]
- [[Architecture du Core]]
- [[Scènes]]
- [[Inputs]]
- [[GUI - Pages, groupes et boutons]]
- [[GUI - Priorité des périphériques]]
- [[Options]]
- [[Settings et sauvegarde]]
- [[Rendu virtuel et letterbox]]
- [[Assets et sprites]]
- [[Recettes]]
- [[Référence rapide de l'API]]

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
