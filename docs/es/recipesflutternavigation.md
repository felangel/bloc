# Recetas: Navegación

> En esta receta, veremos cómo usar `BlocBuilder` y/o `BlocListener` para hacer la navegación. Vamos a explorar dos enfoques: navegación directa y navegación de ruta.

## Navegación directa

> En este ejemplo, veremos cómo usar `BlocBuilder` para mostrar una página específica (widget) en respuesta a un cambio de estado en un bloc sin el uso de una ruta.

![demo](../assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

Construyamos `MyBloc` que tomará `MyEvents` y los convertiremos en `MyStates`.

#### MyEvent

Para simplificar, nuestro `MyBloc` solo responderá a dos `MyEvents`: `eventA` y `eventB`.

[my_event.dart](../_snippets/recipes_flutter_navigation/my_event.dart.md ':include')

#### MyState

Nuestro `MyBloc` puede tener uno de dos diferentes `DataStates` (Estados de datos):
- `StateA` - el estado del bloc cuando se representa `PageA`.
- `StateB` - el estado del bloc cuando se representa `PageB`.

[my_state.dart](../_snippets/recipes_flutter_navigation/my_state.dart.md ':include')

#### MyBloc

Nuestro `MyBloc` debería verse así:

[my_bloc.dart](../_snippets/recipes_flutter_navigation/my_bloc.dart.md ':include')

### Capa del UI

Ahora echemos un vistazo a cómo conectar nuestro `MyBloc` a un widget y mostrar una página diferente según el estado del bloc.

[main.dart](../_snippets/recipes_flutter_navigation/direct_navigation/main.dart.md ':include')

?> Utilizamos el widget `BlocBuilder` para representar el widget correcto en respuesta a los cambios de estado en nuestro `MyBloc`.

?> Usamos el widget `BlocProvider` para que nuestra instancia de `MyBloc` esté disponible para todo el árbol de widgets.

La fuente completa de esta receta se puede encontrar [aquí](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09).

## Navegación de ruta

> En este ejemplo, veremos cómo usar `BlocListener` para navegar a una página específica (widget) en respuesta a un cambio de estado en un bloc usando una ruta.

![demo](../assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

Vamos a reutilizar el mismo `MyBloc` del ejemplo anterior.

### Capa del UI

Echemos un vistazo a cómo enrutar a una página diferente según el estado de `MyBloc`.

[main.dart](../_snippets/recipes_flutter_navigation/route_navigation/main.dart.md ':include')

?> Utilizamos el widget `BlocListener` para impulsar una nueva ruta en respuesta a los cambios de estado en nuestro `MyBloc`.

!> Por el bien de este ejemplo, estamos agregando un evento solo para navegación. En una aplicación real, no debe crear eventos de navegación explícitos. Si no es necesaria una "lógica empresarial" para activar la navegación, siempre debe navegar directamente en respuesta a la entrada del usuario (en la devolución de llamada `onPressed`, etc.). Solo navegue en respuesta a los cambios de estado si se requiere alguna "lógica de negocios" para determinar dónde navegar.

La fuente completa de esta receta se puede encontrar [aquí](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd).
