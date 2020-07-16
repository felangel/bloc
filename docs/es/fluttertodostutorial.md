# Tutorial de lista de quehaceres en Flutter

![avanzado](https://img.shields.io/badge/nivel-avanzado-red.svg)

> En el siguiente tutorial, vamos a construir una aplicación de quehaceres en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_todos.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto Flutter

[script](../_snippets/flutter_todos_tutorial/flutter_create.sh.md ':include')

Entonces podemos reemplazar el contenido de `pubspec.yaml` con

[pubspec.yaml](../_snippets/flutter_todos_tutorial/pubspec.yaml.md ':include')

y luego instalar todas las dependencias

[script](../_snippets/flutter_todos_tutorial/flutter_packages_get.sh.md ':include')

?> **Nota:** Estamos anulando algunas dependencias porque las reutilizaremos de [las muestras de arquitectura de Flutter de Brian Egan](https://github.com/brianegan/flutter_architecture_samples).

## Llaves de la aplicación

Antes de saltar al código de la aplicación, crearemos `flutter_todos_keys.dart`. Este archivo contendrá llaves que usaremos para identificar de manera única los widgets importantes. Más tarde podemos escribir pruebas que encuentren widgets basados en llaves.

[flutter_todos_keys.dart](../_snippets/flutter_todos_tutorial/flutter_todos_keys.dart.md ':include')

Haremos referencia a estas llaves en el resto del tutorial.

?> **Nota:** Puede consultar las pruebas de integración de la aplicación [aquí](https://github.com/brianegan/flutter_architecture_samples/tree/master/integration_tests). También puede consultar las pruebas de unidades y widgets [aquí](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library/test).

## Localization

Un último concepto que abordaremos antes de entrar en la aplicación en sí es la localización. Cree `localization.dart` y crearemos la base para el soporte multilingüe.

[localization.dart](../_snippets/flutter_todos_tutorial/localization.dart.md ':include')

Ahora podemos importar y proporcionar nuestro `FlutterBlocLocalizationsDelegate` a nuestro `MaterialApp`(más adelante en este tutorial).

Para obtener más información sobre la localización, consulte los [documentos oficiales de flutter](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

## Todos Repository

En este tutorial no vamos a entrar en los detalles de implementación del `TodosRepository` porque fue implementado por [Brian Egan](https://github.com/brianegan) y se comparte entre todas las [Muestras de Arquitectura de quehaceres](https://github.com/brianegan/flutter_architecture_samples). En un nivel alto, el `TodosRepository` expondrá un método a `loadTodos` y a `saveTodos`. Eso es casi todo lo que necesitamos saber, así que para el resto del tutorial nos centraremos en las capas Bloc y Presentación.

## Todos Bloc

> Nuestro `TodosBloc` se encargará de convertir `TodosEvents` en `TodosStates` y gestionará la lista de quehaceres.

### Modelo

Lo primero que debemos hacer es definir nuestro modelo `Todo`. Cada quehacer deberá tener una identificación, una tarea, una nota opcional y un indicador completado opcional.

Crearemos un directorio `models` y crearemos `todo.dart`.

[todo.dart](../_snippets/flutter_todos_tutorial/todo.dart.md ':include')

?> **Nota:** Estamos utilizando el paquete [Equatable](https://pub.dev/packages/equatable) para poder comparar instancias de `Todos` sin tener que anular manualmente `==` y `hashCode`.

A continuación, necesitamos crear el `TodosState` que recibirá nuestra capa de presentación.

### Estados

Crearemos `blocs/todos/todos_state.dart` y definamos los diferentes estados que necesitaremos manejar.

Los tres estados que implementaremos son:

- `TodosLoadInProgress` - el estado mientras nuestra aplicación está cargando los quehaceres del repositorio.
- `TodosLoadSuccess` - el estado de nuestra aplicación después de que quehaceres se hayan cargado correctamente.
- `TodosLoadFailure` - el estado de nuestra aplicación si los quehaceres no se cargaron correctamente.

[todos_state.dart](../_snippets/flutter_todos_tutorial/todos_state.dart.md ':include')

A continuación, implementemos los eventos que necesitaremos manejar.

### Eventos

Los eventos que tendremos que manejar en nuestro `TodosBloc` son:

- `TodosLoadSuccess` - le dice al bloc que necesita cargar los quehaceres desde el `TodosRepository`.
- `TodoAdded` - le dice al bloc que necesita agregar un nuevo quehacer a la lista de quehaceres.
- `TodoUpdated` - le dice al bloc que necesita actualizar una quehacer existente.
- `TodoDeleted` - le dice al bloc que necesita eliminar un todo existente.
- `ClearCompleted` - le dice al bloc que necesita eliminar todos los quehaceres completados.
- `ToggleAll` - le dice al bloc que necesita alternar el estado completado de todos los quehaceres.

Cree `blocs/todos/todos_event.dart` e implementemos los eventos que describimos anteriormente.

[todos_event.dart](../_snippets/flutter_todos_tutorial/todos_event.dart.md ':include')

Ahora que tenemos implementados nuestros `TodosStates` y `TodosEvents` podemos implementar nuestro `TodosBloc`.

### Bloc

¡Crearemos `blocs/todos/todos_bloc.dart` y comencemos! Solo necesitamos implementar `initialState` y `mapEventToState`.

[todos_bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc.dart.md ':include')

!> Cuando hacemos "yield" a un estado en los manejadores privados `mapEventToState`, siempre están produciendo un nuevo estado en lugar de mutar el `state` (estado). Esto se debe a que cada vez que hacemos "yield", el bloc comparará el `state` con el `nextState` (siguiente estado) y solo provocará un cambio de estado (`transition`, transición)  si los dos estados son **no iguales**. Si solo mutamos y producimos la misma instancia de estado, entonces `state == nextState` se evaluaría como verdadero y no se produciría ningún cambio de estado.

Nuestro `TodosBloc` tendrá una dependencia del `TodosRepository` para que pueda cargar y guardar quehaceres. Tendrá un estado inicial de `TodosLoadInProgress` y define los controladores privados para cada uno de los eventos. Cada vez que `TodosBloc` cambia la lista de todos, llama al método `saveTodos` en el `TodosRepository` para mantener todo persistido localmente.

### Archivo de barril

Ahora que hemos terminado con nuestro `TodosBloc`, podemos crear un archivo barril para exportar todos nuestros archivos de bloc y hacer que sea conveniente importarlos más adelante.

Cree `blocs/todos/todos.dart` y exporte el bloc, los eventos y los estados:

[bloc.dart](../_snippets/flutter_todos_tutorial/todos_bloc_barrel.dart.md ':include')

## Filtered Todos Bloc

> El `FilteredTodosBloc` será responsable de reaccionar a los cambios de estado en el `TodosBloc` que acabamos de crear y mantendrá el estado de todos filtrados en nuestra aplicación.

### Modelo

Antes de comenzar a definir e implementar los `TodosStates`, necesitaremos implementar un modelo de `VisibilityFilter` que determinará cuales quehaceres contendrá nuestro `FilteredTodosState`. En este caso, tendremos tres filtros:

- `all` - mostrar todos los quehaceres (predeterminado)
- `active` - solo muestra los quehaceres que no se han completado
- `completed` - solo muestra los quehaceres que se han completado

Podemos crear `models/visibility_filter.dart` y definir nuestro filtro como un enum:

[visibility_filter.dart](../_snippets/flutter_todos_tutorial/visibility_filter.dart.md ':include')

### Estados

Al igual que hicimos con el `TodosBloc`, necesitaremos definir los diferentes estados para nuestro `FilteredTodosBloc`.

En este caso, solo tenemos dos estados:

- `FilteredTodosLoadInProgress` - el estado mientras estamos buscando quehaceres
- `FilteredTodosLoadSuccess` - el estado en el que ya no estamos buscando quehaceres

Creamos `blocs/filter_todos/filter_todos_state.dart` e implementemos los dos estados.

[filtered_todos_state.dart](../_snippets/flutter_todos_tutorial/filtered_todos_state.dart.md ':include')

?> **Nota:** El estado `FilteredTodosLoadSuccess` contiene la lista de quehaceres filtrados, así como el filtro de visibilidad activo.

### Eventos

Vamos a implementar dos eventos para nuestro `FilteredTodosBloc`:

- `FilterUpdated` - notifica al bloc que el filtro de visibilidad ha cambiado
- `TodosUpdated` - notifica al bloc que la lista de quehaceres ha cambiado

Cree `blocs/filter_todos/filter_todos_event.dart` e implementemos los dos eventos.

[filtered_todos_event.dart](../_snippets/flutter_todos_tutorial/filtered_todos_event.dart.md ':include')

¡Estamos listos para implementar nuestro `FilteredTodosBloc` a continuación!

### Bloc

Nuestro `FilteredTodosBloc` será similar a nuestro `TodosBloc`; sin embargo, en lugar de tener una dependencia en el `TodosRepository`, tendrá una dependencia en el mismo `TodosBloc`. Esto permitirá que `FilteredTodosBloc` actualice su estado en respuesta a los cambios de estado en `TodosBloc`.

Cree `blocs/filter_todos/filter_todos_bloc.dart` y comencemos.

[filtered_todos_bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc.dart.md ':include')

!> Creamos una `StreamSubscription` para la transmisión de `TodosStates` para que podamos escuchar los cambios de estado en el `TodosBloc`. Anulamos el método de cierre del bloc y cancelamos la suscripción para que podamos limpiar después de cerrar el bloc.

### Archivo de barril

Al igual que antes, podemos crear un archivo de barril para que sea más conveniente importar las diversas clases filtradas de quehaceres.

Cree `blocs/filter_todos/filter_todos.dart` y exporte los tres archivos:

[bloc.dart](../_snippets/flutter_todos_tutorial/filtered_todos_bloc_barrel.dart.md ':include')

A continuación, vamos a implementar el `StatsBloc`.

## Stats Bloc

> El `StatsBloc` será responsable de mantener las estadísticas para el número de quehaceres activos y el número de quehaceres completados. De manera similar, al `FilteredTodosBloc`, dependerá del propio `TodosBloc` para que pueda reaccionar a los cambios en el estado `TodosBloc`.

### Estado

Nuestro `StatsBloc` tendrá dos estados en los que puede estar:

- `StatsLoadInProgress` - el estado en que las estadísticas aún no se han calculado.
- `StatsLoadSuccess` - el estado en que se han calculado las estadísticas.

Cree `blocs/stats/stats_state.dart` e implementemos nuestro `StatsState`.

[stats_state.dart](../_snippets/flutter_todos_tutorial/stats_state.dart.md ':include')

A continuación, definamos e implementemos los `StatsEvents`.

### Eventos

Habrá un solo evento al que nuestro `StatsBloc` responderá: `StatsUpdated`. Este evento se agregará cada vez que cambie el estado de `TodosBloc` para que nuestro `StatsBloc` pueda recalcular las nuevas estadísticas.

Crea `blocs/stats/stats_event.dart` y vamos a implementarlo.

[stats_event.dart](../_snippets/flutter_todos_tutorial/stats_event.dart.md ':include')

Ahora estamos listos para implementar nuestro `StatsBloc` que se verá muy similar al `FilteredTodosBloc`.

### Bloc

Nuestro `StatsBloc` tendrá una dependencia del `TodosBloc` en sí mismo, lo que le permitirá actualizar su estado en respuesta a los cambios de estado en el `TodosBloc`.

Cree `blocs/stats/stats_bloc.dart` y comencemos.

[stats_bloc.dart](../_snippets/flutter_todos_tutorial/stats_bloc.dart.md ':include')

¡Eso es todo al respecto! Nuestro `StatsBloc` recalcula su estado que contiene el número de quehaceres activos y el número de quehaceres completados en cada cambio de estado de nuestro `TodosBloc`.

Ahora que hemos terminado con el `StatsBloc` solo tenemos que implementar un último bloc: el `TabBloc`.

## Tab Bloc

> El `TabBloc` será responsable de mantener el estado de las pestañas en nuestra aplicación. Tomará `TabEvents` como entrada y salida de `AppTabs`.

### Modelo/Estado

Necesitamos definir un modelo `AppTab` que también usaremos para representar el `TabState`. La `AppTab` solo será una `enum` que representa la pestaña activa en nuestra aplicación. Dado que la aplicación que estamos creando solo tendrá dos pestañas: quehaceres y estadísticas, solo necesitamos dos valores.

Cree `models/app_tab.dart`:

[app_tab.dart](../_snippets/flutter_todos_tutorial/app_tab.dart.md ':include')

### Eventos

Nuestro `TabBloc` será responsable de manejar un solo `TabEvent`:

- `TabUpdated` - notifica al bloc que la pestaña activa se ha actualizado

Create `blocs/tab/tab_event.dart`:

[tab_event.dart](../_snippets/flutter_todos_tutorial/tab_event.dart.md ':include')

### Bloc

Nuestra implementación `TabBloc` será súper simple. Como siempre, solo necesitamos implementar `initialState` y `mapEventToState`.

Cree `blocs/tab/tab_bloc.dart` y hagamos rápidamente la implementación.

[tab_bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc.dart.md ':include')

Te dije que sería simple. Todo lo que está haciendo `TabBloc` es establecer el estado inicial en la pestaña quehaceres y manejar el evento `TabUpdated` produciendo una nueva instancia de `AppTab`.

### Archivo de barril

Por último, crearemos otro archivo de barril para nuestras exportaciones `TabBloc`. Cree `blocs/tab/tab.dart` y exporte los dos archivos:

[bloc.dart](../_snippets/flutter_todos_tutorial/tab_bloc_barrel.dart.md ':include')

## Bloc Delegate

Antes de pasar a la capa de presentación, implementaremos nuestro propio `BlocDelegate` que nos permitirá manejar todos los cambios de estado y errores en un solo lugar. Es realmente útil para cosas como registros de desarrolladores o análisis.

Cree `blocs/simple_bloc_delegate.dart` y comencemos.

[simple_bloc_delegate.dart](../_snippets/flutter_todos_tutorial/simple_bloc_observer.dart.md ':include')

Todo lo que estamos haciendo en este caso es imprimir todos los cambios de estado ('transiciones') y errores en la consola solo para que podamos ver qué sucede cuando ejecutamos nuestra aplicación. Puede conectar su `BlocDelegate` a google analytics, sentry, crashlytics, etc.

## Barril de Bloc

Ahora que tenemos todos nuestros blocs implementados, podemos crear un archivo de barril. Cree `blocs/blocs.dart` y exporte todos nuestros blocs para que podamos importar convenientemente cualquier código de bloc con una sola importación.

[blocs.dart](../_snippets/flutter_todos_tutorial/blocs_barrel.dart.md ':include')

A continuación, nos centraremos en implementar las pantallas principales en nuestra aplicación de quehaceres.

## Pantallas

### Home Screen

> Nuestra `HomeScreen` será responsable de crear el `Scaffold` de nuestra aplicación. Mantendrá la `AppBar`, `BottomNavigationBar`, así como los widgets `Stats`/`FilteredTodos` (dependiendo de la pestaña activa).

Creemos un nuevo directorio llamado `screens` donde colocaremos todos nuestros nuevos widgets de pantalla y luego crearemos `screens/home_screen.dart`.

[home_screen.dart](../_snippets/flutter_todos_tutorial/home_screen.dart.md ':include')

El `HomeScreen` accede al `TabBloc` usando `BlocProvider.of<TabBloc>(context)` que estará disponible desde nuestro widget raíz `TodosApp` (lo veremos más adelante en este tutorial).

A continuación, implementaremos la `DetailsScreen`.

### Details Screen

> La `DetailsScreen` muestra los detalles completos de los quehaceres seleccionados y permite al usuario editar o eliminar el quehacer.

Crea `screens/details_screen.dart` y vamos a construirlo.

[details_screen.dart](../_snippets/flutter_todos_tutorial/details_screen.dart.md ':include')

?> **Nota:** La `DetailsScreen` requiere una identificación o ID de un quehacer para poder extraer los detalles de tarea de `TodosBloc` y para que pueda actualizarse siempre que se hayan cambiado los detalles de un quehacer (la identificación de un quehacer no se puede cambiar).

Lo principal a tener en cuenta es que hay un `IconButton` que agrega un evento `TodoDeleted`, así como una casilla de verificación que agrega un evento `TodoUpdated`.

También hay otro `FloatingActionButton` que navega al usuario a la `AddEditScreen` con `isEditing` establecido en `true`. Echaremos un vistazo a la `AddEditScreen` a continuación.

### Add/Edit Screen

> El widget `AddEditScreen` le permite al usuario crear un nuevo quehacer o actualizar nuevo quehacer existente basada en el indicador `isEditing` que se pasa a través del constructor.

Cree `screens/add_edit_screen.dart` y echemos un vistazo a la implementación.

[add_edit_screen.dart](../_snippets/flutter_todos_tutorial/add_edit_screen.dart.md ':include')

No hay nada específico de bloc en este widget. Simplemente presenta un formulario y:

- si `isEditing` es verdadero, el formulario se completa con los detalles de quehaceres existentes.
- de lo contrario, las entradas están vacías para que el usuario pueda crear un nuevo quehacer.

Utiliza una función callback llamada `onSave` para notificar a su padre del trabajo actualizado o recién creado.

Eso es todo para las pantallas en nuestra aplicación, así que antes de que se nos olvide, vamos a crear un archivo de barril para exportarlos.

### Archivo barril de pantallas

Crea `screens/screens.dart` y exporta los tres.

[screens.dart](../_snippets/flutter_todos_tutorial/screens_barrel.dart.md ':include')

A continuación, implementemos todos los "widgets" (cualquier cosa que no sea una pantalla).

## Widgets

### Filter Button

> El widget `FilterButton` será responsable de proporcionar al usuario una lista de opciones de filtro y notificará a `FilteredTodosBloc` cuando se seleccione un nuevo filtro.

Creemos un nuevo directorio llamado `widgets` y pongamos nuestra implementación `FilterButton` en `widgets/filter_button.dart`.

[filter_button.dart](../_snippets/flutter_todos_tutorial/filter_button.dart.md ':include')

El `FilterButton` necesita responder a los cambios de estado en el `FilteredTodosBloc`, por lo que utiliza `BlocProvider` para acceder al `FilteredTodosBloc` desde el `BuildContext`. Luego usa `BlocBuilder` para volver a renderizar cada vez que `FilteredTodosBloc` cambia de estado.

El resto de la implementación es Flutter puro y no está sucediendo mucho, por lo que podemos pasar al widget `ExtraActions`.

### Extra Actions

> De manera similar al `FilterButton`, el widget `ExtraActions` es responsable de proporcionar al usuario una lista de opciones adicionales: activar quehaceres y borrar quehaceres completados.

Dado que este widget no se preocupa por los filtros, interactuará con el `TodosBloc` en lugar del `FilteredTodosBloc`.

Creemos el modelo `ExtraAction` en `models/extra_action.dart`.

[extra_action.dart](../_snippets/flutter_todos_tutorial/extra_action.dart.md ':include')

Y no olvide exportarlo desde el archivo de barril `models/models.dart`.

A continuación, cree `widgets/extra_actions.dart` e impleméntelo.

[extra_actions.dart](../_snippets/flutter_todos_tutorial/extra_actions.dart.md ':include')

Al igual que con el `FilterButton`, utilizamos `BlocProvider` para acceder a `TodosBloc` desde `BuildContext` y `BlocBuilder` para responder a los cambios de estado en `TodosBloc`.

En función de la acción seleccionada, el widget agrega un evento a `TodosBloc` a los estados de finalización de `ToggleAll` para seleccionar todos los quehaceres o `ClearCompleted` para borrar todos los quehaceres seleccionados.

A continuación, veremos el widget `TabSelector`.

### Tab Selector

> El widget `TabSelector` es responsable de mostrar las pestañas en el `BottomNavigationBar` y de manejar la entrada del usuario.

Vamos a crear `widgets/tab_selector.dart` e implementarlo.

[tab_selector.dart](../_snippets/flutter_todos_tutorial/tab_selector.dart.md ':include')

Puede ver que no hay dependencia de blocs en este widget; simplemente llama a `onTabSelected` cuando se selecciona una pestaña y también toma una `activeTab` como entrada para que sepa qué pestaña está seleccionada actualmente.

A continuación, veremos el widget `FilteredTodos`.

### Filtered Todos

> El widget `FilteredTodos` es responsable de mostrar una lista de quehaceres en función del filtro activo actual.

Crea `widgets/filter_todos.dart` y vamos a implementarlo.

[filtered_todos.dart](../_snippets/flutter_todos_tutorial/filtered_todos.dart.md ':include')

Al igual que los widgets anteriores que hemos escrito, el widget `FilteredTodos` usa `BlocProvider` para acceder a los blocs (en este caso, tanto el `FilteredTodosBloc` como el `TodosBloc` son necesarios).

?> El `FilteredTodosBloc` es necesario para ayudarnos a representar los quehaceres correctos basados en el filtro actual

?> El `TodosBloc` es necesario para permitirnos agregar/eliminar quehaceres en respuesta a las interacciones del usuario, como deslizar un quehaceres individual.

Desde el widget `FilteredTodos`, el usuario puede navegar a la `DetailsScreen` donde es posible editar o eliminar un quehacer seleccionada. Dado que nuestro widget `FilteredTodos` representa una lista de widgets `TodoItem`, los veremos a continuación.

### Todo Item

> `TodoItem` es un stateless widget que se encarga de representar un quehacer y manejar las interacciones del usuario (toques/deslizamientos).

Cree `widgets/todo_item.dart` y vamos a construirlo.

[todo_item.dart](../_snippets/flutter_todos_tutorial/todo_item.dart.md ':include')

Nuevamente, observe que el `TodoItem` no tiene código específico de bloc. Simplemente se procesa en función del quehacer que pasamos a través del constructor y llama a las funciones inyectadas tipo callback cada vez que el usuario interactúa con el trabajo.

A continuación, crearemos el `DeleteTodoSnackBar`.

### Delete Todo SnackBar

> El `delete_todo_snack_bar` es responsable de indicar al usuario que se eliminó un quehacer y le permite deshacer su acción.

Crea `widgets/delete_todo_snack_bar.dart` y vamos a implementarlo.

[delete_todo_snack_bar.dart](../_snippets/flutter_todos_tutorial/delete_todo_snack_bar.dart.md ':include')

A estas alturas, probablemente esté notando un patrón: este widget tampoco tiene código específico de bloc. Simplemente toma un quehacecr para representar la tarea y llama a una función tipo callback llamada `onUndo` si un usuario presiona el botón deshacer.

Ya casi hemos terminado; ¡Solo quedan dos widgets más!

### Loading Indicator

> El widget `LoadingIndicator` es un stateless widget que es responsable de indicar al usuario que algo está en progreso.

Crea `widgets/loading_indicator.dart` y escribámoslo.

[loading_indicator.dart](../_snippets/flutter_todos_tutorial/loading_indicator.dart.md ':include')

No hay mucho que discutir aquí; solo estamos usando un `CircularIndicatorIndicator` envuelto en un widget `Center` (nuevamente no hay código específico de bloc).

Por último, necesitamos construir nuestro widget `Stats`.

### Stats

> El widget `Stats` es responsable de mostrar al usuario cuántos quehaceres están activos (en progreso) vs completados.

Creemos `widgets/stats.dart` y echemos un vistazo a la implementación.

[stats.dart](../_snippets/flutter_todos_tutorial/stats.dart.md ':include')

Estamos accediendo a `StatsBloc` usando `BlocProvider` y usando `BlocBuilder` para reconstruir en respuesta a los cambios de estado en el estado `StatsBloc`.

## Poniendolo todo junto

Creemos `main.dart` y nuestro widget `TodosApp`. Necesitamos crear una función `main` y ejecutar nuestra`TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/main1.dart.md ':include')

?> **Nota:** Estamos configurando nuestro delegado de BlocSupervisor para el `SimpleBlocDelegate` que creamos anteriormente para que podamos conectarnos a todas las transiciones y errores.

?> **Nota:** También estamos envolviendo nuestro widget `TodosApp` en un `BlocProvider` que gestiona la inicialización, el cierre y el suministro de `TodosBloc` a todo nuestro árbol de widgets desde [flutter_bloc](https://pub.dev/packages/flutter_bloc). Inmediatamente agregamos el evento `TodosLoadSuccess` para solicitar los últimos todos.

A continuación, implementemos nuestro widget `TodosApp`.

[main.dart](../_snippets/flutter_todos_tutorial/todos_app.dart.md ':include')

Nuestro `TodosApp` es un `StatelessWidget` que accede al `TodosBloc` proporcionado a través del `BuildContext`.

El `TodosApp` tiene dos rutas:

- `Home` - que representa una `HomeScreen`
- `TodoAdded` - que representa un `AddEditScreen` con `isEditing` establecido en `false`.

El `TodosApp` también hace que el `TabBloc`, `FilteredTodosBloc` y `StatsBloc` estén disponibles para los widgets en su subárbol utilizando el widget `MultiBlocProvider` de [flutter_bloc](https://pub.dev/packages/flutter_bloc).

[multi_bloc_provider.dart](../_snippets/flutter_todos_tutorial/multi_bloc_provider.dart.md ':include')

es equivalente a escribir

[nested_bloc_providers.dart](../_snippets/flutter_todos_tutorial/nested_bloc_providers.dart.md ':include')

Puede ver cómo usar `MultiBlocProvider` ayuda a reducir los niveles de anidamiento y hace que el código sea más fácil de leer y mantener.

Todo el `main.dart` debería verse así:

[main.dart](../_snippets/flutter_todos_tutorial/main2.dart.md ':include')

¡Eso es todo al respecto! Ahora hemos implementado con éxito una aplicación todos en flutter usando los paquetes [bloc](https://pub.dev/packages/bloc) y [flutter_bloc](https://pub.dev/packages/flutter_bloc) y nosotros hemos separado con éxito nuestra capa de presentación de nuestra lógica de negocios.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos).
