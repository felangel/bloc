# Tutorial de iniciar sesión con Firebase en Flutter 

![avanzado](https://img.shields.io/badge/nivel-avanzado-red.svg)

> En el siguiente tutorial, crearemos un flujo de inicio de sesión de Firebase en Flutter usando la biblioteca Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto Flutter

[flutter_create.sh](../_snippets/flutter_firebase_login_tutorial/flutter_create.sh.md ':include')

Entonces podemos reemplazar el contenido de `pubspec.yaml` con

[pubspec.yaml](../_snippets/flutter_firebase_login_tutorial/pubspec.yaml.md ':include')

Tenga en cuenta que estamos especificando un directorio de recursos para todos los recursos locales de nuestras aplicaciones. Cree un directorio `assets` en la raíz de su proyecto y agregue el [logotipo flutter](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) (que usaremos más tarde).

luego instale todas las dependencias

[flutter_packages_get.sh](../_snippets/flutter_firebase_login_tutorial/flutter_packages_get.sh.md ':include')

Lo último que debemos hacer es seguir las [instrucciones de uso de firebase_auth](https://pub.dev/packages/firebase_auth#usage) para conectar nuestra aplicación a firebase y habilitar [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Al igual que en el [tutorial de inicio de sesión de flutter](../flutterlogintutorial.md), vamos a necesitar crear nuestro `UserRepository` que será responsable de abstraer la implementación subyacente de cómo autenticamos y recuperamos la información del usuario.

Creamos `user_repository.dart` y comencemos.

Podemos comenzar definiendo nuestra clase `UserRepository` e implementando el constructor. Puede ver de inmediato que el `UserRepository` tendrá una dependencia tanto en `FirebaseAuth` como en `GoogleSignIn`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository_constructor.dart.md ':include')

?> **Nota:** Si `FirebaseAuth` y/o `GoogleSignIn` no se inyectan en el `UserRepository`, los instanciamos internamente. Esto nos permite poder inyectar instancias simuladas para que podamos probar fácilmente el `UserRepository`.

El primer método que vamos a implementar lo llamaremos `signInWithGoogle` y autenticará al usuario utilizando el paquete `GoogleSignIn`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_google.dart.md ':include')

A continuación, implementaremos un método `signInWithCredentials` que permitirá a los usuarios iniciar sesión con sus propias credenciales usando `FirebaseAuth`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_credentials.dart.md ':include')

A continuación, debemos implementar un método de `signUp` que permita a los usuarios crear una cuenta si eligen no usar Google Sign In.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_up.dart.md ':include')

Necesitamos implementar un método `signOut` para que podamos dar a los usuarios la opción de cerrar sesión y borrar su información de perfil del dispositivo.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_out.dart.md ':include')

Por último, necesitaremos dos métodos adicionales: `isSignedIn` y `getUser` para permitirnos verificar si un usuario ya está autenticado y recuperar su información.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/is_signed_in_and_get_user.dart.md ':include')

?> **Nota:** `getUser` solo devuelve la dirección de correo electrónico del usuario actual por simplicidad, pero podemos definir nuestro propio modelo de Usuario y llenarlo con mucha más información sobre el usuario en aplicaciones más complejas.

Nuestro `user_repository.dart` terminado debería verse así:

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository.dart.md ':include')

A continuación, crearemos nuestro `AuthenticationBloc`, que será responsable de manejar el `AuthenticationState` de la aplicación en respuesta a `AuthenticationEvents`.

## Authentication States

Necesitamos determinar cómo vamos a administrar el estado de nuestra aplicación y crear los blocs necesarios (componentes de lógica de negocios).

En un nivel alto, vamos a necesitar administrar el estado de autenticación del usuario. El estado de autenticación de un usuario puede ser uno de los siguientes:

- AuthenticationInitial - esperando para ver si el usuario está autenticado o no al iniciar la aplicación.
- AuthenticationSuccess - autenticado con éxito
- Fallo de autenticación - no autenticado

Cada uno de estos estados tendrá una implicación en lo que ve el usuario.

Por ejemplo:

- si el estado de autenticación era AuthenticationInitial, el usuario podría estar viendo una pantalla de bienvenida
- si el estado de autenticación era AuthenticationSuccess, el usuario podría ver una pantalla de inicio.
- si el estado de autenticación era AuthenticationFailure, el usuario podría ver un formulario de inicio de sesión.

> Es fundamental identificar cuáles serán los diferentes estados antes de sumergirse en la implementación.

Ahora que tenemos identificados nuestros estados de autenticación, podemos implementar nuestra clase `AuthenticationState`.

Cree una carpeta/directorio llamado `authentication_bloc` y podemos crear nuestros archivos de bloc de autenticación.

[authentication_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_dir.sh.md ':include')

?> **Tip:** Puede usar [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) o [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview), son extensiones para autogenerar los archivos por usted.

[authentication_state.dart](../_snippets/flutter_firebase_login_tutorial/authentication_state.dart.md ':include')

?> **Nota**: El paquete [`equatable`](https://pub.dev/packages/equatable) se usa para poder comparar dos instancias de `AuthenticationState`. Por defecto, `==` devuelve verdadero solo si los dos objetos son la misma instancia.

?> **Nota**: `toString` se reemplaza para que sea más fácil leer un `AuthenticationState` cuando se imprime en la consola o en `Transitions`.

!> Dado que estamos usando `Equatable` para permitirnos comparar diferentes instancias de `AuthenticationState`, necesitamos pasar cualquier propiedad a la superclase. Sin `List<Object> get props => [displayName]`, no podremos comparar adecuadamente diferentes instancias de `AuthenticationSuccess`.

## Authentication Events

Ahora que tenemos definido nuestro `AuthenticationState`, necesitamos definir los `AuthenticationEvents` a los que reaccionará nuestro `AuthenticationBloc`.

Necesitaremos:

- un evento `AuthenticationStarted` para notificar al bloc que necesita verificar si el usuario está autenticado actualmente o no.
- un evento `AuthenticationLoggedIn` para notificar al bloc que el usuario ha iniciado sesión correctamente.
- un evento `AuthenticationLoggedOut` para notificar al bloc que el usuario ha cerrado la sesión correctamente.

[autenticación_evento.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc.dart.md ':include')

## Authentication Bloc

Ahora que tenemos definidos nuestro `AuthenticationState` y `AuthenticationEvents`, podemos trabajar en la implementación del `AuthenticationBloc` que gestionará la comprobación y actualización del `AuthenticationState` de un usuario en respuesta a `AuthenticationEvents`.

Comenzaremos creando nuestra clase `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Nota**: Solo de leer la definición de clase, ya sabemos que este bloc va a convertir `AuthenticationEvents` en `AuthenticationStates`.

?> **Nota**: Nuestro `AuthenticationBloc` depende del `UserRepository`.

Podemos comenzar anulando el `initialState` al estado `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Ahora todo lo que queda es implementar `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Creamos funciones privadas de ayuda separadas para convertir cada `AuthenticationEvent` en el `AuthenticationState` específicas para mantener el `mapEventToState` limpio y fácil de leer.

?> **Nota:** Estamos usando `yield*` en cada `mapEventToState` para separar los controladores de eventos en sus propias funciones. `yield*` inserta todos los elementos de la subsecuencia en la secuencia que se está construyendo actualmente, como si tuviéramos un rendimiento individual para cada elemento.

Nuestro completo `authentication_bloc.dart` ahora debería verse así:

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc.dart.md ':include')

Ahora que tenemos nuestro `AuthenticationBloc` totalmente implementado, vamos a trabajar en la capa de presentación.

## App

Comenzaremos eliminando todo de `main.dart` e implementando nuestra función principal.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main1.dart.md ':include')

Estamos envolviendo todo nuestro widget `App` en un `BlocProvider` para que el `AuthenticationBloc` esté disponible para todo el árbol de widgets.

?> `WidgetsFlutterBinding.ensureInitialized()` se requiere en Flutter v1.9.4 + antes de usar cualquier complemento si el código se ejecuta antes de runApp.

?> `BlocProvider` también se encarga de cerrar el `AuthenticationBloc` automáticamente, por lo que no es necesario que lo hagamos.

A continuación, necesitamos implementar nuestro widget `App`.

> `App` será un `StatelessWidget` y será responsable de reaccionar al estado de `AuthenticationBloc` y mostrar el widget apropiado.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main2.dart.md ':include')

Estamos utilizando `BlocBuilder` para representar la interfaz de usuario basada en el estado `AuthenticationBloc`.

Hasta ahora no tenemos widgets para renderizar, pero volveremos a esto una vez que hagamos nuestra `SplashScreen`, `LoginScreen` y `HomeScreen`.

## Bloc Delegate

Antes de avanzar demasiado, siempre es útil implementar nuestro propio `BlocDelegate` que nos permite anular `onTransition` y `onError` y nos ayudará a ver todos los cambios de estado de bloc (transiciones) y errores en un solo lugar.

Creamos `simple_bloc_delegate.dart` e implementemos rápidamente nuestro propio delegado.

[simple_bloc_delegate.dart](../_snippets/flutter_firebase_login_tutorial/simple_bloc_delegate.dart.md ':include')

Ahora podemos conectar nuestro `BlocDelegate` en nuestro `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main3.dart.md ':include')

## Splash Screen

A continuación, tendremos que crear un widget `SplashScreen` que se mostrará mientras nuestro `AuthenticationBloc` determina si un usuario está conectado o no.

¡Creamos `splash_screen.dart` y lo implementemos!

[splash_screen.dart](../_snippets/flutter_firebase_login_tutorial/splash_screen.dart.md ':include')

Como puede ver, este widget es súper mínimo y probablemente desee agregar algún tipo de imagen o animación para que se vea mejor. Por motivo de la simplicidad, vamos a dejarlo como está.

Ahora, vamos a conectarlo a nuestro `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main4.dart.md ':include')

¡Ahora, cuando nuestro `AuthenticationBloc` tiene un `state` de `AuthenticationInitial`, presentaremos nuestro widget `SplashScreen`!

## Home Screen

A continuación, tendremos que crear nuestra `HomeScreen` para que podamos navegar por los usuarios allí una vez que hayan iniciado sesión correctamente. En este caso, nuestra 'Pantalla de inicio' permitirá que el usuario cierre sesión y también mostrará su nombre actual (correo electrónico).

Creemos `home_screen.dart` y comencemos.

[home_screen.dart](../_snippets/flutter_firebase_login_tutorial/home_screen.dart.md ':include')

`HomeScreen` es un `StatelessWidget` que requiere que se inyecte un `name` para que pueda mostrar el mensaje de bienvenida. También utiliza `BlocProvider` para acceder a `AuthenticationBloc` a través de `BuildContext` para que cuando un usuario presione el botón de cerrar sesión, podamos agregar el evento `AuthenticationLoggedOut`.

Ahora vamos a actualizar nuestra `App` para representar la `HomeScreen` si el `AuthenticationState` es `AuthenticationSuccess`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main5.dart.md ':include')

## Login States

Finalmente es hora de comenzar a trabajar en el flujo de inicio de sesión. Comenzaremos identificando los diferentes `LoginStates` que tendremos.

Cree un directorio `login`, un directorio estándar de bloc y los archivos estándar del bloc.

[login_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/login_bloc_dir.sh.md ':include')

Nuestro `login/bloc/login_state.dart` debería verse así:

[login_state.dart](../_snippets/flutter_firebase_login_tutorial/login_state.dart.md ':include')

Los estados que representamos son:

`initial` es el estado inicial del LoginForm.

`loading` es el estado del LoginForm cuando estamos validando credenciales

`failure` es el estado de LoginForm cuando falla un intento de inicio de sesión.

`success` es el estado del LoginForm cuando un intento de inicio de sesión ha tenido éxito.

También hemos definido una función `copyWith` y una `update` por conveniencia (que usaremos en breve).

Ahora que tenemos definido el `LoginState`, echemos un vistazo a la clase `LoginEvent`.

## Login Events

Abra `login/bloc/login_event.dart` y definamos e implementemos nuestros eventos.

[login_event.dart](../_snippets/flutter_firebase_login_tutorial/login_event.dart.md ':include')

Los eventos que definimos son:

`LoginEmailChanged` - notifica al bloc que el usuario ha cambiado el correo electrónico

`LoginPasswordChanged` - notifica al bloc que el bloc ha cambiado la contraseña

`LoginWithGooglePressed` - notifica al bloc que el usuario ha presionado el botón Google Sign In

`LoginWithCredentialsPressed` - notifica al bloc que el usuario ha presionado el botón de inicio de sesión normal.

## Login Barrel File

Antes de implementar el `LoginBloc`, asegurémonos de que nuestro archivo barril esté listo para poder importar fácilmente todos los archivos relacionados con el bloc de inicio de sesión con una sola importación.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_barrel.dart.md ':include')

## Login Bloc

Es hora de implementar nuestro `LoginBloc`. Como siempre, necesitamos extender `Bloc` y definir nuestro `initialState` así como `mapEventToState`.

[login_bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_bloc.dart.md ':include')

**Nota:** Estamos anulando `transformEvents` para eliminar los eventos `LoginEmailChanged` y `LoginPasswordChanged` para que podamos darle al usuario algo de tiempo para dejar de escribir antes de validar la entrada.

Estamos utilizando una clase `Validators` para validar el correo electrónico y la contraseña que implementaremos a continuación.

## Validators

Creemos `validators.dart` e implementemos nuestras comprobaciones de validación de correo electrónico y contraseña.

[validators.dart](../_snippets/flutter_firebase_login_tutorial/validators.dart.md ':include')

No pasa nada especial aquí. Es solo un código Dart antiguo que usa expresiones regulares para validar el correo electrónico y la contraseña. En este punto, deberíamos tener un `LoginBloc` completamente funcional que podamos conectar a la interfaz de usuario.

## Login Screen

Ahora que hemos terminado el `LoginBloc` es hora de crear nuestro widget `LoginScreen` que será responsable de crear y cerrar el `LoginBloc`, así como de proporcionar el Scaffold para nuestro widget `LoginForm`.

Crea `login/login_screen.dart` y vamos a implementarlo.

[login_screen.dart](../_snippets/flutter_firebase_login_tutorial/login_screen.dart.md ':include')

Nuevamente, estamos ampliando `StatelessWidget` y utilizando un `BlocProvider` para inicializar y cerrar el `LoginBloc`, así como para que la instancia de `LoginBloc` esté disponible para todos los widgets dentro del subárbol.

En este punto, necesitamos implementar el widget `LoginForm` que será responsable de mostrar el formulario y los botones de envío para que un usuario se autentique a sí mismo.

## Login Form

Cree `login/login_form.dart` y desarrollemos nuestro formulario.

[login_form.dart](../_snippets/flutter_firebase_login_tutorial/login_form.dart.md ':include')

Nuestro widget `LoginForm` es un `StatefulWidget` porque necesita mantener sus propios `TextEditingControllers` para la entrada de correo electrónico y contraseña.

Utilizamos un widget `BlocListener` para ejecutar acciones únicas en respuesta a cambios de estado. En este caso, estamos mostrando diferentes widgets `SnackBar` en respuesta a un estado pendiente/falla. Además, si el envío es exitoso, utilizamos el método `listener` para notificar a `AuthenticationBloc` que el usuario ha iniciado sesión correctamente.

?> **Sugerencia:** Consulte la [Receta SnackBar](../recipesfluttershowsnackbar.md) para obtener más detalles.

Utilizamos un widget `BlocBuilder` para reconstruir la IU en respuesta a diferentes` LoginStates`.

Cada vez que cambia el correo electrónico o la contraseña, agregamos un evento al `LoginBloc` para que valide el estado del formulario actual y devuelva el nuevo estado del formulario.

?> **Nota:** Estamos usando `Image.asset` para cargar el logotipo de flutter desde nuestro directorio de activos.

En este punto, notará que no hemos implementado `LoginButton`, `GoogleLoginButton` o `CreateAccountButton`, así que haremos los siguientes.

## Login Button

Cree `login/login_button.dart` e implementemos rápidamente nuestro widget `LoginButton`.

[login_button.dart](../_snippets/flutter_firebase_login_tutorial/login_button.dart.md ':include')

No pasa nada especial aquí; solo un `StatelessWidget` que tiene un poco de estilo y una devolución de llamada `onPressed` para que podamos tener un `VoidCallback` personalizado cada vez que se presiona el botón.

## Google Login Button

Creamos `login/google_login_button.dart` y comencemos a trabajar en nuestro inicio de sesión de Google.

[google_login_button.dart](../_snippets/flutter_firebase_login_tutorial/google_login_button.dart.md ':include')

Nuevamente, no hay mucho que hacer aquí. Tenemos otro `StatelessWidget`; sin embargo, esta vez no estamos exponiendo una devolución de llamada `onPressed`. En cambio, estamos manejando el onPressed internamente y agregando el evento `LoginWithGooglePressed` a nuestro `LoginBloc` que manejará el proceso de inicio de sesión de Google.

?> **Nota:** Estamos usando [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) para el genial ícono de google.

## Create Account Button

El último de los tres botones es el `CreateAccountButton`. Creamos `login/create_account_button.dart` y manos a la obra.

[create_account_button.dart](../_snippets/flutter_firebase_login_tutorial/create_account_button.dart.md ':include')

En este caso, nuevamente tenemos un `StatelessWidget` y nuevamente estamos manejando el callback `onPressed` internamente. Esta vez, sin embargo, estamos empujando una nueva ruta en respuesta a la presión del botón a la `RegisterScreen`. ¡Construyamos eso a continuación!

## Register States

Al igual que con el inicio de sesión, vamos a necesitar definir nuestros `RegisterStates` antes de continuar.

Cree un directorio `register` y cree el directorio de bloc estándar y sus archivos.

[register_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/register_bloc_dir.sh.md ':include')

Nuestro `register/bloc/register_state.dart` debería verse así:

[register_state.dart](../_snippets/flutter_firebase_login_tutorial/register_state.dart.md ':include')

?> **Nota:** El `RegisterState` es muy similar al `LoginState` y podríamos haber creado un solo estado y compartirlo entre los dos; sin embargo, es muy probable que las funciones de inicio de sesión y registro difieran y, en la mayoría de los casos, es mejor mantenerlas desconectadas.

A continuación, pasaremos a la clase `RegisterEvent`.

## Register Events

Abra `register/bloc/register_event.dart` e implementemos nuestros eventos.

[register_event.dart](../_snippets/flutter_firebase_login_tutorial/register_event.dart.md ':include')

?> **Nota:** Nuevamente, la implementación de `RegisterEvent` se ve muy similar a la implementación de `LoginEvent` pero dado que las dos son características separadas, las mantenemos independientes en este ejemplo.

## Register Barrel File

Nuevamente, al igual que con el inicio de sesión, necesitamos crear un archivo barril para exportar nuestros archivos relacionados con el bloc de registro.

Abra `bloc.dart` en nuestro directorio `register/bloc` y exporte los tres archivos.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_barrel.dart.md ':include')

## Register Bloc

Ahora, abramos `register/bloc/register_bloc.dart` e implementemos el `RegisterBloc`.

[register_bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_bloc.dart.md ':include')

Al igual que antes, necesitamos extender `Bloc`, implementar `initialState` y `mapEventToState`. Opcionalmente, estamos anulando `transformEvents` nuevamente para que podamos dar a los usuarios algo de tiempo para terminar de escribir antes de validar el formulario.

Ahora que el `RegisterBloc` es completamente funcional, solo necesitamos construir la capa de presentación.

## Register Screen

De forma similar a la `LoginScreen`, nuestra `RegisterScreen` será un `StatelessWidget` responsable de inicializar y cerrar el `RegisterBloc`. También proporcionará el Scaffold para el `RegisterForm`.

Crea `register/register_screen.dart` y vamos a implementarlo.

[register_screen.dart](../_snippets/flutter_firebase_login_tutorial/register_screen.dart.md ':include')

## Register Form

A continuación, creamos el `RegisterForm` que proporcionará los campos de formulario para que un usuario cree su cuenta.

Crea `register/register_form.dart` y construyémoslo.

[register_form.dart](../_snippets/flutter_firebase_login_tutorial/register_form.dart.md ':include')

Nuevamente, necesitamos administrar `TextEditingControllers` para la entrada de texto, por lo que nuestro `RegisterForm` debe ser un `StatefulWidget`. Además, estamos usando `BlocListener` nuevamente para ejecutar acciones únicas en respuesta a cambios de estado como mostrar `SnackBar` cuando el registro está pendiente o falla. También estamos agregando el evento `AuthenticationLoggedIn` al `AuthenticationBloc` si el registro fue exitoso para que podamos iniciar sesión inmediatamente al usuario.

?> **Nota:** Estamos utilizando `BlocBuilder` para que nuestra interfaz de usuario responda a los cambios en el estado `RegisterBloc`.

Vamos a construir nuestro widget `RegisterButton` a continuación.

## Register Button

Crea `register/register_button.dart` y comencemos.

[register_button.dart](../_snippets/flutter_firebase_login_tutorial/register_button.dart.md ':include')

Muy similar a cómo configuramos el `LoginButton`, el `RegisterButton` tiene un estilo personalizado y expone un `VoidCallback` para que podamos manejar cada vez que un usuario presiona el botón en el widget principal.

Todo lo que queda por hacer es actualizar nuestro widget `App` en `main.dart` para mostrar la `LoginScreen` si el `AuthenticationState` es `AuthenticationFailure`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main6.dart.md ':include')

En este punto, tenemos una implementación de inicio de sesión bastante sólida usando Firebase y hemos desacoplado nuestra capa de presentación de la capa de lógica de negocios usando la Biblioteca de bloc.

La fuente completa de este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
