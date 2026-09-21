# tmux

Raccourcis, thème, presse-papiers, plugins.

Préfixe : **`Ctrl-Space`** (`C-b` délié). Touches vi partout.

## Raccourcis

### Sessions, fenêtres, panneaux

**`prefix ?`** liste tout, y compris les touches ci-dessous : chaque `bind` du
fichier porte une note `-N`, et `prefix ?` n'affiche que les bindings qui en
ont une. Ce tableau est donc un doublon assumé, pour lire depuis GitHub.

| Touche | Action |
|---|---|
| `prefix r` | recharge tmux.conf |
| `prefix b` | découpe côte à côte, même répertoire |
| `prefix v` | découpe haut/bas, même répertoire |
| `prefix c` | nouvelle fenêtre, même répertoire |
| `Ctrl-h/j/k/l` | navigue entre les panneaux **et** les splits nvim |
| `prefix h/j/k/l` | redimensionne le panneau de 5 (répétable) |
| `prefix z` | zoom du panneau (bascule, défaut tmux) |
| `prefix m` | marque le panneau, pour `join-pane` et `swap-pane` |
| `prefix Tab` | revient à la fenêtre précédente |
| `prefix ;` | revient au panneau précédent (défaut tmux) |
| `prefix n` / `p` | fenêtre suivante / précédente (répétable) |
| `prefix !` | sort le panneau dans sa propre fenêtre (défaut tmux) |
| `prefix @` | ramène une fenêtre comme panneau |
| `prefix Shift-←/→` | déplace la fenêtre à gauche / à droite (répétable) |

### Mode copie (touches vi)

| Touche | Action |
|---|---|
| `v` | commence la sélection |
| `V` | sélection de ligne |
| `Ctrl-v` | sélection rectangulaire |
| `y` / `Enter` | copie et sort |
| `Esc` | efface la sélection |
| `prefix P` | colle le buffer tmux |

Le glissé de souris ne copie **pas** automatiquement. C'est délibéré : la
sélection survit au relâchement du bouton.

### Sessions enregistrées

| Touche | Action |
|---|---|
| `prefix Ctrl-s` | enregistre maintenant |
| `prefix Ctrl-r` | restaure |

L'enregistrement est automatique toutes les 15 minutes, et la restauration se
fait au démarrage du serveur. Le contenu des panneaux revient aussi, sessions
nvim comprises.

## Thème

Barre de statut écrite à la main sur la palette
[Catppuccin](https://github.com/catppuccin/catppuccin), pas le plugin officiel.
Deux fichiers dans `themes/`, zéro dépendance.

Le choix **suit l'apparence de l'OS en continu**.
`scripts/theme/tmux.sh` est appelé par la barre de statut, donc toutes les
`status-interval` secondes, et ne re-source un fichier de thème que si la
réponse a changé. `TERM_THEME=light|dark` la force.

<details>
<summary>Où est le crochet, et le fallback</summary>

tmux n'a ni minuterie ni événement « l'apparence a changé » : le
rafraîchissement de la barre est le seul rendez-vous périodique disponible,
d'où le `#()` dans `status-right` — qui n'imprime rien. Il vit là et non dans
un fichier de thème, sinon il serait effacé à chaque re-source. La dernière
réponse est retenue dans l'option `@theme`, qui meurt avec le serveur tmux.

La sonde et son ordre : [outils.md](../../docs/outils.md). Quand tout se tait
— ssh, tty, machine sans bureau — le fallback est **mocha** : une barre pâle
serait illisible, alors que l'inverse se lit encore.

</details>

## Presse-papiers

Chaque assistant de copie est **sondé** avant usage : pbcopy (macOS), wl-copy
(Wayland), xclip (X11).

Si aucun n'existe, la sélection tmux sert de fallback, et `set-clipboard on`
émet quand même de l'OSC 52. Le terminal reçoit donc la copie, SSH compris,
sans aucun binaire côté distant.

## Plugins

Via TPM, clonés dans `plugins/`, gitignoré. `prefix I` installe, `prefix U` met
à jour.

| Plugin | Rôle |
|---|---|
| [tpm](https://github.com/tmux-plugins/tpm) | gestionnaire de plugins |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | `Ctrl-h/j/k/l` à travers tmux *et* nvim |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | enregistre/restaure les sessions |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | enregistrement auto, restauration au démarrage |
| [tmux-cpu-mem-monitor](https://github.com/hendrikmi/tmux-cpu-mem-monitor) | cpu / mém / disque dans la barre (a besoin de python3) |

Non épinglés, même politique que zinit :
[docs/architecture.md](../../docs/architecture.md).

<details>
<summary>Deux notes sur ces plugins</summary>

**cpu-mem-monitor** est tenu par une seule personne, accepté en connaissance de
cause : il ne publie aucun tag à épingler, et l'exposition reste bornée à
`prefix I` / `prefix U`. Sans lui, ou sans python3, la barre est simplement
plus courte. Rien d'autre n'en dépend.

**resurrect** écrit dans `~/.local/share/tmux/resurrect/`, posé explicitement.
Le plugin va déjà par défaut vers XDG, sauf quand `~/.tmux/resurrect` survit
d'une installation plus ancienne, auquel cas il y retourne.

</details>

<details>
<summary>Les réglages de fond de tmux.conf</summary>

| Réglage | Pourquoi |
|---|---|
| fenêtres et panneaux à partir de 1 | renumérotés à la fermeture |
| 100k lignes d'historique par panneau | le scrollback, c'est de la RAM |
| `escape-time 10` | défaut amont depuis la 3.5, remède aux raccourcis `M-` capricieux à 0 |
| `focus-events` | autoread de nvim |
| `allow-passthrough` | séquences OSC à travers tmux |
| `detach-on-destroy off` | détruire la dernière session bascule vers une autre |

</details>
