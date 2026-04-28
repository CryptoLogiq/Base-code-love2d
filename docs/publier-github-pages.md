# Publier avec GitHub Pages

Cette documentation est prévue pour être publiée depuis le dossier `docs/` du dépôt principal.

## Structure attendue

```txt
repo/
 ├─ core/
 ├─ scenes/
 ├─ main.lua
 └─ docs/
     ├─ index.md
     ├─ installation.md
     ├─ quick-start.md
     └─ ...
```

## Activer GitHub Pages

Sur GitHub :

```txt
Settings → Pages
```

Puis choisis :

```txt
Source: Deploy from a branch
Branch: main
Folder: /docs
```

Clique ensuite sur `Save`.

## URL finale

Ton site sera disponible à une adresse du type :

```txt
https://ton-user.github.io/ton-repo/
```

## Liens internes

Pour GitHub Pages, utilise des liens Markdown classiques :

```md
[Quick Start](quick-start.html)
[Référence API](api-reference.html)
```

Évite le format de lien réservé au wiki GitHub.

---

[← Accueil](index.html) · [Navigation complète](navigation.html)
