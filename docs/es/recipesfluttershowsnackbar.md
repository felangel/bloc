# Recetas: Mostrar SnackBar con BlocListener

> En esta receta, veremos cómo usar `BlocListener` para mostrar una` SnackBar` en respuesta a un cambio de estado en un bloque.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Construyamos un `DataBloc` básico que manejará `DataEvents` y generará `DataStates`.

### DataEvent

Para simplificar, nuestro `DataBloc` solo responderá a un solo `DataEvent` llamado `FetchData`.

[data_event.dart](../_snippets/recipes_flutter_show_snack_bar/data_event.dart.md ':include')

### DataState

Nuestro `DataBloc` puede tener uno de tres diferentes `DataStates`:

- `Initial` - el estado inicial antes de agregar cualquier evento
- `Loading` - el estado del bloc mientras está asincrónicamente "recuperando datos"
- `Success` - el estado del bloc cuando ha "obtenido datos" con éxito

[data_state.dart](../_snippets/recipes_flutter_show_snack_bar/data_state.dart.md ':include')

### DataBloc

Nuestro `DataBloc` debería verse así:

[data_bloc.dart](../_snippets/recipes_flutter_show_snack_bar/data_bloc.dart.md ':include')

?> **Nota:** Estamos usando `Future.delayed` para simular la latencia.

## Capa de la interfaz del usuario

Ahora echemos un vistazo a cómo conectar nuestro `DataBloc` a un widget y mostrar una `SnackBar` en respuesta a un estado de éxito.

[main.dart](../_snippets/recipes_flutter_show_snack_bar/main.dart.md ':include')

?> Utilizamos el widget `BlocListener` para **HACER COSAS** en respuesta a los cambios de estado en nuestro `DataBloc`.

?> Utilizamos el widget `BlocBuilder` para **PRODUCIR WIDGETS** en respuesta a los cambios de estado en nuestro `DataBloc`.

!> Deberíamos **NUNCA** "hacer cosas" en respuesta a los cambios de estado en el método `builder` de `BlocBuilder` porque el marco Flutter puede llamar a ese método muchas veces. El método `builder` debe ser una [función pura](https://en.wikipedia.org/wiki/Pure_function) que solo devuelve un widget en respuesta al estado del bloc.

La fuente completa de esta receta se puede encontrar [aquí](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).
