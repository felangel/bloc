# Tutorial de iniciar sesión con Firebase en Flutter

![avanzado](https://img.shields.io/badge/nivel-avanzado-red.svg)

> En el siguiente tutorial, crearemos un flujo de inicio de sesión de Firebase en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Para comenzar

Empezaremos creando un nuevo proyecto en Flutter.

```sh
flutter create flutter_firebase_login
```

Al igual que en el [tutorial de inicio de sesión](es/flutterlogintutorial.md), crearemos paquetes internos para mejorar la capa de nuestra arquitectura de aplicación, mantener límites claros y maximizar tanto la reutilización como la de testeo.

En este caso, los paquetes [firebase_auth](https://pub.dev/packages/firebase_auth) y [google_sign_in](https://pub.dev/packages/google_sign_in) serán nuestra capa de datos, por lo que solo se va a crear un `AuthenticationRepository` para componer datos de los dos clientes API.

## Authentication Repository

El `AuthenticationRepository` será responsable de abstraer los detalles de implementación interna de cómo autenticamos y obtenemos la información del usuario. En este caso, se integrará con firebase, pero siempre podemos cambiar la implementación interna más adelante y nuestra aplicación no se verá afectada.

### Preparación

Comenzaremos creando `packages/authentication_repository` y crearemos un `pubspec.yaml`.

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/pubspec.yaml ':include')


A continuación, podemos instalar las dependencias ejecutando

```sh
flutter packages get
```

en el directorio `authentication_repository`.

Al igual que la mayoría de los paquetes, el `authentication_repository` definirá su superficie API a través de `packages/authentication_repository/lib/authentication_repository.dart`

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

?> **Nota**: El paquete `authentication_repository` expondrá un `AuthenticationRepository` así también como modelos.

A continuación, echemos un vistazo a los modelos.

### User

> El modelo `User` describirá a un usuario en el contexto del dominio de autenticación. Para los propósitos de este ejemplo, un usuario constará de un `email`, `id`, `name` y `photo`.

?> **Nota**: Depende completamente de usted definir cómo debe verse un usuario en el contexto de su dominio.

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/src/models/user.dart ':include')

?> **Nota**: La clase `User` está extendiendo [equatable](https://pub.dev/packages/equatable) para anular las comparaciones de igualdad para que podamos comparar diferentes instancias de `User` por valor.

?> **Sugerencia**: Es útil definir un `User` que sea `static` y vacío para que no tengamos que manejar Usuarios `nulos` y siempre podamos trabajar con un objeto `User` concreto.

### Repository

> El `AuthenticationRepository` es responsable de abstraer la implementación subyacente de cómo se autentica un usuario y cómo se busca a un usuario.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

El `AuthenticationRepository` expone un `Stream<User>` al que podemos suscribirnos para recibir notificaciones cuando cambia un `User`. Además, expone métodos como `signUp`, `logInWithGoogle`, `logInWithEmailAndPassword` y `logOut`.

?> **Nota**: El `AuthenticationRepository` también es responsable de manejar los errores de bajo nivel que pueden ocurrir en la capa de datos y expone un conjunto limpio y simple de errores que se alinean con el dominio.

Eso es todo para el `AuthenticationRepository`, a continuación, echemos un vistazo a cómo integrarlo en el proyecto Flutter que creamos.

## Preparación Firebase

Debemos seguir las [instrucciones de uso de firebase_auth](https://pub.dev/packages/firebase_auth#usage) para conectar nuestra aplicación a firebase y habilitar [google_signin](https://pub.dev/packages/google_sign_in).

!> Recuerde actualizar `google-services.json` en Android y `GoogleService-Info.plist` & `Info.plist` en iOS, de lo contrario la aplicación no funcionará.

## Dependencias del proyecto

Podemos reemplazar el `pubspec.yaml` generado en la raíz del proyecto con lo siguiente:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/pubspec.yaml ':include')

Tenga en cuenta que estamos especificando un directorio de recursos para todos nuestros recursos locales de aplicaciones. Cree un directorio `assets` en la raíz de su proyecto y agregue el [bloc logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/lib/assets/bloc_logo_small.png) (que usaremos más adelante).

Luego instala todas las dependencias

```sh
flutter packages get
```

?> **Nota**: Dependemos del paquete `authentication_repository` a través de la ruta que nos permitirá iterar rápidamente sin dejar de mantener una separación clara.

## main.dart

El archivo `main.dart` se puede reemplazar con lo siguiente:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/main.dart ':include')

Es simplemente establecer una configuración global para la aplicación y llamar a `runApp` con una instancia de `App`.

?> **Nota**: Estamos inyectando una sola instancia de `AuthenticationRepository` en la `App` y es una dependencia explícita del constructor.

## App

Al igual que en el [tutorial de inicio de sesión](es/flutterlogintutorial.md), nuestro `app.dart` proporcionará una instancia del `AuthenticationRepository` a la aplicación a través de `RepositoryProvider` y también crea y proporciona una instancia de `AuthenticationBloc`. Luego, `AppView` consume el `AuthenticationBloc` y se encarga de actualizar la ruta actual basándose en el `AuthenticationState`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/app.dart ':include')

## Authentication Bloc

> El `AuthenticationBloc` es responsable de administrar el estado de autenticación de la aplicación. Tiene una dependencia del `AuthenticationRepository` y se suscribe al Stream del `usuario` para emitir nuevos estados en respuesta a cambios en el usuario actual.

### Estado

El `AuthenticationState` consta de un `AuthenticationStatus` y un `User`. Se exponen tres constructores con nombre: `unknown`, `authenticated` y `unauthenticated` para facilitar el trabajo.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_state.dart ':include')

### Evento

El `AuthenticationEvent` tiene dos subclases:

- `AuthenticationUserChanged` que notifica al bloc que el usuario actual ha cambiado
- `AuthenticationLogoutRequested` que notifica al bloc que el usuario actual ha solicitado cerrar la sesión

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_event.dart ':include')

### Bloc

El `AuthenticationBloc` responde a los `AuthenticationEvents` entrantes y los transforma en `AuthenticationStates` salientes. Tras la inicialización, se suscribe inmediatamente a la secuencia de `usuario` desde el `AuthenticationRepository` y agrega un evento `AuthenticationUserChanged` internamente para procesar los cambios en el usuario actual.

!> `close` se anula para manejar la cancelación de la `StreamSubscription` interna.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/bloc/authentication_bloc.dart ':include')

## Modelos

Un modelo de entrada `Email` y `Password` es útil para encapsular la lógica de validación y se utilizará tanto en el `LoginForm` como en el `SignUpForm` (más adelante en el tutorial).

Ambos modelos de entrada se hacen usando el paquete [formz](https://pub.dev/packages/formz) y nos permiten trabajar con un objeto validado en lugar de un tipo primitivo como un `String`.

### Email

[email.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/models/email.dart ':include')

### Password

[email.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/authentication/models/password.dart ':include')

## Pantalla de Bienvenida

La `SplashPage` se muestra mientras la aplicación determina el estado de autenticación del usuario. Es solo un simple `StatelessWidget` que muestra una imagen a través de `Image.asset`.

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/splash/view/splash_page.dart ':include')

## Login Page

La `LoginPage` es responsable de crear y proporcionar una instancia de `LoginCubit` al `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/view/login_page.dart ':include')

?> **Sugerencia**: Es muy importante mantener la creación de blocs/cubits separados de donde se consumen. Esto le permitirá inyectar instancias simuladas fácilmente y probar su vista de forma aislada.

## Login Cubit

> El `LoginCubit` es responsable de administrar el `LoginState` del formulario. Expone las API a `logInWithCredentials`, `logInWithGoogle`, y también recibe una notificación cuando se actualiza el correo electrónico/contraseña.

### Estado

El `LoginState` consta de un `Email`, `Password` y `FormzStatus`. Los modelos `Email` y` Password` extienden `FormzInput` del paquete [formz](https://pub.dev/packages/formz).

[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/cubit/login_state.dart ':include')

### Cubit

El `LoginCubit` depende del `AuthenticationRepository` para que el usuario pueda iniciar sesión mediante credenciales o mediante el inicio de sesión de Google.

[login_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/cubit/login_cubit.dart ':include')

?> **Nota**: Usamos un `Cubit` en lugar de un `Bloc` aquí porque el `LoginState` es bastante simple y localizado. Incluso sin eventos, podemos tener una idea bastante clara de lo que sucedió con solo mirar los cambios de un estado a otro y nuestro código es mucho más simple y conciso.

## Login Form

El `LoginForm` es responsable de representar el formulario en respuesta al `LoginState` e invoca métodos en el `LoginCubit` en respuesta a las interacciones del usuario.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/login/view/login_form.dart ':include')

El `LoginForm` también muestra un botón "Create Account" que navega a la `SignUpPage` donde un usuario puede crear una nueva cuenta.

## Sign Up Page

> La estructura `SignUp` refleja la estructura `Login` y consta de un `SignUpPage`,` SignUpView` y `SignUpCubit`.

El `SignUpPage` es solo responsable de crear y proporcionar una instancia del `SignUpCubit` al `SignUpForm` (exactamente como en` LoginPage`).

[sign_up_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/view/sign_up_page.dart ':include')

?> **Nota**: Al igual que en el `LoginCubit`, el `SignUpCubit` tiene una dependencia del `AuthenticationRepository` para crear nuevas cuentas de usuario.

## Sign Up Cubit

El `SignUpCubit` gestiona el estado del `SignUpForm` y se comunica con el `AuthenticationRepository` para crear nuevas cuentas de usuario.

### State

El `SignUpState` reutiliza los mismos modelos de entrada de formulario `Email` y `Password` porque la lógica de validación es la misma.

[sign_up_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/cubit/sign_up_state.dart ':include')

### Cubit

El `SignUpCubit` es extremadamente similar al `LoginCubit` con la principal excepción de que expone una API para enviar el formulario en lugar de iniciar sesión.

[sign_up_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/cubit/sign_up_cubit.dart ':include')

## Sign Up Form

El `SignUpForm` es responsable de representar el formulario en respuesta al `SignUpState` e invocar métodos en el `SignUpCubit` en respuesta a las interacciones del usuario.

[sign_up_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/sign_up/view/sign_up_form.dart ':include')

## Home Page

Después de que un usuario inicie sesión o se registre correctamente, la secuencia del `usuario` se actualizará, lo que desencadenará un cambio de estado en el `AuthenticationBloc` y dará como resultado que el `AppView` empuje la ruta `HomePage` a la pila de navegación.

Desde la `HomePage`, el usuario puede ver la información de su perfil y cerrar sesión tocando el ícono de salida en la `AppBar`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_firebase_login/lib/home/view/home_page.dart ':include')

?> **Nota**: Se creó un directorio `widgets` junto con el directorio `view` dentro de la función `home` para los componentes reutilizables que son específicos de esa función en particular. En este caso, se exporta un `Avatar` widget simple y se utiliza dentro de la `HomePage`.

?> **Nota**: Cuando se presiona el botón de cierre de sesión `IconButton`, se agrega un evento `AuthenticationLogoutRequested` al `AuthenticationBloc` que cierra la sesión del usuario y lo lleva de regreso a `LoginPage`.

En este punto, tenemos una implementación de inicio de sesión bastante sólida con Firebase y hemos desacoplado nuestra capa de presentación de la capa de lógica empresarial mediante el uso de la biblioteca de Bloc.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/bloc/tree/master/examples/flutter_firebase_login).
