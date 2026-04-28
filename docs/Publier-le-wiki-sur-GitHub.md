# Publier le wiki sur GitHub

GitHub stocke le wiki dans un dépôt séparé :

```txt
https://github.com/<user>/<repo>.wiki.git
```

## Méthode simple

```bash
git clone https://github.com/<user>/<repo>.wiki.git
cd <repo>.wiki
cp /chemin/vers/les/pages/*.md .
git add .
git commit -m "docs: add engine wiki"
git push
```

## Pages importantes

- `Home.md` : page d’accueil du wiki.
- `_Sidebar.md` : menu latéral.
- Les autres fichiers `.md` deviennent des pages du wiki.

## Conseil

Garde les titres des fichiers simples, sans caractères trop exotiques si tu veux éviter les surprises. Les liens internes utilisent la syntaxe :

```md
[[Nom de la page]]
```
