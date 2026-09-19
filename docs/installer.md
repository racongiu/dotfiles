# L'installeur

`./run` en POSIX sh : `install`, `update`, `upgrade`. Aucun framework, aucune
dépendance au-delà de git et de coreutils.

## L'essentiel

| Commande | Ce qu'elle fait |
|---|---|
| `./run install` | les dix étapes, dans l'ordre |
| `./run update` | `git pull`, puis rejoue les six étapes qui lisent le dépôt |
| `./run upgrade` | aucune étape : monte les versions des outils déjà posés |
| `./run install -n` | aperçu fidèle, n'écrit rien |
| `./run install <étape>` | une seule étape |

Quatre garanties, tenues par toutes les étapes :

| Garantie | Ce que ça veut dire |
|---|---|
| **Idempotent** | une seconde exécution ne fait rien |
| **Dry-run fidèle** | `-n` n'écrit rien, ni dans `$HOME` ni sur le système |
| **Échec bruyant** | une étape qui échoue n'arrête pas le run, mais le code de sortie est 1 |
| **Backups restaurables** | tout ce qui est remplacé part dans `~/.local/state/dotfiles/backups/<horodatage>/` |

<details>
<summary>Les quatre garanties en détail</summary>

**1. Idempotent.** Liens testés par inode, `mkdir -p`, marqueurs. Deux
`./run install` consécutifs sont le test.

**2. Dry-run fidèle.** `-n` imprime chaque commande qu'il exécuterait. Une
étape peut construire un fichier de travail dans le répertoire mktemp privé du
run pour calculer un diff, et c'est ce qui rend l'aperçu informatif.

**3. Échec bruyant, pas d'abandon.** Les commandes réseau et de gestionnaire de
paquets passent par `run_soft` : l'échec est journalisé et compté, le run
continue, `log_summary` renvoie 1. Un miroir mort ne tue jamais une
installation à mi-chemin.

La ligne finale d'une étape est **conditionnelle** (`log_done_clean`). Son ✓
veut dire « elle a réussi », pas « elle s'est exécutée ». Un avertissement ne
le supprime pas : un saut délibéré n'est pas un échec, une erreur si.

**4. Backups restaurables.** Le chemin relatif à `$HOME` est conservé. Si un
lien échoue après le backup, l'original est restauré.

</details>

## Les dix étapes

| # | Étape | Ce qu'elle fait | sudo | réseau |
|---|---|---|---|---|
| 1 | `prereqs` | Homebrew, et avec lui les Command Line Tools | oui | oui |
| 2 | `submodules` | init/sync des submodules, rattache chacun à sa branche | non | oui |
| 3 | `directories` | crée les répertoires XDG | non | non |
| 4 | `migrate` | déplace les anciens historiques vers XDG | non | non |
| 5 | `symlinks` | applique `manifest.sh`, avec backup | non | non |
| 6 | `packages` | `brew bundle`, puis claude code | non | oui |
| 7 | `gitsign` | génère `config.local`, complète `allowed_signers` | non | non |
| 8 | `runtimes` | ce que `mise` déclare | non | oui |
| 9 | `plugins` | clone TPM, puis les plugins de `tmux.conf` | non | oui |
| 10 | `shell` | `chsh` vers zsh, après confirmation | oui | non |

Une dépendance manquante donne un saut propre avec une ligne de journal, jamais
un plantage.

<details>
<summary>L'ordre, les dépendances, et trois notes</summary>

`STEPS` dans `run` fixe l'ordre, et cet ordre est la chaîne de dépendances,
rien de plus.

| Étape | Dépend de |
|---|---|
| `submodules` | git, et l'accès au remote du submodule |
| `symlinks` | `submodules`, pour que le submodule soit peuplé au moment du lien |
| `packages` | `prereqs` |
| `runtimes` | `packages`, pour avoir mise sur le PATH |
| `plugins` | `prereqs` pour git, `symlinks` pour `~/.config/tmux` |
| `shell` | `packages` : `chsh` a besoin que zsh soit installé |

Trois méritent une note :

- **migrate** est rejoué à chaque `install` mais ne fait rien la deuxième fois.
  `update` ne le rejoue pas du tout.
- **gitsign** n'écrase jamais un `config.local` écrit à la main.
- **prereqs** et **shell** sont les deux seules à demander sudo. La première
  parce que l'installeur Homebrew appelle `have_sudo_access` et abandonne sans
  lui, la seconde pour `/etc/shells`.

</details>

## Ce que chaque commande rejoue

| Étape | `install` | `update` | `upgrade` |
|---|---|---|---|
| prereqs, migrate, gitsign, shell | ✓ | | |
| submodules, directories, symlinks, packages, runtimes, plugins | ✓ | ✓ | |
| `git pull --ff-only` (avant toute étape) | | ✓ | |
| montées de version (brew, mise, claude code, zinit, TPM, submodules) | | | ✓ |

<details>
<summary>Pourquoi ce partage, et le cas particulier de gitsign</summary>

La ligne de partage n'est pas « ce qui est risqué », c'est **où vit la
vérité**. Les six étapes rejouées lisent le dépôt : `manifest.sh`, `Brewfile`,
`config.toml`, `.gitmodules`. Modifier l'un d'eux et pousser veut dire que
l'autre machine a besoin d'`update`.

`gitsign` se tient juste de l'autre côté. Ses entrées sont mixtes : les clés
dans `~/.ssh` viennent de la machine, les identités de `config` et
`config.gitlab` viennent du dépôt. Un pull apporte l'identité **et** les lignes
de signataire que l'autre machine a déjà écrites, donc il ne reste rien à
calculer.

L'angle mort est étroit : une clé de signature que cette machine n'a jamais
vue. `./run install gitsign` le referme à la demande.

</details>

> [!IMPORTANT]
> L'**étape** et les **outils qu'elle a installés** sont deux choses
> différentes. `upgrade` n'exécute aucune étape et maintient pourtant tout ce
> que `packages` a posé. Une clé de signature ajoutée plus tard, elle, demande
> bien `./run install gitsign`.

## Anatomie

```text
.
├── run                   # CLI : arguments, validation des noms d'étape, set -f
├── Brewfile              # liste brew/cask, lue par l'étape packages
└── setup/
    ├── manifest.sh       # source unique de vérité : liens, dossiers, migrations
    ├── lib/
    │   ├── log.sh        #   journaux colorés, compteurs (mktemp + traps)
    │   └── util.sh       #   run, run_soft, run_steps, backup/migration/liens
    ├── steps/
    │   └── <nom>.sh      #   une responsabilité chacun, dans l'ordre de $STEPS
    └── commands/
        ├── install.sh    #   une commande par fichier
        ├── update.sh
        └── upgrade.sh
```

## Ce que `./run install` télécharge

Six sources, et rien d'autre. Toute autre adresse est un défaut, pas une option.

| Source | Étape | Ce qu'elle apporte |
|---|---|---|
| installeur officiel **Homebrew** | `prereqs` | le gestionnaire de paquets + les Command Line Tools |
| **`brew bundle`** | `packages` | tout le `Brewfile` |
| installeur officiel **claude code** | `packages` | le CLI |
| **`mise install`** | `runtimes` | runtimes et linters de `config.toml` |
| **`git clone`** de **TPM** | `plugins` | tpm, puis les plugins de `tmux.conf` |
| **`git submodule`** | `submodules` | [racongiu/nvim](https://github.com/racongiu/nvim) |

`update` ajoute l'`origin` de ce dépôt. `upgrade` fait parler les outils déjà
posés : `brew update/upgrade`, `mise upgrade`, `claude update`,
`zinit self-update` puis `update --all`, TPM `update_plugins`, et
`git submodule update --remote`.

<details>
<summary>Téléchargé puis exécuté, et ce que ça ne prouve pas</summary>

« Source » se lit au sens de *qui décide où aller*. TPM compte pour une, et les
adresses qu'il tire sont celles que `tmux.conf` liste, pas les siennes.

Les deux qui exécutent un script, Homebrew et claude code, le **téléchargent
puis l'exécutent**, jamais `curl | sh` : un téléchargement tronqué ne doit pas
atteindre le shell.

Ce que ça ne prouve pas : l'authenticité. Rien ici ne vérifie une signature
amont. La confiance va à l'éditeur et au TLS, pas à une somme de contrôle.

zinit n'est pas dans ce tableau : il se clone lui-même au premier démarrage de
zsh, pas pendant `./run install`.

</details>

## Scripts manuels

Dans `scripts/`, sur le `PATH`, jamais lancés par `./run`.

| Script | Effet |
|---|---|
| `osx.sh` | ~15 `defaults` macOS, désactive le raccourci Spotlight, crée `~/Pictures/screenshots` et le lien `~/icloud` (lu par `env.sh` pour `$ICLOUD`), relance Dock, Finder et SystemUIServer. **À lire avant de le lancer** |
| `tool42.sh` | norminette + c_formatter_42 : pipx s'il est là, pip sinon. Le script annonce lequel il utilise et où il pose les binaires |
| `bootstrap-aidd.sh` | clone deux dépôts privés dans `~/.config/aiddconf` et déploie leurs liens |

## Ajouter une étape

1. Créer `setup/steps/<nom>.sh`.
2. Ajouter `<nom>` à `STEPS` dans `run`, à la bonne position.
3. Décider si `update` doit le rejouer, et si oui l'ajouter à la liste dans
   `setup/commands/update.sh`.
4. `./run install <nom> -n`, puis deux fois pour de vrai. La seconde exécution
   doit ne rien faire.

> [!CAUTION]
> **Ne jamais appeler `exit` dans une étape** : ça tue `run` et le résumé avec.
> `return 1` : `run_steps` l'attrape, `log_summary` possède le code de sortie.

<details>
<summary>Les deux régimes de `set -e`, et ce que la CI attrape</summary>

`run_steps` source les **étapes** sous `set -u` avec `-e` **désactivé**. Une
commande en échec n'arrête pas l'étape, et le statut de l'étape est celui de sa
dernière commande. Il faut donc vérifier ce qui peut échouer, à la main ou via
`run` / `run_soft`, et terminer sur une ligne qui dit ce qu'elle veut dire.

Les fichiers de `setup/commands/` sont l'**inverse** : `run` les source avec
`set -e` **actif**. Une commande qui échoue là tue `run` avant `log_summary` :
pas de résumé, pas de compte, juste un code de sortie. Toute commande faillible
y porte son `|| log_warn …` ou son `|| true`.

Pour le point 2, la CI vérifie les **deux sens** : un nom dans `STEPS` sans
fichier, et un fichier qu'aucune entrée de `STEPS` ne nomme. Le second est
celui qu'aucune exécution ne pourrait révéler.

Pour le point 3, la règle est « ne le rejoue que si son entrée vit dans le
dépôt ». Cette liste est écrite à la main volontairement, pour que rien ne
rejoigne `update` sans décision explicite. Une *faute de frappe* y est attrapée,
`run_steps` journalise une erreur. Un *oubli* ne l'est pas, et ne peut pas
l'être.

</details>

<details>
<summary>Les aides déjà sourcées</summary>

| Aide | Usage |
|---|---|
| `run <cmd…>` | l'exécute, ou l'imprime sous `--dry-run`. Le défaut pour tout ce qui écrit |
| `run_soft <cmd…>` | pareil, mais un échec est journalisé et compté au lieu d'arrêter le run |
| `run_steps <noms…>` | exécute des étapes par nom. Un nom inconnu est une erreur, pas un saut silencieux |
| `log_step/info/ok/warn/error` | le seul canal de sortie ; warn et error alimentent le résumé |
| `log_done <msg>` | ligne de succès, préfixée `[dry-run]` quand rien n'a eu lieu |
| `log_done_clean <ok> <ko>` | ligne **finale** : le ✓ seulement si l'étape n'a journalisé aucune erreur |
| `confirm "question ?"` | demande sur `/dev/tty` ; oui sous `-y` et `--dry-run` |
| `link_with_backup <src> <dst>` | lien comparé par inode, backup et restauration incluses |
| `backup_file` / `migrate_file` | déplace vers le backup du run / relocalise un ancien fichier |
| `require_cmd <bin>` | échouer bruyamment sur un outil manquant |
| `$_log_dir` | le `mktemp -d` privé du run, supprimé par trap. À lire ainsi : `"${_log_dir:?log.sh not sourced}"` |

</details>

---

Voir aussi : [architecture.md](architecture.md) pour ce que ces étapes mettent
en place, et [outils.md](outils.md) pour l'origine de chaque paquet.
