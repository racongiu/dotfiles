# Usage

Tout ce qu'on tape : les raccourcis que cette configuration ajoute ou change,
et les alias et fonctions qu'elle définit. Les valeurs par défaut d'origine
ne sont pas listées.

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

| Alias ou fonction | Devient | A besoin de |
|---|---|---|
| `ll` / `la` | `eza -lh` / `eza -lah`, icônes et statut git | eza (fallback : `ls -lh` / `ls -lah`) |
| `lt` | `eza --tree --level=2 --long --icons --git` | eza (fallback : `tree -L 2`) |
| `ls` | `eza --icons=auto` | eza seulement : sans lui, `ls` reste le `ls` du système |
| `cat` | `bat` | bat |
| `diff` | `diff --color=auto` | GNU diff (sondé) |
| `df` | `df -h` | rien |
| `v` | `nvim` | rien |
| `c` | `clear` | rien |
| `path` | `$PATH`, un répertoire par ligne | rien |
| `gad` / `gad.` | `git add` / `add .` | git |
| `gst` | `git status` | git |
| `gd` / `gds` | `git diff` / `diff --staged` | git |
| `gc` / `gca` | `git commit -m` / `commit -am` | git |
| `gck` | `git checkout` | git |
| `gbd` / `gbD` | `git branch --delete` / `branch -D` | git |
| `gpu` / `gp` | `git pull origin` / `git push` | git |
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

Ce sont des alias de **shell**, pas des alias git : `gst`, pas `git st`.
Hors d'un shell interactif, git ne répond qu'à git tel quel — le coût est écrit
là où ils vivent, dans `shell/aliases.sh`. La config git elle-même :
[.config/git/README.md](../.config/git/README.md).

## Objets git : fzf-git.sh

[fzf-git.sh](https://github.com/junegunn/fzf-git.sh), chargé par zinit quand
fzf est présent. Chaque raccourci commence par `Ctrl-G` ; les mêmes fonctions
sont aussi joignables comme de simples commandes.

Chaque raccourci est lié **deux fois** : `Ctrl-G Ctrl-B` et `Ctrl-G b` appellent
le même widget. La seconde forme évite de garder `Ctrl` enfoncé, la table
ci-dessous ne cite que la première.

| Raccourci | Commande | Objet | Repli sans fzf-git |
|---|---|---|---|
| `Ctrl-G Ctrl-B` | `gb` | branches | `git branch` |
| `Ctrl-G Ctrl-T` | `gt` | tags | `git tag` |
| `Ctrl-G Ctrl-R` | `gr` | remotes | `git remote -v` |
| `Ctrl-G Ctrl-H` | `gh` | hachages de commits | `git log --oneline` |
| `Ctrl-G Ctrl-W` | `gw` | worktrees | `git worktree list` |
| `Ctrl-G Ctrl-E` | `ger` | chaque ref | `git for-each-ref` |
| `Ctrl-G ?` | `gfk` | la liste de ces raccourcis | aucun |

`Ctrl-G Ctrl-F` (fichiers), `Ctrl-G Ctrl-S` (stashes) et `Ctrl-G Ctrl-L`
(reflogs) gardent leur raccourci clavier, sans forme en ligne de commande.

Les commandes sont des **fonctions** de `shell/aliases.sh`, pas des alias de
`zsh/fzf.zsh` : elles choisissent au moment où on les tape. Deux raisons. zinit
charge fzf-git.sh en différé, après l'apparition du prompt, donc un test écrit
au démarrage le trouverait toujours absent. Et bash n'a jamais fzf-git.sh,
zinit étant un gestionnaire de greffons zsh : sans repli, `gb` y répondrait
`command not found`.

Le raccourci **insère** la sélection dans la ligne de commande ; la commande
l'**affiche**, d'où `git switch $(gb)`. Dans le sélecteur : `Ctrl-O` ouvre
dans le navigateur, `Alt-E` dans `$EDITOR`, `Ctrl-/` fait défiler l'aperçu.

`gfk` fait exception, et c'est la seule ligne de la table où les deux colonnes
ne sont pas équivalentes : le raccourci affiche la liste **sous** le prompt, en
message transitoire, effacé à la frappe suivante ; la commande l'écrit dans le
défilement, où elle reste lisible pendant qu'on tape. C'est aussi le seul qui
n'exige pas d'être dans un dépôt git.

## Terminaux

Ni ghostty ni kitty ne porte de raccourci personnalisé. Les valeurs d'origine
sur les deux, c'est ce qui garde la mémoire musculaire portable entre eux.
Comportements notables : `copy-on-select`, `macos-option-as-alt`.
Configuration : [outils.md](outils.md), section « Terminaux ».

---

Voir aussi : [outils.md](outils.md) pour les outils derrière ces raccourcis
et l'origine de chacun.
