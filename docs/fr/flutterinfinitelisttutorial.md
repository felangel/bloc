# Tutoriel Flutter liste infinie

![intermédiaire](https://img.shields.io/badge/level-intermediate-orange.svg)

> Dans ce tutoriel, nous allons implémenter une application qui récupère des données sur le réseau et les charger au fur et à mesure qu'un utilisateur les fait défiler. On utilisera Flutter et la bibliothèque Bloc.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

[script](../_snippets/flutter_infinite_list_tutorial/flutter_create.sh.md ':include')

Nous pouvons alors remplacer le contenu de pubspecspec.yaml par

[pubspec.yaml](../_snippets/flutter_infinite_list_tutorial/pubspec.yaml.md ':include')

et ensuite installer toutes nos dépendances

[script](../_snippets/flutter_infinite_list_tutorial/flutter_packages_get.sh.md ':include')

## API REST

Pour cette application de démonstration, nous utiliserons [jsonplaceholder](http://jsonplaceholder.typicode.com) comme source de données.

?> jsonplaceholder est une API REST en ligne qui fournit de fausses données ; c'est très utile pour construire des prototypes.

Ouvrez un nouvel onglet dans votre navigateur et visitez https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 pour voir ce que l'API renvoie.

[posts.json](../_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **Note:** dans notre url, nous avons spécifié le début et la limite comme paramètres de requête à la requête GET.

Super, maintenant que nous savons à quoi vont ressembler nos données, créons le modèle.

## Modèle de données

Créez `post.dart` et mettons-nous au travail en créant le modèle de notre objet Post.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post.dart.md ':include')

"Post" est juste une classe avec un `id`, un `titre` et un `corps`.

?> Nous remplaçons la fonction `toString` afin d'avoir une représentation personnalisée de notre `Post` pour plus tard.

?> Nous étendons [`Equatable`](https://pub.dev/packages/equatable) pour pouvoir comparer `Posts` ; par défaut, l'opérateur d'égalité retourne vrai si et seulement si ceci et d'autres sont la même instance.

Maintenant que nous avons notre modèle objet `Post`, commençons à travailler sur le Business Logic Component (bloc).

## Post Events

Avant de nous lancer dans la mise en œuvre, nous devons définir ce que notre `PostBloc`va faire.

A un haut niveau d'abstraction, il répondra aux entrées des utilisateurs (défilement) et récupérera plus de messages afin que la couche de présentation les affiche. Commençons par créer notre événement.

Notre `PostBloc` ne répondra qu'à un seul événement ; `PostFetched` qui sera envoyé par la couche de présentation chaque fois qu'elle aura besoin de plus de messages à présenter. Puisque notre événement `PostFetched` est un type de `PostEvent` nous pouvons créer `bloc/post_event.dart` et implémenter l'événement comme ceci.

[post_event.dart](../_snippets/flutter_infinite_list_tutorial/post_event.dart.md ':include')

Pour résumer, notre `PostBloc` recevra les `PostEvents` et les convertira en `PostStates`. Nous avons défini tous nos `PostEvents` (PostFetched) donc définissons maintenant notre `PostState`.

## Post States

Notre couche de présentation aura besoin de plusieurs éléments d'information afin de bien se présenter :

- `PostInitial`- indiquera à la couche de présentation qu'elle doit rendre un indicateur de chargement pendant que le lot initial de messages est chargé
- `PostSuccess`- indiquera à la couche de présentation qu'il a du contenu à afficher
  - `posts`- sera la `Liste<Post>` qui sera affichée
  - `hasReachedMax`- indiquera à la couche de présentation s'il a atteint ou non le nombre maximum de messages.
- `PostFailure`- indiquera à la couche de présentation qu'une erreur s'est produite lors de la récupération des messages

Nous pouvons maintenant créer `bloc/post_state.dart` et l'implémenter de cette manière.

[post_state.dart](../_snippets/flutter_infinite_list_tutorial/post_state.dart.md ':include')

Nous avons implémenté `copyWith` pour pouvoir copier une instance de `PostSuccess`et mettre à jour zéro ou plus de propriétés de manière pratique (cela sera utile plus tard).

Maintenant que nous avons mis en place nos `Events` et nos `States`, nous pouvons créer notre `PostBloc`.

Pour faciliter l'importation de nos états et événements avec une seule importation, nous pouvons créer `bloc/bloc.dart` qui les exporte tous (nous ajouterons notre exportation `post_bloc.dart` dans la section suivante).

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc_initial.dart.md ':include')

## Post Bloc

Pour plus de simplicité, notre `PostBloc` dépendra directement d'un `http client` ; cependant, dans une application de production, vous pouvez injecter un client api et utiliser le pattern du référentiel [docs](./architecture.md).

Créons `post_bloc.dart` et créons notre `PostBloc` vide.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **Note:** À partir de la déclaration de classe nous pouvons dire que notre PostBloc prendra PostEvents comme entrée et des PostStates en sortie.

Nous pouvons commencer par implémenter `initialState` qui sera l'état de notre `PostBloc` avant que les événements n'aient été envoyés.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial_state.dart.md ':include')

Ensuite, nous devons implémenter `mapEventToState` qui sera lancé chaque fois qu'un `PostEvent` est envoyé.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_map_event_to_state.dart.md ':include')

Notre `PostBloc` cède à chaque fois qu'il y a un nouvel état car il retourne un `Stream<PostState>`. Consultez [concepts de base](https://felangel.github.io/bloc/#/coreconcepts?id=streams) pour plus d'informations sur `Streams` et d'autres concepts de base.

Maintenant, chaque fois qu'un `PostEvent` est envoyé, s'il s'agit d'un événement `PostFetched` et qu'il y a plus de messages à récupérer, notre `PostBloc` ira chercher les 20 messages suivants.

L'API retournera un tableau vide si nous essayons de récupérer au-delà du nombre maximum de messages (100), donc si nous récupérons un tableau vide, notre bloc retournera `yield` l'état courant sauf que nous mettrons `hasReachedMax` à true.

Si nous ne pouvons pas récupérer les messages, nous lançons une exception et `yield` `PostFailure()`.

Si nous pouvons récupérer les messages, nous retournons `PostSuccess()` qui prend la liste complète des messages.

Une optimisation que nous pouvons faire est de `rebondir` les `Events` afin d'éviter le spamming de notre API inutilement. Nous pouvons le faire en surchargeant la méthode `transform` dans notre `PostBloc`.

?> **Note:** Surpasser transform nous permet de transformer le Stream<Event> avant que mapEventToState ne soit appelé. Ceci permet d'appliquer des opérations comme distinct(), debounceTime(), etc......

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_transform_events.dart.md ':include')

Notre `PostBloc` fini devrait maintenant ressembler à ceci :

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc.dart.md ':include')

N'oubliez pas de mettre à jour `bloc/bloc.dart` pour inclure notre `PostBloc` !

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc.dart.md ':include')

Super ! Maintenant que nous avons fini d'implémenter la logique métier, il ne nous reste plus qu'à implémenter la couche de présentation.

## Couche de présentation

Dans notre `main.dart` nous pouvons commencer par implémenter notre fonction principale et appeler `runApp` pour rendre notre widget racine.

Dans notre widget `App`, nous utilisons `BlocProvider` pour créer et fournir une instance de `PostBloc` au sous-arbre. De plus, nous envoyons un événement `PostFetched` pour que lorsque l'application se charge, elle demande le lot initial de messages.

[main.dart](../_snippets/flutter_infinite_list_tutorial/main.dart.md ':include')

Ensuite, nous devons implémenter notre widget `HomePage` qui présentera nos messages et se connectera à notre `PostBloc`.

[home_page.dart](../_snippets/flutter_infinite_list_tutorial/home_page.dart.md ':include')

?> HomePage est un `StatefulWidget` parce qu'il devra maintenir un `ScrollController`. Dans `initState`, nous ajoutons un auditeur à notre `ScrollController` afin de pouvoir répondre aux événements de défilement. Nous accédons également à notre instance `PostBloc` via `BlocProvider.of<PostBloc>(contexte)`.

Notre méthode de compilation retourne un `BlocBuilder`. `BlocBuilder` est un widget Flutter du paquet [flutter_bloc](https://pub.dev/packages/flutter_bloc) qui gère la construction d'un widget en réponse aux nouveaux états de bloc. Chaque fois que notre état `PostBloc` change, notre fonction constructeur sera appelée avec le nouveau `PostState`.

!> Nous devons nous rappeler de bien nettoyer derrière nous et de nous débarrasser de notre `ScrollController` quand le StatefulWidget est disposé.

Chaque fois que l'utilisateur fait défiler, nous calculons à quelle distance du bas de la page il se trouve et si la distance est ≤ notre `_scrollThreshold` nous envoyons un événement `PostFetched` afin de charger plus de messages.

Ensuite, nous devons implémenter notre widget `BottomLoader' qui indiquera à l'utilisateur que nous chargeons plus de messages.

[bottom_loader.dart](../_snippets/flutter_infinite_list_tutorial/bottom_loader.dart.md ':include')
Enfin, nous devons implémenter notre `PostWidget` qui rendra un message individuel.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post_widget.dart.md ':include')

À ce stade, nous devrions être en mesure d'exécuter notre application et tout devrait fonctionner ; cependant, il y a encore une chose que nous pouvons faire.

Un avantage supplémentaire de l'utilisation de la bibliothèque de blocs est que nous pouvons avoir accès à toutes les `Transitions` dans un seul endroit.

> Le passage d'un état à un autre s'appelle une `Transition`.

?> Une `Transition` se compose de l'état courant, de l'événement et de l'état suivant.

Même si dans cette application nous n'avons qu'un seul bloc, il est assez courant dans les applications plus grandes d'avoir plusieurs blocs gérant différentes parties de l'état de l'application.

Si nous voulons pouvoir faire quelque chose en réponse à toutes les `Transitions`, nous pouvons simplement créer notre propre `BlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/flutter_infinite_list_tutorial/simple_bloc_delegate.dart.md ':include')

?> Tout ce que nous avons à faire est d'étendre `BlocDelegate` et de remplacer la méthode `onTransition`.

Pour dire à Bloc d'utiliser notre `SimpleBlocDelegate`, il nous suffit d'ajuster notre fonction principale.

[main.dart](../_snippets/flutter_infinite_list_tutorial/bloc_delegate_main.dart.md ':include')

Maintenant, lorsque nous exécutons notre application, chaque fois qu'un Bloc `Transition` se produit, nous pouvons voir la transition imprimée sur la console.

?> En pratique, vous pouvez créer différents `BlocDelegates` et parce que chaque changement d'état est enregistré, nous sommes capables d'instrumenter très facilement nos applications et de suivre toutes les interactions utilisateur et les changements d'état en un seul endroit !

C'est tout ce qu'il y a à faire ! Nous avons maintenant implémenté avec succès une liste infinie dans Flutter en utilisant les paquets [bloc](https://pub.dev/packages/bloc) et [flutter_bloc](https://pub.dev/packages/flutter_bloc) et nous avons réussi à séparer notre couche de présentation de notre logique métier.

Notre page d'accueil n'a aucune idée d'où viennent les `Posts` ou comment ils sont récupérés. Inversement, notre `PostBloc` n'a aucune idée de la façon dont le `State` est rendu, il convertit simplement les événements en états.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
