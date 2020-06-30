# Flutter Todos Tutorial

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> Dans ce tutoriel, nous allons construire une application Todos (Liste de choses à faire) en utilisant la librairie Bloc !
?> **Note:** Pour des raisons de sens, je ne vais toujours tout traduire donc voici une liste des mots anglais et leur équivalent français que vous allez retrouver tout au long du tutorial : state -> état / Todos -> Choses à faires / Overriding -> Réécrire du code par dessus un code déjà existant et similaire / Input -> valeur d'entrée / Output -> valeur de sortie

![demo](../assets/gifs/flutter_todos.gif)

## Configuration

Commençons par créer un tout nouveau projet Flutter

[script](../_snippets/flutter_todos_tutorial/flutter_create.sh.md ':include')

Ensuite, remplaçons le contenu de `pubspec.yaml` avec

[pubspec.yaml](../_snippets/flutter_todos_tutorial/pubspec.yaml.md ':include')

et ensuite nous allons installer toutes les dépendances

[script](../_snippets/flutter_todos_tutorial/flutter_packages_get.sh.md ':include')

?> **Note:** Nous allons overriding quelques dépendances car nous allons les réutiliser depuis [Brian Egan's Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples).

## App Keys (Clefs d'application)

Avant de sauter dans le code de l'application, créons `flutter_todos_keys.dart`. Ce fichier contiendra des clefs (keys) qui seront utilisés pour identifier uniquement les widgets importants. Plus tard, nous pourrons écrire des tests qui trouvent les widgets en se basant sur les keys.

[flutter_todos_keys.dart](../_snippets/flutter_todos_tutorial/flutter_todos_keys.dart.md ':include')

Nous allons référencer ces clefs tout au long du reste du tutoriel.

?> **Note:** Vous pouvvez vérifier les tests d'intégrations de votre appli [ici](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). Et également checker les tests unitaires et de widgets [ici](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Localisation

Le dernier concept que nous allons apporter avant de rentrer dans le vif de l'application est la localisation. Créons `localization.dart` et nous allons créer la fondation pour un support multi-langage.

[localization.dart](../_snippets/flutter_todos_tutorial/localization.dart.md ':include')

Nous pouvons maintenant importer et fournir notre `FlutterBlocLocalizationsDelegate` à notre `MaterialApp` (plus tard dans ce tutoriel).
Pour plus d'informations sur la localisation, visitez [la doc officiel Flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos Repository (Répertoire Todos)

Dans ce tutoriel, nous n'allons pas aller dans les détails de l'implémentation du `TodosRepository` car il a été implémenté par [Brian Egan](https://github.com/brianegan) et il partagé parmi la [Todo Architecture Samples](https://github.com/brianegan/flutter_architecture_samples). A un plus haut niveau, le `TodosRepository` va exposer une méthode pour `loadTodos` et pour `saveTodos`. C'est à peu prèt tout ce que nous avons de savoir pour le reste du tutorial et nous allons pouvoir se focus sur le Bloc et la Presentation de notre application.

## Le Bloc Todos

> Notre `TodosBloc` va être responsable de convertir les `TodosEvents` en `TodosStates` et va gérer la liste des todos.

### Modèle

La première chose que nous avons besoin de définir est notre modèle `Todo`. Chaque todo aura besoin d'un id, d'une tâche (task), optionnellement d'une note et d'un drapeau complété optionnel lui aussi.
Créons un dossier `models` et créons `todo.dart`.

[todo.dart](../_snippets/flutter_todos_tutorial/todo.dart.md ':include')

?> **Note:** Nous utilisons le package [Equatable](https://pub.dev/packages/equatable) pour que l'on puisse comparer les instances de `Todos` sans avoir a manuellement override `==` et `hashCode`.

Ensuite, nousa avons besoin de créer le `TodosState` qui sera interprété par notre couche de présentation.

### States (états)

Créons `blocs/todos/todos_state.dart` et définissons les différents states que nous allons devoir gérer.

Les trois states que nous allons implémenter sont:

- `TodosLoadInProgress` - le state pendant que notre application va chercher (fetching) les todos depuis notre répertoire (repository). 
- `TodosLoadSuccess` - le state de notre application une fois que la liste des todos a chargé avec succès.
- `TodosLoadFailure` - le state de notre application si la liste n'a pas été correctement chargé.

[todos_state.dart](../_snippets/flutter_todos_tutorial/todos_state.dart.md ':include')

Ensuite, nous allons implémenter les événements que nous allons devoir gérer.

### Events (événements)

Les événements qui nous allons devoir gérer dans notre `TodosBloc` sont:

- `TodosLoadSuccess` - dis au bloc qu'il est nécessaire de charger les todos depuis `TodosRepository`.
- `TodoAdded` - dis au bloc qu'il est nécessaire d'ajouter un nouveau todo à la liste des todos.
- `TodoUpdated` - dis au bloc qu'il est nécessaire d'actualiser un todo existant.
- `TodoDeleted` - dis au bloc qu'il est nécessaire de supprimer un todo existant.
- `ClearCompleted` - dis au bloc qu'il est nécessaire de supprimer tous les todos complétés.
- `ToggleAll` - dis au bloc qu'il est nécessaire de basculer (toggle) le state completed de tous les todos.

Créons `blocs/todos/todos_event.dart` et implémentons les événements décris au dessus.

[todos_event.dart](../_snippets/flutter_todos_tutorial/todos_event.dart.md ':include')

Maintenant que nous avons `TodosStates` et `TodosEvents` d'implémenter, nous puvons implémenter notre `TodosBloc`.

### Bloc

Créons `blocs/todos/todos_bloc.dart` et commençons! Nous avons juste besoin d'implémenter `initialState` et `mapEventToState`.

[todos_bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc.dart.md ':include')

!> Quand nous "yieldons" un state dans le gestionnaire privé (private handlers) `mapEventToState`, nous sommes toujours entrain de yield un nouveau state plutôt de muter le `state`. Cela s'explique car à chaque fois que nous yieldons, le bloc va comparer le `state` au `nextState` et va déclencher un changement de state (`transition`) si les deux states **ne sont pas égaux**. Si nous faisons juste muter et yield la même instance de notren state, alors `state == nextState` renverra vrai (true) et aucun changement de state n'aurait lieu.

Notre `TodosBloc` aura une dépendance sur le `TodosRepository` pour qu'il puisse charger et sauvegarder les todos. Il aura un state initial de `TodosLoadInProgress` et définira le private handlers pour chacun des événements. Peu importe quand le `TodosBloc` change la liste des todos, il appelle la méthode `saveTodos` dans le `TodosRepository` dans le but de tout garder localement.

### Barrel File (Fichier baril)

Maintenant que nous en avons terminé avec notre `TodosBloc`, nous pouvons créer un barrel file pour exporter tous les fichiers de notre et faciliter leur import plus tard.

Créons `blocs/todos/todos.dart` et exportons le bloc, les événements (events) et les states:

[bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc_barrel.dart.md ':include')

## Filtrés Todos Bloc

> Le `FilteredTodosBloc` sera responsable de réagir aux changements de states dans le `TodosBloc` que nous venons de créer et il maintiendra le state de filtrage des todos dans notre application.

### Modèle

Avant que nous commençons à définir et à implémenter le `TodosStates`, nous allons implémenter le modèle `VisibilityFilter` qui déterminera quel todo notre `FilteredTodosState` contiendra. Dans ce cas, nous aurons trois filtres:

- `all` - va afficher tous les Todos (par défaut)
- `active` - affichera seulement les Todos qui ne sont pas complétés
- `completed` affichera seulement les Todos complétés

Nous pouvons créer `models/visibility_filter.dart` aet définir notre filtre comme un enum:

[visibility_filter.dart](../_snippets/flutter_todos_tutorial/visibility_filter.dart.md ':include')

### States (états)

Comme nous l'avons fais dans `TodosBloc`, nous allons définir les différents states pour notre `FilteredTodosBloc`.

Dans ce cas, nous aurons uniquement deux states:

- `FilteredTodosLoadInProgress` - le state pendant que nous récupérons les todos
- `FilteredTodosLoadSuccess` - le state quand nous avons fini de récupérer les todos

Créons `blocs/filtered_todos/filtered_todos_state.dart` et implémentons les deux states.

[filtered_todos_state.dart](../_snippets/flutter_todos_tutorial/filtered_todos_state.dart.md ':include')

?> **Note:** Le state `FilteredTodosLoadSuccess` contient la liste des todos filtrés ainsi que le filtre de visibilité activé.

### Events (événements)

Nous allons implémenter deux événements pour notre `FilteredTodosBloc`:

- `FilterUpdated` - qui notifiera le bloc que la visibilité du filtre a changé
- `TodosUpdated` - qui notifiera le bloc que la list des todos a changé

Créons `blocs/filtered_todos/filtered_todos_event.dart` et implémentons les deux événements.

[filtered_todos_event.dart](../_snippets/flutter_todos_tutorial/filtered_todos_event.dart.md ':include')

Nous sommes prêts pour implémenter `FilteredTodosBloc`!

### Bloc

Notre `FilteredTodosBloc` sera similaire à celui `TodosBloc`; toutefois, au lieu d'avoir une dépendance sur `TodosRepository`, il aura une dépendance sur le bloc `TodosBloc`. Cela nous permettra au `FilteredTodosBloc` d'actualiser son propre state en réponse aux changements du state dans le `TodosBloc`.

Créons `blocs/filtered_todos/filtered_todos_bloc.dart` et commençons.

[filtered_todos_bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc.dart.md ':include')

!> Nous créons un `StreamSubscription` pour le stream de `TodosStates` pour que l'on puisse écouter les changements du state dans le `TodosBloc`. On override la méthode de fermeture du bloc et annulons la souscription pour que l'on puisse nettoyer(clean) après que le bloc soit fermé.

### Barrel File (fichier baril)

Comme avant, nous pouvons créer un fichier baril pour permettre l'import des classes de filtrage des todos.

Créons `blocs/filtered_todos/filtered_todos.dart` et exportons les trois fichiers:

[bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc_barrel.dart.md ':include')

Ensuite, nous allons implémenter le `StatsBloc`.

## Stats Bloc (Bloc de statistiques)

> Le `StatsBloc` sera responsable de maintenir les statistiques du nombre de todos actifs et du nombres de todos complétés.
Comme pour le `FilteredTodosBloc`, il aura une dépendance sur le `TodosBloc` pour qu'il puisse réagir aux changements dans le `TodosBloc` state.

### State

Notre `StatsBloc` pourra être dans deux states:

- `StatsLoadInProgress` - soit le state quand les statistiques n'ont pas encore été calculées.
- `StatsLoadSuccess` -  ques les statistiques ont été calculées.

Créons `blocs/stats/stats_state.dart` et implémentons notre `StatsState`.

[stats_state.dart](../_snippets/flutter_todos_tutorial/stats_state.dart.md ':include')

Ensuite, définissons et implémentons `StatsEvents`.

### Events

Il y aura qu'un seul événement dans notre `StatsBloc` il répondra à: `StatsUpdated`. Cet événement sera ajouté peu importe quand le state de `TodosBloc` changera pour que notre `StatsBloc` puisse recalculer les nouvelles statistiques.

Créons `blocs/stats/stats_event.dart` et implémentons le.

[stats_event.dart](../_snippets/flutter_todos_tutorial/stats_event.dart.md ':include')

Maintenant nous sommes prêts à implémenter notre `StatsBloc` which will look very similar to the `FilteredTodosBloc`.

### Bloc

Notre `StatsBloc` aura une dépendance avec `TodosBloc` ce qui lui permettra d'actualiser son state en réponse aux changements du state dans le `TodosBloc`.

Créons `blocs/stats/stats_bloc.dart` et commençons.

[stats_bloc.dart](../_snippets/flutter_todos_tutorial/stats_bloc.dart.md ':include')

C'est tout ce dont nous avons besoin! Notre `StatsBloc` recalculera son state qui contient le nombre de todos actifs et le nombre de todos complétés à chaque fois que le state de notre bloc `TodosBloc` changera.

Maintenant que nous avons terminé avec le `StatsBloc` il ne faut plus qu'implémenter notre dernier bloc : le `TabBloc`.

## Tab Bloc

> Le `TabBloc` sera responsable de maintenir le state des différentes fenêtres (tabs) dans notre application. Il prendra `TabEvents` comme input et son output sera `AppTabs`.

### Model / State (Modèle / état)

Nous avons besoin de définir un modèle `AppTab` que nous utiliserons pour représenter le `TabState`. Le `AppTab` sera juste un `enum` qui représente la fenêtre active dans notre application. Comme notre application ne contiendra que deux fenêtres à savoir les todos et les statistiques, nous avons besoin d'y ajouter 2 valeurs.

Créons `models/app_tab.dart`:

[app_tab.dart](../_snippets/flutter_todos_tutorial/app_tab.dart.md ':include')

### Event 

Notre `TabBloc` sera responsable de gérer un seul événement `TabEvent`:

- `TabUpdated` - il notifiera le bloc que la fenêtre active a été mise à jour

Créons `blocs/tab/tab_event.dart`:

[tab_event.dart](../_snippets/flutter_todos_tutorial/tab_event.dart.md ':include')

### Bloc

Dans notre `TabBloc` l'implémentation sera super simple. Comme toujours, nous avons juste besoin d'implémenter `initialState` et `mapEventToState`.

Créons `blocs/tab/tab_bloc.dart` et implémentons le rapidement.

[tab_bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc.dart.md ':include')

Je vous avais prévenu que ce serait simple! Tout ce que `TabBloc` va faire est de définir le state initial à la fenêtre des todos (cela veut dire que par défaut l'application s'ouvrira sur cette fenêtre) et gérer l'événement `TabUpdated` en "yieldant" une nouvelle instance `AppTab`.

### Barrel File (Fichier baril)

Enfin, nous allons créer un autre fichier baril pour exporter notre `TabBloc`. Créons `blocs/tab/tab.dart` et exportons les deux fichiers:

[bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc_barrel.dart.md ':include')

## Bloc Delegate

Avant de passer à la couche de présentation, nous allons implémenter notre propre `BlocDelegate` qui nous permettra de gérer tous les changements de state et les erreurs dans une seule place. C'est très pratique pour des choses comme avoir les développeurs logs ou les analyses (analytics).

Créons `blocs/simple_bloc_delegate.dart` et commençons.

[simple_bloc_delegate.dart](../_snippets/flutter_todos_tutorial/simple_bloc_delegate.dart.md ':include')

Tout ce que nous faisons dans ce cas est d'afficher (en console) tous les changements de states (`transitions`) et les erreurs pour que l'on puisse voir ce qu'il se passe quand nous utilisons notre application. Vous pourriez même relier `BlocDelegate` à votre Google analytics, sentry, crashlytics, etc...

## Blocs Barrel (Baril de blocs)

Maintenant que nous avons tous nos blocs d'implémentés, nous pouvons créer un fichier baril.
Créons `blocs/blocs.dart` et exportons tous nos blocs pour pouvoir importer de manière conventionnel nos blocs dans n'importe quel fichier avec un simple import.

[blocs.dart](../_snippets/flutter_todos_tutorial/blocs_barrel.dart.md ':include')

Ensuite, nous allons nous concentrer sur la manière dont nous allons implémenter la plus part de nos écrans (screens) dans notre Todos application.

## Screens (écrans)

### Home Screen (Ecran d'accueil)

> Notre `HomeScreen` sera responsable de la créaton du `Scaffold` de notre application. Il contiendra notre `AppBar`, `BottomNavigationBar`, mais aussi nos widgets `Stats`/`FilteredTodos` (en fonction de la fenêtre active).

Créons un nouveau dossier appelé `screens` où nous mettrons tous nos nouveaux screen widgets et ensuite créons `screens/home_screen.dart`.

[home_screen.dart](../_snippets/flutter_todos_tutorial/home_screen.dart.md ':include')

Le `HomeScreen` a accès au `TabBloc` en utilisant `BlocProvider.of<TabBloc>(context)` qui va devenir disponible depuis la racine(root) de notre widget `TodosApp` (nous y reviendrons un peu plus tard dans ce tutoriel).

Ensuite, nous allons implémenter notre `DetailsScreen`.

### Details Screen

> L'écran `DetailsScreen` affichera tous les détails du todo que nous l'utilisateur aura sélectionné et lui permettra de soit l'éditer ou alors de le supprimer.

Créons et construisons `screens/details_screen.dart`.

[details_screen.dart](../_snippets/flutter_todos_tutorial/details_screen.dart.md ':include')

?> **Note:** Le `DetailsScreen` requiert un id d'un todo pour qu'il puisse afficher les détail du todo sélectionné à partir du `TodosBloc` et pour qu'il puisse la mettre à jour peu importe quand les détails d'unb todo ont été changés (l'id d'un todo ne peut pas être modifié).

Les choses à remarqués ici sont l'icône `IconButton` qui ajoute un événement `TodoDeleted` ainsi qu'une checkbox qui ajoute un événement `TodoUpdated`.

Il y aussi un autre `FloatingActionButton` qui fait naviguer l'utilisateur à `AddEditScreen` avec `isEditing` qui prend `true` comme valeur. Nous allons examiner l'écran `AddEditScreen` juste après.

### Add/Edit Screen (Ecran d'ajout/de modification)

> Le widget `AddEditScreen` permet à l'utilisateur de soit créer un nouveau todo ou alors d'actualiser un todo existant en se basant sur le flag (drapeau) `isEditing` qui lui est passé via le constructeur.

Créons `screens/add_edit_screen.dart` et regardons comment l'implémenter.

[add_edit_screen.dart](../_snippets/flutter_todos_tutorial/add_edit_screen.dart.md ':include')

Il n'y a rien de specific au bloc dans ce widget, il s'agit simplement d'un formulaire et:

- si `isEditing` est true le formulaire est rempli avec les détails existantes du todo.
- sinon les inputs sont vides pour que l'utilisateur puisse créer un nouveau todo.

On utilise une fonction de rappel (callback) `onSave` pour notifier le parent de l'actualisation ou la création d'un todo.

C'est tout pour les écrans dans notre application, mais avant d'oublier, créons notre fichier baril.

### Screens Barrel (Baril d'écrans)

Créons `screens/screens.dart` et exportons les trois fichiers.

[screens.dart](../_snippets/flutter_todos_tutorial/screens_barrel.dart.md ':include')

Ensuite, implémentons tous les "widgets" (tout ce qui n'est pas un screen).

## Widgets

### Filter Button (Boutton pour filtrer)

> Le widget `FilterButton` sera responsable de fournir à l'utilisateur unbe liste des options de filtrage et il notifiera le `FilteredTodosBloc` quand un filtre a été selectionné.

Créons un nouveau fichier appelé `widgets` et mettons-y l'implémentation de `FilterButton` dans `widgets/filter_button.dart`.

[filter_button.dart](../_snippets/flutter_todos_tutorial/filter_button.dart.md ':include')

Le `FilterButton` a besoin de répondre aux changements d'états (states) dans le `FilteredTodosBloc` donc il utilise un `BlocProvider` pour accèder au `FilteredTodosBloc` depuis `BuildContext`. Ensuite, il utilise `BlocBuilder` pour ré-affichier peu importe quand le state de `FilteredTodosBloc` change.

Le reste de l'implémentation est du Flutter pur et il n'y a rien de spécial qui se passe, nous pouvons donc passer au widget `ExtraActions`.

### Extra Actions

> Comme pour `FilterButton`, le widget `ExtraActions` est responsable de founir à l'utilisateur une liste d'options supplémentaires :  Toggling Todos et nettoyer (clear) les todos complétés.

Puisque ce widget s'en fiche des filters, il va intéragir directement avec `TodosBloc` plutôt que `FilteredTodosBloc`.

Créons le modèle `ExtraAction` dans `models/extra_action.dart`.

[extra_action.dart](../_snippets/flutter_todos_tutorial/extra_action.dart.md ':include')

Et n'oubliez pas de l'exporter dans le fichier baril `models/models.dart`.

Ensuite, créons `widgets/extra_actions.dart` et implémentons le.

[extra_actions.dart](../_snippets/flutter_todos_tutorial/extra_actions.dart.md ':include')

Comme pouir le `FilterButton`, on utilise un `BlocProvider` pour accèder au `TodosBloc` à partir de  `BuildContext` et `BlocBuilder` to en réponse aux changements de states dans le bloc `TodosBloc`.

En fonction des actions sélectionnées, le widget ajoutera un événement soit au `TodosBloc` ou alors à `ToggleAll` aux todos ayant un state de complété ou pour clear `ClearCompleted` les todos.

Ensuite nous travaillerons sur le widget `TabSelector`.

### Tab Selector (Sélectionner la fenêtre)

> Le widget `TabSelector` a pour rôle d'afficher les fenêtres dans le `BottomNavigationBar` et de gérer les input des utilisateurs.

Créons `widgets/tab_selector.dart` et implémentons le.

[tab_selector.dart](../_snippets/flutter_todos_tutorial/tab_selector.dart.md ':include')

Vous pouvez voir qu'il n'y aucune dépendance sur les blocs dans ce widget; il appel juste `onTabSelected` quand une fenêtre est sélectionné et il prend aussi `activeTab` comme input afin de savoir quelle fenêtre est actuellement sélectionné.
Ensuite, nous allons regarder le widget `FilteredTodos`.

### Filtered Todos (Filtrés les todos)

> Le widget `FilteredTodos` est reponsable d'afficher une liste de todos en fonction des filtres actifs.
Créons `widgets/filtered_todos.dart` et implémentons le.

[filtered_todos.dart](../_snippets/flutter_todos_tutorial/filtered_todos.dart.md ':include')

Comme pour les widgets précédemment écrits, le widget `FilteredTodos` utilise `BlocProvider` pour accèder au bloc (dans ce cas les deux blocs `FilteredTodosBloc` et `TodosBloc` son nécessaires).

?> Le `FilteredTodosBloc` est nécessaire pour nous aider à afficher correment les todos en fonction de leur filtre actuel

?> Le `TodosBloc` est nécessaire pour nous permettre d'ajouter/supprimer des todos en réponse aux intéractions de l'utilisateur comme swiper sur un todo individuel.

Depuis le widget `FilteredTodos`, l'utilisateur peut naviguer sur l'écran `DetailsScreen` où il est possible de soit supprimer ou éditer un todo sélectionné. Puisque notre widget `FilteredTodos` affiche une liste de widgets `TodoItem`, nous allons nous y intéresser prochainement.

### Todo Item

> `TodoItem` est un stateless widget qui est reponsable d'afficher un seul todo et de gérer les intéractions de l'utilisateurs (taps/swipes).

Créons `widgets/todo_item.dart` et construisons le.

[todo_item.dart](../_snippets/flutter_todos_tutorial/todo_item.dart.md ':include')

Encore une fois, notez que le `TodoItem` n'a pas de relation avec un bloc specific dans ce code. Il va simplement afficher via le todo passé dans le constructeur et ensuite appelé les fonctions de rappels (callback) injectés quand l'utilisateur va intéragir avec le todo.
Ensuite, nous allons construire le widget `DeleteTodoSnackBar`.

### Delete Todo SnackBar (Supprimer un todo)

> Le `DeleteTodoSnackBar` sera responsable d'afficher à l'utilisateur que le todo a été supprimé et va permettre à l'utilisateur d'annuler son action.

Créons `widgets/delete_todo_snack_bar.dart` et implémentons le.

[delete_todo_snack_bar.dart](../_snippets/flutter_todos_tutorial/delete_todo_snack_bar.dart.md ':include')

Maintenant, vous avez probablement repérer le pattern: ce widget lui aussi ne possède pas de bloc-specific code. Il va simplement prendre un todo dans le but d'afficher la tâche et d'appeler une fonction callback appelé `onUndo` si un utilisateur appuie sur le boutton undo.

Nous y sommes presque; plus que deux widgets restants!

### Loading Indicator (Indicateur de chargement)

> Le widget `LoadingIndicator` est stateless widget qui est responsable d'indiquer à l'utilisateur que quelque chose est en progrès.

Créons `widgets/loading_indicator.dart` et écrivons le.

[loading_indicator.dart](../_snippets/flutter_todos_tutorial/loading_indicator.dart.md ':include')

Il n'y a rien de spécial à dire ici; nous utilisons un standard `CircularProgressIndicator` enveloppé dans un widget `Center` (encore une fois rien de spécific à du code Bloc).

Lastly, we need to build our `Stats` widget.

### Stats

> Le widget `Stats` est responsable de montrer à l'utilisateur combien de todos sont actifs (en progrès donc) vs combien sont complétés.
Créons `widgets/stats.dart` et regardons comme l'implémenter.

[stats.dart](../_snippets/flutter_todos_tutorial/stats.dart.md ':include')

Nous accèdons à `StatsBloc` en utilisant `BlocProvider` et `BlocBuilder` pour reconstruire la réponse aux changements de state dans le state `StatsBloc`.

## Assemblons le tout !

Créons `main.dart` dans notre widget `TodosApp`. Nous avons besoin de créer une fonction `main` pour lancer notre `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/main1.dart.md ':include')

?> **Note:** Le BlocSupervisor's delegate prend la valeur de `SimpleBlocDelegate` que nous avons créé plutôt pour qu'on puisse récupérer toutes les transitions et les erreurs.

?> **Note:** Nous enveloppons aussi notre widget `TodosApp` dans un `BlocProvider` qui va gérer l'initialisation, la fermeture et de fournir le bloc `TodosBloc` à l'arbre entier de notre widget depuis [flutter_bloc](https://pub.dev/packages/flutter_bloc). Cela permet d'y avoir accès dans tous les widgets enfants. Nous ajoutons aussi immédiatement l'événement `TodosLoadSuccess` dans le but de "demander" les todos les plus récents.

Ensuite nous implémentons notre widget `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/todos_app.dart.md ':include')

Notre `TodosApp` est un `StatelessWidget` qui accède le bloc `TodosBloc` fourni par le `BuildContext`.

Le `TodosApp` possède deux routes:

- `Home` - qui affiche `HomeScreen`
- `TodoAdded` - qui affiche `AddEditScreen` avec `isEditing` qui a pour valeur `false`.

Le `TodosApp` rend `TabBloc`, `FilteredTodosBloc`, et `StatsBloc` disponible pour les widgets dans le sous-arbre en utilisant le widget `MultiBlocProvider` de [flutter_bloc](https://pub.dev/packages/flutter_bloc).

[multi_bloc_provider.dart](../_snippets/flutter_todos_tutorial/multi_bloc_provider.dart.md ':include')

revient à écrire

[nested_bloc_providers.dart](../_snippets/flutter_todos_tutorial/nested_bloc_providers.dart.md ':include')

Vous pouvez voir à quel point `MultiBlocProvider` aide à réduire les niveaux  reduce the levels de nesting et donne un code plus facile à lire et à maintenir.

Notre `main.dart` en entier devrait ressmebler à ceci :

[main.dart](../_snippets/flutter_todos_tutorial/main2.dart.md ':include')

C'est tout ce qu'il nous faut! Nous avons réussi à implémenter une todo app dans flutter en utilisant les packages [bloc] https://pub.dev/packages/bloc) et [flutter_bloc](https://pub.dev/packages/flutter_bloc) et nous avons  and we’ve séparés avec succès notre présentation (screens et widgets) de notre business logic.

Le code source en entier est disponible [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos)!
