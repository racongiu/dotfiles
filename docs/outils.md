# Outils et paquets

D'où vient chaque outil, et pourquoi il est là.

## L'essentiel

| Question | Réponse |
|---|---|
| Qui installe quoi ? | `brew bundle` lit le `Brewfile` à la racine |
| Les exceptions ? | claude code (installeur officiel) et les runtimes (mise) |
| Ce qui reste à la main ? | donner sa VM à podman, une fois par machine |
| Où sont épinglées les versions ? | `.config/mise/config.toml` |

## Installé par `./run`

Légende : **brew** / **cask** = Brewfile · **mise** = `config.toml` ·
**`./run`** = la recette de `packages.sh`.

| Outil | Vient de |
|---|---|
| git · tmux · zsh · bash · tree · eza · zoxide · fzf · bat · fd · ripgrep · btop · jq · make · cmake · just · lazygit · yazi · xh · posting · uv · gcc · ansible · ansible-lint | brew |
| bash-completion | brew `bash-completion@2` |
| delta | brew `git-delta` |
| age · sops · age-plugin-yubikey · ykman | brew, voir « Ce qui sert un autre dépôt » |
| openssh · libfido2 | brew, ils comblent un manque de macOS ([security.md](security.md)) |
| cloudflared | brew, voir « Ce qui sert un autre dépôt » |
| ghostty · kitty · Nerd Font JetBrains Mono | cask |
| jetbrains-toolbox · gitkraken · bruno · postman · raycast · keymapp · obsidian · claude (bureau) · firefox · google-chrome | cask |
| podman · docker | brew `podman` + cask `podman-desktop` · cask `docker-desktop` |
| starship · mise | brew |
| claude code (le CLI) | **`./run`**, installeur officiel |
| runtimes et linters épinglés | mise |

`chsh` et `pbcopy` sont intégrés à macOS.

La formule `gcc` ne pose qu'un binaire numéroté, `gcc-16` : elle ne recouvre
jamais le `gcc` d'Apple. Un alias de shell interactif, dans
`.config/shell/aliases.sh`, fait pointer `gcc` dessus au clavier. `make` et
`cc` restent sur clang d'Apple ; un projet qui veut GNU le dit avec
`CC = gcc-16` dans son Makefile.

<details>
<summary>Trois précisions qui évitent une erreur</summary>

Presque tout vient de `brew bundle`, qui lit le `Brewfile` **à la racine du
dépôt**. Deux exceptions : **claude code**, dont la formule brew traîne
derrière ses releases, et les **runtimes**, que `mise install` pose depuis
`.config/mise/config.toml`.

Le test d'idempotence de la recette claude regarde `command -v` **puis**
`~/.local/bin` directement. Un shell démarré avant que ce répertoire existe ne
le porte pas sur son PATH, et `command -v` seul réinstallerait à chaque
exécution.

Le `cask "claude"` et le CLI `claude code` sont **deux produits différents**.
Le cask pose `/Applications/Claude.app` et ne déclare aucun binaire. Les deux
ne se voient jamais.

</details>

## Ceux du quotidien

| Outil | Remplace | Pourquoi |
|---|---|---|
| [eza](https://github.com/eza-community/eza) | ls | icônes, colonne git, vue en arbre ; câblé dans `ls/ll/la/lt` |
| [bat](https://github.com/sharkdp/bat) | cat | coloration syntaxique ; aussi le moteur d'aperçu de fzf |
| [fd](https://github.com/sharkdp/fd) | find | syntaxe plus saine, conscient du .gitignore ; alimente fzf |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | grep | recherche récursive rapide, consciente du .gitignore |
| [fzf](https://github.com/junegunn/fzf) | rien | la couche floue : `^R`, `^T`, `^F`, `Alt-C`, menu Tab |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | cd | sauts par fréquence-récence : `z proj` |
| [starship](https://starship.rs) | PS1 | une seule config de prompt pour zsh et bash |
| [btop](https://github.com/aristocratos/btop) | top | vue lisible des ressources |
| [yazi](https://yazi-rs.github.io) | `ls` et `cd` à la main | explorateur de fichiers en terminal ; thème auto clair/sombre, réglages d'origine pour le reste |
| [lazygit](https://github.com/jesseduffield/lazygit) | rien | mettre des hunks en index sans `git add -p` ; rend les diffs avec delta, et le numéro de ligne cliqué ouvre l'éditeur à cette ligne |
| [delta](https://github.com/dandavison/delta) | le pager de git | `git diff`, `git log`, `git show` en deux colonnes, avec numéros de ligne et coloration syntaxique ; thème Catppuccin, clair ou sombre selon le bureau |
| [jq](https://github.com/jqlang/jq) | rien | du JSON en ligne de commande |
| [xh](https://github.com/ducaale/xh) | `curl`, à la main | requêtes HTTP écrites à la main : syntaxe lisible, JSON coloré. `curl` reste pour les scripts et les téléchargements |
| [just](https://github.com/casey/just) | rien | lanceur de commandes nommées, **pas** un remplaçant de make |
| [uv](https://docs.astral.sh/uv/) | `pip`, `venv` | dépendances, verrous et environnements d'un projet python. **Pas** l'interpréteur : mise le garde |
| [posting](https://posting.sh) | Postman, Insomnia | client HTTP en TUI, requêtes en YAML versionnables. Complète `xh` : l'un pour une ligne, l'autre pour une collection |

`bat` : config `numbers,changes,header` ; l'aperçu fzf la remplace par
`plain,numbers`. Son thème suit le clair/sombre tout seul, sans script :
`--theme-dark` et `--theme-light` nomment les deux saveurs Catppuccin, et
`auto:system` décide — voir plus bas pourquoi `auto` tout court ne suffit pas. `just` contre `make` : make construit (C, cibles
incrémentales), just lance les tâches d'un dépôt sans la cérémonie des
`.PHONY`.

## Le clair/sombre, un seul détecteur

`scripts/theme/detect.sh` répond `light` ou `dark`, et c'est le seul à répondre.
Il interroge le **bureau**, pas le terminal : ghostty est réglé sur
`light:...,dark:...`, donc il suit la même apparence système et les deux
réponses ne peuvent pas diverger.

La préférence appartient au **bureau**, pas à la distribution : Fedora et Arch
répondent l'un comme l'autre à travers le bureau qui y est installé. D'où
l'ordre des sondes :

| Ordre | Sonde | Ce qu'elle couvre | Déjà présente grâce à |
|---|---|---|---|
| 1 | `TERM_THEME=light\|dark` | la main, et ssh | — |
| 2 | `defaults read -g AppleInterfaceStyle` | macOS | le système |
| 3 | portail `org.freedesktop.appearance` | GNOME, KDE, Hyprland, tout ce qui l'implémente | `gdbus` (glib2) ou `busctl` (systemd) |
| 4 | `gsettings` `org.gnome.desktop.interface` | GNOME sans portail | glib2 |
| 5 | rien : `dark` | gestionnaire de fenêtres nu, tty, conteneur | — |

Le portail renvoie 2 pour clair, 1 pour sombre et 0 pour « sans préférence » —
ce dernier ne décide rien et laisse passer à la sonde suivante. Aucune de ces
commandes n'est un paquet à installer sur Fedora ou Arch : glib2 et systemd
sont déjà là, ce qui compte sur une machine où l'on n'est pas root.

Le repli final est `dark` délibérément : une palette claire sur fond sombre est
illisible, et c'est la sonde qui échoue, jamais l'affichage.

| Qui consomme | Comment | Quand ça bascule |
|---|---|---|
| delta | `scripts/theme/delta.sh`, le pager de git | au `git diff` suivant |
| lazygit, les diffs | le même script, via `diffRenderers` | au lancement suivant |
| lazygit, l'interface | les couleurs ANSI du terminal | en direct |
| bat | sa détection à lui, réglée sur `auto:system` | à l'appel suivant |
| yazi, nvim | leur propre détection | en direct |
| tmux | `scripts/theme/tmux.sh`, appelé par la barre de statut | au tick suivant, 3 s au pire |

Pourquoi un script plutôt qu'une variable d'environnement : une variable est
**figée à l'ouverture du shell**. Basculer le bureau en clair après coup, et
tous les shells déjà ouverts continuent de servir la saveur sombre — mesuré.
Le pager, lui, est relancé à chaque commande.

tmux n'a ni minuterie ni événement « le bureau a changé » : le rafraîchissement
de sa barre de statut est le seul rendez-vous périodique disponible, d'où le
`#()` dans `status-right`. Il n'affiche rien ; il re-source un fichier de thème
**uniquement quand la réponse a changé**, la dernière étant retenue dans
l'option `@theme` — qui vit dans le serveur tmux et meurt avec lui.

Le pager coûte un fork et une lecture de préférence par commande git **qui
pagine** ; git n'en lance un que si sa sortie est un terminal, donc les scripts
et la CI ne paient rien. Côté bat, les deux thèmes Catppuccin sont embarqués
depuis la version 0.26.0 ; en dessous, il faut les installer à la main.

Ce qui est **déjà affiché** ne se repeint pas, et c'est la ligne de partage
entre tes outils. `bat` et `delta` dessinent une page puis rendent la main :
basculer le bureau pendant qu'on les lit demande de quitter et de relancer la
commande. tmux, yazi, nvim et lazygit redessinent d'eux-mêmes, donc ils suivent
en direct — lazygit parce qu'il relance son rendu à chaque fichier
sélectionné. Ce n'est pas une limite de ce montage : un `cat` et un pager
choisissent leur thème au moment où ils écrivent, un point c'est tout.

delta sait détecter seul, mais **uniquement quand sa sortie n'est pas
redirigée** : dans lazygit il écrit dans un tuyau et n'interroge jamais rien.
Et une saveur Catppuccin pose `dark` ou `light`, ce qui coupe de toute façon
sa détection. Le choix de la saveur doit donc venir de l'extérieur.

## Quatre clients HTTP, quatre usages

| Outil | Interface | Les requêtes vivent | Hors ligne |
|---|---|---|---|
| `xh` | ligne de commande | nulle part, c'est une ligne | oui |
| `posting` | TUI | YAML, dans le dépôt du projet | oui |
| `bruno` | GUI | fichiers `.bru`, dans le dépôt du projet | oui |
| `postman` | GUI | dans un compte Postman | non |

`xh` ne recouvre rien : il n'a pas de collection. Les trois autres en ont une,
et ce qui les sépare est **où elle est rangée** — versionnée à côté du code,
ou dans un compte.

`postman` est là pour les collections qui arrivent dans ce format, pas par
préférence.

## Les aperçus de yazi

Cinq paquets n'ont pas d'autre client : ils alimentent les aperçus de yazi, et
chacun couvre un type de fichier.

| Paquet | Ce qu'il permet d'afficher |
|---|---|
| `sevenzip` | le contenu d'une archive |
| `poppler` | un PDF |
| `resvg` | un SVG |
| `ffmpeg` | la vignette d'une vidéo |
| `imagemagick` | polices, HEIC, JPEG XL |

Sans eux yazi fonctionne : il n'affiche simplement rien pour ces types. `jq`,
`fd`, `ripgrep`, `fzf` et `zoxide`, qu'il utilise aussi, sont déjà là pour leurs
propres raisons.

Les *flavors* ne sont pas fournis avec le binaire. `package.toml` enregistre
lesquels, l'étape `plugins` lance `ya pkg install`, et `flavors/` est gitignoré
— même mécanique que les plugins tmux.

## Ce qui sert un autre dépôt

Cinq entrées du Brewfile n'ont aucun client **ici**. Ce n'est pas un oubli :
elles servent des usages qui vivent ailleurs, et c'est ce dépôt-ci qui les
installe.

| Outil | Pourquoi |
|---|---|
| [cloudflared](https://github.com/cloudflare/cloudflared) | côté client d'un tunnel Cloudflare : sans ce binaire, la machine au bout est injoignable depuis ici |
| sops + age + age-plugin-yubikey + ykman | chiffrement de mes secrets, adossé aux YubiKeys ([security.md](security.md)) |

Les nommer ici est ce qui les empêche de devenir du folklore. Un paquet dont
personne ne sait plus pourquoi il est là finit par être retiré, ou pire, gardé
par superstition.

## Ce que mise épingle

| Outil | Épinglage |
|---|---|
| neovim | `0.12` |
| node | `lts` |
| python | `3.14` |
| rust | `1` |
| shellcheck | `0.11` |
| shfmt | `3.13` |
| yamllint | `1` |
| pipx · tree-sitter · usage | `latest` |

<details>
<summary>Pourquoi des majeures épinglées, et `latest` pour trois seulement</summary>

`latest` installe ce qui existe le jour même. Deux installations montées à un
mois d'écart divergeraient, et « reproductible » cesserait d'être vrai.

Les mises à jour mineures et correctives passent par `./run upgrade`, qui
reste dans l'épingle. Les majeures se montent dans le fichier, délibérément :
`mise upgrade --bump` le fait et réécrit la ligne, à relire avant de committer.

`latest` est réservé à la plomberie sans enjeu, les trois entrées dont rien ne
dépend au niveau version : pipx, tree-sitter et usage.

**shellcheck et shfmt sont épinglés par mise, pas pris depuis brew**, parce que
leur sortie définit la conformité. La machine et la CI doivent linter avec la
même version ; shfmt peut changer son formatage sur une montée mineure.

C'est aussi pour ça que **neovim n'est pas dans le Brewfile** : un seul
installeur par outil, aucune copie masquée, les mêmes versions ici et en CI.

</details>

## Conteneurs

podman et docker sont tous deux installés, et sur macOS ils tournent **dans une
VM** : il n'y a pas de noyau Linux ici.

Docker Desktop embarque la sienne. podman est sans démon, et le Brewfile n'en
pose que le CLI. Sa VM se crée **une fois par machine**, avec
`podman machine init`. Le cask `podman-desktop` la démarre ensuite à
l'ouverture de session.

## Éditeurs

nvim porte la vraie config, en submodule
([.config/nvim](https://github.com/racongiu/nvim)).

`.vimrc` reçoit cinq lignes pour qu'un fichier édité sans nvim garde la même
indentation : **tabulations, jamais d'espaces, quatre colonnes**.

`~/.vimrc` et pas le chemin XDG, à dessein : vim ne lit `~/.config/vim/vimrc`
que depuis la 9.1.0327, donc la route XDG serait ignorée en silence sur un vim
plus ancien.

## Prompt

`.config/starship.toml`, un seul fichier pour zsh et bash.

<details>
<summary>Les deux choix qui comptent</summary>

Le `format` est **fermé** : il ne liste que les runtimes réellement installés
(node, rust). Chaque module coûte une sonde à *chaque prompt*, même quand il
n'affiche rien. Chemin tronqué à 4, coupé à la racine du dépôt. Glyphes : Nerd
Font requise.

`[os.symbols]` **fusionne** avec les défauts de starship au lieu de les
remplacer. Un symbole retiré de la table retombe sur l'emoji intégré, il ne
disparaît pas. Deux seulement y sont déclarés : macOS, et Arch.

</details>

## Terminaux

Deux terminaux, une seule identité visuelle. tmux est documenté avec sa
config : [.config/tmux/README.md](../.config/tmux/README.md).

| | Ghostty (principal) | Kitty (le second) |
|---|---|---|
| Config | `.config/ghostty/config` | `.config/kitty/kitty.conf` |
| Police | JetBrainsMono Nerd Font Mono | identique |
| Thème | suit l'OS (Catppuccin) | suit l'OS via `*-theme.auto.conf` |
| Curseur bloc | `shell-integration-features = no-cursor` | `shell_integration no-cursor` |

> [!NOTE]
> La variante **Nerd Font** a son importance. starship, eza et la barre tmux
> affichent des glyphes de sa plage privée ; la simple « JetBrains Mono » les
> rend en tofu.

<details>
<summary>Pourquoi kitty est gardé, et les détails de chaque config</summary>

Kitty est maintenu à parité avec ghostty alors que rien ne l'exige
aujourd'hui. La raison est en avant : ghostty ne publie de binaires officiels
que pour macOS, de son propre aveu, et qualifie tout paquet Linux de build
communautaire. Le jour où ce dépôt connaîtra un second OS, kitty sera le
terminal déjà configuré.

**Ghostty** : `copy-on-select = clipboard`, `macos-option-as-alt = true`. Le
`no-cursor` est ce qui rend `cursor-style = block` vrai : l'intégration shell
pose une barre au prompt « regardless of this configuration », si bien que le
bloc survivrait partout sauf à l'endroit où on le regarde. L'OSC 52 est actif
par défaut, et c'est lui qui fait marcher la copie tmux à travers SSH sans
aucun binaire côté distant.

**Kitty** : miroir de ghostty, même police, mêmes tailles, `copy_on_select`,
même opacité. Les deux palettes Catppuccin vivent mot pour mot dans `themes/`
(MIT, amont dans l'en-tête) : couleurs statiques, aucun code exécuté, donc hors
du périmètre de la politique sur les plugins.

</details>

## Qualité du shell

shellcheck et shfmt sont imposés par `.editorconfig` et par la CI. Les scripts
du dépôt doivent passer les deux. **Le formateur est une autorité, pas une
suggestion.**

---

Voir aussi : [installer.md](installer.md) pour l'étape `packages`, et
[usage.md](usage.md) pour les raccourcis auxquels ces outils répondent.
