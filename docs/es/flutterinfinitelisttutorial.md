# Flutter: Tutorial de Lista Infinita

![intermediate](https://img.shields.io/badge/nivel-intermedio-orange)

> En este tutorial, implementaremos una aplicación que obtiene datos a través de la red y los carga a medida que el usuario se desplaza utilizando Flutter y la biblioteca de bloc.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto Flutter

```bash
flutter create flutter_infinite_list
```

Luego podemos continuar y reemplazar el contenido de pubspec.yaml con

```yaml
name: flutter_infinite_list
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  http: ^0.12.0
  equatable: ^1.0.0

flutter:
  uses-material-design: true
```

y luego instalar todas nuestras dependencias

```bash
flutter packages get
```

## REST API

Para esta aplicación de demostración, utilizaremos [jsonplaceholder](http://jsonplaceholder.typicode.com) como nuestra fuente de datos.

?> jsonplaceholder es una REST API en línea que sirve datos falsos; Es muy útil para construir prototipos.

Abra una nueva pestaña en su navegador y visite https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 para ver qué devuelve el API.

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

?> **Nota:** en nuestra url especificamos el inicio y el límite como parámetros de consulta a la solicitud GET.

Genial, ahora que sabemos cómo se verán nuestros datos, creemos el modelo.

## Modelo

Cree `post.dart` y comencemos a crear el modelo de nuestro objeto Post.

```dart
import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;

  const Post({this.id, this.title, this.body});

  @override
  List<Object> get props => [id, title, body];

  @override
  String toString() => 'Post { id: $id }';
}
```

`Post` es solo una clase con un` id`, `title` y` body`.

?> Anulamos la función `toString` para tener una representación de cadena personalizada de nuestro `Post` para más adelante.

?> Extendemos [`Equatable`](https://pub.dev/packages/equatable) para que podamos comparar `Posts`; de forma predeterminada, el operador de igualdad devuelve verdadero si y solo si, esta y la otra son la misma instancia.

Ahora que tenemos nuestro modelo de objeto `Post`, comencemos a trabajar en el Componente Lógico de Negocios (bloc).

## Post Events

Antes de sumergirnos en la implementación, debemos definir qué hará nuestro `PostBloc`.

En un nivel alto, responderá a la entrada del usuario (deslizar) y buscará más publicaciones para que la capa de presentación las muestre. Comencemos creando nuestro `Event`.

Nuestro `PostBloc` solo responderá a un solo evento; `Fetch` que será agregado por la capa de presentación cada vez que necesite más publicaciones para presentar. Dado que nuestro evento `Fetch` es un tipo de `PostEvent` podemos crear `bloc/post_event.dart` e implementar el evento así.

```dart
import 'package:equatable/equatable.dart';

abstract class PostEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch extends PostEvent {}
```

?> Nuevamente, estamos anulando `toString` para una representación de cadena String más fácil de leer de nuestro evento. Nuevamente, estamos extendiendo [`Equatable`](https://pub.dev/packages/equatable) para que podamos comparar instancias para la igualdad.

En resumen, nuestro `PostBloc` recibirá `PostEvents` y los convertirá en `PostStates`. Hemos definido todos nuestros `PostEvents` (Fetch), así que a continuación definamos nuestro` PostState`.

## Post States

Nuestra capa de presentación necesitará tener varias piezas de información para poder presentarse correctamente:

- `PostUninitialized`- le dirá a la capa de presentación que necesita presentar un indicador de carga mientras se carga el lote inicial de publicaciones

- `PostLoaded`- le dirá a la capa de presentación que tiene contenido para representar
  - `posts`- será la `Lista <Post>` que se mostrará
  - `hasReachedMax`- le dirá a la capa de presentación si ha alcanzado o no el número máximo de publicaciones
- `PostError`- le dirá a la capa de presentación que se ha producido un error al buscar publicaciones

Ahora podemos crear `bloc/post_state.dart` e implementarlo así.

```dart
import 'package:equatable/equatable.dart';

import 'package:flutter_infinite_list/models/models.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostUninitialized extends PostState {}

class PostError extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  final bool hasReachedMax;

  const PostLoaded({
    this.posts,
    this.hasReachedMax,
  });

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
  List<Object> get props => [posts, hasReachedMax];

  @override
  String toString() =>
      'PostLoaded { posts: ${posts.length}, hasReachedMax: $hasReachedMax }';
}
```

?> Implementamos `copyWith` para que podamos copiar una instancia de `PostLoaded` y actualizar cero o más propiedades convenientemente (esto será útil más adelante).

Ahora que tenemos implementados nuestros `Eventos` y `Estados`, podemos crear nuestro `PostBloc`.

Para que sea conveniente importar nuestros estados y eventos con una sola importación, podemos crear `bloc/bloc.dart` que los exporta a todos (agregaremos nuestra exportación `post_bloc.dart` en la siguiente sección).

```dart
export './post_event.dart';
export './post_state.dart';
```

## Post Bloc

Por simplicidad, nuestro `PostBloc` tendrá una dependencia directa de un `cliente http`; sin embargo, en una aplicación de producción, es posible que desee inyectar un cliente api y usar el patrón de repositorio [docs](./architecture.md).

Creemos `post_bloc.dart` y creemos nuestro `PostBloc` vacío.

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

?> **Nota:** solo a partir de la declaración de la clase podemos decir que nuestro PostBloc tomará PostEvents como entrada y como salida PostStates.

Podemos comenzar implementando `initialState`, que será el estado de nuestro `PostBloc` antes de que se agregue cualquier evento.

```dart
@override
get initialState => PostUninitialized();
```

A continuación, necesitamos implementar `mapEventToState` que se disparará cada vez que se agregue un `PostEvent`.

```dart
@override
Stream<PostState> mapEventToState(PostEvent event) async* {
  final currentState = state;
  if (event is Fetch && !_hasReachedMax(currentState)) {
    try {
      if (currentState is PostUninitialized) {
        final posts = await _fetchPosts(0, 20);
        yield PostLoaded(posts: posts, hasReachedMax: false);
        return;
      }
      if (currentState is PostLoaded) {
        final posts =
            await _fetchPosts(currentState.posts.length, 20);
        yield posts.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : PostLoaded(
                posts: currentState.posts + posts,
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

Nuestro `PostBloc` hará `yield` siempre que haya un nuevo estado porque devuelve un `Stream<PostState>`. Consulte [conceptos básicos](https://bloclibrary.dev/#/es/coreconcepts?id=streams) para obtener más información sobre `Streams` y otros conceptos básicos.

Ahora, cada vez que se agrega un `PostEvent`, si es un evento `Fetch` y hay más publicaciones para buscar, nuestro `PostBloc` buscará las próximas 20 publicaciones.

La API devolverá una matriz vacía si intentamos obtener más allá del número máximo de publicaciones (100), por lo que si recuperamos una matriz vacía, nuestro bloc hará `yield` al estado actual, excepto que estableceremos `hasReachedMax` en verdadero.

Si no podemos recuperar las publicaciones, lanzamos una excepción y hacemos `yield` al `PostError()`.

Si podemos recuperar las publicaciones, devolvemos `PostLoaded()` que toma la lista completa de publicaciones.

Una optimización que podemos hacer es `rebotar` los `Eventos` para evitar spam innecesariamente en nuestra API. Podemos hacer esto anulando el método `transform` en nuestro` PostBloc`.

?> **Nota:** La transformación de anulación nos permite transformar el Stream<Event> antes de llamar a mapEventToState. Esto permite que se apliquen operaciones como distinct(), debounceTime(), etc.

```dart
@override
Stream<PostState> transformEvents(
  Stream<PostEvent> events,
  Stream<PostState> Function(PostEvent event) next,
) {
  return super.transformEvents(
    events.debounceTime(
      Duration(milliseconds: 500),
    ),
    next,
  );
}
```

Nuestro `PostBloc` terminado debería verse así:

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
      events.debounceTime(
        Duration(milliseconds: 500),
      ),
      next,
    );
  }

  @override
  get initialState => PostUninitialized();

  @override
  Stream<PostState> mapEventToState(event) async* {
    final currentState = state;
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

¡No olvide actualizar `bloc/bloc.dart` para incluir nuestro` PostBloc`!

```dart
export './post_bloc.dart';
export './post_event.dart';
export './post_state.dart';
```

¡Excelente! Ahora que hemos terminado de implementar la lógica de negocios, todo lo que queda por hacer es implementar la capa de presentación.

## Capa de presentación

En nuestro `main.dart` podemos comenzar implementando nuestra función principal y llamando a` runApp` para representar nuestro widget raíz.

En nuestro widget `App`, usamos `BlocProvider` para crear y proporcionar una instancia de `PostBloc` al subárbol. Además, agregamos un evento `Fetch` para que cuando se cargue la aplicación, solicite el lote inicial de publicaciones.

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
          create: (context) =>
              PostBloc(httpClient: http.Client())..add(Fetch()),
          child: HomePage(),
        ),
      ),
    );
  }
}
```

A continuación, necesitamos implementar nuestro widget `HomePage` que presentará nuestras publicaciones y se conectará a nuestro `PostBloc`.

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
      _postBloc.add(Fetch());
    }
  }
}
```

?> `HomePage` es un` StatefulWidget` porque necesitará mantener un `ScrollController`. En `initState`, agregamos un oyente a nuestro `ScrollController` para que podamos responder a los eventos de desplazamiento. También accedemos a nuestra instancia de `PostBloc` a través de `BlocProvider.of<PostBloc>(context) `.

Avanzando, nuestro método de construcción que retorna un `BlocBuilder`. `BlocBuilder` es un widget de Flutter del [paquete flutter_bloc](https://pub.dev/packages/flutter_bloc) que maneja la construcción de un widget en respuesta a los nuevos estados de bloque. Cada vez que cambie nuestro estado `PostBloc`, se llamará a nuestra función de creación con el nuevo `PostState`.

!> Debemos recordar limpiar después de nosotros mismos y desechar nuestro `ScrollController` cuando se elimine el StatefulWidget.

Cada vez que el usuario se desplaza, calculamos qué tan lejos están de la parte inferior de la página y si la distancia es ≤ nuestro `_scrollThreshold` le agregamos un event `Fetch` para cargar más publicaciones.

A continuación, necesitamos implementar nuestro widget `Bottom Loader` que le indicará al usuario que estamos cargando más publicaciones.

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

Por último, necesitamos implementar nuestro `PostWidget` que representará una publicación individual.

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

En este punto, deberíamos poder ejecutar nuestra aplicación y todo debería funcionar; Sin embargo, hay una cosa más que podemos hacer.

Una ventaja adicional de usar la librería de bloc es que podemos tener acceso a todas las `Transiciones` en un solo lugar.

> El cambio de un estado a otro se llama `Transición`.

?> Una `Transición` consiste en el estado actual, el evento y el siguiente estado.

Aunque en esta aplicación solo tenemos un bloque, es bastante común en aplicaciones más grandes tener muchos bloques que manejen diferentes partes del estado de la aplicación.

Si queremos poder hacer algo en respuesta a todas las `Transiciones`, simplemente podemos crear nuestro propio `BlocDelegate`.

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

?> Todo lo que necesitamos hacer es extender `BlocDelegate` y anular el método `onTransition`.

Para decirle a Bloc que use nuestro `SimpleBlocDelegate`, solo necesitamos ajustar nuestra función principal.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}
```

Ahora, cuando ejecutamos nuestra aplicación, cada vez que se produce un Bloc 'Transition' podemos ver la transición impresa en la consola.

?> En práctica, puedes crear diferentes `BlocDelegates` y, dado que se registran todos los cambios de estado, ¡podemos instrumentar fácilmente nuestras aplicaciones y rastrear todas las interacciones del usuario y los cambios de estado en un solo lugar!

¡Eso es todo al respecto! Ahora hemos implementado con éxito una lista infinita en flutter usando los paquetes [bloc](https://pub.dev/packages/bloc) y [flutter_bloc](https://pub.dev/packages/flutter_bloc) y nosotros hemos separado con éxito nuestra capa de presentación de nuestra lógica de negocios.

Nuestro `HomePage` no tiene idea de dónde provienen las `Posts` o cómo se están recuperando. Por el contrario, nuestro `PostBloc` no tiene idea de cómo se representa el `Estado`, simplemente convierte los eventos en estados.

La fuente completa para este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
