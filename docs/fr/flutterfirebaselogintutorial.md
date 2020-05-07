# Tutoriel formulaire de connexion Flutter avec Firebase

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> Dans ce tutorial, nous allons voir comment créer une formulaire de connexion Firebase en utilisant la librairie Bloc dans Flutter.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Installation

Commençons par créer un tout nouveau projet Flutter.

```bash
flutter create flutter_firebase_login
```
Nous pouvons ensuite remplacer le contenu du fichier `pubspec.yaml` par :

```yaml
name: flutter_firebase_login
description: A new Flutter project.

version: 1.0.0+1

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^0.4.0+8
  google_sign_in: ^4.0.0
  firebase_auth: ^0.15.0+1
  flutter_bloc: ^4.0.0
  equatable: ^1.0.0
  meta: ^1.1.6
  rxdart: ^0.23.1
  font_awesome_flutter: ^8.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/
```
Notez que nous spécifions un fichier contenant les assets pour tous les assets locales de notre application.
Créez un dossier `assets` à la racine du projet et ajoutez le [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) asset (nous l'utiliserons plus tard).

ensuite installez toutes les dependencies : 

```bash
flutter packages get
```
La dernière chose qu'on le doit faire est suivre [firebase_auth usage instructions](https://pub.dev/packages/firebase_auth#usage) 
dans le but de relier notre l'application et d'activer [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Comme dans [flutter login tutorial](./flutterlogintutorial.md), nous allons créer notre `UserRepository` qui sera responsable pour l'abstraction de toutes les implémentations futures sous jacentes comme quelle authentification nous allons utiliser et pour récupérer les valeurs de l'utilisateur connectés.

Commençons par créer `user_repository.dart`.

Premiérement, nous allons définir la class `UserRepository` et implémenter son constructeur. On peut directement constater que `UserRepository` aura une dépendance sur `FirebaseAuth` et `GoogleSignIn`.

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

?> **Note:** Si `FirebaseAuth` et/ou `GoogleSignIn` ne sont pas injectés à `UserRepository`, alors nous les instancions nous mêmes. Cela nous permet d'injecter des instances mock pour pouvoir facilement tester `UserRepository`.

 `signInWithGoogle` sera la première méthode que nous allons implémenter et elle authentifiera l'utilisateur en utilisant le `GoogleSignIn` package.

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

En suite nous allons implémenter `signInWithCredentials` méthodequi permettra à l'utilisatgeur d'utiliser ses propres identifiants en utilisant `FirebaseAuth`.

```dart
Future<void> signInWithCredentials(String email, String password) {
  return _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

Ensuite, nous avons besoin d'implémenter `signUp` méthode qui va permettre aux utilisateurs de se créer un compte si ils n'ont pas choisi Google Sign in.

```dart
Future<void> signUp({String email, String password}) async {
  return await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```

Implémentons ensuite `signOut`méthode pour que les utilisateurs puissent se déconnecter et que l'on supprime les informations de leur profil.
```dart
Future<void> signOut() async {
  return Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut(),
  ]);
}
```

Enfin, nous avons besoin de deux méthodes supplémentaires `isSignedIn` et `getUser`qui nous permet de vérifier si un utilisateur est déjà connecté et la deuxième de récupérer ses informations.
```dart
Future<bool> isSignedIn() async {
  final currentUser = await _firebaseAuth.currentUser();
  return currentUser != null;
}

Future<String> getUser() async {
  return (await _firebaseAuth.currentUser()).email;
}
```

?> **Note:** `getUser` retourne uniquement l'adresse mail de l'utilisateur connecté pour faire simple mais nous pourrions définir notre propre modèle User et lui ajouter beaucoup plus d'informations sur l'utilisateur pour en des applications plus complexes.

Notre fichier `user_repository.dart` terminé devrait ressembler à ceci :

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
Ensuite, nous allons construire notre `AuthenticationBloc` qui sera responsable de gérer le `AuthenticationState`de l'application qui lui répondra à `AuthenticationEvents`.

## Authentication States (Les états d'authentification)

Nous avons besoin de déterminer comment nous allons gérer le state ("état") de notre application et créer les blocs (business logic components) nécessaires.
A un haut niveau, nous allons devoir gérer l'Authentification state de l'utilisateur. Le state d'un utilisateur peut être l'un parmis la liste suivante : 

- uninitialized - attend de voir si l'utilisateur est authentifié ou non quand l'application commence.
- authenticated - l'authentification est un succès.
- unauthenticated - non authentifié.

Chacun de ses états (states) modifiera ce que l'utilisateur verra.

Par exemple :
- si l'authentification state est uninitialized, l'utilisateur pourrait voir un splash screen.
- si l'authentification state est authenticated, l'utilisateur pourrait voir la page d'accueil.
- si l'authentification state est unauthenticated, l'utilisateur pourrait voir un formulaire de connexion.

> Il est important d'identifier quels seront les différents états (states) avant de plonger dans leur implémentation. 

Maintenant que les états(states) d'authentification sont identifiés, nous pouvons implémenter notre class `AuthenticationState`.

Créer une dossier/répertoire appelé `authentication_bloc` dans lequel nous allons créer nos fichiers d'authentification bloc.

```sh
├── authentication_bloc
│   ├── authentication_bloc.dart
│   ├── authentication_event.dart
│   └── authentication_state.dart
```

?> **Conseil:** Vous pouvez utiliser le plugin [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) pour générer les fichiers automatiquement.

```dart
part of 'authentication_bloc.dart';

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

?> **Note**: Le package [`equatable`](https://pub.dev/packages/equatable) est utilisé dans le but de permettre de comparer deux instances de `AuthenticationState`. Par défaut, `==` renvoie true seulement si deux objets ont la même instance.

?> **Note**: `toString` est "overridden" pour faciliter la lecture d'un `AuthenticationState` quand on l'affiche dans la console ou dans `Transitions`.

!> Puisque nous utilisons `Equatable` pour pouvoir comparer deux instances de `AuthenticationState`, nous avons besoin de passer toutes les propriétés de la superclass. Sans `List<Object> get props => [displayName]`, nous ne pourrions pas comparer proprement différentes instances de  `Authenticated`.

## Authentication Events (les événements d'authentification)

Maintenant que nous avons notre `AuthenticationState` de définie, nous allons définir `AuthenticationEvents` auquel notre `AuthenticationBloc`réagira.

Nous allons avoir besoin :

- d'un événement `AppStarted` pour notifier le bloc qu'il a besoin de vérifier si l'utilisateur est actuellement authentifié ou non.
- d'un événement `LoggedIn` pour notifier le bloc que l'utilisateur s'est connecté avec succès.
- d'un événement `LoggedOut` pour notifier le bloc que l'utilisateur s'est déconnecté avec succès.

```dart
part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}
```

## Authentication Bloc (Le bloc d'authentification)

Maintenant que nous avons notre `AuthenticationState` et `AuthenticationEvents` de définis, nous pouvons travailler sur l'implémentation de `AuthenticationBloc` qui va s'occuper de vérifier et d'actualiser l'`AuthenticationState` d'un utilisateur en réponse à `AuthenticationEvents`.

Nous allons commencer par créer notre class `AuthenticationBloc`.

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;
```

?> **Note**: Juste en lisant la class, nous savons déjà que le bloc convertira `AuthenticationEvents` en `AuthenticationStates`.

?> **Note**: Notre `AuthenticationBloc` a des dépendances avec `UserRepository`.

Nous pouvons commencer par overriding `initialState` à l'état (state) `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => Uninitialized();
```
Maintenant il nous reste plus qu'à implémenter `mapEventToState`.

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
  final isSignedIn = await _userRepository.isSignedIn();
  if (isSignedIn) {
    final name = await _userRepository.getUser();
    yield Authenticated(name);
  } else {
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
Les fonctions privés `_mapLoggedInToState()` ou `_mapLoggedOutToState()` sont crées en dehors de `mapEventToState` pour convertir chaque `AuthenticationEvent` en son propre `AuthenticationState` et dans le but de garder `mapEventToState` le plus propre et facile à lire possible.


?> **Note:** Nous utilisions `yield*` (yield-each) dans `mapEventToState` pour séparer les event handler dans leurs propres fonctions. `yield*` insert tous les élements de la sous-séquence dans la séquence actuellement construite, comme si nous avions un yiel individuel poour chaque élément.

Notre `authentication_bloc.dart` devrait ressembler à ceci maintenant :

```dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_login/user_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

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
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final name = await _userRepository.getUser();
      yield Authenticated(name);
    } else {
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

Maintenant que nous avons notre `AuthenticationBloc` entièrement implenté, nous pouvons maintenant travailler sur la couche de présentation.

## App

Nous allons commencer par supprimer tout le contenu de `main.dart` et implémenter notre fonction main.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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
Nous envelopons notre widget `App` entière dans un `BlocProvider` dans le but de mettre l'`AuthenticationBloc` disponible partout dans l'arbre du widget.


?> `WidgetsFlutterBinding.ensureInitialized()` est requis dans Flutter v1.9.4+ avant d'utiliser n'importe quel plugin si le code est exécuée avant runApp.

?> `BlocProvider` gère aussi la fermeture `AuthenticationBloc` automatiquement donc nous n'en avons pas besoin de nous en occuper.

Ensuite, nous allons implémenter notre widget `App`.

> `App` sera un `StatelessWidget` et réagira à `AuthenticationBloc` state et affichera le widget approprié.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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

Nous utilisons `BlocBuilder` dans le but d'afficher l'UI en fonction du  `AuthenticationBloc` state.
`SplashScreen`,

À  l'heure actuelle nous n'avons pas de widget à afficher mais nous y reviendrons plus tard quand nous allons créer `SplashScreen`, `LoginScreen`, et `HomeScreen`.

## Bloc Delegate

Avant de rentrer dans le vif du sujet, c'est toujours une bonne pratique d'implémenter notre propre `BlocDelegate` ce qui nous permet d'override `onTransition` et `onError` ce qui va nous aider à voir tous les changements d'état (state) des blocs (les transifitions) et les erreurs à une seule et même place!

Créez `simple_bloc_delegate.dart` et implémentons rapidement notre delegate.

```dart
import 'package:bloc/bloc.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    print(event);
    super.onEvent(bloc, event);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition);
    super.onTransition(bloc, transition);
  }
}
```

Maintenant nous pouvons attraper (hook up) notre `BlocDelegate` dans notre `main.dart`.

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

## Splash Screen (Ecran d'atterrissage)

Ensuite, nous allons créer un `SplashScreen` widget qui s'affichera pendant qu'`AuthenticationBloc` détermine si un utilisateur est connecté ou non.

Créeons `splash_screen.dart` et implémentons le!

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

Comme vous pouvez le voir, ce widget est super minimalist et nous pourrions y ajouter des images ou des animations dans le but de le rendre plus esthétique à regarder. 
As you can tell, this widget is super minimal and you would probably want to add some sort of image or animation in order to make it look nicer. Pour rester dans la simplicité nous allons juste le laisser tel quel.

Maintenant, rattachons le à `main.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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
Maintenant peu importe quand notre `AuthenticationBloc` a un `state` de `Uninitialized` nous allons afficher le widget `SplashScreen`!

## Home Screen (Page d'accueil)

Ensuite, nous allons avoir besoin de créer notre `HomeScreen` pour que l'on puisse diriger l'utilisateur une fois qu'ils ont réussi à se connecter. Dans ce cas, notre `HomeScreen` va permettre à l'utilisateur de se déconnecter mais également de lui montre son email actuel.

Créons `home_screen.dart` et commençons.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';

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

`HomeScreen` est `StatelessWidget` qui requiert `name` d'être injecté pour qu'il puisse afficher le message de bienvenue. Il utilise aussi `BlocProvider` pour accèder à `AuthenticationBloc` via `BuildContext` pour que lorsqu'un utilisateur presse le boutton se déconnecter, nous pouvons ajouter l'évenement `LoggedOut`.

Maintenant nous allons actualiser `App` pour afficher `HomeScreen` si l'`AuthenticationState` est `Authentication`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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

## Login States (Les états de connexion)

Nous pouvons enfin commencer à travailler sur l'environnement de connexion. Nous allons commencer par identifier différents `LoginStates` que nous aurons.

Créez un dossier `login` et créer le schéma classique du dossier bloc et ses fichiers.

```sh
├── lib
│   ├── login
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── login_bloc.dart
│   │   │   ├── login_event.dart
│   │   │   └── login_state.dart
```

Notre `login/bloc/login_state.dart` devrait ressembler à ceci:

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

Les états (states) que nous allons utiliser sont:

`empty` est le state initial de LoginForm.

`loading` est le state du LoginForm quand nous procéssons à la validation des identifiants.

`failure` est le state LoginForm si la connexion a échoué.

`success` est le state du LoginForm si la connexion est un succès.

Nous avons aussi définis les fonctions `copyWith` et une fonction `update` par commodité (nous allons nous en servir bientôt).

Maintenant que le `LoginState` est défini, jetons un oeil sur la class `LoginEvent`.

## Login Events (Evénements de connexion)

Ouvrez `login/bloc/login_event.dart` et définissons et implémentons nos événements.

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

Les événements que nous avons définis sont:

`EmailChanged` - notifie que le bloc que l'email a changé

`PasswordChanged` - notifie le bloc que l'utilisateur a changé le mot de passe

`Submitted` - notifie le bloc que l'utilisateur a soumis le formulaire

`LoginWithGooglePressed` - notifie le bloc que l'utilisateur a pressé le bouton Google Sign In

`LoginWithCredentialsPressed` - notifie le bloc que l'utilisateur a pressé le bouton classique de connexion

## Login Barrel File (Fichier Baril pour la connexion)

Avant d'implémenter `LoginBloc`, assurons nous que notre fichier baril est fait pour que nous puissions importer facilement tous les fichiers reliés à notre Bloc de connexion en un seul import.

```dart
export 'login_bloc.dart';
export 'login_event.dart';
export 'login_state.dart';
```

## Login Bloc (Bloc de connexion)

Il est temps d'implémenter notre `LoginBloc`. Comme toujours, nous avons besoin d'étendre `Bloc` et définir notre `initialState` et notre `mapEventToState`.

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
  Stream<Transition<LoginEvent, LoginState>> transformEvents(
    Stream<LoginEvent> events,
    TransitionFunction<LoginEvent, LoginState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
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

**Note:** Nous allons override `transformEvents` dans le but debounce les événements `EmailChanged` et `PasswordChanged`  so pour que les utilisateurs aient le temps d'arrêter d'écrire avant de valider l'input.

Nous utilisons une class `Validators` pour valider l'email et le mot de passe, nous allons l'implémenter maintenant.

## Validators

Créeons  `validators.dart` et implémentons notre validation pour notre email et notre mot de passe.

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

On ne fait rien de spécial ici. Nous utilisons du code Dart pour utiliser des expressions régulières pour valider l'email et le mot de passe. Maintenant, vous devriez avoir une une class `LoginBloc` entièrement fonctionnel que l'on peut rattacher à notre UI.

## Login Screen (Écran de connexion)

Maintenant que nous avons fini le `LoginBloc`, il est temps de créer notre widget `LoginScreen` qui sera responsable de créer et de fermer le `LoginBloc` et aussi à fournir le Scaffold pour notre widget `LoginForm`.

Créez `login/login_screen.dart` et implémentons le.

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

Encore une fois, extendons `StatelessWidget`et utilisons un `BlocProvider` pour initialiser et fermer le `LoginBloc` aussi bien que pour permettre à l'instance `LoginBloc` d'être disponible partout à tous les widgets à l'intérieur du sous-arbre (sub-tree).

Maintenant, nous allons devoir implémenter le widget `LoginForm` qui sera responsable de l'affichage du formulaire et de la soumission des bouttons dans le but que l'utilisateur puisse s'authentifier lui même.

## Login Form (Formulaire de connexion)

Créez `login/login_form.dart` et construisons notre formulaire.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/user_repository.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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

Notre widget `LoginForm` est un `StatefulWidget` car il a besoin de maintenir ses propres `TextEditingControllers` pour les champs e-mail et mot de passe.

Nous utilisions un widget `BlocListener` pour exécuter en une fois les actions en réponse aux changements de states (états). Dans ce cas, nous allons afficher différentes `SnackBar`  en réponse aux states (états) en attente ou qui ont échoués. En plus de cela, si la soumission est une réussite, nous allons utiliser la méthode `listener` pour notifier l'`AuthenticationBloc` que l'utilisateur a réussi à se connecter.

?> **Tip:** Allez voir la [SnackBar Recette](recipesfluttershowsnackbar.md) pour plus d'informations.

On utilise le widget `BlocBuilder` dans le but de reconstruire l'UI en réponse aux différents `LoginStates`.

Peu importe si l'email ou le mot de passe change, nous ajoutons un événement au `LoginBloc`dans le but qu'il valide l'état actuel du formulaire (current form state) et qu'il retourne le nouvel état du formulaire (new form state)
Whenever the email or password changes, we add an event to the `LoginBloc` in order for it to validate the current form state and return the new form state.

?> **Note:** Nous utilisons `Image.asset` pour charger le logo de Flutter via notre dossier assets.

Maintenant, vous devriez remarquez que nous n'avons pas implémenter `LoginButton`, `GoogleLoginButton`, or `CreateAccountButton`, c'est ce que nous allons faire dès à présent.

## Login Button (Bouton de connexion)

Créez `login/login_button.dart` et implémentons rapidement notre widget `LoginButton`.

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

Encore une fois, rien de spécial dans ce code; nous avons juste un `StatelessWidget` qui a un peu de style et un `onPressed` callback (fonction de rappel) pour que l'on puisse exécuté une fonction `VoidCallback` customisé à chaque fois que le bouton est pressé. 

## Google Login Button (Boutton de connexion Google)

Créez `login/google_login_button.dart` et travaillons sur notre Google Sign In.

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

Encore une fois, il n'y a rien de spécial dans ce snippet. Nous avons un autre `StatelessWidget`; par contre cette fois nous n'exposons pas une fonction de rappel (callback) sur `onPressed`.
A la place, nous allons le gérer à l'intérieur et nous ajoutons l'event (événement) `LoginWithGooglePressed` à notre `LoginBloc` qui lui va gérer le processus du Google Sign In.

?> **Note:** Nous utilisons [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) pour l'icône Google.

## Créer le bouton 'Créer un compte'

Le dernier des trois boutons est `CreateAccountButton`. Commençons par créer `login/create_account_button.dart` et  mettons nous au travail !

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

Dans ce cas, encore une fois nous un `StatelessWidget`et encore une fois nous gérons la fonction de rappel (callback) à l'intérieur du widget. Cette fois, toutefois, nous allons lui ajouter une nouvelle route en réponse au click sur le bouton pour rediriger vers `RegisterScreen`. Allons-y!

## Register States (Etats d'enregistrement)

Comme pour le login (connexion), nous allons avoir besoin de définir notre `RegisterStates` avant de procéder.

Créez un dossier `register` et créez un standard dossier bloc avec ses fichiers comme ci-dessous:

```sh
├── lib
│   ├── register
│   │   ├── bloc
│   │   │   ├── bloc.dart
│   │   │   ├── register_bloc.dart
│   │   │   ├── register_event.dart
│   │   │   └── register_state.dart
```

Notre `register/bloc/register_state.dart` devrait ressembler à ceci:

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

?> **Note:** Le `RegisterState` est très similaire au `LoginState` et nous pourrions créer un seul événement (state) et le partager entre les deux fichiers; cependant, il est très probable que Le Login (connexion) et le Register(inscription) auront des divergences et donc la plus part du temps il vaut mieux les séparer.
Ensuite passons à la class `RegisterEvent`.

## Register Events (Evénements d'inscription)

Ouvrez `register/bloc/register_event.dart` et implémentons nos événements.

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

?> **Note:** Encore une fois, l'implémentation du `RegisterEvent` ressemble fortement à celui du `LoginEvent` mais puisqu'il s'agit de deux features indépendantes nous les gardons séparées l'une de l'autre.

## Register Barrel File (Fichier baril pour l'inscription)

Encore une fois, tout comme pour le login, nous avons besoin de créer un fichier baril pour exporter tous les fichiers relatif à notre bloc d'inscription (register bloc).
Ouvrez `bloc.dart` dans le dossier `register/bloc` et exportez les trois fichiers.

```dart
export 'register_bloc.dart';
export 'register_event.dart';
export 'register_state.dart';
```

## Register Bloc (Bloc d'inscription)

Maintenant, ouvrons `register/bloc/register_bloc.dart` et implémentons `RegisterBloc`.

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
  Stream<Transition<RegisterEvent, RegisterState>> transformEvents(
    Stream<RegisterEvent> events,
    TransitionFunction<RegisterEvent, RegisterState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
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

Comme avant, nous avons besoin d'étendre `Bloc`, d'implémenter `initialState` et `mapEventToState`. Accessoirement, nous overridons `transformEvents` encore une fois pour que l'on puisse donner aux utilisateurs le temps de rentrer des informations avant de valider le formulaire.

Maintenant que notre `RegisterBloc` est entièrement fonctionnel, nous avons juste à construire l'interface.

## Register Screen (L'écran d'inscription)

Comme pour `LoginScreen`, notre `RegisterScreen` sera un `StatelessWidget` responsable pour initialiser et fermer le `RegisterBloc`. Il fournira également le Scaffold pour `RegisterForm`.

Créons `register/register_screen.dart` et implémentons le.

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

## Register Form (Formulaire d'inscription)

Ensuite, créons le `RegisterForm` qui fournira les champs du formulaire pour qu'un utilisateur puisse créer son compte.
Créons `register/register_form.dart` et construisons le.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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
Encore une fois, nous avons besoin de gérer les `TextEditingControllers` pour les champs textes de notre `RegisterForm`, il a donc besoin d'être un `StatefulWidget`.En plus de cela, nous utilisons un `BlocListener` encore une fois dans le but d'exécuter actions en un temps (one-time actions) en réponse aux changements d'états (states) comme par exemple monter une `SnackBar` quand l'inscription est en cours ou si elle échoue. Nous ajoutons également l'évenement (event) `LoggedIn` à l'`AuthenticationBloc` si l'inscription a été un succès pour qu'on puisse connecter directement le l'utilisateur.

?> **Note:** Nous utilisons `BlocBuilder` dans le but de mettre que notre UI puisse répondre aux changements dans le `RegisterBloc` state.

Ensuite, construisons notre widget `RegisterButton`.

## Register Button (Bouton d'inscription)

Créons `register/register_button.dart` et commençons.

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
C'est très similaire à l'installation faite pour `LoginButton`, le `RegisterButton` a du code pour changer son style et il expose une fonction  `VoidCallback` pour que l'on puisse gérer le moment où l'utilisateur va appuyer sur le bouton de le Widget parent.

Tout ce qui nous reste à faire est d'actualiser notre widget `App` dans `main.dart` pour afficher le `LoginScreen` si le `AuthenticationState` est `Unauthenticated`.

```dart
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_firebase_login/authentication_bloc/authentication_bloc.dart';
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

Maintenant nous avons un formulaire de connexion assez robuste utilisant Firebase and nous avons notre couche de présentation qui est séparé de notre couche de business logic tout cela en utilisant la librairie Bloc.

Le code source entier de cette exemple est trouvable [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
