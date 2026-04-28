# Core.Options - widgets UX

Cette version améliore l'interface Options avec des widgets plus ergonomiques.

## Résolution

`Core.Options.addResolution()` récupère automatiquement les modes disponibles via :

```lua
love.window.getFullscreenModes()
```

La résolution actuelle et la résolution bureau sont ajoutées si elles ne sont pas déjà présentes.

L'option est affichée sous forme de liste déroulante :

```lua
Core.Options.addResolution("resolution", "Résolution")
```

Contrôles :

```txt
Entrée / A       ouvrir la liste
Haut / Bas       choisir une résolution
Gauche / Droite  changer aussi dans la liste
Entrée / A       appliquer
Echap / B        fermer sans appliquer
```

## Sliders

Les options de type `slider` affichent maintenant une barre visible avec un curseur.

Exemple :

```lua
Core.Options.addVolume("master_volume", "Volume général")
```

ou :

```lua
Core.Options.addSlider("music", "Musique", 0.8, 0, 1, 0.05, function(value)
  -- appliquer volume musique
end, true)
```

Contrôles :

```txt
Gauche / Droite  ajuste la valeur
Souris           clic / glissé sur la barre
```

## Dropdown générique

`addChoice` sert maintenant de liste déroulante :

```lua
Core.Options.addChoice("difficulty", "Difficulté", {
  "Facile",
  "Normal",
  "Difficile",
}, 2, function(value)
  print("Nouvelle difficulté", value)
end)
```

Alias disponible :

```lua
Core.Options.addDropdown(...)
```

## Remarques

La sauvegarde disque n'est pas encore gérée ici. Cette passe améliore seulement l'UX runtime.
