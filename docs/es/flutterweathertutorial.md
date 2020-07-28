# Tutorial del clima en Flutter

![avanzado](https://img.shields.io/badge/nivel-avanzado-red.svg)

> En el siguiente tutorial, vamos a construir una aplicación de Clima en Flutter que demuestre cómo administrar múltiples blocs para implementar temas dinámicos, pull-to-refresh (desliza-para-actualizar) y mucho más. Nuestra aplicación del clima extraerá datos reales de una API y demostrará cómo separar nuestra aplicación en tres capas (datos, lógica de negocios y presentación).

![demo](../assets/gifs/flutter_weather.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

[script](../_snippets/flutter_weather_tutorial/flutter_create.sh.md ':include')

Luego podemos continuar y reemplazar el contenido de pubspec.yaml con

[pubspec.yaml](../_snippets/flutter_weather_tutorial/pubspec.yaml.md ':include')

?> **Nota:** Vamos a agregar algunos recursos (iconos para tipos de clima) en nuestra aplicación, por lo que debemos incluir la carpeta de "assets" en pubspec.yaml. Continúe y cree una carpeta _assets_ en la raíz del proyecto.

y luego instalar todas nuestras dependencias

[script](../_snippets/flutter_weather_tutorial/flutter_packages_get.sh.md ':include')

## REST API

Para esta aplicación estaremos usando la [API metaweather](https://www.metaweather.com).

Nos centraremos en dos puntos de salida (endpoints):

- `/api/location/search/?query=$city` para obtener un ID de ubicación para un nombre de ciudad dado
- `/api/location/$locationId` para obtener el clima para una ubicación determinada

Abra [https://www.metaweather.com/api/location/search/?query=london](https://www.metaweather.com/api/location/search/?query=london) en su navegador y verá la siguiente respuesta

[london_search.json](../_snippets/flutter_weather_tutorial/location_search.json.md ':include')

Entonces podemos obtener el cualquier-lugar-en-la-tierra-id (where-on-earth-id : woeid) y usarlo para obtener la ubicación.

Navegue hasta [https://www.metaweather.com/api/location/44418](https://www.metaweather.com/api/location/44418) en su navegador y verá la respuesta para el clima en Londres. Debería verse más o menos así:

[london.json](../_snippets/flutter_weather_tutorial/location.json.md ':include')

Genial, ahora que sabemos cómo se verán nuestros datos, vamos a crear los modelos de datos necesarios.

## Crear nuestro modelo de datos del clima

Aunque la API del clima devuelve el clima durante varios días, por simplicidad, solo nos preocuparemos por el clima de hoy.

Comencemos creando una carpeta para nuestros modelos `lib/models` y creemos un archivo llamado `weather.dart` que contendrá nuestro modelo de datos para nuestra clase `Weather`. Luego, dentro de `lib/models`, cree un archivo llamado `models.dart` que es nuestro archivo de barril (barrel file) desde donde exportamos todos los modelos.

#### Importaciones

En primer lugar, necesitamos importar nuestras dependencias para nuestra clase. En la parte superior de `weather.dart`, continúe y agregue:

[weather.dart](../_snippets/flutter_weather_tutorial/equatable_import.dart.md ':include')

- `equatable`: Paquete que permite comparaciones entre objetos sin tener que anular el operador `==`

#### Crea un enum WeatherCondition

A continuación, crearemos un enum para todas nuestras posibles condiciones climáticas. En la siguiente línea, agreguemos el enum.

_Estas condiciones provienen de la definición del [metaweather API](https://www.metaweather.com/api/)_

[weather.dart](../_snippets/flutter_weather_tutorial/weather_condition.dart.md ':include')

#### Crear un Weather Model

A continuación, debemos crear una clase para que sea nuestro modelo de datos definido para el objeto weather devuelto por la API. Vamos a extraer un subconjunto de los datos de la API y crear un modelo `Weather`. Continúe y agregue esto al archivo `weather.dart` debajo de enum `WeatherCondition`.

[weather.dart](../_snippets/flutter_weather_tutorial/weather.dart.md ':include')

?> Extendemos [`Equatable`](https://pub.dev/packages/equatable) para poder comparar las instancias `Weather`. Por defecto, el operador de igualdad devuelve verdadero si y solo si esta y la otra son la misma instancia.

No están sucediendo muchas cosas aquí; solo estamos definiendo nuestro modelo de datos `Weather` e implementando un método `fromJson` para que podamos crear una instancia `Weather` desde el cuerpo de respuesta API y crear un método que asigne la cadena sin formato a una `WeatherCondition` en nuestro enum.

#### Exportar en Barril

Ahora necesitamos exportar esta clase en nuestro archivo de barril. Abra `lib/models/models.dart` y agregue la siguiente línea de código:

[models.dart](../_snippets/flutter_weather_tutorial/weather_export.dart.md ':include')

## Proveedor de datos

A continuación, necesitamos construir nuestro `WeatherApiClient` que será responsable de realizar solicitudes http a la API del clima.

> El `WeatherApiClient` es la capa más baja en nuestra arquitectura de la aplicación (el proveedor de datos). Su única responsabilidad es obtener datos directamente de nuestra API.

Como mencionamos anteriormente, vamos a alcanzar dos puntos finales, por lo que nuestro `WeatherApiClient` necesita exponer dos métodos públicos:

- `getLocationId(String city)`
- `fetchWeather(int locationId)`

#### Creando nuestro Weather API del lado del Cliente 

Esta capa de nuestra aplicación se llama capa de repositorio, así que avancemos y creemos una carpeta para nuestros repositorios. Dentro de `lib/` crea una carpeta llamada `repositories` y luego crea un archivo llamado `weather_api_client.dart`.

#### Agregando un barril

Al igual que hicimos con nuestros modelos, creamos un archivo de barril para nuestros repositorios. Dentro de `lib/repositories` agregue un archivo llamado` repositories.dart` y déjelo en blanco por ahora.

- `models`: Por último, importamos nuestro modelo `Weather` que creamos anteriormente.

#### Cree nuestra clase WeatherApiClient

Vamos a crear una clase. Continua y agrega esto:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_constructor.dart.md ':include')

Aquí estamos creando una constante para nuestra URL base y creando instancias de nuestro cliente http. Luego estamos creando nuestro Constructor y exigiendo que inyectemos una instancia de httpClient. Verás algunas dependencias faltantes. Avancemos y agréguelos al principio del archivo:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/weather_api_client_imports.dart.md ':include')

- `meta`: Defina anotaciones que pueden usar las herramientas que se envían con Dart SDK.
- `http`: Una biblioteca componible basada en "Future" para realizar solicitudes HTTP.

#### Agregue el método getLocationId

Ahora agreguemos nuestro primer método público, que obtendrá el locationId para una ciudad determinada. Debajo del constructor, continúe y agregue:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/get_location_id.dart.md ':include')

Aquí solo estamos haciendo una simple solicitud HTTP y luego decodificando la respuesta como una lista. Hablando de decodificación, verá que `jsonDecode` es una función de una dependencia que necesitamos importar. Así que sigamos adelante y hagámoslo ahora. En la parte superior del archivo por las otras importaciones, continúe y agregue:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/dart_convert_import.dart.md ':include')

- `dart:convert`: Codificador/decodificador para convertir entre diferentes representaciones de datos, incluidos JSON y UTF-8.

#### Agregue el método fetchWeather

A continuación, agreguemos nuestro otro método para alcanzar la API de metaweather. Éste obtendrá el clima de una ciudad dada su ubicación ID. Debajo del método `getLocationId` que acabamos de implementar, sigamos y agreguemos esto:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/fetch_weather.dart.md ':include')

Aquí nuevamente estamos haciendo una simple solicitud HTTP y decodificando la respuesta en JSON. Notarás que nuevamente necesitamos importar una dependencia, esta vez nuestro modelo 'Weather'. En la parte superior del archivo, continúe e impórtelo así:

[weather_api_client.dart](../_snippets/flutter_weather_tutorial/models_import.dart.md ':include')

#### Exporte WeatherApiClient

Ahora que hemos creado nuestra clase con nuestros dos métodos, vamos a exportarla en el archivo de barril. Dentro de `repositories.dart`, continúe y agregue:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_api_client_export.dart.md ':include')

#### ¿Qué sigue?

Hemos terminado nuestro `DataProvider`, así que es hora de pasar a la siguiente capa de la arquitectura de nuestra aplicación: la **capa de repositorio**.

## Repositorio

> El `WeatherRepository` sirve como una abstracción entre el código del cliente y el proveedor de datos para que, como desarrollador que trabaja en funciones, no tenga que saber de dónde provienen los datos. Nuestro `WeatherRepository` dependerá de nuestro `WeatherApiClient` que acabamos de crear y expondrá un único método público llamado, lo has adivinado, `getWeather(String city)`. Nadie necesita saber que está pasando detrás de escenas, solo necesitamos hacer dos llamadas al API (una para locationId y otra para el clima) porque a nadie le importa realmente. Todo lo que nos importa es obtener el "Clima" para una ciudad determinada.

#### Creamos nuestro Weather Repository

Este archivo puede vivir en su carpeta de repositorio. Así que adelante, cree un archivo llamado `weather_repository.dart` y ábralo.

Nuestro `WeatherRepository` es bastante simple y debería verse así:

[weather_repository.dart](../_snippets/flutter_weather_tutorial/weather_repository.dart.md ':include')

#### Exportar el WeatherRepository en un barril

Continúe y abra `repositories.dart` y exporte esto así:

[repositories.dart](../_snippets/flutter_weather_tutorial/weather_repository_export.dart.md ':include')

¡Increíble! Ahora estamos listos para pasar a la capa de lógica de negocios y comenzar a construir nuestro `WeatherBloc`.

## Lógica Empresarial (Bloc)

> Nuestro `WeatherBloc` es responsable de recibir `WeatherEvents` y convertirlos en `WeatherStates`. Tendrá una dependencia del `WeatherRepository` para que pueda recuperar el `Weather` cuando un usuario ingrese una ciudad de su elección.

#### Creando nuestro primer Bloc

Crearemos algunos Blocs durante este tutorial, así que creemos una carpeta dentro de `lib` llamada `blocs`. Una vez más, ya que tendremos varios blocs, primero creemos un archivo barril llamado `blocs.dart` dentro de nuestra carpeta `blocs`.

Antes de saltar al Bloc, necesitamos definir qué eventos manejará nuestro `WeatherBloc`, así como cómo vamos a representar nuestro `WeatherState`. Para mantener nuestros archivos pequeños, separaremos `event` `state` y `bloc` en tres archivos.

#### Weather Event

Creemos un archivo llamado `weather_event.dart` dentro de la carpeta `blocs`. Por simplicidad, comenzaremos teniendo un solo evento llamado `WeatherRequested`.

Lo podemos definir como:

[weather_event.dart](../_snippets/flutter_weather_tutorial/fetch_weather_event.dart.md ':include')

Siempre que un usuario ingrese una ciudad, agregaremos un evento `WeatherRequested` con la ciudad dada y nuestro bloque será responsable de averiguar qué tiempo hace allí y devolver un nuevo `WeatherState`.

Entonces exportemos la clase en nuestro archivo de barril. Dentro de `blocs.dart` por favor agregue:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_event_export.dart.md ':include')

#### Weather State

A continuación, creemos nuestro archivo `state`. Dentro de la carpeta `blocs`, siga adelante y cree un archivo llamado `weather_state.dart` donde vivirá nuestro `weatherState`.

Para la aplicación actual, tendremos 4 estados posibles:

- `WeatherInitial` - nuestro estado inicial que no tendrá datos del clima porque el usuario aún no ha seleccionado una ciudad.
- `WeatherLoadInProgress` - un estado que ocurrirá mientras buscamos el clima para una ciudad determinada.
- `WeatherLoadSuccess` - un estado que ocurrirá si pudiéramos obtener con éxito el clima para una ciudad determinada.
- `WeatherLoadFailure` - un estado que ocurrirá si no pudiéramos obtener el clima para una ciudad determinada.

Podemos representar estos estados así:

[weather_state.dart](../_snippets/flutter_weather_tutorial/weather_state.dart.md ':include')

Entonces exportemos esta clase en nuestro archivo de barril. Dentro de `blocs.dart`, continúe y agregue:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_state_export.dart.md ':include')

Ahora que tenemos nuestros `Events` y nuestros `States` definidos e implementados, estamos listos para hacer nuestro `WeatherBloc`.

#### Weather Bloc

> Nuestro `WeatherBloc` es muy sencillo. Para recapitular, convierte `WeatherEvents` en `WeatherStates` y depende del `WeatherRepository`.

?> **Tip:** Consulte la [extensión Bloc VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) para aprovechar los fragmentos de bloc e incluso mejorar aún más su eficiencia y velocidad de desarrollo.

Continúe y cree un archivo dentro de la carpeta `blocs` llamado `weather_bloc.dart` y agregue lo siguiente:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/weather_bloc.dart.md ':include')

Configuramos nuestro `initialState` en `WeatherInitial` ya que inicialmente, el usuario no ha seleccionado una ciudad. Entonces, todo lo que queda es implementar `mapEventToState`.

Como solo estamos manejando el evento `WeatherRequested`, todo lo que tenemos que hacer es `yield` a nuestro estado `WeatherLoadInProgress` cuando recibimos un evento`WeatherRequested` y luego tratar de obtener el clima del `WeatherRepository`.

Si somos capaces de recuperar el clima exitosamente, entonces producimos un `yield` en el estado `WeatherLoadSuccess` y si no podemos recuperar el clima, producimos un `yield` en el estado `WeatherLoadFailure`.

Ahora exporte esta clase en `blocs.dart`:

[blocs.dart](../_snippets/flutter_weather_tutorial/weather_bloc_export.dart.md ':include')

¡Eso es todo al respecto! Ahora estamos listos para pasar a la capa final: la capa de presentación.

## Presentación

### Para empezar

Como probablemente ya haya visto en otros tutoriales, crearemos un `SimpleBlocDelegate` para que podamos ver todas las transiciones de estado en nuestra aplicación. Avancemos y creemos `simple_bloc_delegate.dart` y creemos nuestro propio delegado personalizado.

[simple_bloc_delegate.dart](../_snippets/flutter_weather_tutorial/simple_bloc_delegate.dart.md ':include')

Luego podemos importarlo al archivo `main.dart` y configurar nuestro delegado de la siguiente manera:

[main.dart](../_snippets/flutter_weather_tutorial/main1.dart.md ':include')

Por último, necesitamos crear nuestro `WeatherRepository` e inyectarlo en nuestro widget `App` (que crearemos en el siguiente paso).

[main.dart](../_snippets/flutter_weather_tutorial/main2.dart.md ':include')

### App Widget

Nuestro widget `App` comenzará como un `StatelessWidget` que tiene el `WeatherRepository` inyectado y construye la `MaterialApp` con nuestro widget `Weather` (que crearemos en el siguiente paso). Estamos utilizando el widget `BlocProvider` para crear una instancia de nuestro `WeatherBloc` y ponerlo a disposición del widget `Weather` y sus hijos. Además, el `BlocProvider` gestiona la construcción y el cierre del `WeatherBloc`.

[main.dart](../_snippets/flutter_weather_tutorial/app.dart.md ':include')

### Weather

Ahora tenemos que crear nuestro widget `Weather`. Continúe y cree una carpeta llamada `widgets` dentro de `lib` y cree un archivo de barril dentro llamado `widgets.dart`. Luego cree un archivo llamado `weather.dart`.

> Nuestro Weather Widget será un `StatelessWidget` responsable de representar los diversos datos del clima.

#### Creando nuestro Stateless Widget

[weather.dart](../_snippets/flutter_weather_tutorial/weather_widget.dart.md ':include')

Todo lo que sucede en este widget es que estamos usando `BlocBuilder` con nuestro` WeatherBloc` para reconstruir nuestra interfaz de usuario en función de los cambios de estado en nuestro `WeatherBloc`.

Continúe y exporte `Weather` en el archivo `widgets.dart`.

Notarás que estamos haciendo referencia a un widget `CitySelection`,`Location`, `LastUpdated` y `CombinedWeatherTemperature` que crearemos en las siguientes secciones.

### Location Widget

Continúe y cree un archivo llamado `location.dart` dentro de la carpeta `widgets`.

> Nuestro widget `Location` es simple; Muestra la ubicación actual.

[location.dart](../_snippets/flutter_weather_tutorial/location.dart.md ':include')

Asegúrese de exportar esto en el archivo `widgets.dart`.

### Last Updated

A continuación, cree un archivo `last_updated.dart` dentro de la carpeta `widgets`.

> Nuestro widget `LastUpdated` también es súper simple; muestra la última hora actualizada para que los usuarios sepan cuán frescos son los datos del clima.

[last_updated.dart](../_snippets/flutter_weather_tutorial/last_updated.dart.md ':include')

Asegúrese de exportar esto en el archivo `widgets.dart`.

?> **Nota:** Estamos usando [`TimeOfDay`](https://api.flutter.dev/flutter/material/TimeOfDay-class.html) para formatear el `DateTime` en un formato más legible para los humanos.

### Combined Weather Temperature

A continuación, cree un archivo `combine_weather_temperature.dart` dentro de la carpeta `widgets`.

> El widget `CombinedWeatherTemperature` es un widget de composición que muestra el clima actual junto con la temperatura. Todavía vamos a modularizar los widgets `Temperatura` y `Condiciones climáticas` para que todos puedan reutilizarse.

[combined_weather_temperature.dart](../_snippets/flutter_weather_tutorial/combined_weather_temperature.dart.md ':include')

Asegúrese de exportar esto en el archivo `widgets.dart`.

?> **Nota:** Estamos utilizando dos widgets no implementados: `WeatherConditions` y `Temperature` que crearemos a continuación.

### Weather Conditions

A continuación, cree un archivo `weather_conditions.dart` dentro de la carpeta `widgets`.

> Nuestro widget de `Condiciones climáticas` se encargará de mostrar las condiciones climáticas actuales (despejado, llovizna, tormentas eléctricas, etc.) junto con un icono correspondiente.

[weather_conditions.dart](../_snippets/flutter_weather_tutorial/weather_conditions.dart.md ':include')

Asegúrese de exportar esto en el archivo `widgets.dart`.

Aquí puede ver que estamos utilizando algunos recursos. Descárguelos desde [aquí](https://github.com/felangel/bloc/tree/master/examples/flutter_weather/assets) y agréguelos al directorio `assets/` que creamos al comienzo del proyecto.

?> **Tip:** Revise [icons8](https://icons8.com/icon/set/weather/office) para los recursos utilizados en este tutorial.

### Temperature

A continuación, cree un archivo `temperature.dart` dentro de la carpeta `widgets`.

> Nuestro widget de `Temperature` será responsable de mostrar las temperaturas promedio, mínimas y máximas.

[temperature.dart](../_snippets/flutter_weather_tutorial/temperature.dart.md ':include')

Asegúrese de exportar esto en el archivo `widgets.dart`.

### City Selection

Lo último que necesitamos implementar para tener una aplicación funcional es el widget `CitySelection` que permite a los usuarios escribir el nombre de una ciudad. Continúe y cree un archivo `city_selection.dart` dentro de la carpeta `widgets`.

> El widget `CitySelection` permitirá a los usuarios ingresar el nombre de una ciudad y devolver la ciudad seleccionada al widget `App`.

[city_selection.dart](../_snippets/flutter_weather_tutorial/city_selection.dart.md ':include')

Debe ser un `StatefulWidget` porque debe mantener un `TextController`.

?> **Nota:** Cuando presionamos el botón de búsqueda usamos `Navigator.pop` y pasamos el texto actual de nuestro `TextController` a la vista anterior.

Asegúrese de exportar esto en el archivo `widgets.dart`.

## Ejecute la aplicación

Ahora que hemos creado todos nuestros widgets, volvamos al archivo `main.dart`. Verá que necesitamos importar nuestro widget `Weather`, así que continúe y agregue esta línea arriba.

[main.dart](../_snippets/flutter_weather_tutorial/widgets_import.dart.md ':include')

Luego puede seguir adelante y ejecutar la aplicación con `flutter run` en la terminal. Siga adelante y seleccione una ciudad y notará que tiene algunos problemas:

- El fondo es blanco y el texto también lo hace muy difícil de leer.
- No tenemos forma de actualizar los datos del clima una vez que se obtienen
- La interfaz de usuario es muy simple
- Todo está en grados Celsius y no tenemos forma de cambiar las unidades.

¡Abordemos estos problemas y llevemos nuestra aplicación de clima al siguiente nivel!

## Pull-To-Refresh

> Para admitir pull-to-refresh(jale para refrescar) necesitaremos actualizar nuestro `WeatherEvent` para manejar un segundo evento: `WeatherRefreshRequested`. Continúe y agregue el siguiente código a `blocs/weather_event.dart`

[weather_event.dart](../_snippets/flutter_weather_tutorial/refresh_weather_event.dart.md ':include')

Luego, necesitamos actualizar nuestro `mapEventToState` dentro de `weather_bloc.dart` para manejar un evento `WeatherRefreshRequested`. Continúe y agregue esta declaración `if` debajo de la existente.

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/refresh_weather_bloc.dart.md ':include')

Aquí estamos creando un nuevo evento que le pedirá a nuestro WeatherRepository que haga una llamada API para conocer el clima de la ciudad.

Podemos refactorizar `mapEventToState` para usar algunas funciones de ayuda privadas para mantener el código organizado y fácil de seguir:

[weather_bloc.dart](../_snippets/flutter_weather_tutorial/map_event_to_state_refactor.dart.md ':include')

Por último, necesitamos actualizar nuestra capa de presentación para usar un widget `RefreshIndicator`. Sigamos adelante y modifiquemos nuestro widget `Weather` en `widgets/weather.dart`. Hay algunas cosas que debemos hacer.

- Importe `async` al archivo `weather.dart` para manejar `Future`.

[weather.dart](../_snippets/flutter_weather_tutorial/dart_async_import.dart.md ':include')

- Agregue un Completer

[weather.dart](../_snippets/flutter_weather_tutorial/add_completer.dart.md ':include')

Dado que nuestro widget `Weather` necesitará mantener una instancia de un `Completer`, necesitamos refactorizarlo para que sea un `StatefulWidget`. Entonces, podemos inicializar el `Completer` en `initState`.

- Dentro del método `build` de los widgets, envuelvamos el `ListView` en un widget `RefreshIndicator`. Luego devuelva el `_refreshCompleter.future;` cuando ocurre el callback `onRefresh`.

[weather.dart](../_snippets/flutter_weather_tutorial/refresh_indicator.dart.md ':include')

Para usar el `RefreshIndicator` tuvimos que crear un [`Completer`](https://api.dart.dev/stable/dart-async/Completer-class.html) que nos permite producir un `Future` que podemos completar más adelante.

Lo último que debemos hacer es completar el `Completer` cuando recibamos el estado `WeatherLoadSuccess` para descartar el indicador de carga una vez que se haya actualizado el clima.

[weather.dart](../_snippets/flutter_weather_tutorial/bloc_consumer_refactor.dart.md ':include')

Convertimos nuestro `BlocBuilder` en un `BlocConsumer` porque necesitamos manejar tanto la reconstrucción de la interfaz del usuario en función de los cambios de estado como la realización de efectos secundarios (completando el `Completer`).

?> **Nota:** `BlocConsumer` es idéntico a tener un `BlocBuilder` anidado dentro de un `BlocListener`.

¡Eso es! Ahora hemos resuelto el problema #1 y los usuarios pueden actualizar el clima jalando hacia abajo. Siéntase libre de correr `flutter run` nuevamente e intente refrescar el clima.

A continuación, abordemos la interfaz de usuario simple creando un `ThemeBloc`.

## Temas dinámicos

> Nuestro `ThemeBloc` se encargará de convertir los `ThemeEvents` en `ThemeStates`.

Nuestros `ThemeEvents` consistirán en un solo evento llamado `WeatherChanged` que se agregará cada vez que las condiciones climáticas que estamos mostrando hayan cambiado.

[theme_event.dart](../_snippets/flutter_weather_tutorial/weather_changed_event.dart.md ':include')

Nuestro `ThemeState` consistirá en un `ThemeData` y un `MaterialColor` que utilizaremos para mejorar nuestra interfaz de usuario.

[theme_state.dart](../_snippets/flutter_weather_tutorial/theme_state.dart.md ':include')

Ahora, podemos implementar nuestro `ThemeBloc` que debería verse así:

[theme_bloc.dart](../_snippets/flutter_weather_tutorial/theme_bloc.dart.md ':include')

Aunque es mucho código, lo único que hay aquí es la lógica para convertir un `WeatherCondition` en un nuevo `ThemeState`.

Ahora podemos actualizar nuestro `main` a `ThemeBloc` para proporcionarlo a nuestra `App`.

[main.dart](../_snippets/flutter_weather_tutorial/main3.dart.md ':include')

Nuestro widget `App` puede usar `BlocBuilder` para reaccionar a los cambios en `ThemeState`.

[app.dart](../_snippets/flutter_weather_tutorial/app2.dart.md ':include')

?> **Nota:** Estamos usando `BlocProvider` para hacer que nuestro `ThemeBloc` esté disponible globalmente usando `BlocProvider.of<ThemeBloc>(context)`.

Lo último que debemos hacer es crear un widget genial de `GradientContainer` que coloreará nuestro fondo con respecto a las condiciones climáticas actuales.

[gradient_container.dart](../_snippets/flutter_weather_tutorial/gradient_container.dart.md ':include')

Ahora podemos usar nuestro `GradientContainer` en nuestro widget `Weather` de esta manera:

[weather.dart](../_snippets/flutter_weather_tutorial/integrate_gradient_container.dart.md ':include')

Como queremos "hacer algo" en respuesta a los cambios de estado en nuestro `WeatherBloc`, estamos utilizando `BlocListener`. En este caso, estamos completando y restableciendo el `Completer` y también estamos agregando el evento `WeatherChanged` al `ThemeBloc`.

?> **Tip:** Consulte la [Receta SnackBar](../recipesfluttershowsnackbar.md) para obtener más información sobre el widget `BlocListener`.

Estamos accediendo a nuestro `ThemeBloc` a través de `BlocProvider.of<ThemeBloc>(context)` y luego estamos agregando un evento `WeatherChanged` en cada `WeatherLoad`.

También envolvimos nuestro widget `GradientContainer` con un `BlocBuilder` de `ThemeBloc` para que podamos reconstruir el `GradientContainer` y sus hijos en respuesta a los cambios de `ThemeState`.

¡Increíble! Ahora tenemos una aplicación que se ve mucho mejor (en mi opinión :P) y hemos abordado el problema #2.

Todo lo que queda es manejar la conversión de unidades entre grados Celsius y Fahrenheit. Para ello, crearemos un widget de `Configuración` y un `SettingsBloc`.

## Conversión de unidades

Comenzaremos creando nuestro `SettingsBloc` que convertirá `SettingsEvents` en `SettingsStates`.

Nuestros `SettingsEvents` consistirán en un solo evento: `TemperatureUnitsToggled`.

[settings_event.dart](../_snippets/flutter_weather_tutorial/settings_event.dart.md ':include')

Nuestro `SettingsState` consistirá simplemente en las actuales `TemperatureUnits`.

[settings_state.dart](../_snippets/flutter_weather_tutorial/settings_state.dart.md ':include')

Por último, necesitamos crear su `SettingsBloc`:

[settings_bloc.dart](../_snippets/flutter_weather_tutorial/settings_bloc.dart.md ':include')

Todo lo que estamos haciendo es usar `fahrenheit` si se agrega `TemperatureUnitsToggled` y las unidades actuales son `celsius` y viceversa.

Ahora necesitamos proporcionar nuestro `SettingsBloc` a nuestro widget `App` en `main.dart`.

[main.dart](../_snippets/flutter_weather_tutorial/main4.dart.md ':include')

Nuevamente, estamos haciendo que `SettingsBloc` sea accesible globalmente usando `BlocProvider` y también lo estamos cerrando en la devolución de llamada `close`. Esta vez, sin embargo, dado que estamos exponiendo más de un Bloc usando `BlocProvider` al mismo nivel, podemos eliminar algunos anidamientos usando el widget `MultiBlocProvider`.

Ahora necesitamos crear nuestro widget de `Settings` desde el cual los usuarios pueden alternar las unidades.

[settings.dart](../_snippets/flutter_weather_tutorial/settings.dart.md ':include')

Estamos usando `BlocProvider` para acceder a `SettingsBloc` a través de `BuildContext` y luego estamos usando `BlocBuilder` para reconstruir nuestra interfaz de usuario basada en `SettingsState` cambiado.

Nuestra interfaz de usuario consiste en un `ListView` con un solo `ListTile` que contiene un `Switch` que los usuarios pueden alternar para seleccionar celsius vs. fahrenheit.

?> **Nota:** En el método `onChanged` del interruptor, agregamos un evento`TemperatureUnitsToggled` para notificar a `SettingsBloc` que las unidades de temperatura han cambiado.

A continuación, debemos permitir que los usuarios accedan al widget `Configuración` desde nuestro widget `Weather`.

Podemos hacerlo agregando un nuevo `IconButton` en nuestra `AppBar`.

[weather.dart](../_snippets/flutter_weather_tutorial/settings_button.dart.md ':include')

¡Ya casi hemos terminado! Solo necesitamos actualizar nuestro widget de `Temperatura` para responder a las unidades actuales.

[temperature.dart](../_snippets/flutter_weather_tutorial/update_temperature.dart.md ':include')

Y, por último, tenemos que inyectar el `TemperatureUnits` en el widget `Temperature`.

[consolidated_weather_temperature.dart](../_snippets/flutter_weather_tutorial/inject_temperature_units.dart.md ':include')

¡Eso es todo al respecto! Ahora hemos implementado con éxito una aplicación sobre el clima en flutter usando los paquetes [bloc](https://pub.dev/packages/bloc) y [flutter_bloc](https://pub.dev/packages/flutter_bloc) y nosotros hemos separado con éxito nuestra capa de presentación de nuestra lógica de negocios.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_weather).
