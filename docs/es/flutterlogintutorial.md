# Flutter Login Tutorial

![intermediate](https://img.shields.io/badge/nivel-intermedio-orange)

> En el siguiente tutorial, crearemos un flujo de inicio de sesión en Flutter utilizando la libreria Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Para comenzar

Comenzaremos creando un nuevo proyecto de Flutter

```bash
flutter create flutter_login
```

Luego podemos continuar y reemplazar el contenido de `pubspec.yaml` con

```yaml
name: flutter_login
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  meta: ^1.1.6
  equatable: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

y luego instalar todas nuestras dependencias

```bash
flutter packages get
```

## UserRepository

Vamos a necesitar crear un `UserRepository` que nos ayude a administrar los datos de un usuario.

```dart
class UserRepository {
  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return 'token';
  }

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return;
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    await Future.delayed(Duration(seconds: 1));
    return false;
  }
}
```

?> **Nota**: Nuestro repositorio de usuarios está haciendo mock de todas las diferentes implementaciones por el bien de la simplicidad, pero en una aplicación real puede inyectar un [HttpClient](https://pub.dev/packages/http), así también algo como [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) para solicitar tokens y leerlos/escribirlos en el almacén de claves/llavero.

## Authentication States

A continuación, vamos a necesitar determinar cómo vamos a administrar el estado de nuestra aplicación y crear los bloques necesarios (componentes de lógica empresarial).

En un nivel alto, vamos a necesitar administrar el estado de autenticación del usuario. El estado de autenticación de un usuario puede ser uno de los siguientes:

- uninitialized - esperando para ver si el usuario está autenticado o no en el inicio de la aplicación.
- loading - esperando para persistir/eliminar un token
- authenticated - autenticado con éxito
- unauthenticated - no autenticado

Cada uno de estos estados tendrá una implicación en lo que ve el usuario.

Por ejemplo:

- si el estado de autenticación no fue inicializado, el usuario podría estar viendo una pantalla de bienvenida.
- si el estado de autenticación se estaba cargando, el usuario podría estar viendo un indicador de progreso.
- si el estado de autenticación fue autenticado, el usuario podría ver una pantalla de inicio.
- si el estado de autenticación no estaba autenticado, el usuario podría ver un formulario de inicio de sesión.

> Es fundamental identificar cuáles serán los diferentes estados antes de sumergirse en la implementación.

Ahora que tenemos identificados nuestros estados de autenticación, podemos implementar nuestra clase `AuthenticationState`.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}
```

?> **Nota**: El paquete [`equatable`](https://pub.dev/packages/equatable) se utiliza para poder comparar dos instancias de `AuthenticationState`. Por defecto, `==` devuelve verdadero solo si los dos objetos son la misma instancia.

## Authentication Events

Ahora que tenemos definido nuestro `AuthenticationState`, necesitamos definir los` AuthenticationEvents` a los que reaccionará nuestro `AuthenticationBloc`.

Nosotros necesitaremos:

- un evento `AppStarted` para notificar al bloc que necesita verificar si el usuario está autenticado actualmente o no.
- un evento `LoggedIn` para notificar al bloc que el usuario ha iniciado sesión correctamente.
- un evento `LoggedOut` para notificar al bloc que el usuario ha cerrado la sesión correctamente.

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String token;

  const LoggedIn({@required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class LoggedOut extends AuthenticationEvent {}
```

?> **Nota**: el paquete `meta` se usa para anotar los parámetros de `AuthenticationEvent` como `@required`. Esto hará que el analizador de dart advierta a los desarrolladores si no proporcionan los parámetros necesarios.

## Authentication Bloc

Ahora que tenemos definidos nuestro `AuthenticationState` y `AuthenticationEvents`, podemos trabajar en la implementación del `AuthenticationBloc` que gestionará la comprobación y actualización del` AuthenticationState` de un usuario en respuesta a `AuthenticationEvents`.

Comenzaremos creando nuestra clase `AuthenticationBloc`.

```dart
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}): assert(userRepository != null);
}
```

?> **Nota**: Solo de leer la definición de la clase, ya sabemos que este bloc va a convertir `AuthenticationEvents` en `AuthenticationStates`.

?> **Nota**: Nuestro `AuthenticationBloc` depende del `UserRepository`.

Podemos comenzar anulando `initialState` al estado `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => AuthenticationUninitialized();
```

Ahora todo lo que queda es implementar `mapEventToState`.

```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    final bool hasToken = await userRepository.hasToken();

    if (hasToken) {
      yield AuthenticationAuthenticated();
    } else {
      yield AuthenticationUnauthenticated();
    }
  }

  if (event is LoggedIn) {
    yield AuthenticationLoading();
    await userRepository.persistToken(event.token);
    yield AuthenticationAuthenticated();
  }

  if (event is LoggedOut) {
    yield AuthenticationLoading();
    await userRepository.deleteToken();
    yield AuthenticationUnauthenticated();
  }
}
```

¡Genial! Nuestro `AuthenticationBloc` final debería verse así

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository})
      : assert(userRepository != null);

  @override
  AuthenticationState get initialState => AuthenticationUninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      final bool hasToken = await userRepository.hasToken();

      if (hasToken) {
        yield AuthenticationAuthenticated();
      } else {
        yield AuthenticationUnauthenticated();
      }
    }

    if (event is LoggedIn) {
      yield AuthenticationLoading();
      await userRepository.persistToken(event.token);
      yield AuthenticationAuthenticated();
    }

    if (event is LoggedOut) {
      yield AuthenticationLoading();
      await userRepository.deleteToken();
      yield AuthenticationUnauthenticated();
    }
  }
}
```

Ahora que tenemos nuestro `AuthenticationBloc` totalmente implementado, vamos a trabajar en la capa de presentación.

## Splash Page

Lo primero que necesitaremos es un widget `SplashPage` que servirá como nuestra Pantalla de bienvenida mientras su `AuthenticationBloc` determina si un usuario ha iniciado sesión o no.

```dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }
}
```

## Home Page

A continuación, necesitaremos crear nuestra `HomePage` para que podamos navegar por los usuarios allí una vez que hayan iniciado sesión con éxito.

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_login/authentication/authentication.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: Center(
            child: RaisedButton(
          child: Text('logout'),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
          },
        )),
      ),
    );
  }
}
```

?> **Nota**: Esta es la primera clase en la que estamos usando `flutter_bloc`. Entraremos en `BlocProvider.of<AuthenticationBloc>(context)` en breve pero por ahora solo sabemos que permite que nuestra `HomePage` para acceder a nuestro `AuthenticationBloc`.

?> **Nota**: Estamos agregando un evento `LoggedOut` a nuestro `AuthenticationBloc` cuando un usuario presiona el botón de cerrar sesión.

A continuación, debemos crear una `LoginPage` y un `LoginForm`.

Debido a que `LoginForm` tendrá que manejar la entrada del usuario (botón de inicio de sesión presionado) y necesitará tener cierta lógica comercial (obtener un token para un nombre de usuario/contraseña dado), necesitaremos crear un `LoginBloc`.

Al igual que hicimos con el `AuthenticationBloc`, necesitaremos definir el `LoginState` y el `LoginEvents`. Comencemos con `LoginState`.

## Login States

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'LoginFailure { error: $error }';
}
```

`LoginInitial` es el estado inicial de LoginForm.

`LoginLoading` es el estado del LoginForm cuando estamos validando credenciales

`LoginFailure` es el estado del LoginForm cuando falla un intento de inicio de sesión.

Ahora que tenemos definido el `LoginState`, echemos un vistazo a la clase `LoginEvent`.

## Login Events

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginButtonPressed({
    @required this.username,
    @required this.password,
  });

  @override
  List<Object> get props => [username, password];

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}
```

`LoginButtonPressed` se agregará cuando un usuario presiona el botón de inicio de sesión. Notificará al `LoginBloc` que necesita solicitar un token para las credenciales dadas.

Ahora podemos implementar nuestro `LoginBloc`.

## Login Bloc

```dart
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.authenticate(
          username: event.username,
          password: event.password,
        );

        authenticationBloc.add(LoggedIn(token: token));
        yield LoginInitial();
      } catch (error) {
        yield LoginFailure(error: error.toString());
      }
    }
  }
}
```

?> **Nota**: `LoginBloc` depende del `UserRepository` para autenticar a un usuario con un nombre de usuario y contraseña.

?> **Nota**: `LoginBloc` depende de `AuthenticationBloc` para actualizar AuthenticationState cuando un usuario ha ingresado credenciales válidas.

Ahora que tenemos nuestro `LoginBloc` podemos comenzar a trabajar en `Login Page` y `LoginForm`.

## Login Page

El widget `LoginPage` servirá como nuestro widget contenedor y proporcionará las dependencias necesarias para el widget `LoginForm` (`LoginBloc` y` AuthenticationBloc`).

```dart
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/login/login.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(),
      ),
    );
  }
}
```

?> **Nota**: `LoginPage` es un `StatelessWidget`. El widget `LoginPage` usa el widget `BlocProvider` para crear, cerrar y proporcionar el `LoginBloc` al subárbol.

?> **Nota**: Estamos utilizando el `UserRepository` inyectado para crear nuestro `LoginBloc`.

?> **Nota**: Estamos utilizando `BlocProvider.of<AuthenticationBloc>(context)` nuevamente para acceder al `AuthenticationBloc` desde la `LoginPage`.

A continuación, avancemos y creemos nuestro `LoginForm`.

## Login Form

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/login/login.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      BlocProvider.of<LoginBloc>(context).add(
        LoginButtonPressed(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'username'),
                  controller: _usernameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                RaisedButton(
                  onPressed:
                      state is! LoginLoading ? _onLoginButtonPressed : null,
                  child: Text('Login'),
                ),
                Container(
                  child: state is LoginLoading
                      ? CircularProgressIndicator()
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

?> **Nota**: Nuestro `LoginForm` utiliza el widget `BlocBuilder` para que pueda reconstruirse siempre que haya un nuevo `LoginState`. `BlocBuilder` es un widget de Flutter que requiere un Bloc y una función de construcción. `BlocBuilder` maneja la construcción del widget en respuesta a nuevos estados. `BlocBuilder` es muy similar a `StreamBuilder` pero tiene una API más simple para reducir la cantidad de código repetitivo necesario y varias optimizaciones de rendimiento.

No hay mucho más en el widget `LoginForm`, así que pasemos a crear nuestro indicador de carga.

## Loading Indicator

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
```

Ahora finalmente es hora de poner todo junto y crear nuestro widget de aplicación principal en `main.dart`.

## Putting it all together

```dart
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import 'package:flutter_login/authentication/authentication.dart';
import 'package:flutter_login/splash/splash.dart';
import 'package:flutter_login/login/login.dart';
import 'package:flutter_login/home/home.dart';
import 'package:flutter_login/common/common.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();
  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (context) {
        return AuthenticationBloc(userRepository: userRepository)
          ..add(AppStarted());
      },
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return SplashPage();
          }
          if (state is AuthenticationAuthenticated) {
            return HomePage();
          }
          if (state is AuthenticationUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          }
          if (state is AuthenticationLoading) {
            return LoadingIndicator();
          }
        },
      ),
    );
  }
}
```

?> **Nota**: Nuevamente, estamos usando `BlocBuilder` para reaccionar a los cambios en `AuthenticationState` para que podamos mostrarle al usuario `SplashPage`,` LoginPage`, `HomePage` o `LoadingIndicator` basado en el actual `AuthenticationState` .

?> **Nota**: Nuestra aplicación está envuelta en un `BlocProvider` que hace que nuestra instancia de `AuthenticationBloc` esté disponible para todo el subárbol de widgets. `BlocProvider` es un widget de Flutter que proporciona un bloque a sus hijos a través de `BlocProvider.of(context)`. Se utiliza como un widget de inyección de dependencia (DI) para que se pueda proporcionar una sola instancia de un bloque a múltiples widgets dentro de un subárbol.

Ahora `BlocProvider.of<AuthenticationBloc>(context)` en nuestro widget `HomePage` y `LoginPage` debería tener sentido.

Dado que envolvimos nuestra `Aplicación` dentro de un `BlocProvider<AuthenticationBloc>`, podemos acceder a la instancia de nuestro `AuthenticationBloc` utilizando el método estático `BlocProvider.of<AuthenticationBloc>(context BuildContext)` desde cualquier parte del subárbol.

En este punto, tenemos una implementación de inicio de sesión bastante sólida y hemos desacoplado nuestra capa de presentación de la capa de lógica de negocios mediante el uso de Bloc.

La fuente completa para este ejemplo se puede encontrar [aquí](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
