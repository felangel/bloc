# Flutter Login Tutorial

![intermediate](https://img.shields.io/badge/nivel-intermedio-orange)

> En el siguiente tutorial, crearemos un flujo de inicio de sesión en Flutter utilizando la libreria Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

[script](../_snippets/flutter_login_tutorial/flutter_create.sh.md ':include')

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con

[pubspec.yaml](../_snippets/flutter_login_tutorial/pubspec.yaml.md ':include')

y luego instalar todas nuestras dependencias

[script](../_snippets/flutter_login_tutorial/flutter_packages_get.sh.md ':include')

## UserRepository

Vamos a necesitar crear un `UserRepository` que nos ayude a administrar los datos de un usuario.

[user_repository.dart](../_snippets/flutter_login_tutorial/user_repository.dart.md ':include')

?> **Nota**: Nuestro repositorio de usuarios está haciendo mock de todas las diferentes implementaciones por el bien de la simplicidad, pero en una aplicación real puede inyectar un [HttpClient](https://pub.dev/packages/http), así también algo como [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) para solicitar tokens y leerlos/escribirlos en el almacén de claves/llavero.

## Authentication States

A continuación, vamos a necesitar determinar cómo vamos a administrar el estado de nuestra aplicación y crear los bloques necesarios (componentes de lógica empresarial).

En un nivel alto, vamos a necesitar administrar el estado de autenticación del usuario. El estado de autenticación de un usuario puede ser uno de los siguientes:

- AuthenticationInitial - esperando para ver si el usuario está autenticado o no en el inicio de la aplicación.
- AuthenticationInProgress - esperando para persistir/eliminar un token
- AuthenticationSuccess - autenticado con éxito
- AuthenticationFailure - no autenticado

Cada uno de estos estados tendrá una implicación en lo que ve el usuario.

Por ejemplo:

- si el estado de autenticación no fue inicializado, el usuario podría estar viendo una pantalla de bienvenida.
- si el estado de autenticación se estaba cargando, el usuario podría estar viendo un indicador de progreso.
- si el estado de autenticación fue autenticado, el usuario podría ver una pantalla de inicio.
- si el estado de autenticación no estaba autenticado, el usuario podría ver un formulario de inicio de sesión.

> Es fundamental identificar cuáles serán los diferentes estados antes de sumergirse en la implementación.

Ahora que tenemos identificados nuestros estados de autenticación, podemos implementar nuestra clase `AuthenticationState`.

[authentication_state.dart](../_snippets/flutter_login_tutorial/authentication_state.dart.md ':include')

?> **Nota**: El paquete [`equatable`](https://pub.dev/packages/equatable) se utiliza para poder comparar dos instancias de `AuthenticationState`. Por defecto, `==` devuelve verdadero solo si los dos objetos son la misma instancia.

## Authentication Events

Ahora que tenemos definido nuestro `AuthenticationState`, necesitamos definir los` AuthenticationEvents` a los que reaccionará nuestro `AuthenticationBloc`.

Nosotros necesitaremos:

- un evento `AuthenticationStarted` para notificar al bloc que necesita verificar si el usuario está autenticado actualmente o no.
- un evento `AuthenticationLoggedIn` para notificar al bloc que el usuario ha iniciado sesión correctamente.
- un evento `AuthenticationLoggedOut` para notificar al bloc que el usuario ha cerrado la sesión correctamente.

[authentication_event.dart](../_snippets/flutter_login_tutorial/authentication_event.dart.md ':include')

?> **Nota**: el paquete `meta` se usa para anotar los parámetros de `AuthenticationEvent` como `@required`. Esto hará que el analizador de dart advierta a los desarrolladores si no proporcionan los parámetros necesarios.

## Authentication Bloc

Ahora que tenemos definidos nuestro `AuthenticationState` y `AuthenticationEvents`, podemos trabajar en la implementación del `AuthenticationBloc` que gestionará la comprobación y actualización del` AuthenticationState` de un usuario en respuesta a `AuthenticationEvents`.

Comenzaremos creando nuestra clase `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Nota**: Solo de leer la definición de la clase, ya sabemos que este bloc va a convertir `AuthenticationEvents` en `AuthenticationStates`.

?> **Nota**: Nuestro `AuthenticationBloc` depende del `UserRepository`.

Podemos comenzar anulando `initialState` al estado `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Ahora todo lo que queda es implementar `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

¡Genial! Nuestro `AuthenticationBloc` final debería verse así

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc.dart.md ':include')

Ahora que tenemos nuestro `AuthenticationBloc` totalmente implementado, vamos a trabajar en la capa de presentación.

## Splash Page

Lo primero que necesitaremos es un widget `SplashPage` que servirá como nuestra Pantalla de bienvenida mientras su `AuthenticationBloc` determina si un usuario ha iniciado sesión o no.

[splash_page.dart](../_snippets/flutter_login_tutorial/splash_page.dart.md ':include')

## Home Page

A continuación, necesitaremos crear nuestra `HomePage` para que podamos navegar por los usuarios allí una vez que hayan iniciado sesión con éxito.

[home_page.dart](../_snippets/flutter_login_tutorial/home_page.dart.md ':include')

?> **Nota**: Esta es la primera clase en la que estamos usando `flutter_bloc`. Entraremos en `BlocProvider.of<AuthenticationBloc>(context)` en breve pero por ahora solo sabemos que permite que nuestra `HomePage` para acceder a nuestro `AuthenticationBloc`.

?> **Nota**: Estamos agregando un evento `AuthenticationLoggedOut` a nuestro `AuthenticationBloc` cuando un usuario presiona el botón de cerrar sesión.

A continuación, debemos crear una `LoginPage` y un `LoginForm`.

Debido a que `LoginForm` tendrá que manejar la entrada del usuario (botón de inicio de sesión presionado) y necesitará tener cierta lógica comercial (obtener un token para un nombre de usuario/contraseña dado), necesitaremos crear un `LoginBloc`.

Al igual que hicimos con el `AuthenticationBloc`, necesitaremos definir el `LoginState` y el `LoginEvents`. Comencemos con `LoginState`.

## Login States

[login_state.dart](../_snippets/flutter_login_tutorial/login_state.dart.md ':include')

`LoginInitial` es el estado inicial de LoginForm.

`LoginInProgress` es el estado del LoginForm cuando estamos validando credenciales

`LoginFailure` es el estado del LoginForm cuando falla un intento de inicio de sesión.

Ahora que tenemos definido el `LoginState`, echemos un vistazo a la clase `LoginEvent`.

## Login Events

[login_event.dart](../_snippets/flutter_login_tutorial/login_event.dart.md ':include')

`LoginButtonPressed` se agregará cuando un usuario presiona el botón de inicio de sesión. Notificará al `LoginBloc` que necesita solicitar un token para las credenciales dadas.

Ahora podemos implementar nuestro `LoginBloc`.

## Login Bloc

[login_bloc.dart](../_snippets/flutter_login_tutorial/login_bloc.dart.md ':include')

?> **Nota**: `LoginBloc` depende del `UserRepository` para autenticar a un usuario con un nombre de usuario y contraseña.

?> **Nota**: `LoginBloc` depende de `AuthenticationBloc` para actualizar AuthenticationState cuando un usuario ha ingresado credenciales válidas.

Ahora que tenemos nuestro `LoginBloc` podemos comenzar a trabajar en `Login Page` y `LoginForm`.

## Login Page

El widget `LoginPage` servirá como nuestro widget contenedor y proporcionará las dependencias necesarias para el widget `LoginForm` (`LoginBloc` y` AuthenticationBloc`).

[login_page.dart](../_snippets/flutter_login_tutorial/login_page.dart.md ':include')

?> **Nota**: `LoginPage` es un `StatelessWidget`. El widget `LoginPage` usa el widget `BlocProvider` para crear, cerrar y proporcionar el `LoginBloc` al subárbol.

?> **Nota**: Estamos utilizando el `UserRepository` inyectado para crear nuestro `LoginBloc`.

?> **Nota**: Estamos utilizando `BlocProvider.of<AuthenticationBloc>(context)` nuevamente para acceder al `AuthenticationBloc` desde la `LoginPage`.

A continuación, avancemos y creemos nuestro `LoginForm`.

## Login Form

[login_form.dart](../_snippets/flutter_login_tutorial/login_form.dart.md ':include')

?> **Nota**: Nuestro `LoginForm` utiliza el widget `BlocBuilder` para que pueda reconstruirse siempre que haya un nuevo `LoginState`. `BlocBuilder` es un widget de Flutter que requiere un Bloc y una función de construcción. `BlocBuilder` maneja la construcción del widget en respuesta a nuevos estados. `BlocBuilder` es muy similar a `StreamBuilder` pero tiene una API más simple para reducir la cantidad de código repetitivo necesario y varias optimizaciones de rendimiento.

No hay mucho más en el widget `LoginForm`, así que pasemos a crear nuestro indicador de carga.

## Loading Indicator

[loading_indicator.dart](../_snippets/flutter_login_tutorial/loading_indicator.dart.md ':include')

Ahora finalmente es hora de poner todo junto y crear nuestro widget de aplicación principal en `main.dart`.

## Putting it all together

[main.dart](../_snippets/flutter_login_tutorial/main.dart.md ':include')

?> **Nota**: Nuevamente, estamos usando `BlocBuilder` para reaccionar a los cambios en `AuthenticationState` para que podamos mostrarle al usuario `SplashPage`,` LoginPage`, `HomePage` o `LoadingIndicator` basado en el actual `AuthenticationState` .

?> **Nota**: Nuestra aplicación está envuelta en un `BlocProvider` que hace que nuestra instancia de `AuthenticationBloc` esté disponible para todo el subárbol de widgets. `BlocProvider` es un widget de Flutter que proporciona un bloque a sus hijos a través de `BlocProvider.of(context)`. Se utiliza como un widget de inyección de dependencia (DI) para que se pueda proporcionar una sola instancia de un bloque a múltiples widgets dentro de un subárbol.

Ahora `BlocProvider.of<AuthenticationBloc>(context)` en nuestro widget `HomePage` y `LoginPage` debería tener sentido.

Dado que envolvimos nuestra `Aplicación` dentro de un `BlocProvider<AuthenticationBloc>`, podemos acceder a la instancia de nuestro `AuthenticationBloc` utilizando el método estático `BlocProvider.of<AuthenticationBloc>(context BuildContext)` desde cualquier parte del subárbol.

En este punto, tenemos una implementación de inicio de sesión bastante sólida y hemos desacoplado nuestra capa de presentación de la capa de lógica de negocios mediante el uso de Bloc.

La fuente completa para este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
