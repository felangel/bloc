# Conceptos básicos de Flutter bloc

?> Asegúrese de leer detenidamente y comprender las siguientes secciones antes de trabajar con [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** es un widget de Flutter que requiere una función `Bloc` y un `builder`. `BlocBuilder` maneja la construcción del widget en respuesta a nuevos estados. `BlocBuilder` es muy similar a `StreamBuilder` pero tiene una API más simple para reducir la cantidad de código repetitivo necesario. La función `builder` se llamará muchas veces y debería ser una [función pura](https://en.wikipedia.org/wiki/Pure_function) que devuelve un widget en respuesta al estado.

Consulte `BlocListener` si desea "hacer"algo en respuesta a cambios de estado como navegación, mostrar un diálogo, etc...

Si se omite el parámetro bloc, `BlocBuilder` realizará automáticamente una búsqueda utilizando `BlocProvider` y el actual `BuildContext`.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Solo especifique el bloc si desea proporcionar un bloc que se abarcará a un solo widget y no es accesible a través de un `BlocProvider` principal y el `BuildContext` actual.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Si desea un control detallado sobre cuándo se llama a la función del generador, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloque anterior y el estado de bloque actual y devuelve un valor booleano. Si `condición` devuelve verdadero, se llamará a `constructor` con `state` y se reconstruirá el widget. Si `condición` devuelve falso, no se llamará a `constructor` con `state` y no se producirá ninguna reconstrucción.

Si desea un control detallado sobre cuándo se llama a la función builder, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloc anterior y el estado de bloc actual y devuelve un valor booleano. Si la `condición` devuelve verdadero, se llamará a `builder` con `state` y se reconstruirá el widget. Si la `condición` devuelve falso, no se llamará a `builder` con `state` y no se producirá ninguna reconstrucción.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** es un widget de Flutter que proporciona un bloc a sus hijos a través de `BlocProvider.of <T> (context)`. Se utiliza como un widget de inyección de dependencia (DI en inglés) para que se pueda proporcionar una sola instancia de un bloc a múltiples widgets dentro de un subárbol.

En la mayoría de los casos, `BlocProvider` debe usarse para crear nuevos `blocs` que estarán disponibles para el resto del subárbol. En este caso, dado que `BlocProvider` es responsable de crear el bloc, se encargará automáticamente de cerrar el bloc.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

En otros casos, `BlocProvider` puede ser usado para proveer un bloc ya existente al subárbol, esto es comúnmente usado cuando ya se requiere que un `bloc` anteriormente creado esté disponible para una nueva ruta, en este caso, `BlocProvider` no cerrará automáticamente el `bloc` puesto que no lo creó.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

entonces desde `ChildA` o `ScreenA` podemos recuperar `BlocA` con:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** es un widget de Flutter que combina múltiples widgets de `BlocProvider` en uno.
`MultiBlocProvider` mejora la legibilidad y elimina la necesidad de anidar múltiples `BlocProviders`.
Al usar `MultiBlocProvider` podemos pasar de:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

por:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** es un widget de Flutter que toma un `BlocWidgetListener` y un `Bloc` opcional e invoca al `listener` en respuesta a los cambios de estado en el bloc. Debe usarse para la funcionalidad que debe ocurrir una vez por cada cambio de estado, como la navegación, mostrar una `SnackBar`, mostrar un `Dialog`, etc.

`listener` solo se llama una vez por cada cambio de estado ( **SIN** incluir `initialState`) a diferencia de `builder` en `BlocBuilder` y es una función `void`.

Si se omite el parámetro bloc, `BlocListener` realizará automáticamente una búsqueda usando `BlocProvider` y el actual `BuildContext`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Solo especifique el bloc si desea proporcionar un bloc que de otro modo no sería accesible a través de `BlocProvider` y el `BuildContext` actual.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Si desea un control detallado sobre cuándo se llama a la función listener, puede proporcionar una `condición` opcional a `BlocListener`. La `condición` toma el estado de bloque anterior y el estado de bloque actual y devuelve un valor booleano. Si `condición` devuelve verdadero, se llamará a `listener` con `state`. Si `condición` devuelve falso, `listener` no será llamado con `state`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** es un widget de Flutter que combina múltiples widgets `BlocListener` en uno.
`MultiBlocListener` mejora la legibilidad y elimina la necesidad de anidar múltiples `BlocListeners`.
Al usar `MultiBlocListener` podemos pasar de:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

por:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer** expone un `constructor` y un `listener` para reaccionar a nuevos estados. `BlocConsumer` es análogo a un `BlocListener` anidado y `BlocBuilder` pero reduce la cantidad de repetitivo necesaria. `BlocConsumer` solo debe usarse cuando sea necesario reconstruir la IU y ejecutar otras reacciones a los cambios de estado en el `bloque`. `BlocConsumer` toma un `BlocWidgetBuilder` y `BlocWidgetListener` requeridos y un `bloc`, `BlocBuilderCondition` y `BlocListenerCondition` opcionales.

Si se omite el parámetro `bloc`, `BlocConsumer` realizará automáticamente una búsqueda utilizando
`BlocProvider` y el actual `BuildContext`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

Se puede implementar un `listenWhen` y `buildWhen` opcionales para un control más granular sobre cuándo se llama a `listener` y `builder`. Se invocarán `listenWhen` y `buildWhen` en cada cambio de estado `bloc`. Cada uno toma el `state` anterior y el `state` actual y debe devolver un `bool` que determina si se invocará o no la función `builder` y / o `listener`. El `state` anterior se inicializará al `state` del `bloc` cuando se inicialice el `BlocConsumer`. `listenWhen` y `buildWhen` son opcionales y, si no se implementan, pasarán por defecto a `true`.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** es un widget de Flutter que proporciona un repositorio a sus hijos a través de `RepositoryProvider.of <T> (context)`. Se utiliza como un widget de inyección de dependencia (DI) para que se pueda proporcionar una sola instancia de un repositorio a múltiples widgets dentro de un subárbol. `BlocProvider` debe usarse para proporcionar bloques mientras que `RepositoryProvider` solo debe usarse para repositorios.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

entonces desde `ChildA` podemos recuperar la instancia de `Repository` con:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** es un widget de Flutter que combina múltiples widgets `RepositoryProvider` en uno.
`MultiRepositoryProvider` mejora la legibilidad y elimina la necesidad de anidar múltiples `RepositoryProvider`.
Al usar `MultiRepositoryProvider` podemos pasar de:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

por:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Uso

Veamos cómo usar `BlocBuilder` para conectar un widget `CounterPage` a un `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

En este punto, hemos separado con éxito nuestra capa de presentación de nuestra capa de lógica de negocios. Observe que el widget `CounterPage` no sabe nada sobre lo que sucede cuando un usuario toca los botones. El widget simplemente le dice al `CounterBloc` que el usuario ha presionado el botón de incremento o decremento.
