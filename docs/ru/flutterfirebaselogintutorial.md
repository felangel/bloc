# Flutter Firebase Login

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы собираемся создать `Login Flow` в Firebase на Flutter, используя библиотеку Bloc.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_firebase_login
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_firebase_login
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: '>=2.6.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^0.4.0+8
  google_sign_in: ^4.0.0
  firebase_auth: ^0.15.0+1
  flutter_bloc: ^3.2.0
  equatable: ^1.0.0
  meta: ^1.1.6
  font_awesome_flutter: ^8.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```

Обратите внимание, что мы указываем каталог `assets` для локальных ресурсов всех наших приложений. Создайте каталог `assets` в корне вашего проекта и добавьте ресурс [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png), который мы позже будем использовать).

затем установите все зависимости

```bash
flutter packages get
```

Последнее что нам нужно сделать, это следовать [инструкциям по использованию firebase_auth](https://pub.dev/packages/firebase_auth#usage), чтобы подключить наше приложение к `Firebase` и включить [google_signin](https://pub.dev/packages/google_sign_in).

## Хранилище пользователя

Как и во [Flutter Login](ru/flutterlogintutorial.md) нам нужно будет создать наш `UserRepository`, который будет отвечать за абстрагирование базовой реализации того как мы аутентифицируем и получаем информацию пользователя.

Давайте создадим `user_repository.dart` и начнем.

Мы можем начать с определения нашего класса `UserRepository` и реализации конструктора. Вы сразу можете увидеть, что `UserRepository` будет зависеть как от `FirebaseAuth`, так и от `GoogleSignIn`.

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();
}
```

?> **Примечание:** Если `FirebaseAuth` и/или `GoogleSignIn` не внедрены в `UserRepository`, то мы создаем их экземпляры внутри себя. Это позволяет нам внедрять фиктивные экземпляры, чтобы мы могли легко протестировать `UserRepository`.

Первый метод, который мы собираемся реализовать мы будем называть `signInWithGoogle` и он будет аутентифицировать пользователя с помощью пакета `GoogleSignIn`.

```dart
Future<FirebaseUser> signInWithGoogle() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  await _firebaseAuth.signInWithCredential(credential);
  return _firebaseAuth.currentUser();
}
```

Далее мы реализуем метод `signInWithCredentials`, который позволит пользователям входить со своими учетными данными, используя `FirebaseAuth`.

```dart
Future<void> signInWithCredentials(String email, String password) {
  return _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

Далее нам нужно реализовать метод `signUp`, который позволяет пользователям создавать учетные записи, если они решат не использовать `Google Sign In`.

```dart
Future<void> signUp({String email, String password}) async {
  return await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

Нам нужно реализовать метод `signOut`, чтобы мы могли дать пользователям возможность выйти из системы и очистить информацию о своем профиле с устройства.

```dart
Future<void> signOut() async {
  return Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut(),
  ]);
}
```

Наконец, нам понадобятся два дополнительных метода: `isSignedIn` и `getUser`, чтобы мы могли проверить, прошел ли пользователь аутентификацию и получить информацию о нем.

```dart
Future<bool> isSignedIn() async {
  final currentUser = await _firebaseAuth.currentUser();
  return currentUser != null;
}

Future<String> getUser() async {
  return (await _firebaseAuth.currentUser()).email;
}
```

?> **Примечание:** `getUser` только для простоты возвращает адрес электронной почты текущего пользователя, но мы можем определить нашу собственную модель `User` и заполнить ее намного большим количеством информации о пользователе в более сложных приложениях.

Наш готовый файл `user_repository.dart` должен выглядеть так:

```dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  UserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn();

  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  Future<String> getUser() async {
    return (await _firebaseAuth.currentUser()).email;
  }
}
```

Далее мы собираемся построить наш `AuthenticationBloc`, который будет отвечать за обработку `AuthenticationState` приложения в ответ на `AuthenticationEvents`.

## Auth состояния

Нам нужно определить, как мы собираемся управлять состоянием нашего приложения и создать необходимые блоки (компоненты бизнес-логики).

На высоком уровне нам нужно будет управлять состоянием аутентификации пользователя. Состояние аутентификации пользователя может быть одним из следующих:

- uninitialized - ожидание проверки подлинности пользователя при запуске приложения
- authenticated - пользователь успешно аутентифицирован
- unauthenticated - пользователь не аутентифицирован

Каждое из этих состояний будет влиять на то, что видит пользователь.

Например:

- если состояние аутентификации не было инициализировано, пользователь может видеть заставку
- если состояние аутентификации было аутентифицировано, пользователь может увидеть домашний экран
- если состояние аутентификации не было аутентифицировано, пользователь может увидеть форму входа в систему

> Очень важно определить, какими будут различные состояния, прежде чем погрузиться в реализацию.

Теперь, когда мы идентифицировали наши состояния аутентификации, мы можем реализовать наш класс `AuthenticationState`.

Создайте папку/каталог с именем `authentication_bloc` где мы сможем создать наши файлы блоков аутентификации.

```sh
├── authentication_bloc
│   ├── authentication_bloc.dart
│   ├── authentication_event.dart
│   ├── authentication_state.dart
│   └── bloc.dart
```

?> **Совет:** Вы можете использовать [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) или [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) расширения для автоматического создания файлов для вас.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String displayName;

  const Authenticated(this.displayName);

  @override
  List<Object> get props => [displayName];

  @override
  String toString() => 'Authenticated { displayName: $displayName }';
}

class Unauthenticated extends AuthenticationState {}
```

?> **Примечание**: Пакет [`equatable`](https://pub.dev/packages/equatable) используется для сравнения двух экземпляров `AuthenticationState`. По умолчанию `==` возвращает true только если два объекта являются одним и тем же экземпляром.

?> **Примечание**: `toString` переопределяется, чтобы упростить чтение `AuthenticationState` при печати его на консоли или в `Transitions`.

!> Поскольку мы используем `Equatable`, чтобы позволить нам сравнивать различные экземпляры `AuthenticationState`, нам нужно передать все свойства суперклассу. Без `List<Object> get props => [displayName]` мы не сможем правильно сравнить различные экземпляры `Authenticated`.

## Auth события

Теперь, когда мы определили `AuthenticationState`, нам нужно определить `AuthenticationEvents`, на который будет реагировать наш `AuthenticationBloc`.

Нам понадобится:

- событие `AppStarted`, чтобы уведомить блок о том, что ему нужно проверить, аутентифицирован ли пользователь в настоящее время или нет.
- событие `LoggedIn`, чтобы уведомить блок о том, что пользователь успешно вошел в систему.
- событие `LoggedOut`, чтобы уведомить блок о том, что пользователь успешно вышел из системы.

```dart
import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}
```

## Auth индекс

Прежде чем приступить к работе над реализацией `AuthenticationBloc`, мы экспортируем все файлы блоков аутентификации из нашего файла индекса `authentication_bloc/bloc.dart`. Это позволит нам импортировать `AuthenticationBloc`, `AuthenticationEvents` и `AuthenticationState` с последующим единственным импортом.

```dart
export 'authentication_bloc.dart';
export 'authentication_event.dart';
export 'authentication_state.dart';
```

## Auth блок

Теперь, когда у нас определены `AuthenticationState` и `AuthenticationEvents`, мы можем приступить к реализации `AuthenticationBloc`, который будет управлять проверкой и обновлением пользовательского `AuthenticationState` в ответ на `AuthenticationEvents`.

Мы начнем с создания нашего класса `AuthenticationBloc`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;
```

?> **Примечание**: Из определения класса мы уже знаем, что этот блок будет преобразовывать `AuthenticationEvents` в `AuthenticationStates`.

?> **Примечание**: `AuthenticationBloc` зависит от `UserRepository`.

Мы можем начать с переопределения `initialState` в состояние `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => Uninitialized();
```

Теперь все, что осталось, это реализовать `mapEventToState`.

```dart
@override
Stream<AuthenticationState> mapEventToState(
  AuthenticationEvent event,
) async* {
  if (event is AppStarted) {
    yield* _mapAppStartedToState();
  } else if (event is LoggedIn) {
    yield* _mapLoggedInToState();
  } else if (event is LoggedOut) {
    yield* _mapLoggedOutToState();
  }
}

Stream<AuthenticationState> _mapAppStartedToState() async* {
  try {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final name = await _userRepository.getUser();
      yield Authenticated(name);
    } else {
      yield Unauthenticated();
    }
  } catch (_) {
    yield Unauthenticated();
  }
}

Stream<AuthenticationState> _mapLoggedInToState() async* {
  yield Authenticated(await _userRepository.getUser());
}

Stream<AuthenticationState> _mapLoggedOutToState() async* {
  yield Unauthenticated();
  _userRepository.signOut();
}
```

Мы создали отдельные приватные вспомогательные функции для преобразования каждого `AuthenticationEvent` в надлежащий `AuthenticationState`, чтобы сохранить `mapEventToState` чистым и легким для чтения.

?> **Примечание:** Мы используем `yield*` (yield-each) в `mapEventToState`, чтобы разделить обработчики событий на их собственные функции. `yield*` вставляет все элементы последовательности в стройную последовательность, как если бы у нас был отдельный выход для каждого элемента.

Наш полный `authentication_bloc.dart` теперь должен выглядеть так:

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final name = await _userRepository.getUser();
        yield Authenticated(name);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _userRepository.getUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _userRepository.signOut();
  }
}
```

Теперь, когда наш `AuthenticationBloc` полностью реализован, давайте приступим к работе на уровне представления.

## Приложение

Мы начнем с удаления всего из `main.dart` и реализуем основную функцию самостоятельно.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}
```

Мы оборачиваем весь наш виджет `App` в `BlocProvider`, чтобы сделать `AuthenticationBloc` доступным для всего дерева виджетов.

?> `WidgetsFlutterBinding.ensureInitialized()` требуется во Flutter v1.9.4 перед использованием любых плагинов, если код выполняется перед `runApp`.

?> `BlocProvider` также автоматически закрывает `AuthenticationBloc`, поэтому нам не нужно этого делать.

Далее нам нужно реализовать наш виджет `App`.

> `App` будет `StatelessWidget` и будет отвечать за реакцию на состояние `AuthenticationBloc` и отрисовку соответствующего виджета.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Container();
        },
      ),
    );
  }
}
```

Мы используем `BlocBuilder` для визуализации интерфейса на основе состояния `AuthenticationBloc`.

Пока что у нас нет виджетов для рендеринга, но мы вернемся к этому как только мы сделаем `SplashScreen`, `LoginScreen` и `HomeScreen`.

## Делегат блока

Прежде чем мы зайдем слишком далеко, всегда удобно реализовать наш собственный `BlocDelegate`, который позволяет нам переопределять `onTransition` и `onError` и поможет нам увидеть все изменения состояния блока (переходы) и ошибки в одном месте!

Создайте `simple_bloc_delegate.dart` и давайте быстро реализуем наш собственный делегат.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

Теперь мы можем подключить наш `BlocDelegate` к нашему `main.dart`.

```dart
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}
```

## Заставка

Затем нам нужно создать виджет `SplashScreen`, который будет отображаться, пока наш `AuthenticationBloc` определяет, вошел ли пользователь в систему.

Давайте создадим `splash_screen.dart` и реализуем его!

```dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Splash Screen')),
    );
  }
}
```

Как вы можете заметить, этот виджет очень минималистичен и вы, возможно, захотите добавить какое-нибудь изображение или анимацию, чтобы он выглядел лучше. Ради простоты мы просто оставим все как есть.

Теперь давайте подключим его к нашему `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          return Container();
        },
      ),
    );
  }
}
```

Теперь, когда наш `AuthenticationBloc` имеет `state Uninitialized`, мы будем отображать наш виджет `SplashScreen`!

## Домашний экран

Затем нам нужно будет создать наш `HomeScreen`, чтобы мы могли переместить пользователя туда после того, как он успешно вошел в систему. В этом случае наш `HomeScreen` позволит пользователю выйти из системы, а также отобразит его текущее имя (адрес электронной почты).

Давайте создадим `home_screen.dart` и начнем.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';

class HomeScreen extends StatelessWidget {
  final String name;

  HomeScreen({Key key, @required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context).add(
                LoggedOut(),
              );
            },
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(child: Text('Welcome $name!')),
        ],
      ),
    );
  }
}
```

`HomeScreen` - это `StatelessWidget`, для которого требуется ввести имя, чтобы оно могло отобразить приветственное сообщение. Он также использует `BlocProvider` для доступа к `AuthenticationBloc` через `BuildContext`, так что когда пользователь нажимает кнопку выхода из системы, мы можем добавить событие `LoggedOut`.

Теперь давайте обновим наше приложение для отображения `HomeScreen` если для `AuthenticationState` установлено значение `Authentication`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/home_screen.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Authenticated) {
            return HomeScreen(name: state.displayName);
          }
        },
      ),
    );
  }
}
```

## Состояния входа

Наконец-то пришло время начать работу над процессом входа в систему. Мы начнем с определения различных `LoginStates`, которые у нас будут далее.

Создайте каталог `login` и создайте стандартный каталог и файлы блоков.

```sh
├── lib
│   ├── login
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
```

`login/bloc/login_state.dart` должен выглядеть так:

```dart
import 'package:meta/meta.dart';

@immutable
class LoginState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory LoginState.empty() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory LoginState.failure() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory LoginState.success() {
    return LoginState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  LoginState update({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  LoginState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return LoginState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''LoginState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}
```

Состояния, которые мы представляем:

`empty` - начальное состояние LoginForm.
`loading` - это состояние LoginForm, когда мы проверяем учетные данные
`fail` - это состояние LoginForm, когда попытка входа не удалась.
`success` - это состояние LoginForm, когда попытка входа в систему была успешной.

Для удобства мы также определили функцию `copyWith` и `update` (которую мы вскоре добавим).

Теперь, когда мы определили `LoginState`, давайте взглянем на класс `LoginEvent`.

## Login события

Откройте `login/bloc/login_event.dart` и давайте определим и реализуем наши события.

```dart
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends LoginEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends LoginEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends LoginEvent {
  final String email;
  final String password;

  const Submitted({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}

class LoginWithGooglePressed extends LoginEvent {}

class LoginWithCredentialsPressed extends LoginEvent {
  final String email;
  final String password;

  const LoginWithCredentialsPressed({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'LoginWithCredentialsPressed { email: $email, password: $password }';
  }
}
```

Определенные нами события:

`EmailChanged` - уведомляет блок о том, что пользователь изменил адрес электронной почты.
`PasswordChanged` - уведомляет блок о том, что пользователь сменил пароль
`Submitted` - уведомляет блок о том, что пользователь отправил форму
`LoginWithGooglePressed` - уведомляет блок о том, что пользователь нажал кнопку входа в Google
`LoginWithCredentialsPressed` - уведомляет блок о том, что пользователь нажал кнопку обычного входа.

## Файл индекса

Прежде чем мы реализуем `LoginBloc`, давайте удостоверимся, что наш индексный файл готов и мы могли легко импортировать все файлы, связанные с `LoginBloc` с помощью одного импорта.

```dart
export 'login_bloc.dart';
export 'login_event.dart';
export 'login_state.dart';
```

## Login блок

Пришло время реализовать наш `LoginBloc`. Как всегда, нам нужно расширить `Bloc` и определить наш `initialState`, а также `mapEventToState`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/validators.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  UserRepository _userRepository;

  LoginBloc({
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  LoginState get initialState => LoginState.empty();

  @override
  Stream<LoginState> transformEvents(
    Stream<LoginEvent> events,
    Stream<LoginState> Function(LoginEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<LoginState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<LoginState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _userRepository.signInWithGoogle();
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield LoginState.loading();
    try {
      await _userRepository.signInWithCredentials(email, password);
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }
}
```

**Примечание:** Мы переопределяем `transformEvents`, чтобы отменить события `EmailChanged` и `PasswordChanged` и дать пользователю время прекратить вводить текст перед проверкой ввода.

Мы используем класс `Validators` для проверки адреса электронной почты и пароля, которые мы собираемся реализовать далее.

## Валидаторы

Давайте создадим `validators.dart` и осуществим проверку электронной почты и проверку пароля.

```dart
class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  static final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  static isValidEmail(String email) {
    return _emailRegExp.hasMatch(email);
  }

  static isValidPassword(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
```

Здесь ничего особенного не происходит. Это просто старый добрый код Dart, который использует регулярные выражения для проверки адреса электронной почты и пароля. На этом этапе у нас должен быть полностью функциональный `LoginBloc`, который мы можем подключить к пользовательскому интерфейсу.

## Экран входа

Теперь, когда мы завершили `LoginBloc`, пришло время создать виджет `LoginScreen`, который будет отвечать за создание и закрытие `LoginBloc`, а также за предоставление `Scaffold` для нашего виджета `LoginForm`.

Создайте `login/login_screen.dart` и давайте его реализуем.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/login/login.dart';

class LoginScreen extends StatelessWidget {
  final UserRepository _userRepository;

  LoginScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(userRepository: _userRepository),
        child: LoginForm(userRepository: _userRepository),
      ),
    );
  }
}

```

Опять же, мы расширяем `StatelessWidget` и используем `BlocProvider` для инициализации и закрытия `LoginBloc`, а также для того, чтобы сделать экземпляр `LoginBloc` доступным для всех виджетов в поддереве.

На этом этапе нам нужно реализовать виджет `LoginForm`, который будет отвечать за отображение кнопок формы и отправки, чтобы пользователь мог аутентифицировать себя.

## Форма входа

Создайте `login/login_form.dart` и давайте создадим нашу форму.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/login/login.dart';

class LoginForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginForm({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginBloc _loginBloc;

  UserRepository get _userRepository => widget._userRepository;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isLoginButtonEnabled(LoginState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _loginBloc = BlocProvider.of<LoginBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Login Failure'), Icon(Icons.error)],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Logging In...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Form(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset('assets/flutter_logo.png', height: 200),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autovalidate: true,
                    autocorrect: false,
                    validator: (_) {
                      return !state.isPasswordValid ? 'Invalid Password' : null;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        LoginButton(
                          onPressed: isLoginButtonEnabled(state)
                              ? _onFormSubmitted
                              : null,
                        ),
                        GoogleLoginButton(),
                        CreateAccountButton(userRepository: _userRepository),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _loginBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _loginBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _loginBloc.add(
      LoginWithCredentialsPressed(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
```

Наш виджет `LoginForm` является `StatefulWidget`, потому что он должен поддерживать свой собственный `TextEditingControllers` для ввода адреса электронной почты и пароля.

Мы используем виджет `BlocListener`, чтобы выполнять одноразовые действия в ответ на изменения состояния. В этом случае мы показываем разные виджеты `SnackBar` в ответ на состояние ожидания/сбоя. Кроме того, если отправка прошла успешно, мы используем метод `listener` для уведомления `AuthenticationBloc` о том, что пользователь успешно вошел в систему.

?> **Совет:** Ознакомьтесь с [рецепт SnackBar](ru/recipesfluttershowsnackbar.md) для получения более подробной информации.

Мы используем виджет `BlocBuilder`, чтобы перестроить пользовательский интерфейс в ответ на различные `LoginStates`.

Всякий раз, когда электронная почта или пароль изменяются, мы добавляем событие в `LoginBloc`, чтобы он мог проверить текущее состояние формы и вернуть новое состояние.

?> **Примечание:** Мы используем `Image.asset` для загрузки логотипа Flutter из нашего каталога ресурсов.

На данный момент вы заметите, что мы не реализовали `LoginButton`, `GoogleLoginButton` или `CreateAccountButton`, но мы сделаем это дальше.

## Кнопка входа

Создайте `login/login_button.dart` и давайте быстро реализуем наш виджет `LoginButton`.

```dart
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback _onPressed;

  LoginButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text('Login'),
    );
  }
}
```

Здесь нет ничего особенного; просто `StatelessWidget`, который имеет некоторые стили и обратный вызов `onPressed`, то есть мы можем иметь собственный `VoidCallback` при каждом нажатии кнопки.

## Кнопка входа в Google

Создайте `login/google_login_button.dart` и давайте приступим к работе над нашим входом в Google.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      icon: Icon(FontAwesomeIcons.google, color: Colors.white),
      onPressed: () {
        BlocProvider.of<LoginBloc>(context).add(
          LoginWithGooglePressed(),
        );
      },
      label: Text('Sign in with Google', style: TextStyle(color: Colors.white)),
      color: Colors.redAccent,
    );
  }
}
```

Опять же, здесь не так уж много и происходит. У нас есть еще один `StatelessWidget`; однако на этот раз мы не выставляем обратный вызов `onPressed`. Вместо этого мы обрабатываем `onPressed` внутри и добавляем событие `LoginWithGooglePressed` в наш `LoginBloc`, который будет обрабатывать процесс входа в Google.

?> **Примечание:** Мы используем [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) для классного значка Google.

## Кнопка создания учетной записи

Последней из трех кнопок является `CreateAccountButton`. Давайте создадим `login/create_account_button.dart` и приступим к работе.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';

class CreateAccountButton extends StatelessWidget {
  final UserRepository _userRepository;

  CreateAccountButton({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Create an Account',
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterScreen(userRepository: _userRepository);
          }),
        );
      },
    );
  }
}
```

В этом случае мы снова имеем `StatelessWidget` и снова обрабатываем обратный вызов `onPressed`. На этот раз, однако, мы выставляем новый маршрут в ответ на нажатие кнопки на `RegisterScreen`. Давайте строить это дальше!

## Состояние регистрации

Как и при входе в систему нам нужно определить наши значения `RegisterStates`, прежде чем продолжить.

Создайте каталог `register` и стандартный `bloc` каталог с файлами.

```sh
├── lib
│   ├── register
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── register_bloc.dart
│   │   │   ├── register_event.dart
│   │   │   └── register_state.dart
```

`register/bloc/register_state.dart` должен выглядеть так:

```dart
import 'package:meta/meta.dart';

@immutable
class RegisterState {
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  bool get isFormValid => isEmailValid && isPasswordValid;

  RegisterState({
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory RegisterState.empty() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.loading() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory RegisterState.failure() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory RegisterState.success() {
    return RegisterState(
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  RegisterState update({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  RegisterState copyWith({
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitEnabled,
    bool isSubmitting,
    bool isSuccess,
    bool isFailure,
  }) {
    return RegisterState(
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''RegisterState {
      isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
    }''';
  }
}
```

?> **Примечание:** `RegisterState` очень похож на `LoginState` и мы могли бы создать одно состояние и разделить его между двумя; однако весьма вероятно, что функции входа в систему и регистрации будут различаться и в большинстве случаев лучше их не связывать.

Далее мы перейдем к классу `RegisterEvent`.

## События регистрации

Откройте `register/bloc/register_event.dart` и давайте реализуем наши события.

```dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends RegisterEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends RegisterEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class Submitted extends RegisterEvent {
  final String email;
  final String password;

  const Submitted({
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}
```

?> **Примечание:** Опять же, реализация `RegisterEvent` выглядит очень похоже на реализацию `LoginEvent`, но, поскольку они являются отдельными функциями, мы сохраняем их независимость в этом примере.

## Индекс регистрации

Опять же, как и при входе в систему, нам нужно создать файл индекса для экспорта файлов, связанных с блоком регистрации.

Откройте `bloc.dart` в нашей директории `register/bloc` и экспортируйте три файла.

```dart
export 'register_bloc.dart';
export 'register_event.dart';
export 'register_state.dart';
```

## Блок регистрации

Теперь давайте откроем `register/bloc/register_bloc.dart` и реализуем `RegisterBloc`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';
import 'package:flutter_firebase_login/validators.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserRepository _userRepository;

  RegisterBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  @override
  RegisterState get initialState => RegisterState.empty();

  @override
  Stream<RegisterState> transformEvents(
    Stream<RegisterEvent> events,
    Stream<RegisterState> Function(RegisterEvent event) next,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      next,
    );
  }

  @override
  Stream<RegisterState> mapEventToState(
    RegisterEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password);
    }
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<RegisterState> _mapFormSubmittedToState(
    String email,
    String password,
  ) async* {
    yield RegisterState.loading();
    try {
      await _userRepository.signUp(
        email: email,
        password: password,
      );
      yield RegisterState.success();
    } catch (_) {
      yield RegisterState.failure();
    }
  }
}
```

Как и прежде, нам нужно расширить `Bloc`, реализовать `initialState` и `mapEventToState`. По желанию, мы снова переопределяем `transformEvents`, чтобы дать пользователям время закончить печатать, прежде чем мы проверим форму.

Теперь, когда `RegisterBloc` полностью функционален, нам просто нужно создать уровень представления.

## Экран регистрации

Подобно `LoginScreen`, наш `RegisterScreen` будет `StatelessWidget`, отвечающим за инициализацию и закрытие `RegisterBloc`. Он также предоставит Scaffold для `RegisterForm`.

Создайте `register/register_screen.dart` и давайте реализуем это.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/register/register.dart';

class RegisterScreen extends StatelessWidget {
  final UserRepository _userRepository;

  RegisterScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Center(
        child: BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(userRepository: _userRepository),
          child: RegisterForm(),
        ),
      ),
    );
  }
}

```

## Регистрационная форма

Далее, давайте создадим `RegisterForm`, которая предоставит поля формы для пользователя, чтобы создать свою учетную запись.

Создайте `register/register_form.dart` и давайте его создадим.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/register/register.dart';

class RegisterForm extends StatefulWidget {
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  RegisterBloc _registerBloc;

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  bool isRegisterButtonEnabled(RegisterState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }

  @override
  void initState() {
    super.initState();
    _registerBloc = BlocProvider.of<RegisterBloc>(context);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.isSubmitting) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registering...'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          BlocProvider.of<AuthenticationBloc>(context).add(LoggedIn());
          Navigator.of(context).pop();
        }
        if (state.isFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registration Failure'),
                    Icon(Icons.error),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: BlocBuilder<RegisterBloc, RegisterState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Form(
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    autovalidate: true,
                    validator: (_) {
                      return !state.isEmailValid ? 'Invalid Email' : null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autocorrect: false,
                    autovalidate: true,
                    validator: (_) {
                      return !state.isPasswordValid ? 'Invalid Password' : null;
                    },
                  ),
                  RegisterButton(
                    onPressed: isRegisterButtonEnabled(state)
                        ? _onFormSubmitted
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _registerBloc.add(
      EmailChanged(email: _emailController.text),
    );
  }

  void _onPasswordChanged() {
    _registerBloc.add(
      PasswordChanged(password: _passwordController.text),
    );
  }

  void _onFormSubmitted() {
    _registerBloc.add(
      Submitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }
}
```

Опять же, нам нужно управлять `TextEditingControllers` для ввода текста, поэтому наша `RegisterForm` должна быть `StatefulWidget`. Кроме того, мы снова используем `BlocListener`, чтобы выполнить одноразовые действия в ответ на изменения состояния, такие как показ `SnackBar`, когда регистрация ожидает или не удается. Мы также добавляем событие `LoggedIn` в `AuthenticationBloc` если регистрация прошла успешно, чтобы мы могли немедленно войти в систему.

?> **Примечание:** Мы используем `BlocBuilder`, чтобы заставить наш пользовательский интерфейс реагировать на изменения в состоянии `RegisterBloc`.

Давайте создадим наш виджет `RegisterButton` дальше.

## Кнопка регистрации

Создайте `register/register_button.dart` и начнем.

```dart
import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback _onPressed;

  RegisterButton({Key key, VoidCallback onPressed})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text('Register'),
    );
  }
}
```

Очень похоже на то, как мы настраивали `LoginButton`, `RegisterButton` имеет некоторый пользовательский стиль и предоставляет `VoidCallback`, чтобы мы могли обрабатывать каждый раз, когда пользователь нажимает кнопку в родительском виджете.

Все, что осталось сделать - это обновить наш виджет `App` в `main.dart`, чтобы показать `LoginScreen`, если для `AuthenticationState` установлено значение `Unauthenticated`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/home_screen.dart';
import 'package:flutter_firebase_login/login/login.dart';
import 'package:flutter_firebase_login/splash_screen.dart';
import 'package:flutter_firebase_login/simple_bloc_delegate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final UserRepository userRepository = UserRepository();
  runApp(
    BlocProvider(
      create: (context) => AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted()),
      child: App(userRepository: userRepository),
    ),
  );
}

class App extends StatelessWidget {
  final UserRepository _userRepository;

  App({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is Uninitialized) {
            return SplashScreen();
          }
          if (state is Unauthenticated) {
            return LoginScreen(userRepository: _userRepository);
          }
          if (state is Authenticated) {
            return HomeScreen(name: state.displayName);
          }
        },
      ),
    );
  }
}
```

На данный момент у нас есть довольно надежная реализация входа в систему с использованием `Firebase` и мы отделили наш уровень представления от уровня бизнес-логики с помощью библиотеки `Bloc`.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
