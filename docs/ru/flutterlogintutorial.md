# Flutter Login

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> В следующем руководстве мы собираемся создать `Login Flow` на Flutter, используя библиотеку `Bloc`.

![демо](../assets/gifs/flutter_login.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_login
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_login
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.1.0
  meta: ^1.1.6
  equatable: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

а затем установить все наши зависимости

```bash
flutter packages get
```

## Хранилище

Нам нужно создать `UserRepository` для управления данными пользователя.

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

?> **Примечание**: наш пользовательский репозиторий просто имитирует все различные реализации для простоты, но в реальном приложении вы можете добавить [HttpClient](https://pub.dev/packages/http), а также что-то вроде [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) для запроса токенов, чтения/записи связки ключей из/в хранилища(е).

## Auth состояния

Далее нам нужно определить, как мы собираемся управлять состоянием нашего приложения и создать необходимые блоки (компоненты бизнес-логики).

На верхнем уровне нам нужно будет управлять состоянием аутентификации пользователя. Состояние аутентификации пользователя может быть одним из следующих:

- `Uninitialized` - ожидание проверки подлинности пользователя при запуске приложения.
- `Loading` - ожидание сохранения/удаления токена
- `Authenticated` - успешно аутентифицирован
- `Unauthenticated` - не аутентифицирован

Каждое из этих состояний будет влиять на то, что видит пользователь.

Например:

- если состояние аутентификации было НЕ определено, пользователь может видеть заставку.
- если состояние аутентификации загружается, пользователь может видеть индикатор выполнения.
- если состояние аутентификации было определено, пользователь может увидеть домашний экран.
- если состояние аутентификации было НЕ определено, пользователь может увидеть форму входа в систему.

> Очень важно определить, какими будут различные состояния, прежде чем погрузиться в реализацию.

Теперь, когда мы определили наши состояния аутентификации, мы можем реализовать наш класс `AuthenticationState`

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

?> **Note**: The [`equatable`](https://pub.dev/packages/equatable) package is used in order to be able to compare two instances of `AuthenticationState`. By default, `==` returns true only if the two objects are the same instance.

?> **Примечание**: Пакет [Equatable](https://pub.dev/packages/equatable) используется для сравнения двух экземпляров `AuthenticationState`. По умолчанию `==` возвращает true, только если два объекта являются одним и тем же экземпляром.

## Auth события

Теперь, когда мы определили наш `AuthenticationState`, нам нужно определить `AuthenticationEvents`, на который будет реагировать наш `AuthenticationBloc`.

Нам понадобится:

- событие `AppStarted`, чтобы уведомить блок о том, что ему нужно проверить, аутентифицирован ли пользователь в настоящее время или нет.
- событие `LoggedIn`, чтобы уведомить блок о том, что пользователь успешно вошел в систему.
- событие `LoggedOut`, чтобы уведомить блок о том, что пользователь успешно вышел из системы.

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

?> **Примечание**: пакет `meta` используется для аннотирования параметров `AuthenticationEvent` как `@ required`. Это заставит анализатор `dart` предупреждать разработчиков, если они не предоставляют требуемые параметры.

## Auth блок

Теперь, когда у нас определены `AuthenticationState` и `AuthenticationEvents`, мы можем приступить к реализации `AuthenticationBloc`, который будет управлять проверкой и обновлением пользовательского `AuthenticationState` в ответ на `AuthenticationEvents`.

Мы начнем с создания нашего класса `AuthenticationBloc`.

```dart
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}): assert(userRepository != null);
}
```

?> **Примечание**: Из определения класса мы уже знаем, что этот блок будет преобразовывать `AuthenticationEvents` в `AuthenticationStates`.

?> **Примечание**: наш `AuthenticationBloc` зависит от `UserRepository`.

Мы можем начать с переопределения `initialState` в состояние `AuthenticationUninitialized ()`.

```dart
@override
AuthenticationState get initialState => AuthenticationUninitialized();
```

Теперь все, что осталось это реализовать `mapEventToState`.

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

Великолепно! Наш финальный `AuthenticationBloc` должен выглядеть так:

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

Теперь, когда наш `AuthenticationBloc` полностью реализован, давайте приступим к работе на уровне представления.

## Экран заставки

Первое, что нам понадобится - это виджет `SplashPage`, который будет служить нашией заставкой, а наш `AuthenticationBloc` определяет, вошел ли пользователь в систему или нет.

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

## Домашняя страница

Затем нам нужно создать нашу `HomePage`, чтобы мы могли перенаправить пользователя на нее после успешного входа в систему.

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

?> **Примечание**: Это первый класс, в котором мы используем `flutter_bloc`. Мы коротко затронем `BlocProvider.of<AuthenticationBloc>(context)` выражение, но пока нам достаточно знать, что это позволит нашему `HomePage` получить доступ к `AuthenticationBloc`.

?> **Примечание**: мы добавляем событие `LoggedOut` к нашему `AuthenticationBloc`, когда пользователь нажимает кнопку выхода из системы.

Далее нам нужно создать `LoginPage` и `LoginForm`.

Поскольку `LoginForm` будет обрабатывать ввод пользователя (нажатие кнопки входа) и иметь некоторую бизнес-логику (получение токена для заданного имени пользователя/пароля), нам нужно будет создать `LoginBloc`.

Как и в случае с `AuthenticationBloc`, нам нужно определить `LoginState` и `LoginEvents`. Давайте начнем с `LoginState`.

## Login состояния

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

Состояния могут выглядет так:

- `LoginInitial` - является начальным состоянием LoginForm.
- `LoginLoading` - состояние LoginForm, когда мы проверяем учетные данные
- `LoginFailure` - состояние LoginForm, когда попытка входа не удалась.

Теперь, когда мы определили `LoginState`, давайте взглянем на класс `LoginEvent`.

## Login события

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

`LoginButtonPressed` будет добавлено, когда пользователь нажал кнопку входа в систему. Это сообщит `LoginBloc`, что ему необходимо запросить токен для заданных учетных данных.

Теперь мы можем реализовать наш `LoginBloc`.

## Login блок

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

?> **Примечание**: `LoginBloc` зависит от `UserRepository` для аутентификации пользователя с использованием имени пользователя и пароля.

?> **Примечание**: `LoginBloc` зависит от `AuthenticationBloc` для обновления `AuthenticationState`, когда пользователь ввел действительные учетные данные.

Теперь, когда у нас есть `LoginBloc`, мы можем начать работать с `LoginPage` и `LoginForm`.

## Login страница

Виджет `LoginPage` будет служить нашим контейнерным виджетом и предоставит необходимые зависимости для виджета `LoginForm` (`LoginBloc` и `AuthenticationBloc`).

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

?> **Примечание**: `LoginPage` является `StatelessWidget`. Виджет `LoginPage` использует виджет `BlocProvider` для создания, закрытия и предоставления `LoginBloc` для поддерева.

?> **Примечание**: мы используем введенный `UserRepository` для создания нашего `LoginBloc`.

?> **Примечание**: Мы снова используем `BlocProvider.of<AuthenticationBloc>(context)` для доступа к `AuthenticationBloc` из `LoginPage`.

Далее, давайте продолжим и создадим нашу `LoginForm`.

## Login форма

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

?> **Примечание**: наша `LoginForm` использует виджет `BlocBuilder`, чтобы он мог перестраиваться при появлении нового `LoginState`. `BlocBuilder` это виджет Flutter, для которого требуется блок и функция построения. `BlocBuilder` обрабатывает создание виджета в ответ на новые состояния. `BlocBuilder` очень похож на `StreamBuilder`, но имеет более простой API для уменьшения необходимого количества стандартного кода с различными оптимизациями по производительности.

В виджете `LoginForm` больше ничего не происходит, поэтому давайте перейдем к созданию индикатора загрузки.

## Индикатор загрузки

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
```

Теперь пришло время собрать все вместе и создать наш основной виджет приложения в `main.dart`.

## Собираем все вместе

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

?> **Примечание**: опять же, мы используем `BlocBuilder`, чтобы реагировать на изменения в `AuthenticationState`, чтобы мы могли показать пользователю либо `SplashPage`, `LoginPage`, `HomePage`, либо `LoadingIndicator` на основе текущего `AuthenticationState`.

?> **Примечание**: Наше приложение обернуто в `BlocProvider`, который делает наш экземпляр `AuthenticationBloc` доступным для всего поддерева виджетов. `BlocProvider` это виджет Flutter, который предоставляет блок своим дочерним элементам через `BlocProvider.of(context)`. Он используется как виджет внедрения зависимостей (DI), так что один экземпляр блока может быть предоставлен нескольким виджетам в поддереве.

Теперь `BlocProvider.of<AuthenticationBloc>(context)` в нашем виджете `HomePage` и `LoginPage` должен иметь смысл.

Поскольку мы обернули наш `App` в `BlocProvider<AuthenticationBloc>`, мы можем получить доступ к экземпляру нашего `AuthenticationBloc`, используя статический метод `BlocProvider.of<AuthenticationBloc>(BuildContext context)` из любого места в поддереве.

На данный момент у нас есть довольно солидная реализация входа в систему и мы отделили наш уровень представления от уровня бизнес-логики с помощью `Bloc`.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
