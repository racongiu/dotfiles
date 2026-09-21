# git

La mécanique des fichiers, la signature, les alias, et les valeurs par défaut.

## L'essentiel

| Question | Réponse |
|---|---|
| Quelle identité ici ? | `git config user.email` |
| Qu'est-ce qui décide ? | l'**URL du remote** d'abord, le chemin ensuite |
| Où est l'identité ? | `config`, versionné |
| Où est la clé ? | `config.local`, généré par machine, gitignoré |
| Les alias git ? | aucun : ce sont des alias de shell |

## Les six fichiers

| Fichier | Rôle |
|---|---|
| `config` | la config versionnée, portable. Identité par défaut (GitHub) + les deux conditions qui la basculent |
| `config.gitlab` | l'identité GitLab, versionnée, tirée par ces conditions |
| `config.local` | la part **machine** : `allowedSignersFile`, et la clé quand elle existe. Généré par `./run install gitsign`, gitignoré |
| `catppuccin.gitconfig` | les couleurs de delta, latte et mocha. Recopié de l'amont, **à ne pas réécrire à la main** |
| `allowed_signers` | les signataires acceptés. **Maintenu par `gitsign`**, en ajout seul |
| `ignore` | exclusions globales : déchets d'OS et d'éditeur, rien d'autre |

### delta

`config` pose ce qui ne dépend pas du thème (deux colonnes, numéros de ligne,
`navigate`) et `catppuccin.gitconfig` pose les couleurs. La saveur, elle, est
choisie **à chaque appel** par `scripts/theme/delta.sh`, qui est le pager — la
ligne `features` de `config` n'est plus qu'un repli pour un `delta` lancé à la
main. Voir [outils.md](../../docs/outils.md).

Trois pièges vérifiés : une variable d'environnement ne convient pas ici, elle
est figée à l'ouverture du shell ; `DELTA_FEATURES=+catppuccin-latte` (avec le
`+`, qui **ajoute**) applique les deux saveurs à la fois et delta refuse de
démarrer ; et `side-by-side` est un drapeau sans négation en ligne de commande,
donc lazygit hérite des deux colonnes sans pouvoir les refuser.

<details>
<summary>Pourquoi cette séparation</summary>

La séparation `config` / `config.local` garde le dépôt portable. La clé et le
chemin d'`ssh-keygen` diffèrent d'une machine à l'autre, ils n'ont rien à faire
dans un fichier versionné.

`user.name` et `user.email` sont dans `config`, versionnés à dessein : une
personne, plusieurs machines, une seule modification.

Les motifs propres à un projet ont leur place dans le `.gitignore` de chaque
dépôt, pas dans `ignore`.

</details>

## Deux forges, une machine

L'identité est par forge. `config` porte GitHub par défaut, `config.gitlab`
prend le relais sous deux conditions :

| Condition | Correspond sur | Couvre |
|---|---|---|
| `gitdir:~/lab/gitlab/` | le **chemin** | un `git init` là-dedans, avant qu'un remote existe |
| `hasconfig:remote.*.url:git@gitlab.com:**/**` | l'**URL du remote** | un dépôt GitLab cloné n'importe où |

La seconde est l'importante. **`~/lab/gitlab` est une habitude de rangement,
pas une obligation** : dès qu'`origin` pointe sur `gitlab.com`, l'identité
GitLab s'applique, où que soit le dépôt. `ghc` et `glc` économisent de la
frappe, rien de plus.

```sh
git config user.email
```

> [!WARNING]
> **Deux pièges, tous deux mesurés.**
>
> Un dépôt **hors** de `~/lab/gitlab` **sans remote encore** : `git init`,
> commit, et ces commits portent l'adresse GitHub. Ajouter le remote avant le
> premier commit, ou réparer avec `git commit --amend --reset-author`.
>
> L'inverse : un dépôt **GitHub** placé **dans** `~/lab/gitlab` reçoit
> l'identité GitLab. `gitdir` a correspondu, et la condition d'URL ne fait
> jamais qu'*ajouter* GitLab, elle ne le reprend jamais.

<details>
<summary>Deux contraintes techniques à connaître</summary>

Le défaut doit rester une vraie adresse : un dépôt qui ne correspond à aucune
des deux conditions a quand même besoin d'un email, sinon git refuse de
committer.

`hasconfig` demande git ≥ 2.36. Et git n'étend aucune variable dans une
condition, donc `~/lab/gitlab` est écrit en toutes lettres. Si `$REPOS`
déménage un jour, cette ligne déménage avec lui.

</details>

> [!IMPORTANT]
> Changer `user.email` ne casse **pas** la vérification locale : elle met en
> correspondance la **clé**. Ça casse le côté **forge**, et seulement lui
> ([docs/security.md](../../docs/security.md)).

## Signature

Les commits sont signés en ssh (`gpg.format = ssh`) avec une clé FIDO2
`sk-ssh-ed25519`.

Une seule chose appartient à cette page : l'`ssh-keygen` capable de signer avec
une telle clé est une donnée de machine, et c'est pour ça que
`gpg.ssh.program` est dans `config.local`.

Tout le reste — créer les clés, les récupérer, les enregistrer sur les forges,
vérifier, faire tourner la clé — est dans
[docs/security.md](../../docs/security.md).

## Alias

**Aucun ici, à dessein.** Ce sont des alias de **shell** (`gst`, pas `git st`)
et ils vivent dans `shell/aliases.sh`, voir
[docs/usage.md](../../docs/usage.md).

Coût assumé : ils n'existent que dans les shells interactifs. Les scripts et
les outils appellent git tel quel.

## Valeurs par défaut notables

| Réglage | Pourquoi |
|---|---|
| `diff.algorithm = histogram` | de meilleurs hunks que myers quand des blocs se déplacent |
| `merge.conflictStyle = zdiff3` | le conflit montre aussi la base commune |
| `rerere` (+ autoupdate) | un conflit résolu une fois est rejoué sur les rebases suivants |
| `pull.rebase` + `rebase.autoStash/autoSquash/updateRefs` | historique linéaire ; `updateRefs` fait avancer les branches empilées |
| `push.autoSetupRemote` | premier push sans `-u` |
| `push.followTags` + `fetch.prune`/`pruneTags` | tags et refs synchronisés dans les deux sens |
| `transfer.fsckObjects` | intégrité des objets vérifiée à chaque transfert |
| `commit.verbose` | le diff sous le message de commit, dans l'éditeur |
| `help.autocorrect = prompt` | suggère la correction, ne la lance jamais |
| `branch.sort` / `tag.sort` | branches récentes en premier, tags triés par version |
| `merge/diff.tool = editor` | suit `$EDITOR` ; `trustExitCode = false`, un code de sortie d'éditeur ne dit rien d'un merge |
