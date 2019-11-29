# Tutoriel Flutter liste infinie

![intermédiaire](https://img.shields.io/badge/level-intermediate-orange.svg)

> Dans ce tutoriel, nous allons implémenter une application qui récupère des données sur le réseau et les charger au fur et à mesure qu'un utilisateur les fait défiler. On utilisera Flutter et la bibliothèque Bloc.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

```bash
flutter create flutter_infinite_list
```

Nous pouvons alors remplacer le contenu de pubspecspec.yaml par

```yaml
name: flutter_infinite_list
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.0.0-dev.68.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^0.21.0
  http: ^0.12.0
  equatable: ^0.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

et ensuite installer toutes nos dépendances

```bash
flutter packages get
```

## API REST 

Pour cette application de démonstration, nous utiliserons [jsonplaceholder](http://jsonplaceholder.typicode.com) comme source de données.

?> jsonplaceholder est une API REST en ligne qui fournit de fausses données ; c'est très utile pour construire des prototypes.

Ouvrez un nouvel onglet dans votre navigateur et visitez https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 pour voir ce que l'API renvoie.

```json
[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"
  },
  {
    "userId": 1,
    "id": 2,
    "title": "qui est esse",
    "body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla"
  }
]
```

?> **Note:** dans notre url, nous avons spécifié le début et la limite comme paramètres de requête à la requête GET.

Super, maintenant que nous savons à quoi vont ressembler nos données, créons le modèle.

## Modèle de données

Créez `post.dart` et mettons-nous au travail en créant le modèle de notre objet Post.

```dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  Post({this.id, this.title, this.body}) : super([id, title, body]);

  @override
  String toString() => 'Post { id: $id }';
}
```

"Post" est juste une classe avec un `id`, un `titre` et un `corps`.

?> Nous remplaçons la fonction `toString` afin d'avoir une représentation personnalisée de notre `Post` pour plus tard.

?> Nous étendons [`Equatable`](https://pub.dev/packages/equatable) pour pouvoir comparer `Posts` ; par défaut, l'opérateur d'égalité retourne vrai si et seulement si ceci et d'autres sont la même instance.


Maintenant que nous avons notre modèle objet `Post`, commençons à travailler sur le Business Logic Component (bloc).

## Post Events

Avant de nous lancer dans la mise en œuvre, nous devons définir ce que notre `PostBloc`va faire.

A un haut niveau d'abstraction, il répondra aux entrées des utilisateurs (défilement) et récupérera plus de messages afin que la couche de présentation les affiche. Commençons par créer notre événement.

Notre `PostBloc` ne répondra qu'à un seul événement ; `Fetch` qui sera envoyé par la couche de présentation chaque fois qu'elle aura besoin de plus de messages à présenter. Puisque notre événement `Fetch` est un type de `PostEvent' nous pouvons créer `bloc/post_event.dart` et implémenter l'événement comme ceci.

```dart
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {}

class Fetch extends PostEvent {
  @override
  String toString() => 'Fetch';
}
```

?> Encore une fois, nous avons remplacé `toString` pour une représentation plus facile à lire des chaînes de caractères de notre événement. Encore une fois, nous étendons [`Equatable`](https://pub.dev/packages/equatable) afin de pouvoir comparer leurs égalités.

Pour résumer, notre `PostBloc` recevra les `PostEvents` et les convertira en `PostStates`. Nous avons défini tous nos `PostEvents` (Fetch) donc définissons maintenant notre `PostState`.

## Post States

Notre couche de présentation aura besoin de plusieurs éléments d'information afin de bien se présenter :

- `PostUninitialized`- indiquera à la couche de présentation qu'elle doit rendre un indicateur de chargement pendant que le lot initial de messages est chargé
- `PostLoaded`- indiquera à la couche de présentation qu'il a du contenu à afficher
  - `posts`- sera la `Liste<Post>` qui sera affichée
  - `hasReachedMax`- indiquera à la couche de présentation s'il a atteint ou non le nombre maximum de messages.
- `PostError`- indiquera à la couche de présentation qu'une erreur s'est produite lors de la récupération des messages

Nous pouvons maintenant créer `bloc/post_state.dart` et l'implémenter de cette manière.

```dart
import 'package:equatable/equatable.dart';

import 'package:flutter_infinite_list/post.dart';

abstract class PostState extends Equatable {
  PostState([List props = const []]) : super(props);
}

class PostUninitialized extends PostState {
  @override
  String toString() => 'PostUninitialized';
}

class PostError extends PostState {
  @override
  String toString() => 'PostError';
}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  PostLoaded({
    this.posts,
    this.hasReachedMax,
  }) : super([posts, hasReachedMax]);

  PostLoaded copyWith({
    List<Post> posts,
    bool hasReachedMax,
  }) {
    return PostLoaded(
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
```

Nous avons implémenté `copyWith` pour pouvoir copier une instance de `PostLoaded`et mettre à jour zéro ou plus de propriétés de manière pratique (cela sera utile plus tard).

Maintenant que nous avons mis en place nos `Events` et nos `States`, nous pouvons créer notre `PostBloc`.

Pour faciliter l'importation de nos états et événements avec une seule importation, nous pouvons créer `bloc/bloc.dart` qui les exporte tous (nous ajouterons notre exportation `post_bloc.dart` dans la section suivante).
```dart
export './post_event.dart';
export './post_state.dart';
```

## Post Bloc

Pour plus de simplicité, notre `PostBloc` dépendra directement d'un `http client` ; cependant, dans une application de production, vous pouvez injecter un client api et utiliser le pattern du référentiel [docs](./architecture.md).

Créons `post_bloc.dart` et créons notre `PostBloc` vide.

```dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_infinite_list/bloc/bloc.dart';
import 'package:flutter_infinite_list/post.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  // TODO: implement initialState
  PostState get initialState => null;

  @override
  Stream<PostState> mapEventToState(PostEvent event) async* {
    // TODO: implement mapEventToState
    yield null;
  }
}
```

?> **Note:** À partir de la déclaration de classe nous pouvons dire que notre PostBloc prendra PostEvents comme entrée et des PostStates en sortie.

Nous pouvons commencer par implémenter `initialState` qui sera l'état de notre `PostBloc` avant que les événements n'aient été envoyés.

```dart
@override
get initialState => PostUninitialized();
```

Ensuite, nous devons implémenter `mapEventToState` qui sera lancé chaque fois qu'un `PostEvent` est envoyé.

```dart
@override
Stream<PostState> mapEventToState(PostEvent event) async* {
  if (event is Fetch && !_hasReachedMax(currentState)) {
    try {
      if (currentState is PostUninitialized) {
        final posts = await _fetchPosts(0, 20);
        yield PostLoaded(posts: posts, hasReachedMax: false);
        return;
      }
      if (currentState is PostLoaded) {
        final posts =
            await _fetchPosts((currentState as PostLoaded).posts.length, 20);
        yield posts.isEmpty
            ? (currentState as PostLoaded).copyWith(hasReachedMax: true)
            : PostLoaded(
                posts: (currentState as PostLoaded).posts + posts,
                hasReachedMax: false,
              );
      }
    } catch (_) {
      yield PostError();
    }
  }
}

bool _hasReachedMax(PostState state) =>
    state is PostLoaded && state.hasReachedMax;

Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
  final response = await httpClient.get(
      'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List;
    return data.map((rawPost) {
      return Post(
        id: rawPost['id'],
        title: rawPost['title'],
        body: rawPost['body'],
      );
    }).toList();
  } else {
    throw Exception('error fetching posts');
  }
}
```

Notre `PostBloc` cède à chaque fois qu'il y a un nouvel état car il retourne un `Stream<PostState>`. Consultez [concepts de base] (https://felangel.github.io/bloc/#/coreconcepts?id=streams) pour plus d'informations sur `Streams` et d'autres concepts de base.

Maintenant, chaque fois qu'un `PostEvent` est envoyé, s'il s'agit d'un événement `Fetch` et qu'il y a plus de messages à récupérer, notre `PostBloc` ira chercher les 20 messages suivants.

L'API retournera un tableau vide si nous essayons de récupérer au-delà du nombre maximum de messages (100), donc si nous récupérons un tableau vide, notre bloc retournera `yield` l'état courant sauf que nous mettrons `hasReachedMax` à true.

Si nous ne pouvons pas récupérer les messages, nous lançons une exception et `yield` `PostError()`.

Si nous pouvons récupérer les messages, nous retournons `PostLoaded()` qui prend la liste complète des messages.

Une optimisation que nous pouvons faire est de `rebondir` les `Events` afin d'éviter le spamming de notre API inutilement. Nous pouvons le faire en surchargeant la méthode `transform` dans notre `PostBloc`.

?> **Note:** Surpasser transform nous permet de transformer le Stream<Event> avant que mapEventToState ne soit appelé. Ceci permet d'appliquer des opérations comme distinct(), debounceTime(), etc......
```dart
@override
Stream<PostState> transformEvents(
  Stream<PostEvent> events,
  Stream<PostState> Function(PostEvent event) next,
) {
  return super.transformEvents(
    (events as Observable<PostEvent>).debounceTime(
      Duration(milliseconds: 500),
    ),
    next,
  );
}
```

Notre `PostBloc` fini devrait maintenant ressembler à ceci :

```dart
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';

import 'package:flutter_infinite_list/post.dart';
import 'package:flutter_infinite_list/bloc/bloc.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final http.Client httpClient;

  PostBloc({@required this.httpClient});

  @override
  Stream<PostState> transformEvents(
    Stream<PostEvent> events,
    Stream<PostState> Function(PostEvent event) next,
  ) {
    return super.transformEvents(
      (events as Observable<PostEvent>).debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(event) async* {
    if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is PostUninitialized) {
          final posts = await _fetchPosts(0, 20);
          yield PostLoaded(posts: posts, hasReachedMax: false);
        }
        if (currentState is PostLoaded) {
          final posts = await _fetchPosts(currentState.posts.length, 20);
          yield posts.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : PostLoaded(
                  posts: currentState.posts + posts, hasReachedMax: false);
        }
      } catch (_) {
        yield PostError();
      }
    }
  }

  bool _hasReachedMax(PostState state) =>
      state is PostLoaded && state.hasReachedMax;

  Future<List<Post>> _fetchPosts(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawPost) {
        return Post(
          id: rawPost['id'],
          title: rawPost['title'],
          body: rawPost['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching posts');
    }
  }
}
```

N'oubliez pas de mettre à jour `bloc/bloc.dart` pour inclure notre `PostBloc` !

```dart
export './post_bloc.dart';
export './post_event.dart';
export './post_state.dart';
```

Super ! Maintenant que nous avons fini d'implémenter la logique métier, il ne nous reste plus qu'à implémenter la couche de présentation.

## Couche de présentation

Dans notre `main.dart` nous pouvons commencer par implémenter notre fonction principale et appeler `runApp` pour rendre notre widget racine.

Dans notre widget `App`, nous utilisons `BlocProvider` pour créer et fournir une instance de `PostBloc` au sous-arbre. De plus, nous envoyons un événement `Fetch` pour que lorsque l'application se charge, elle demande le lot initial de messages.
```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_infinite_list/bloc/bloc.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Infinite Scroll',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Posts'),
        ),
        body: BlocProvider(
          builder: (context) =>
              PostBloc(httpClient: http.Client())..dispatch(Fetch()),
          child: HomePage(),
        ),
      ),
    );
  }
}
```

Ensuite, nous devons implémenter notre widget `HomePage` qui présentera nos messages et se connectera à notre `PostBloc`.

```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;
  PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _postBloc = BlocProvider.of<PostBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostBloc, PostState>(
      builder: (context, state) {
        if (state is PostUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is PostError) {
          return Center(
            child: Text('failed to fetch posts'),
          );
        }
        if (state is PostLoaded) {
          if (state.posts.isEmpty) {
            return Center(
              child: Text('no posts'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.posts.length
                  ? BottomLoader()
                  : PostWidget(post: state.posts[index]);
            },
            itemCount: state.hasReachedMax
                ? state.posts.length
                : state.posts.length + 1,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _postBloc.dispatch(Fetch());
    }
  }
}
```

?> HomePage est un `StatefulWidget` parce qu'il devra maintenir un `ScrollController`. Dans `initState`, nous ajoutons un auditeur à notre `ScrollController` afin de pouvoir répondre aux événements de défilement. Nous accédons également à notre instance `PostBloc` via `BlocProvider.of<PostBloc>(contexte)`.

Notre méthode de compilation retourne un `BlocBuilder`. `BlocBuilder` est un widget Flutter du paquet [flutter_bloc](https://pub.dev/packages/flutter_bloc) qui gère la construction d'un widget en réponse aux nouveaux états de bloc. Chaque fois que notre état `PostBloc` change, notre fonction constructeur sera appelée avec le nouveau `PostState`.

!> Nous devons nous rappeler de bien nettoyer derrière nous et de nous débarrasser de notre `ScrollController` quand le StatefulWidget est disposé.

Chaque fois que l'utilisateur fait défiler, nous calculons à quelle distance du bas de la page il se trouve et si la distance est ≤ notre `_scrollThreshold` nous envoyons un événement `Fetch` afin de charger plus de messages.

Ensuite, nous devons implémenter notre widget `BottomLoader' qui indiquera à l'utilisateur que nous chargeons plus de messages.

```dart
class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}
```

Enfin, nous devons implémenter notre `PostWidget` qui rendra un message individuel.

```dart
class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({Key key, @required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: TextStyle(fontSize: 10.0),
      ),
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(post.body),
      dense: true,
    );
  }
}
```

À ce stade, nous devrions être en mesure d'exécuter notre application et tout devrait fonctionner ; cependant, il y a encore une chose que nous pouvons faire.

Un avantage supplémentaire de l'utilisation de la bibliothèque de blocs est que nous pouvons avoir accès à toutes les `Transitions` dans un seul endroit.

> Le passage d'un état à un autre s'appelle une `Transition`.

?> Une `Transition` se compose de l'état courant, de l'événement et de l'état suivant.

Même si dans cette application nous n'avons qu'un seul bloc, il est assez courant dans les applications plus grandes d'avoir plusieurs blocs gérant différentes parties de l'état de l'application.

Si nous voulons pouvoir faire quelque chose en réponse à toutes les `Transitions`, nous pouvons simplement créer notre propre ` BlocsDelegate`.
```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> Tout ce que nous avons à faire est d'étendre `BlocDelegate` et de remplacer la méthode `onTransition`.

Pour dire à Bloc d'utiliser notre `SimpleBlocDelegate`, il nous suffit d'ajuster notre fonction principale.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}
```

Maintenant, lorsque nous exécutons notre application, chaque fois qu'un Bloc `Transition` se produit, nous pouvons voir la transition imprimée sur la console.

?> En pratique, vous pouvez créer différents `BlocDelegates` et parce que chaque changement d'état est enregistré, nous sommes capables d'instrumenter très facilement nos applications et de suivre toutes les interactions utilisateur et les changements d'état en un seul endroit !

C'est tout ce qu'il y a à faire ! Nous avons maintenant implémenté avec succès une liste infinie dans Flutter en utilisant les paquets [bloc](https://pub.dev/packages/bloc) et [flutter_bloc](https://pub.dev/packages/flutter_bloc) et nous avons réussi à séparer notre couche de présentation de notre logique métier.

Notre page d'accueil n'a aucune idée d'où viennent les `Posts` ou comment ils sont récupérés. Inversement, notre `PostBloc` n'a aucune idée de la façon dont le `State` est rendu, il convertit simplement les événements en états.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
