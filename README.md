# G.B.G — Glayna Better Guild

**Version 1.8.26** · **World of Warcraft 3.3.5a** · **Project Ascension: Conquest of Azeroth** · Interface `30300`

**G.B.G — Glayna Better Guild** remplace la fenêtre de guilde Blizzard par un véritable espace communautaire moderne, synchronisé et pensé pour Project Ascension.

L’objectif est de réunir au même endroit la discussion de guilde, les profils des membres, l’organisation d’activités, le recrutement, les candidatures, les invitations et la personnalisation visuelle de la guilde.

## Fonctionnalités

### Interface de guilde moderne

- Remplace l’interface de guilde Blizzard par une fenêtre complète G.B.G.
- Navigation dédiée pour la discussion, les membres, les activités, le recrutement, les invitations et les paramètres.
- Interface déplaçable, redimensionnable et mise à l’échelle progressivement.
- Taille et position sauvegardées entre les sessions.
- Mode semi-transparent configurable pendant les combats et/ou les déplacements.
- Niveau de transparence configurable.
- Lanceur G.B.G déplaçable.
- Bouton de minicarte avec clic gauche pour ouvrir/fermer G.B.G et clic droit pour accéder aux paramètres.
- Interface disponible en **français** et en **anglais**.

### Discussion de guilde synchronisée

- Historique partagé de la discussion entre utilisateurs de G.B.G.
- Conservation et récupération progressive de l’historique disponible.
- Messages non lus avec compteur visible sur l’interface et le lanceur.
- Détection des mentions du personnage.
- Mise en évidence persistante lorsqu’une mention n’a pas encore été lue.
- Liens WoW pris en charge dans la discussion.
- Détection des liens présents dans les messages et possibilité de les copier.
- Protection anti-doublon et limitation des échanges inutiles entre clients.

### Anti-spam local

- Protection anti-spam de la discussion de guilde activable dans les paramètres.
- Détection des messages répétés ou envoyés anormalement rapidement.
- Les messages bloqués restent **locaux** et ne sont pas retransmis aux autres joueurs.
- Notification du nombre de messages bloqués.
- Fenêtre permettant de consulter les messages filtrés.

### Membres et profils

- Liste des membres de la guilde avec informations utiles et état de connexion.
- Profils G.B.G synchronisés entre les utilisateurs de l’addon.
- Portraits personnalisés avec une bibliothèque intégrée de visuels.
- Association **Main / rerolls** pour identifier facilement les personnages d’un même joueur.
- Notes privées locales.
- Gestion locale des joueurs ignorés.
- Sélection de membres à surveiller pour les alertes de connexion.
- Notifications de connexion et de déconnexion configurables.
- Protection des portraits natifs de Blizzard : G.B.G ne remplace pas les portraits joueur, cible, familier ou groupe.

### Notifications

- Notifications G.B.G configurables et déplaçables.
- Taille, durée et opacité configurables.
- Plusieurs comportements visuels pour les alertes.
- Aperçu des notifications directement depuis les paramètres.
- Alertes de connexion configurables globalement ou pour certains membres seulement.

### Créateur de bannière / tabard

- Créateur visuel intégré pour la bannière de guilde.
- Plusieurs calques personnalisables.
- Choix des couleurs.
- Réglage indépendant de la taille des éléments.
- Position X / Y.
- Rotation des éléments.
- Gestion de la bordure, du fond, de l’emblème et du texte.
- Choix de police et lettrages.
- Brouillon conservé localement pendant l’édition.
- Publication de la bannière officielle de la guilde par le maître de guilde.
- Bannière officielle réutilisée dans le système de recrutement G.B.G.

### Guild Group Finder — activités JcE / JcJ

G.B.G intègre son propre système de recherche d’activités de guilde.

- Création d’activités **JcE** ou **JcJ**.
- Types d’activités adaptés à Ascension.
- Gestion des niveaux recommandés.
- Composition personnalisable du groupe.
- Rôles **Tank**, **Heal**, **DPS** et **Support**.
- Nombre de places visible par rôle.
- Blocage automatique d’un rôle lorsqu’il est complet.
- Inscription des membres directement depuis G.B.G.
- Suivi des membres inscrits, acceptés, invités ou déjà présents dans le groupe.
- Gestion par le chef du groupe ou du raid.
- Invitations depuis l’interface de l’activité.
- Nettoyage des activités terminées ou expirées.
- Synchronisation conçue pour éviter les anciens groupes fantômes après une reconnexion.

### Recherche et recrutement de guilde

G.B.G permet aussi de rechercher et rejoindre des guildes utilisant l’addon.

- Recherche de guildes directement depuis G.B.G.
- Annonces de recrutement partagées entre utilisateurs de l’addon.
- Filtres **JcE**, **JcJ**, **JcE & JcJ** ou tous.
- Présentation de la guilde.
- Objectif principal.
- Plage de niveaux recommandée.
- Nombre de membres et joueurs connectés lorsque disponible.
- Affichage de la bannière officielle G.B.G de la guilde.
- Candidature directement depuis l’interface avec message de présentation.
- État persistant de la candidature : en attente, acceptée, refusée ou terminée.
- Possibilité de mettre à jour ou renvoyer une candidature.
- Conservation de l’état même lorsqu’une annonce de guilde est temporairement hors ligne.

### Gestion des candidatures

Pour les guildes qui recrutent :

- Liste des candidatures reçues.
- Profil, portrait, classe, niveau et message du candidat.
- Détection de sa présence via G.B.G lorsqu’elle est disponible.
- Acceptation et invitation depuis l’interface.
- Refus avec **raison personnalisée** visible par le candidat.
- Nouvelle tentative d’invitation si le joueur n’a pas encore rejoint la guilde.
- Les candidatures acceptées restent suivies jusqu’à l’entrée réelle du joueur dans la guilde.
- Mode **manuel** : les candidatures sont examinées par les membres autorisés.
- Mode **automatique** : les nouvelles candidatures peuvent être acceptées et invitées automatiquement.
- Permissions de publication et de gestion contrôlées selon l’autorité de guilde.

### Invitations de guilde adaptées à Ascension

- Page dédiée aux invitations.
- Invitation par nom de personnage.
- Invitation du joueur actuellement ciblé.
- Vérification des permissions avant l’invitation.
- Vérification des cas invalides : soi-même, joueur déjà guildé, cible invalide, etc.
- **Maj + clic** sur un joueur pris en charge pour préremplir l’invitation.
- Action **Guilder / Invite to Guild** intégrée au menu contextuel des noms dans le tchat standard.
- Fonctionnement prévu pour l’environnement inter-faction de Project Ascension.

### Synchronisation et performances

G.B.G est conçu pour fonctionner dans une guilde entière sans envoyer brutalement toutes les données à la connexion.

- Synchronisation progressive des profils, portraits, messages, activités et informations de recrutement.
- Files d’attente internes et budgets de traitement pour limiter les pics de charge.
- Regroupement de certaines données afin de réduire le nombre de paquets.
- Anti-doublon pour les données déjà reçues.
- Étalement de la synchronisation après connexion ou changement de guilde.
- Relais distribué pour les informations de recrutement inter-guildes.
- Compatibilité conservée avec les échanges des versions G.B.G plus anciennes lorsque nécessaire.

## Installation

Placez le dossier `GBG` dans :

```text
World of Warcraft\Interface\AddOns\
```

Puis activez **G.B.G — Glayna Better Guild** dans la liste des addons avant de lancer votre personnage.

La version publique peut également être récupérée depuis : **addon.devquestlog.com**.

## Commandes

```text
/gbg              Ouvre ou ferme l’interface G.B.G.
/gbg reset        Réinitialise les positions de la fenêtre et du lanceur.
```

## Compatibilité

- World of Warcraft **3.3.5a**
- Interface **30300**
- Project Ascension
- Conquest of Azeroth

G.B.G est développé spécifiquement autour des besoins et particularités de l’environnement Ascension ; il ne s’agit pas d’un simple port d’un addon Retail.

## Auteur

**Glayna**

## Licence

G.B.G est distribué sous licence **MIT**.

Vous pouvez utiliser, modifier, redistribuer et publier le code conformément aux conditions de la licence disponible dans le fichier [`LICENSE`](LICENSE).
