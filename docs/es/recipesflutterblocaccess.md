# Recetas: Acceso al bloc

> En esta receta, vamos a ver cómo usar `BlocProvider` para hacer que un bloc sea accesible en todo el árbol de widgets. Vamos a explorar tres escenarios: acceso local, acceso a ruta y acceso global.

## Acceso local

> En este ejemplo, vamos a usar `BlocProvider` para hacer que un bloc esté disponible para un subárbol local. En este contexto, local significa dentro de un contexto donde no hay rutas pushed(insertadas)/popped(sacadas).

### Bloc

Por motivo de simplicidad, vamos a utilizar un `Counter` (contador) como nuestra aplicación de ejemplo.

Nuestra implementación de `CounterBloc` se verá así:

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Vamos a tener 3 partes en nuestra interfaz de usuario:

- App: el widget de la aplicación raíz
- CounterPage: el widget de contenedor que gestionará el `CounterBloc` y expone los `FloatingActionButtons` a `increment` (incrementar) y `decrement` (decrementar) el counter.
- CounterText: un widget de texto que se encarga de mostrar el `count` (conteo) actual.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/local_access/main.dart.md ':include')

Nuestro widget `App` es un `StatelessWidget` que utiliza una `MaterialApp` y establece nuestra `CounterPage` como el widget de inicio. El widget `App` es responsable de crear y cerrar el `CounterBloc`, así como de ponerlo a disposición del `CounterPage` utilizando un `BlocProvider`.

?> **Nota:** Cuando envolvemos un widget con `BlocProvider`, podemos proporcionar un bloc a todos los widgets dentro de ese subárbol. En este caso, podemos acceder al `CounterBloc` desde el widget `CounterPage` y a cualquier elemento secundario del widget `CounterPage` usando `BlocProvider.of<CounterBloc>(context)`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_page.dart.md ':include')

El widget `CounterPage` es un `StatelessWidget` que accede al `CounterBloc` a través del `BuildContext`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/local_access/counter_text.dart.md ':include')

Nuestro widget `CounterText` está utilizando un `BlocBuilder` para reconstruirse cada vez que cambia el estado de `CounterBloc`. Utilizamos `BlocProvider.of<CounterBloc>(context)` para acceder al `CounterBloc` proporcionado y devolver un widget `Text` con el conteo actual.

Eso envuelve la porción de acceso al bloc local de esta receta y el código fuente completo se puede encontrar [aquí](https://gist.github.com/felangel/20b03abfef694c00038a4ffbcc788c35).

A continuación, veremos cómo proporcionar un bloc en varias páginas/rutas.

## Acceso anónimo a la ruta

> En este ejemplo, vamos a usar `BlocProvider` para acceder a un bloc a través de las rutas. Cuando se empuja/inserta una nueva ruta, tendrá un `BuildContext` diferente que ya no tiene una referencia a los blocs proporcionados anteriormente. Como resultado, tenemos que envolver la nueva ruta en un `BlocProvider` separado.

### Bloc

Nuevamente, vamos a usar el `CounterBloc` por simplicidad.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Nuevamente, vamos a tener tres partes en la interfaz de usuario de nuestra aplicación:

- App: el widget de la aplicación raíz
- HomePage: el widget contenedor que gestionará el `CounterBloc` y expone los `FloatingActionButtons` a `increment` (incrementar) y `decrement` (decrementar) el contador.
- CounterPage: un widget que se encarga de mostrar el `count` (conteo) actual como una ruta separada.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/main.dart.md ':include')

Nuevamente, nuestro widget `App` es el mismo que antes.

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/home_page.dart.md ':include')

El `HomePage` es similar al `CounterPage` del ejemplo anterior; sin embargo, en lugar de representar un widget `CounterText`, muestra un `ElevatedButton` en el centro que permite al usuario navegar a una nueva pantalla que muestra el conteo actual.

Cuando el usuario toca el `ElevatedButton`, empujamos/insertamos un nuevo `MaterialPageRoute` y devolvemos el `CounterPage`; sin embargo, estamos envolviendo el `CounterPage` en un `BlocProvider` para que la instancia actual de `CounterBloc` esté disponible en la página siguiente.

!> Es crítico que estemos usando el constructor de valores `BlocProvider` en este caso porque estamos proporcionando una instancia existente de `CounterBloc`. El constructor de valor de `BlocProvider` debe usarse solo en los casos en que deseamos proporcionar un bloc existente a un nuevo subárbol. Además, el uso del constructor de valores no cerrará el bloc automáticamente, lo que, en este caso, es lo que queremos (ya que todavía necesitamos el `CounterBloc` para funcionar en los widgets ancestrales). En cambio, simplemente pasamos el `CounterBloc` existente a la nueva página como un valor existente en lugar de en un generador. Esto garantiza que el único nivel superior `BlocProvider` maneje el cierre del `CounterBloc` cuando ya no sea necesario.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/anonymous_route_access/counter_page.dart.md ':include')

`CounterPage` es un `StatelessWidget` súper simple que usa `BlocBuilder` para volver a representar un widget `Text` con el conteo actual. Al igual que antes, podemos usar `BlocProvider.of<CounterBloc>(context)` para acceder al `CounterBloc`.

Eso es todo lo que hay en este ejemplo y la fuente completa se puede encontrar [aquí](https://gist.github.com/felangel/92b256270c5567210285526a07b4cf21).

A continuación, veremos cómo abarcar un bloc a solo una o más rutas con nombre.

## Acceso a la ruta con nombre

> En este ejemplo, vamos a usar `BlocProvider` para acceder a un bloc a través de múltiples rutas con nombre. Cuando se empuja/inserta una nueva ruta con nombre, tendrá un `BuildContext` diferente (al igual que antes) que ya no tiene una referencia a los blocs proporcionados anteriormente. En este caso, vamos a administrar los blocs que queremos abarcar en el widget principal y proporcionarlos selectivamente a las rutas que deberían tener acceso.

### Bloc

Nuevamente, vamos a usar el `CounterBloc` por simplicidad.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Nuevamente, vamos a tener tres partes en la interfaz de usuario de nuestra aplicación:

- App: el widget de la aplicación raíz que gestiona el `CounterBloc` y lo proporciona a las rutas con nombre apropiadas.
- HomePage: el widget de contenedor que accede a `CounterBloc` y expone `FloatingActionButtons` a `increment` (incrementar) y `decrement` (decrementar) el contador.
- CounterPage: un widget que se encarga de mostrar el `count` (conteo) actual como una ruta separada.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/main.dart.md ':include')

Nuestro widget `App` es responsable de administrar la instancia del `CounterBloc` que proporcionaremos a las rutas raíz (`/`) y counter (`/counter`).

!> Es fundamental comprender que, dado que `_AppState` está creando la instancia de `CounterBloc`, también debería cerrarla en la anulación `dispose`.

!> Estamos usando `BlocProvider.value` cuando proporcionamos la instancia de `CounterBloc` a las rutas porque no queremos que `BlocProvider` se encargue de eliminar el bloc (ya que `_AppState` es responsable de eso).

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/home_page.dart.md ':include')

El `HomePage` es similar al ejemplo anterior; sin embargo, cuando el usuario toca el `ElevatedButton`, empujamos/insertamos una nueva ruta con nombre para navegar a la ruta `/counter` que definimos anteriormente.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/named_route_access/counter_page.dart.md ':include')

`CounterPage` es un `StatelessWidget` súper simple que usa `BlocBuilder` para volver a representar un widget `Text` con el conteo actual. Al igual que antes, podemos usar `BlocProvider.of<CounterBloc>(context)` para acceder al `CounterBloc`.

Eso es todo lo que hay en este ejemplo y la fuente completa se puede encontrar [aquí](https://gist.github.com/felangel/8d143cf3b7da38d80de4bcc6f65e9831).

A continuación, veremos cómo crear un `Router` para administrar y abarcar un bloc a solo una o más rutas generadas.

## Acceso a ruta generada

> En este ejemplo, crearemos un `Router` y utilizaremos `BlocProvider` para acceder a un bloc a través de múltiples rutas generadas. Vamos a gestionar los bloc que deseamos abarcar en el `Router` y proporcionarlos selectivamente a las rutas que deberían tener acceso.

### Bloc

Nuevamente, vamos a usar el `CounterBloc` por simplicidad.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Nuevamente, vamos a tener tres partes en la interfaz de usuario de nuestra aplicación, pero también vamos a agregar un `AppRouter`:

- App: el widget de la aplicación raíz que gestiona el `AppRouter`.
- AppRouter: clase que gestionará y proporcionará el `CounterBloc` a las rutas generadas apropiadas.
- HomePage: el widget de contenedor que accede a `CounterBloc` y expone `FloatingActionButtons` a `increment` (incrementar) y `decrement` (decrementar) del contador.
- CounterPage: un widget que se encarga de mostrar el `count` (conteo) actual como una ruta separada.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/main.dart.md ':include')

Nuestro widget `App` es responsable de administrar la instancia del `AppRouter` y utiliza el router del `onGenerateRoute` para determinar la ruta actual.

!> Necesitamos desechar el `_router` cuando el widget `App` está dispuesto para cerrar todos los blocs en el `AppRouter`.

#### App Router

[app_router.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/app_router.dart.md ':include')

Nuestro `AppRouter` es responsable de gestionar la instancia del `CounterBloc` y proporciona `onGenerateRoute` que devuelve la ruta correcta en función de los `RouteSettings` proporcionados.

!> Dado que `AppRouter` crea la instancia de `CounterBloc`, también debe exponer un `dispose` que `cierra` la instancia de `CounterBloc`. `dispose` se llama desde la anulación `dispose` del widget `_AppState`.

!> Estamos usando `BlocProvider.value` cuando proporcionamos la instancia de `CounterBloc` a las rutas porque no queremos que `BlocProvider` se encargue de eliminar el bloc (ya que `AppRouter` es responsable de eso).

#### HomePage

[home_page.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/home_page.dart.md ':include')

La `HomePage` es idéntica al ejemplo anterior. Cuando el usuario toca el `ElevatedButton`, empujamos/insertamos una nueva ruta con nombre para navegar a la ruta `/counter` que definimos anteriormente.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/generated_route_access/counter_page.dart.md ':include')

`CounterPage` es un `StatelessWidget` súper simple que usa `BlocBuilder` para volver a representar un widget `Text` con el conteo actual. Al igual que antes, podemos usar `BlocProvider.of<CounterBloc>(context)` para acceder al `CounterBloc`.

Eso es todo lo que hay en este ejemplo y la fuente completa se puede encontrar [aquí](https://gist.github.com/felangel/354f9499dc4573699c62fc90c6bb314e).

Por último, veremos cómo hacer que un bloc que esté disponible globalmente para el árbol de widgets.

## Acceso global

> En este último ejemplo, vamos a demostrar cómo hacer que una instancia de bloc esté disponible para todo el árbol de widgets. Esto es útil para casos específicos como un `AuthenticationBloc` o `ThemeBloc` porque ese estado se aplica a todas las partes de la aplicación.

### Bloc

Como de costumbre, vamos a usar el `CounterBloc` como nuestro ejemplo de simplicidad.

[counter_bloc.dart](../_snippets/recipes_flutter_bloc_access/counter_bloc.dart.md ':include')

### UI

Vamos a seguir la misma estructura de aplicación que en el ejemplo de "Acceso local". Como resultado, vamos a tener tres partes en nuestra interfaz de usuario:

- App: el widget de la aplicación raíz que gestiona la instancia global de nuestro `CounterBloc`.
- CounterPage: el widget contenedor que expone `FloatingActionButtons` a `increment` (incrementar) y `decrement` (decrementar) el contador.
- CounterText: un widget de texto que se encarga de mostrar el `count` (conteo) actual.

#### App

[main.dart](../_snippets/recipes_flutter_bloc_access/global_access/main.dart.md ':include')

Al igual que en el ejemplo de acceso local anterior, la `App` administra la creación, el cierre y la provisión de `CounterBloc` al subárbol usando `BlocProvider`. La principal diferencia es en este caso, `MaterialApp` es un hijo de `BlocProvider`.

Envolver todo el `MaterialApp` en un `BlocProvider` es la clave para hacer que nuestra instancia de `CounterBloc` sea accesible globalmente. Ahora podemos acceder a nuestro `CounterBloc` desde cualquier lugar de nuestra aplicación donde tengamos un `BuildContext` usando `BlocProvider.of<CounterBloc>(context);`

?> **Nota:** Este enfoque aún funciona si está utilizando una `CupertinoApp` o `WidgetsApp`.

#### CounterPage

[counter_page.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_page.dart.md ':include')

Nuestro `CounterPage` es un `StatelessWidget` porque no necesita administrar ninguno de sus propios estados. Tal como mencionamos anteriormente, utiliza `BlocProvider.of<CounterBloc>(context)` para acceder a la instancia global de `CounterBloc`.

#### CounterText

[counter_text.dart](../_snippets/recipes_flutter_bloc_access/global_access/counter_text.dart.md ':include')

Nada nuevo aquí; El widget `CounterText` es el mismo que en el primer ejemplo. Es solo un `StatelessWidget` que usa un `BlocBuilder` para volver a renderizar cuando el estado de `CounterBloc` cambia y accede a la instancia global de `CounterBloc` usando `BlocProvider.of<CounterBloc>(context)`.

¡Eso es todo al respecto! La fuente completa se puede encontrar [aquí](https://gist.github.com/felangel/be891e73a7c91cdec9e7d5f035a61d5d).
