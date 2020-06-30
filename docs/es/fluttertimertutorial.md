# Flutter: Tutorial de temporizador

![beginner](https://img.shields.io/badge/nivel-principiante-green)

> En el siguiente tutorial veremos cómo construir una aplicación de temporizador utilizando la biblioteca de bloc. La aplicación final debería verse así:

![demo](../assets/gifs/flutter_timer.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

[script](../_snippets/flutter_timer_tutorial/flutter_create.sh.md ':include')

Luego podemos reemplazar el contenido de pubspec.yaml con:

[pubspec.yaml](../_snippets/flutter_timer_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Utilizaremos [flutter_bloc](https://pub.dev/packages/flutter_bloc), [equatable](https://pub.dev/packages/equatable) y [wave](https://pub.dev/packages/wave) como paquetes en esta aplicación.

A continuación, ejecute `flutter packages get` para instalar todas las dependencias.

## Ticker 

> La clase ticker será nuestra fuente de datos para la aplicación del temporizador. Expondrá un flujo de ticks a los que podemos suscribirnos y reaccionar.

Comienze creando `ticker.dart`.

[ticker.dart](../_snippets/flutter_timer_tutorial/ticker.dart.md ':include')

Todo lo que hace nuestra clase `Ticker` es exponer una función de tick que toma el número de ticks (segundos) que queremos y devuelve una secuencia que emite los segundos restantes cada segundo.

A continuación, necesitamos crear un `TimerBloc` que consumirá el `Ticker`.

## TimerBloc

### TimerState

Comenzaremos definiendo los `TimerStates` en los que puede estar nuestro `TimerBloc`.

Nuestro estado `TimerBloc` puede ser uno de los siguientes:

- TimerInitial — listo para comenzar la cuenta regresiva desde la duración especificada.
- TimerRunInProgress — cuenta regresiva activa desde la duración especificada.
- TimerRunPause — en pausa en la duración restante.
- TimerRunComplete — completado con una duración restante de 0.

Cada uno de estos estados tendrá una implicación en lo que ve el usuario. Por ejemplo:

- si el estado está "listo", el usuario podrá iniciar el temporizador.
- si el estado está "en ejecución", el usuario podrá pausar y restablecer el temporizador, así como ver la duración restante.
- si el estado está "en pausa", el usuario podrá resumir el temporizador y restablecerlo.
- si el estado está "completado", el usuario podrá restablecer el temporizador.

Para mantener todos nuestros archivos de bloc juntos, creamos un directorio de bloc con `bloc/timer_state.dart`.

?> **Consejo:** Puedes usar las extensiones de [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) para generar automáticamente los siguientes archivos de bloc para usted.

[timer_state.dart](../_snippets/flutter_timer_tutorial/timer_state.dart.md ':include')

Tenga en cuenta que todos los `TimerStates` extienden la clase base abstracta `TimerState` que tiene una propiedad de duración. Esto se debe a que no importa en qué estado se encuentre nuestro `TimerBloc`, queremos saber cuánto tiempo nos queda.

A continuación, definamos e implementemos los `TimerEvents` que nuestro `TimerBloc` procesará.

### TimerEvent

Nuestro `TimerBloc` necesitará saber cómo procesar los siguientes eventos:

- TimerStarted — informa al TimerBloc que el temporizador debe iniciarse.
- TimerPaused — informa al TimerBloc que el temporizador debe pausarse.
- TimerResumed — informa al TimerBloc que se debe resumir el temporizador.
- TimerReset — informa al TimerBloc que el temporizador debe reiniciar al estado original.
- TimerTicked — informa al TimerBloc que se ha producido un tick y que necesita actualizar su estado en consecuencia.

Sino usaste las extensiones de [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) luego cree `bloc/timer_event.dart` y implementemos esos eventos.

[timer_event.dart](../_snippets/flutter_timer_tutorial/timer_event.dart.md ':include')

¡A continuación, implementemos el `TimerBloc`!

### TimerBloc

Si aún no lo ha hecho, cree `bloc/timer_bloc.dart` y cree un `TimerBloc` vacío.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_empty.dart.md ':include')

Lo primero que debemos hacer es definir el `initialState` de nuestro `TimerBloc`. En este caso, queremos que el `TimerBloc` comience en el estado `TimerInitial` con una duración predeterminada de 1 minuto (60 segundos).

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_initial_state.dart.md ':include')

A continuación, necesitamos definir la dependencia de nuestro `Ticker`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_ticker.dart.md ':include')

También estamos definiendo un `StreamSubscription` para nuestro `Ticker` al que llegaremos en un momento.

En este punto, todo lo que queda por hacer es implementar `mapEventToState`. Para mejorar la legibilidad, me gusta dividir cada controlador de eventos en su propia función auxiliar. Comenzaremos con el evento `TimerStarted`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_start.dart.md ':include')

Si el `TimerBloc` recibe un evento `TimerStarted`, empuja un estado `TimerRunInProgress` con la duración de inicio. Además, si ya había una `_tickerSubscription` abierto, debemos cancelarla para desasignar la memoria. También tenemos que anular el método `close` en nuestro `TimerBloc` para que podamos cancelar la `_tickerSubscription` cuando el `TimerBloc` está cerrado. Por último, escuchamos la transmisión `_ticker.tick` y en cada tic agregamos un evento `TimerTicked` con la duración restante.

A continuación, implementemos el controlador de eventos `TimerTicked`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_tick.dart.md ':include')

Cada vez que se recibe un evento `TimerTicked`, si la duración del tick es mayor que 0, debemos impulsar un estado actualizado `TimerRunInProgress` con la nueva duración. De lo contrario, si la duración de la marca es 0, nuestro temporizador ha finalizado y debemos presionar un estado `TimerRunComplete`.

Ahora implementemos el controlador de eventos `TimerPaused`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_pause.dart.md ':include')

En `_mapTimerPausedToState` si el `estado` de nuestro `TimerBloc` es `TimerRunInProgress`, entonces podemos pausar la `_tickerSubscription` y presionar un estado `TimerRunPause` con la duración actual del temporizador.

A continuación, implementemos el controlador de eventos `TimerResumed` para que podamos pausar el temporizador.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_resume.dart.md ':include')

El controlador de eventos `TimerResumed` es muy similar al controlador de eventos `TimerPaused`. Si el `TimerBloc` tiene un `estado` de `TimerRunPause` y recibe un evento `TimerResumed`, entonces resume la `_tickerSubscription` y empuja un estado `TimerRunInProgress` con la duración actual.

Por último, necesitamos implementar el controlador de eventos `TimerReset`.

[timer_bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc.dart.md ':include')

Si el `TimerBloc` recibe un evento `TimerReset`, necesita cancelar la `_tickerSubscription` actual para que no se le notifique ningún tick adicional y empuje un estado `TimerInitial` con la duración original.

Si no usó [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) asegúrese de crear `bloc/bloc.dart` para exportar todos los archivos de bloque y hacer posible el uso de una sola importación por conveniencia.

[bloc.dart](../_snippets/flutter_timer_tutorial/timer_bloc_barrel.dart.md ':include')

Eso es todo lo que hay para el `TimerBloc`. Ahora todo lo que queda es implementar la interfaz de usuario para nuestra aplicación de temporizador.

## UI de la aplicación

### MyApp

Podemos comenzar eliminando el contenido de `main.dart` y creando nuestro widget `MyApp` que será la raíz de nuestra aplicación.

[main.dart](../_snippets/flutter_timer_tutorial/main1.dart.md ':include')

`MyApp` es un `StatelessWidget` que gestionará la inicialización y el cierre de una instancia de `TimerBloc`. Además, está utilizando el widget `BlocProvider` para que nuestra instancia `TimerBloc` esté disponible para los widgets de nuestro subárbol.

A continuación, necesitamos implementar nuestro widget `Timer`.

### Timer

Nuestro widget `Timer` será responsable de mostrar el tiempo restante junto con los botones adecuados que permitirán a los usuarios iniciar, pausar y restablecer el temporizador.

[timer.dart](../_snippets/flutter_timer_tutorial/timer1.dart.md ':include')

Hasta ahora, solo estamos usando `BlocProvider` para acceder a la instancia de nuestro `TimerBloc` y estamos usando un widget `BlocBuilder` para reconstruir la IU cada vez que recibimos un nuevo `TimerState`.

A continuación, implementaremos nuestro widget `Actions` que tendrá las acciones adecuadas (inicio, pausa y reinicio).

### Actions

[actions.dart](../_snippets/flutter_timer_tutorial/actions.dart.md ':include')

El widget `Actions` es solo otro `StatelessWidget` que utiliza `BlocProvider` para acceder a la instancia de `TimerBloc` y luego devuelve diferentes `FloatingActionButtons` en función del estado actual de `TimerBloc`. Cada uno de los `FloatingActionButtons` agrega un evento en su devolución de llamada `onPressed` para notificar al `TimerBloc`.

Ahora necesitamos conectar las `Acciones` a nuestro widget `Temporizador`.

[timer.dart](../_snippets/flutter_timer_tutorial/timer2.dart.md ':include')

Agregamos otro `BlocBuilder` que representará el widget `Actions`; sin embargo, esta vez estamos utilizando una función [flutter_bloc](https://pub.dev/packages/flutter_bloc) recientemente introducida para controlar con qué frecuencia se reconstruye el widget `Actions` (introducido en `v0.15.0`).

Si desea un control detallado sobre cuándo se llama a la función `constructor`, puede proporcionar una `condición` opcional a `BlocBuilder`. La `condición` toma el estado de bloc anterior y el estado de bloc actual y devuelve un `booleano`. Si la `condición` devuelve `verdadero`, se llamará el `constructor` con `estado` y el widget se reconstruirá. Si `condición` devuelve `falso`, no se llamará a `constructor` con `estado` y no se producirá ninguna reconstrucción.

En este caso, no queremos que el widget `Actions` se reconstruya en cada tick porque eso sería ineficiente. En cambio, solo queremos que las `Actions` se reconstruyan si el `runtimeType` del `TimerState` cambia (TimerInitial => TimerRunInProgress, TimerRunInProgress => TimerRunPause, etc...).

Como resultado, si coloreáramos aleatoriamente los widgets en cada reconstrucción, se vería así:

![Demo de condición de BlocBuilder](https://cdn-images-1.medium.com/max/1600/1*YyjpH1rcZlYWxCX308l_Ew.gif)

?> **Aviso:** Aunque el widget `Text` se reconstruye en cada tic, solo reconstruimos `Actions` si es necesario reconstruirlo.

Por último, necesitamos agregar el súper genial fondo de onda usando el paquete [wave](https://pub.dev/packages/wave).

### Fondo de olas

[background.dart](../_snippets/flutter_timer_tutorial/background.dart.md ':include')

### Poniéndolo todo junto

Nuestro acabado, `main.dart` debería verse así:

[main.dart](../_snippets/flutter_timer_tutorial/main2.dart.md ':include')

¡Eso es todo al respecto! En este punto, tenemos una aplicación de temporizador bastante sólida que reconstruye eficientemente solo widgets que necesitan ser reconstruidos.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_timer).