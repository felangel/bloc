# Tutoriel Flutter chronomètre

![débutant](https://img.shields.io/badge/level-beginner-green.svg)

> Dans ce tutoriel, nous allons expliquer comment construire une application de minuterie à l'aide de la bibliothèque bloc. L’application terminée devrait ressembler à ceci:

![demo](../assets/gifs/flutter_timer.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

Nous pouvons alors remplacer le contenu de pubspec.yaml par:

[pubspec.yaml](../_snippets/flutter_timer_tutorial/pubspec.yaml.md ':include')

?> **Note:** Nous utiliserons les paquets [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable), et [wave](https://pub.dev/packages/wave) dans cette application.

Ensuite, lancez `flutter packages get` pour installer toutes les dépendances.

## Ticker

> Le ticker (ou minuteur) sera notre source de données pour l'application de minuterie. Il exposera un flot de tick répititif auxquel nous pouvons nous abonner et auxquel nous pouvons réagir.

Commencez par créer `ticker.dart`.

[ticker.dart](../_snippets/flutter_timer_tutorial/ticker.dart.md ':include')

Tout ce que fait notre classe `Ticker` est d'exposer une fonction de tick qui prend le nombre de ticks (secondes) que nous voulons et renvoie un flux qui émet les secondes restantes chaque seconde.

Ensuite, nous devons créer notre `TimerBloc` qui consommera le `Ticker`.

## Timer Bloc

### TimerState

Nous allons commencer par définir les `TimerStates` dans lesquels notre `TimerBloc` peut se trouver.

Nos états du `TimerBloc` peuvent être l'un des suivants :

- TimerInitial — prêt à commencer le décompte à partir de la durée spécifiée.
- TimerRunInProgress — compte à rebours actif à partir de la durée spécifiée.
- TimerRunPause — s'est arrêté à une certaine durée restante.
- TimerRunComplete — complétée avec une durée restante de 0.

Chacun de ces états aura une implication sur ce que l'utilisateur voit. Par exemple :

- si l'État est `TimerInitial` l'utilisateur pourra démarrer la minuterie.
- si l'État est `TimerRunInProgress` l'utilisateur pourra faire une pause et réinitialiser la minuterie ainsi que voir la durée restante.
- si l'État est `TimerRunPause` l'utilisateur pourra reprendre la minuterie et la réinitialiser.
- si l'État est `TimerRunComplete` l'utilisateur pourra réinitialiser la minuterie.

Afin de garder tous nos fichiers bloc ensemble, créons un répertoire bloc avec `bloc/timer_state.dart`.

?> **Tip:** Vous pouvez utiliser les extensions[IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) pour autogénérer les fichiers bloc suivants

[timer_state.dart](../_snippets/flutter_timer_tutorial/timer_state.dart.md ':include')

Notez que tous les `TimerStates` étendent la classe abstraite de base `TimerState` qui a une propriété duration. C'est parce que quel que soit l'état dans lequel se trouve notre `TimerBloc`, nous voulons savoir combien de temps il nous reste.

Ensuite, définissons et implémentons les `TimerEvents` que notre `TimerBloc` va traiter.

### TimerEvent

Notre `TimerBloc` aura besoin de savoir comment traiter les événements suivants :

- TimerStarted — informe le TimerBloc que la minuterie doit être démarrée.
- TimerPaused — informe le TimerBloc que la minuterie doit être mise en pause.
- TimerResumed — informe le TimerBloc que la minuterie doit être reprise.
- TimerReset — informe le TimerBloc que la minuterie doit être remise à l'état d'origine.
- TimerTicked — informe le TimerBloc qu'une coche s'est produite et qu'il doit mettre à jour son état en conséquence.

Si vous n'avez pas utilisé les extensions [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), alors créez `bloc/timer_event.dart` et implémentons ces événements.

[timer_event.dart](../_snippets/flutter_timer_tutorial/timer_event.dart.md ':include')

Ensuite, implémentons le `TimerBloc` !

### TimerBloc

Si ce n'est pas déjà fait, créez `bloc/timer_bloc.dart` et créez un `TimerBloc` vide.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

La première chose que nous devons faire est de définir l'"EtatInitial" de notre `TimerBloc`. Dans ce cas, nous voulons que le TimerBloc démarre à l'état " Prêt " avec une durée prédéfinie de 1 minute (60 secondes).

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

Ensuite, nous devons définir la dépendance par rapport à notre `Ticker`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

Nous sommes également en train de définir un `StreamSubscription` pour notre `Ticker` que nous allons voir dans un instant.

A ce stade, il ne reste plus qu'à implémenter `mapEventToState`. Pour une meilleure lisibilité, j'aime diviser chaque gestionnaire d'événement en sa propre fonction d'aide. Nous allons commencer par l'événement `TimerStarted`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

Si le `TimerBloc` reçoit un événement `TimerStarted`, il pousse un état `TimerRunInProgress` avec la durée de départ. De plus, s'il y avait déjà un `_tickerSubscription` ouvert, nous devons l'annuler pour délocaliser la mémoire. Nous devons également remplacer la méthode `close` sur notre `TimerBloc` de sorte que nous puissions annuler le `_tickerSubscription` lorsque le `TimerBloc` est fermé. Enfin, nous écoutons le flux `_ticker.tick` et à chaque tick nous ajoutons un événement `TimerTicked` avec la durée restante.

Ensuite, implémentons le gestionnaire d'événements `TimerTicked`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Chaque fois qu'un événement `TimerTicked` est reçu, si la durée de la tick est supérieure à 0, nous devons pousser un état `TimerRunInProgress` mis à jour avec la nouvelle durée. Sinon, si la durée du tick est 0, notre temporisateur est terminé et nous devons pousser un état `TimerRunComplete`.

Maintenant, implémentons le gestionnaire d'événements `TimerPaused`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

Dans `_mapTimerPausedToState` si l'état de notre `TimerBloc` est `TimerRunInProgress`, alors nous pouvons mettre en pause le `_tickerSubscription` et pousser un état `TimerRunPause` avec la durée du timer actuel.

Ensuite, implémentons le gestionnaire d'événements `TimerResumed` pour que nous puissions désamorcer le timer.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

Le gestionnaire d'événements `TimerResumed` est très similaire au gestionnaire d'événements `TimerPaused`. Si le `TimerBlocTemporisateur` a un état de `TimerRunPause` et qu'il reçoit un événement `TimerResumed`, alors il reprend l'état `_tickerSubscription` et pousse un état `TimerRunInProgress` avec la durée courante.

Enfin, nous devons implémenter le gestionnaire d'événements `TimerReset`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc.dart.md ':include')

Si le `TimerBloc` reçoit un événement `TimerReset`, il doit annuler l'abonnement `_tickerSubscription` en cours afin de ne pas être notifié du tick supplémentaire et pousser un état `TimerInitial` avec la durée originale.

Si vous n'avez pas utilisé les extensions [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc), assurez-vous de créer `bloc/bloc.dart` afin d'exporter tous les fichiers bloc et de permettre d'utiliser une seule importation par commodité.

[bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_barrel.dart.md ':include')

C'est tout ce qu'il y a dans le `TimerBloc`. Il ne reste plus qu'à implémenter l'interface utilisateur pour notre application Timer.

## Interface de l'application

### MyApp

Nous pouvons commencer par supprimer le contenu de `main.dart` et créer notre widget `MyApp` qui sera la racine de notre application.

[main.dart](../_snippets/flutter_timer_tutorial/main1.dart.md ':include')

MyApp est un `StatelessWidget` qui gère l'initialisation et la fermeture d'une instance de `TimerBloc`. De plus, il utilise le widget `BlocProvider` afin de rendre notre instance `TimerBloc` disponible pour les widgets de notre sous-arbre.

Ensuite, nous devons implémenter notre widget `Timer`.

### Timer

Notre widget `Timer` sera responsable de l'affichage du temps restant ainsi que des boutons appropriés qui permettront aux utilisateurs de démarrer, de mettre en pause et de réinitialiser la minuterie.

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

Jusqu'à présent, nous utilisons simplement `BlocProvider` pour accéder à l'instance de notre `TimerBloc` et utilisons un widget `BlocBuilder` afin de reconstruire l'interface chaque fois que nous obtenons un nouvel `TimerState`.

Ensuite, nous allons implémenter notre widget `Actions` qui aura les actions appropriées (démarrage, pause et reset).

### Actions

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

Le widget `Actions` n'est qu'un autre `StatelessWidget` qui utilise `BlocProvider` pour accéder à l'instance `TimerBloc` et retourne ensuite différents `FloatingActionButton` basés sur l'état actuel du `TimerBloc`. Chacun des boutons `FloatingActionButton` ajoute un événement dans son rappel `onPressed` pour notifier le `TimerBloc`.

Maintenant nous devons connecter les `Actions` à notre widget `Timer`.

[timer.dart](../_snippets/flutter_timer_tutorial/timer2.dart.md ':include')

Nous avons ajouté un autre `BlocBuilder` qui se charge du rendu du widget `Actions` ; cependant, cette fois-ci, nous utilisons une fonctionnalité nouvellement introduite [flutter_bloc](https://pub.dev/packages/flutter_bloc) pour contrôler à quelle fréquence le widget `Actions` est reconstruit (introduit dans `v0.15.0`).

Si vous voulez un contrôle fin sur le moment où la fonction `builder` est appelée, vous pouvez fournir une `condition` optionnelle à `BlocBuilder`. La `condition` prend l'état de bloc précédent et l'état de bloc courant et retourne un `boolean`. Si `condition` renvoie `true`, `builder` sera appelé avec `state` et le widget sera reconstruit. Si `condition` retourne `false`, `builder` ne sera pas appelé avec `state` et aucune reconstruction ne sera effectuée.

Dans ce cas, nous ne voulons pas que le widget `Actions` soit reconstruit à chaque tick parce que ce serait inefficace. Au lieu de cela, nous voulons seulement que `Actions` soit reconstruit si le `runtimeType` du `TimerState` change (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, etc...).

Par conséquent, si nous colorions au hasard les widgets sur chaque reconstruction, cela ressemblerait à :

![Démonstration de l'état du BlocBuilder](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Note:** Même si le widget `Text` est reconstruit à chaque tick, nous ne reconstruisons les `Actions` que si elles doivent être reconstruites.

Enfin, nous devons ajouter le fond d'onde super cool en utilisant le paquet [wave](https://pub.dev/packages/wave).

### Waves Background

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Réunir le tout

Notre fichier fini, `main.dart` devrait ressembler à :

[main.dart](../_snippets/flutter_timer_tutorial/main2.dart.md ':include')

C'est tout ce qu'il y a à faire ! A ce stade, nous avons une application de minuterie assez solide qui ne reconstruit efficacement que les widgets qui ont besoin d'être reconstruits.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).
