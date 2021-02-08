# Tutorial de iniciar sesión en Flutter

![intermediate](https://img.shields.io/badge/nivel-intermedio-orange.svg)

> En el siguiente tutorial, crearemos un flujo de inicio de sesión en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Para comenzar

Empezaremos creando un nuevo proyecto en Flutter

```sh
flutter create flutter_login
```

A continuación, podemos instalar todas nuestras dependencias

```sh
flutter packages get
```

## Authentication Repository

Lo primero que vamos a hacer es crear un paquete `authentication_repository` que será responsable de administrar el dominio de autenticación.

Empezaremos creando un directorio `packages/authentication_repository` en la raíz del proyecto que contendrá todos los paquetes internos.

En un nivel alto, la estructura del directorio debería verse así:

```sh
├── android
├── ios
├── lib
├── packages
│   └── authentication_repository
└── test
```

A continuación, podemos crear un `pubspec.yaml` para el paquete `authentication_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/pubspec.yaml ':include')

?> **Nota**: `package:authentication_repository` será un paquete de Dart puro y por sencillez solo tendremos una dependencia en [package:meta](https://pub.dev/packages/meta) para algunas anotaciones.

A continuación, debemos implementar la clase `AuthenticationRepository` que estará en `lib/src/authentication_repository.dart`.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

El `AuthenticationRepository` expone un `Stream` de actualizaciones de `AuthenticationStatus` que se utilizarán para notificar a la aplicación cuando un usuario inicie o cierre sesión.

Además, existen los métodos `logIn` y `logOut` que son muy simples, pero que pueden extenderse fácilmente para autenticarse por ejemplo con `FirebaseAuth`, o algún otro proveedor de autenticación.

?> **Nota**: Dado que estamos manteniendo un `StreamController` internamente, se expone un método `dispose` para que el controlador pueda cerrarse cuando ya no sea necesario.

Por último, necesitamos crear `lib/authentication_repository.dart` que contendrá las exportaciones públicas:

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

Eso es todo para el `AuthenticationRepository`, a continuación trabajaremos en el `UserRepository`.

## User Repository

Al igual que con el `AuthenticationRepository`, crearemos un paquete `user_repository` dentro del directorio `packages`.

```sh
├── android
├── ios
├── lib
├── packages
│   ├── authentication_repository
│   └── user_repository
└── test
```

A continuación, crearemos el `pubspec.yaml` para el `user_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/pubspec.yaml ':include')

El `user_repository` será responsable del dominio del usuario y expondrá las API para interactuar con el usuario actual.

Lo primero que definiremos es el modelo de usuario en `lib/src/models/user.dart`:

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/user.dart ':include')

Por sencillez, un usuario solo tiene una propiedad `id` pero en práctica podríamos tener propiedades adicionales como `firstName`, `lastName`, `avatarUrl`, etc...

?> **Nota**: [paquete:equatable](https://pub.dev/packages/equatable) se utiliza para habilitar las comparaciones de valores del objeto `User`.

A continuación, podemos crear un `models.dart` en`lib/src/models` que exportará todos los modelos para que podamos usar un solo estado de importación para importar varios modelos.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/models.dart ':include')

Ahora que se han definido los modelos, podemos implementar la clase `UserRepository`.

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/user_repository.dart ':include')

Para este simple ejemplo, el `UserRepository` expone un método único `getUser` que recuperará al usuario actual. Estamos eliminando esto, pero en práctica es aquí es donde consultaríamos al usuario actual desde el backend.

Casi terminamos con el paquete `user_repository` - lo único que queda por hacer es crear el archivo `user_repository.dart` en `lib` que define las exportaciones públicas:

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/user_repository.dart ':include')

Ahora que tenemos los paquetes `authentication_repository` y `user_repository` completos, podemos enfocarnos en la aplicación Flutter.

## Instalación de dependencias

Comencemos actualizando el `pubspec.yaml` generado en la raíz de nuestro proyecto:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/pubspec.yaml ':include')

Podemos instalar las dependencias ejecutando:

```sh
flutter packages get
```

## Authentication Bloc

El `AuthenticationBloc` será responsable de reaccionar a los cambios en el estado de autenticación (expuesto por el `AuthenticationRepository`) y emitirá estados a los que podemos reaccionar en la capa de presentación.

La implementación de `AuthenticationBloc` está dentro de `lib/authentication` porque tratamos la autenticación como una característica en nuestra capa de aplicación.

```sh
├── lib
│   ├── app.dart
│   ├── authentication
│   │   ├── authentication.dart
│   │   └── bloc
│   │       ├── authentication_bloc.dart
│   │       ├── authentication_event.dart
│   │       └── authentication_state.dart
│   ├── main.dart
```

?> **Sugerencia**: Use la [extensión de VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) o [el plugin de IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) para crear blocs automáticamente.

### authentication_event.dart

> Las instancias de `AuthenticationEvent` serán la entrada al `AuthenticationBloc` y se procesarán y usarán para emitir nuevas instancias de `AuthenticationState`.

En esta aplicación, el `AuthenticationBloc` reaccionará a dos eventos diferentes:

- `AuthenticationStatusChanged`: notifica al bloc de un cambio en el AuthenticationStatus del usuario
- `AuthenticationLogoutRequested`: notifica al bloc de una solicitud de cierre de sesión

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_event.dart ':include')

A continuación, echemos un vistazo a `AuthenticationState`.

### authentication_state.dart

> Las instancias de `AuthenticationState` serán la salida del `AuthenticationBloc` y serán consumidas por la capa de presentación.

La clase `AuthenticationState` tiene tres constructores con nombre (named constructors):

- `AuthenticationState.unknown()`: el estado predeterminado que indica que el bloc aún no sabe si el usuario actual está autenticado o no.

- `AuthenticationState.authenticated()`: el estado que indica que el usuario está autenticado actualmente.

- `AuthenticationState.unauthenticated()`: el estado que indica que el usuario actualmente no está autenticado.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_state.dart ':include')

Ahora que hemos visto las implementaciones de `AuthenticationEvent` y `AuthenticationState`, echemos un vistazo a `AuthenticationBloc`.

### authentication_bloc.dart

> El `AuthenticationBloc` gestiona el estado de autenticación de la aplicación que se utiliza para determinar cosas como si el usuario debe iniciar o no en una página de inicio de sesión o en una página de inicio donde estará autenticado.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_bloc.dart ':include')

El `AuthenticationBloc` tiene una dependencia tanto del `AuthenticationRepository` como del `UserRepository` y define el estado inicial como `AuthenticationState.unknown()`.

En el cuerpo del constructor, el `AuthenticationBloc` se suscribe al flujo de `status` del `AuthenticationRepository` y agrega un evento `AuthenticationStatusChanged` internamente en respuesta a un nuevo `AuthenticationStatus`.

!> El `AuthenticationBloc` anula el método `close` para eliminar tanto el `StreamSubscription` como el `AuthenticationRepository`.

A continuación, `mapEventToState` maneja la transformación de las instancias de`AuthenticationEvent` entrantes en nuevas instancias de `AuthenticationState`.

Cuando se agrega un evento `AuthenticationStatusChanged` si el estado asociado es `AuthenticationStatus.authenticated`, el `AuthentictionBloc` consulta al usuario a través del `UserRepository`.

## main.dart

A continuación, podemos reemplazar el `main.dart` predeterminado con:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/main.dart ':include')

?> **Nota**: Estamos inyectando una sola instancia de `AuthenticationRepository` y `UserRepository` en el widget de `App` (que veremos a continuación).

## App

`app.dart` contendrá el widget raíz `App` para toda la aplicación.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/app.dart ':include')

?> **Nota**: `app.dart` se divide en dos partes, `App` y `AppView`. `App` es responsable de crear/proporcionar el `AuthenticationBloc` que será consumido por el `AppView`. Este desacoplamiento nos permitirá probar fácilmente los widgets `App` y `AppView` más adelante.

?> **Nota**: `RepositoryProvider` se utiliza para proporcionar la instancia única de `AuthenticationRepository` a toda la aplicación, lo que será útil más adelante.

`AppView` es un `StatefulWidget` porque mantiene una `GlobalKey` que se utiliza para acceder al `NavigatorState`. Por defecto, `AppView` renderizará el `SplashPage` (que veremos más adelante) y usa `BlocListener` para navegar a diferentes páginas según los cambios en el `AuthenticationState`.

## Splash

> La función de presentación solo contendrá una vista simple que se mostrará justo cuando se inicie la aplicación, mientras que la aplicación determina si el usuario está autenticado.

```sh
lib
└── splash
    ├── splash.dart
    └── view
        └── splash_page.dart
```

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/splash/view/splash_page.dart ':include')

?> **Sugerencia**: `SplashPage` expone una `Ruta` estática que hace que sea muy fácil navegar a través de `Navigator.of(context).push(SplashPage.route())`;

## Login

> La función de inicio de sesión contiene un `LoginPage`, `LoginForm` y `LoginBloc` y permite a los usuarios ingresar un nombre de usuario y contraseña para iniciar sesión en la aplicación.

```sh
├── lib
│   ├── login
│   │   ├── bloc
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
│   │   ├── login.dart
│   │   ├── models
│   │   │   ├── models.dart
│   │   │   ├── password.dart
│   │   │   └── username.dart
│   │   └── view
│   │       ├── login_form.dart
│   │       ├── login_page.dart
│   │       └── view.dart
```

### Login Models

Estamos usando [package:formz](https://pub.dev/packages/formz) para crear modelos estándar y reutilizables con el `username` y el `password`.

#### Username

[username.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/username.dart ':include')

Por sencillez, solo estamos validando el nombre de usuario para asegurarnos de que no esté vacío, pero en práctica puede imponer el uso de caracteres especiales, la longitud, etc...

#### Password

[password.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/password.dart ':include')

Nuevamente, solo estamos realizando una verificación simple para asegurarnos de que la contraseña no esté vacía.

#### Modelos de Barril

Al igual que antes, hay un barril `models.dart` para facilitar la importación de los modelos `Username` y `Password` con una sola importación.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/models.dart ':include')

### Login Bloc

> El `LoginBloc` gestiona el estado del `LoginForm` y se encarga de validar el nombre de usuario y la contraseña, así como el estado del formulario.

#### login_event.dart

En esta aplicación hay tres tipos diferentes de `LoginEvent`:

- `LoginUsernameChanged`: notifica al bloc que el nombre de usuario ha sido modificado.
- `LoginPasswordChanged`: notifica al bloc que la contraseña ha sido modificada.
- `LoginSubmitted`: notifica al bloc que el formulario ha sido enviado.

[login_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_event.dart ':include')

#### login_state.dart

El `LoginState` contendrá el estado del formulario, así como los estados de entrada de nombre de usuario y contraseña.

[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_state.dart ':include')

?> **Nota**: Los modelos `Username` y `Password` se utilizan como parte de `LoginState` y el estado también es parte de [package:formz](https://pub.dev/packages/formz).

#### login_bloc.dart

> El `LoginBloc` es responsable de reaccionar a las interacciones del usuario en el `LoginForm` y de manejar la validación y el envío del formulario.

[login_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_bloc.dart ':include')

El `LoginBloc` tiene una dependencia del `AuthenticationRepository` porque cuando se envía el formulario, invoca `logIn`. El estado inicial del bloc es `puro`, lo que significa que ni las entradas ni la forma han sido tocadas o interactuadas.

Siempre que cambie el `username` o el `password`, el bloc creará una variante sucia del modelo `Username`/`Password` y actualizará el estado del formulario a través de la API `Formz.validate`.

Cuando se agrega el evento `LoginSubmitted`, si el estado actual del formulario es válido, el bloc realiza una llamada a `logIn` y actualiza el estado según el resultado de la solicitud.

A continuación, echemos un vistazo a `LoginPage` y `LoginForm`.

### Login Page

> La `LoginPage` es responsable de exponer la `Ruta` así como de crear y proporcionar el `LoginBloc` al `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_page.dart ':include')

?> **Nota**: `context.read` se usa para buscar la instancia de `AuthenticationRepository` a través de `BuildContext`.

### Login Form

> El `LoginForm` maneja la notificación que hace a `LoginBloc` de los eventos del usuario y también responde a los cambios de estado usando `BlocBuilder` y `BlocListener`.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_form.dart ':include')

`BlocListener` se usa para mostrar un `SnackBar` si falla el envío de inicio de sesión. Además, los widgets `BlocBuilder` se utilizan para envolver cada uno de los widgets `TextField` y hacer uso de la propiedad `buildWhen` para optimizar las reconstrucciones. La devolución de llamada `onChanged` se utiliza para notificar al `LoginBloc` de los cambios del usuario/contraseña.

El widget `_LoginButton` solo está habilitado si el estado del formulario es válido y se muestra un `CircularProgressIndicator` en su lugar mientras se envía el formulario.

## Home

> Tras una solicitud de `logIn` exitosa, el estado del `AuthenticationBloc` cambiará a `authenticated` y el usuario será dirigido al `HomePage` donde mostramos el `id` del usuario, así como un botón para cerrar sesión.

```sh
├── lib
│   ├── home
│   │   ├── home.dart
│   │   └── view
│   │       └── home_page.dart
```

### Home Page

La `HomePage` puede acceder al usuario actual a través de `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` y lo muestra a través de un widget de `Text`. Además, cuando se presiona el botón de cierre de sesión, se agrega un evento `AuthenticationLogoutRequested` al` AuthenticationBloc`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/home/view/home_page.dart ':include')

?> **Nota**: `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` se suscribe para recibir actualizaciones.

En este punto, tenemos una implementación de inicio de sesión bastante sólida y hemos desacoplado nuestra capa de presentación de la capa de lógica empresarial mediante Bloc.

La fuente completa de este ejemplo (incluidas las pruebas de unidades y widgets) se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
