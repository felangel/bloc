# Flutter: Tutorial de Lista Infinita

![intermediate](https://img.shields.io/badge/nivel-intermedio-orange)

> En este tutorial, implementaremos una aplicación que obtiene datos a través de la red y los carga a medida que el usuario se desplaza utilizando Flutter y la biblioteca de bloc.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto Flutter

```sh
flutter create flutter_infinite_list
```

Luego podemos continuar y reemplazar el contenido de pubspec.yaml con

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/pubspec.yaml ':include')

y luego instalar todas nuestras dependencias

```sh
flutter pub get
```

## REST API

Para esta aplicación de demostración, utilizaremos [jsonplaceholder](http://jsonplaceholder.typicode.com) como nuestra fuente de datos.

?> jsonplaceholder es una REST API en línea que sirve datos falsos; Es muy útil para construir prototipos.

Abra una nueva pestaña en su navegador y visite https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2 para ver qué devuelve el API.

[posts.json](../_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **Nota:** en nuestra url especificamos el inicio y el límite como parámetros de consulta a la solicitud GET.

Genial, ahora que sabemos cómo se verán nuestros datos, creemos el modelo.

## Modelo

Cree `post.dart` y comencemos a crear el modelo de nuestro objeto Post.

[post.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/models/post.dart ':include')

`Post` es solo una clase con un` id`, `title` y` body`.

?> Anulamos la función `toString` para tener una representación de cadena personalizada de nuestro `Post` para más adelante.

?> Extendemos [`Equatable`](https://pub.dev/packages/equatable) para que podamos comparar `Posts`; de forma predeterminada, el operador de igualdad devuelve verdadero si y solo si, esta y la otra son la misma instancia.

Ahora que tenemos nuestro modelo de objeto `Post`, comencemos a trabajar en el Componente Lógico de Negocios (bloc).

## Post Events

Antes de sumergirnos en la implementación, debemos definir qué hará nuestro `PostBloc`.

En un nivel alto, responderá a la entrada del usuario (deslizar) y buscará más publicaciones para que la capa de presentación las muestre. Comencemos creando nuestro `Event`.

Nuestro `PostBloc` solo responderá a un solo evento; `PostFetched` que será agregado por la capa de presentación cada vez que necesite más publicaciones para presentar. Dado que nuestro evento `PostFetched` es un tipo de `PostEvent` podemos crear `bloc/post_event.dart` e implementar el evento así.

[post_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_event.dart ':include')

En resumen, nuestro `PostBloc` recibirá `PostEvents` y los convertirá en `PostStates`. Hemos definido todos nuestros `PostEvents` (PostFetched), así que a continuación definamos nuestro` PostState`.

## Post States

Nuestra capa de presentación necesitará tener varias piezas de información para poder presentarse correctamente:

- `PostInitial`- le dirá a la capa de presentación que necesita presentar un indicador de carga mientras se carga el lote inicial de publicaciones

- `PostSuccess`- le dirá a la capa de presentación que tiene contenido para representar
  - `posts`- será la `Lista <Post>` que se mostrará
  - `hasReachedMax`- le dirá a la capa de presentación si ha alcanzado o no el número máximo de publicaciones
- `PostFailure`- le dirá a la capa de presentación que se ha producido un error al buscar publicaciones

Ahora podemos crear `bloc/post_state.dart` e implementarlo así.

[post_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_state.dart ':include')

?> Implementamos `copyWith` para que podamos copiar una instancia de `PostSuccess` y actualizar cero o más propiedades convenientemente (esto será útil más adelante).

Ahora que tenemos implementados nuestros `Eventos` y `Estados`, podemos crear nuestro `PostBloc`.


## Post Bloc

Por simplicidad, nuestro `PostBloc` tendrá una dependencia directa de un `cliente http`; sin embargo, en una aplicación de producción, es posible que desee inyectar un cliente api y usar el patrón de repositorio [docs](./architecture.md).

Creemos `post_bloc.dart` y creemos nuestro `PostBloc` vacío.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **Nota:** solo a partir de la declaración de la clase podemos decir que nuestro PostBloc tomará PostEvents como entrada y como salida PostStates.

A continuación, necesitamos implementar `on<PostFetched>` que se disparará cada vez que se agregue un `PostEvent`.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_on_post_fetched.dart.md ':include')

Nuestro `PostBloc` hará `yield` siempre que haya un nuevo estado porque devuelve un `Stream<PostState>`. Consulte [conceptos básicos](https://bloclibrary.dev/#/es/coreconcepts?id=streams) para obtener más información sobre `Streams` y otros conceptos básicos.

Ahora, cada vez que se agrega un `PostEvent`, si es un evento `PostFetched` y hay más publicaciones para buscar, nuestro `PostBloc` buscará las próximas 20 publicaciones.

La API devolverá una matriz vacía si intentamos obtener más allá del número máximo de publicaciones (100), por lo que si recuperamos una matriz vacía, nuestro bloc hará `yield` al estado actual, excepto que estableceremos `hasReachedMax` en verdadero.

Si no podemos recuperar las publicaciones, lanzamos una excepción y hacemos `yield` al `PostFailure()`.

Si podemos recuperar las publicaciones, devolvemos `PostSuccess()` que toma la lista completa de publicaciones.

Una optimización que podemos hacer es `rebotar` los `Eventos` para evitar spam innecesariamente en nuestra API. Podemos hacer esto anulando el método `transform` en nuestro` PostBloc`.

?> **Nota:** La transformación de anulación nos permite transformar el Stream<Event> antes de llamar a `on<PostFetched>`. Esto permite que se apliquen operaciones como distinct(), debounceTime(), etc.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_transformer.dart.md ':include')

Nuestro `PostBloc` terminado debería verse así:

[post_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_bloc.dart ':include')

¡No olvide actualizar `bloc/bloc.dart` para incluir nuestro` PostBloc`!

[post_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/bloc/post_bloc.dart ':include')

¡Excelente! Ahora que hemos terminado de implementar la lógica de negocios, todo lo que queda por hacer es implementar la capa de presentación.

## Capa de presentación

En nuestro `main.dart` podemos comenzar implementando nuestra función principal y llamando a` runApp` para representar nuestro widget raíz.

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/main.dart ':include')

En nuestro widget `App`, usamos `BlocProvider` para crear y proporcionar una instancia de `PostBloc` al subárbol. Además, agregamos un evento `PostFetched` para que cuando se cargue la aplicación, solicite el lote inicial de publicaciones.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/app.dart ':include')

En nuestro `PostsPage`widget usamos `BlocProvider` para crear una instancia de `PostBloc` el sub-árbol. Añadimos el evento `PostFetched` para cargar los primeros Posts cuando la app comience.


[posts_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/view/posts_page.dart ':include')

Implementamos la vista de `PostsList` que mostrará los posts de nuestro `PostBloc`

[posts_list.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/view/posts_list.dart ':include')

?> `PostsList` es un` StatefulWidget` porque necesitará mantener un `ScrollController`. En `initState`, agregamos un oyente a nuestro `ScrollController` para que podamos responder a los eventos de desplazamiento. También accedemos a nuestra instancia de `PostBloc` a través de `context.read<PostBloc>()`.

Avanzando, nuestro método de construcción que retorna un `BlocBuilder`. `BlocBuilder` es un widget de Flutter del [paquete flutter_bloc](https://pub.dev/packages/flutter_bloc) que maneja la construcción de un widget en respuesta a los nuevos estados de bloque. Cada vez que cambie nuestro estado `PostBloc`, se llamará a nuestra función de creación con el nuevo `PostState`.

!> Debemos recordar limpiar después de nosotros mismos y desechar nuestro `ScrollController` cuando se elimine el StatefulWidget.

Cada vez que el usuario se desplaza, calculamos qué tan lejos están de la parte inferior de la página y si la distancia es ≤ nuestro `_scrollThreshold` le agregamos un event `PostFetched` para cargar más publicaciones.

A continuación, necesitamos implementar nuestro widget `Bottom Loader` que le indicará al usuario que estamos cargando más publicaciones.

[bottom_loader.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/widgets/bottom_loader.dart ':include')

Por último, necesitamos implementar nuestro `PostListItem` que representará una publicación individual.

[post_list_item.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/posts/widgets/post_list_item.dart ':include')

En este punto, deberíamos poder ejecutar nuestra aplicación y todo debería funcionar; Sin embargo, hay una cosa más que podemos hacer.

Una ventaja adicional de usar la librería de bloc es que podemos tener acceso a todas las `Transiciones` en un solo lugar.

> El cambio de un estado a otro se llama `Transición`.

?> Una `Transición` consiste en el estado actual, el evento y el siguiente estado.

Aunque en esta aplicación solo tenemos un bloque, es bastante común en aplicaciones más grandes tener muchos bloques que manejen diferentes partes del estado de la aplicación.

Si queremos poder hacer algo en respuesta a todas las `Transiciones`, simplemente podemos crear nuestro propio `BlocObserver`.

[simple_bloc_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_infinite_list/lib/simple_bloc_observer.dart ':include')

?> Todo lo que necesitamos hacer es extender `BlocObserver` y anular el método `onTransition`.

Para decirle a Bloc que use nuestro `SimpleBlocObserver`, solo necesitamos ajustar nuestra función principal.

Ahora, cuando ejecutamos nuestra aplicación, cada vez que se produce un Bloc 'Transition' podemos ver la transición impresa en la consola.

?> En práctica, puedes crear diferentes `BlocObservers` y, dado que se registran todos los cambios de estado, ¡podemos instrumentar fácilmente nuestras aplicaciones y rastrear todas las interacciones del usuario y los cambios de estado en un solo lugar!

¡Eso es todo al respecto! Ahora hemos implementado con éxito una lista infinita en flutter usando los paquetes [bloc](https://pub.dev/packages/bloc) y [flutter_bloc](https://pub.dev/packages/flutter_bloc) y nosotros hemos separado con éxito nuestra capa de presentación de nuestra lógica de negocios.

Nuestro `HomePage` no tiene idea de dónde provienen las `Posts` o cómo se están recuperando. Por el contrario, nuestro `PostBloc` no tiene idea de cómo se representa el `Estado`, simplemente convierte los eventos en estados.

La fuente completa para este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
