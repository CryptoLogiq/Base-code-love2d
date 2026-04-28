# Rendu virtuel et letterbox

Le Core fournit un rendu virtuel basé par défaut sur :

```lua
1280 x 720
```

Cela permet de dessiner dans une résolution logique stable, même si la fenêtre change de taille.

## Définir la résolution virtuelle

```lua
Core.setDimensions(1280, 720)
```

## Activer / désactiver le rendu scalé

```lua
Core.setScaledDrawEnabled(true)
```

## Letterbox

```lua
Core.setLetterbox(true)
Core.getLetterbox()
```

Quand le letterbox est actif, le moteur conserve le ratio de la résolution virtuelle et ajoute des bandes noires si nécessaire.

Quand il est désactivé, le rendu est étiré sur toute la fenêtre.

## Conversion souris

Le Core convertit automatiquement les coordonnées souris vers l’espace virtuel :

```lua
local vx, vy = Core.toVirtual(x, y)
local vdx, vdy = Core.toVirtualDelta(dx, dy)
```

Les callbacks relayés par `Core.mousepressed` et `Core.mousemoved` fournissent déjà des coordonnées virtuelles à la scène.

## Push / Pop

Le rendu est encadré par :

```lua
Core.push()
  -- draw scène
Core.pop()
```

En général, tu n’as pas besoin de les appeler toi-même : `Core.draw()` le fait.

## Exemple

Même si la fenêtre est en 1920x1080, tu peux dessiner en 1280x720 :

```lua
function game.draw()
  love.graphics.rectangle("fill", 0, 0, 1280, 720)
  love.graphics.circle("fill", 640, 360, 32)
end
```

## Pourquoi c’est utile ?

- Menus plus simples à placer.
- Coordonnées stables.
- Meilleure compatibilité avec plusieurs résolutions.
- La souris reste cohérente grâce à `Core.toVirtual`.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
