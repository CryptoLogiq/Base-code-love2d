# Settings et sauvegarde

Les options peuvent être sauvegardées dans un fichier Lua via `love.filesystem`.

Par défaut, les réglages sont chargés au démarrage du moteur via :

```lua
Core.Options.loadSettings()
```

## Charger

```lua
Core.Options.loadSettings()
```

Ou avec un chemin spécifique :

```lua
Core.Options.loadSettings("settings.lua")
```

## Sauvegarder

```lua
Core.Options.saveSettings()
```

Ou :

```lua
Core.Options.saveSettings("settings.lua")
```

Le fichier sauvegardé ressemble à :

```lua
return {
  options = {
    master_volume = 0.75,
    fullscreen = false,
    letterbox = true,
    resolution = { w = 1280, h = 720 },
  },
  inputBindings = {
    validate = { "key:return", "key:space", "pad:a" },
    attack = { "key:x", "mouse:1", "pad:x" },
  },
}
```

## Appliquer les settings

```lua
Core.Options.applySettings()
```

Cela applique notamment :

- volume ;
- fullscreen ;
- résolution ;
- letterbox ;
- layout clavier ;
- bindings d’inputs.

## Sauvegarde automatique

Le module Options appelle la sauvegarde après les changements importants.

Exemples :

- changement de volume ;
- changement de résolution ;
- toggle fullscreen ;
- remapping input.

## À savoir

`love.filesystem.write()` écrit dans le dossier de sauvegarde LÖVE, pas forcément dans le dossier source du projet.

Pour trouver le chemin de sauvegarde :

```lua
print(love.filesystem.getSaveDirectory())
```

## Reset des inputs

```lua
Core.Input.resetBindings()
Core.Options.saveSettings()
```

## Conseil

Garde la persistance dans `Core.Options` / `Core.Settings`, pas dans les scènes. Une scène Options doit afficher et relayer ; elle ne devrait pas contenir la logique de sérialisation.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
