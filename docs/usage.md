# Usage

Tout ce qu'on tape : les raccourcis que cette configuration ajoute ou change,
et les alias qu'elle définit. Les valeurs par défaut d'origine ne sont pas
listées.

## zsh : édition de ligne (mode vi)

`bindkey -v`, `KEYTIMEOUT=10` (100 ms pour sortir du mode insertion). bash le
reproduit (`set -o vi` dans `.bashrc`), si bien que les réflexes se reportent
sur le shell de fallback.

| Touche | Action | Source |
|---|---|---|
| `Esc` | mode normal (vi) | `.zshrc` |
| `Ctrl-R` | recherche floue dans l'historique (fzf) | `fzf --zsh` |
| `Ctrl-T` | sélecteur de fichiers flou, aperçu bat | `fzf --zsh` |
| `Alt-C` | cd flou dans un sous-répertoire | `fzf --zsh` |
| `Ctrl-F` | sélecteur de fichiers **sans** les fichiers cachés | widget `fzf.zsh` |
| `Tab` | menu de complétion fzf-tab (`<`/`>` changent de groupe, `Tab` descend) | fzf-tab |

fzf utilise `fd` quand il est présent, `find` sinon ; les aperçus utilisent
`bat`, puis `head` en fallback, si bien que chaque raccourci fonctionne sur une
machine qui n'a aucun des trois.

## tmux

[.config/tmux/README.md](../.config/tmux/README.md).

## Alias et fonctions de shell

| Alias | Devient | A besoin de |
|---|---|---|
| `ll` / `la` | `eza -lh` / `eza -lah`, icônes et statut git | eza (fallback : `ls -lh` / `ls -lah`) |
| `lt` | `eza --tree --icons=auto` | eza (fallback : `tree`) |
| `ls` | `eza --icons=auto` | eza seulement : sans lui, `ls` reste le `ls` du système |
| `cat` | `bat` | bat |
| `diff` | `diff --color=auto` | GNU diff (sondé) |
| `df` | `df -h` | rien |
| `v` | `nvim` | rien |
| `path` | `$PATH`, un répertoire par ligne | rien |
| `g` | `git` | git |
| `ga` / `ga.` / `gaa` | `git add` / `add .` / `add --all` | git |
| `gs` / `gd` / `gds` | `git status` / `diff` / `diff --staged` | git |
| `gc` / `gck` | `git commit` / `checkout` | git |
| `gb` / `gbd` / `gbD` | `git branch` / `branch --delete` / `branch -D` | git |
| `gpl` / `gp` | `git pull` / `git push` | git |
| `gl` | `git log --graph --oneline` | git |
| `gconf` | `git config --list --show-origin --show-scope` | git |
| `ghc <repo>` | clone `github.com:$GITUSER/<repo>` dans `$GHREPOS`, puis cd | git |
| `glc <repo>` | clone `gitlab.com:$GLUSER/<repo>` dans `$GLREPOS`, puis cd | git |

`GITUSER` (GitHub), `GLUSER` (GitLab), `REPOS` (`~/lab`), `GHREPOS`
(`$REPOS/github`) et `GLREPOS` (`$REPOS/gitlab`) sont posés dans
`shell/env.sh`, et c'est là qu'elles se changent. Deux variables de nom
d'utilisateur, qui portent le même nom aujourd'hui : les garder séparées est ce
qui permet de renommer un compte sans toucher aux URL de l'autre. Les
répertoires sont créés par `./run install` (étape directories).

`ghc` et `glc` sont des **raccourcis de rangement, pas une organisation que git
exigerait** : l'identité qu'un dépôt utilise est décidée par l'URL de son
remote, donc un simple `git clone` dans n'importe quel répertoire choisit la
bonne tout seul.

Ce sont des alias de **shell**, pas des alias git : `gs`, pas `git st`.
Hors d'un shell interactif, git ne répond qu'à git tel quel — le coût est écrit
là où ils vivent, dans `shell/aliases.sh`. La config git elle-même :
[.config/git/README.md](../.config/git/README.md).

## Objets git : fzf-git.sh

[fzf-git.sh](https://github.com/junegunn/fzf-git.sh), chargé par zinit quand
fzf est présent. Chaque raccourci commence par `Ctrl-G` ; les mêmes fonctions
sont aussi joignables comme de simples commandes. Une **lettre doublée** pour
les trois du quotidien, le préfixe `gf*` pour le reste.

Chaque raccourci est lié **deux fois** : `Ctrl-G Ctrl-B` et `Ctrl-G b` appellent
le même widget. La seconde forme évite de garder `Ctrl` enfoncé, la table
ci-dessous ne cite que la première.

| Raccourci | Alias | Objet |
|---|---|---|
| `Ctrl-G Ctrl-F` | `gff` | fichiers (suivis + non suivis, avec le statut) |
| `Ctrl-G Ctrl-B` | `gbb` | branches |
| `Ctrl-G Ctrl-T` | `gft` | tags |
| `Ctrl-G Ctrl-R` | `gfr` | remotes |
| `Ctrl-G Ctrl-H` | `ghh` | hachages de commits |
| `Ctrl-G Ctrl-S` | `gfs` | stashes |
| `Ctrl-G Ctrl-L` | `gfl` | reflogs |
| `Ctrl-G Ctrl-W` | `gfw` | worktrees |
| `Ctrl-G Ctrl-E` | `gfe` | chaque ref (`git for-each-ref`) |
| `Ctrl-G ?` | `gfk` | la liste de ces raccourcis |

Le raccourci **insère** la sélection dans la ligne de commande ; l'alias
l'**affiche**, d'où `git switch $(gbb)`. Dans le sélecteur : `Ctrl-O` ouvre
dans le navigateur, `Alt-E` dans `$EDITOR`, `Ctrl-/` fait défiler l'aperçu.

`gfk` fait exception, et c'est la seule ligne de la table où les deux colonnes
ne sont pas équivalentes : le raccourci affiche la liste **sous** le prompt, en
message transitoire, effacé à la frappe suivante ; l'alias l'écrit dans le
défilement, où elle reste lisible pendant qu'on tape. C'est aussi le seul des
dix qui n'exige pas d'être dans un dépôt git.

## Terminaux

Ni ghostty ni kitty ne porte de raccourci personnalisé. Les valeurs d'origine
sur les deux, c'est ce qui garde la mémoire musculaire portable entre eux.
Comportements notables : `copy-on-select`, `macos-option-as-alt`.
Configuration : [outils.md](outils.md), section « Terminaux ».

---

Voir aussi : [outils.md](outils.md) pour les outils derrière ces raccourcis
et l'origine de chacun.
