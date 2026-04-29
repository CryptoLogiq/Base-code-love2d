# AGENTS.md

## Projet

Ce dépôt contient un engine/framework LÖVE2D en Lua.

L’objectif est de garder une structure simple, modulaire, lisible et proche de l’esprit LÖVE2D.

## Règles générales

- Ne pas refactorer tout le projet sans demande explicite.
- Faire des modifications minimales et ciblées.
- Garder les API existantes autant que possible.
- Préférer du Lua simple et lisible.
- Éviter les abstractions trop lourdes.
- Ne pas modifier les fichiers de documentation sauf si la tâche concerne la doc.
- Ne pas supprimer de code sans expliquer pourquoi.

## Style de code

- Utiliser des modules Lua avec `local M = {}` puis `return M` si le fichier est conçu comme module.
- Garder des noms explicites.
- Éviter les variables globales sauf pour les objets centraux déjà assumés par le projet, comme `Core` si c’est le choix architectural.
- Préférer des fonctions courtes et faciles à comprendre.
- Garder les commentaires utiles, mais éviter de commenter l’évidence.

## Architecture

- `main.lua` doit rester minimal.
- Le lancement principal doit passer par `Core.run()` si possible.
- Le dossier `core/` contient les systèmes internes de l’engine.
- Le dossier `scenes/` contient les scènes utilisateur.
- Le dossier `docs/` contient la documentation utilisateur / wiki.
- Le GUI doit rester dessiné après le rendu principal du jeu.

## Contraintes importantes

- Ne pas casser la compatibilité avec LÖVE2D.
- Ne pas ajouter de dépendance externe sans demande explicite.
- Ne pas mélanger logique GUI, input et scene manager si une séparation existe déjà.
- Ne pas modifier `.gitignore` sauf si la tâche le demande.

## Avant de modifier

Avant de proposer un patch :
1. Identifier les fichiers réellement concernés.
2. Éviter de lire ou modifier tout le repo si le problème est localisé.
3. Expliquer brièvement la cause du problème.
4. Proposer une correction ciblée.

## Après modification

À la fin, expliquer :
- les fichiers modifiés ;
- ce qui a été corrigé ;
- les éventuels points à tester manuellement dans LÖVE2D.