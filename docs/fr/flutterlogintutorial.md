# Tutoriel Flutter Connexion

![intermédiaire](https://img.shields.io/badge/level-intermediate-orange.svg)

> Dans le tutoriel suivant, nous allons construire un flux de connexion dans Flutter en utilisant la bibliothèque Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

```bash
flutter create flutter_login
```

Nous pouvons alors remplacer le contenu de `pubspec.yaml` par

```yaml
name: flutter_login
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^2.0.0
  meta: ^1.1.6
  equatable: ^0.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

et ensuite installer toutes nos dépendances
``
```bash
flutter packages get
```
``
## Répertoire utilisateur

Nous allons devoir créer un `UserRepository` qui nous aide à gérer les données d'un utilisateur.

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

?> **Note**: Notre référentiel utilisateur se moque des différentes implémentations pour des raisons de simplicité, mais dans une application réelle, vous pouvez injecter un [HttpClient] (https://pub.dev/packages/http) ainsi que quelque chose comme [Flutter Secure Storage] (https://pub.dev/packages/flutter_secure_storage) afin de demander des tokens et de les lire/écrire dans un trousseau de clés.

## Etats d'authentification

Ensuite, nous allons devoir déterminer comment nous allons gérer l'état de notre application et créer les blocs nécessaires (composants logiques métier).

A un haut niveau, nous allons devoir gérer l'état d'authentification de l'utilisateur. L'état d'authentification d'un utilisateur peut être l'un des suivants :

- uninitialized - en attendant de voir si l'utilisateur est authentifié ou non au démarrage de l'application.
- loading - attente pour persister/supprimer un jeton
- authenticated - authentifié avec succès
- unauthenticated - non authentifié

Chacun de ces états aura une implication sur ce que l'utilisateur voit.

Par exemple :

- si l'état d'authentification n'a pas été initialisé, l'utilisateur peut voir un écran de démarrage.
- si l'état d'authentification était en cours de chargement, l'utilisateur peut voir un indicateur de progression.
- si l'état d'authentification a été authentifié, l'utilisateur peut voir un écran d'accueil.
- si l'état d'authentification n'était pas authentifié, l'utilisateur peut voir un formulaire de connexion.

> Il est essentiel d'identifier ce que seront les différents états avant de se plonger dans la mise en œuvre.

Maintenant que nous avons identifié nos états d'authentification, nous pouvons implémenter notre classe `AuthenticationState`.

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

## Événements d'authentification

Maintenant que nous avons défini notre `AuthenticationState`, nous devons définir les `AuthenticationEvents` auxquels notre `AuthenticationBloc` va réagir.
Nous en aurons besoin :

- un événement `AppStarted` pour avertir le bloc qu'il doit vérifier si l'utilisateur est actuellement authentifié ou non.
- un événement `LoggedIn` pour notifier au bloc que l'utilisateur s'est connecté avec succès.
- a événement `LoggedOut` pour avertir le bloc que l'utilisateur s'est déconnecté avec succès.

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

?> **Note**: le paquet `meta` est utilisé pour annoter les paramètres `AuthenticationEvent` comme `@required`. L'analyseur dart avertira les développeurs s'ils ne fournissent pas les paramètres requis.

## Bloc d'authentification

Maintenant que nous avons défini nos `AuthenticationState` et `AuthenticationEvents`, nous pouvons commencer à travailler sur l'implémentation du `AuthenticationBloc` qui va gérer la vérification et la mise à jour du `AuthenticationState` d'un utilisateur en réponse aux `AuthenticationEvents`.

Nous allons commencer par créer notre classe `AuthenticationBloc`.

```dart
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;

  AuthenticationBloc({@required this.userRepository}): assert(userRepository != null);
}
```

?> **Note**: Rien qu'en lisant la définition de classe, nous savons déjà que ce bloc va convertir `AuthenticationEvents` en `AuthenticationStates`.

?> **Note**: Notre `AuthenticationBloc` dépend du `UserRepository`.

Nous pouvons commencer par remplacer l'état `initialState` par l'état `AuthenticationUninitialized()`.

```dart
@override
AuthenticationState get initialState => AuthenticationUninitialized();
```

Maintenant, il ne reste plus qu'à mettre en œuvre `mapEventToState`.

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

Super ! Notre `AuthenticationBloc` final devrait ressembler à ce qui suit

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

Maintenant que notre `AuthenticationBloc` est complètement implémenté, commençons à travailler sur la couche présentation.

## Ecran d'accueil

La première chose dont nous aurons besoin est un widget `SplashPage` qui servira d'écran d'accueil pendant que notre `AuthenticationBloc` détermine si un utilisateur est connecté ou non.

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

## Page d'accueil

Ensuite, nous devrons créer notre `HomePage` pour que nous puissions y naviguer les utilisateurs une fois qu'ils se sont connectés avec succès.

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

?> **Note**: C'est la première classe dans laquelle nous utilisons `flutter_bloc`. Nous entrerons dans `BlocProvider.of<AuthenticationBloc>(contexte)` prochainement mais pour l'instant nous savons juste qu'il permet à notre `HomePage` d'accéder à notre `AuthenticationBloc`.

?> **Note**: Nous ajoutons un événement `LoggedOut` à notre `AuthenticationBloc` lorsqu'un utilisateur appuie sur le bouton Logout.

Ensuite, nous devons créer une `LoginPage ` et un `LoginForm`.

Parce que le `LoginForm` devra gérer l'entrée des utilisateurs (Bouton de connexion appuyé) et aura besoin d'une logique métier (obtenir un jeton pour un nom d'utilisateur/mot de passe donné), nous devrons créer un `LoginBloc`.

Tout comme nous l'avons fait pour le `AuthenticationBloc`, nous devrons définir le `LoginState`, et `LoginEvents`. Commençons par `LoginState'.

## États de connexion

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

`LoginInitial` est l'état initial du LoginForm.

`LoginLoading` est l'état du LoginForm lorsque nous validons les informations d'identification

`LoginFailure` est l'état du LoginForm lorsqu'une tentative de connexion a échoué.

Maintenant que nous avons défini `LoginState`, jetons un coup d'oeil à la classe `LoginEvent`.

## Évènements de connexion

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

`LoginButtonPressed` sera ajouté lorsqu'un utilisateur appuiera sur le bouton de connexion. Il informera le `LoginBloc` qu'il doit demander un jeton pour les informations d'identification données.

Nous pouvons maintenant implémenter notre `LoginBloc`.

## Bloc de connexion

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

?> **Note**: `LoginBloc` dépend de `UserRepository' pour authentifier un utilisateur avec un nom d'utilisateur et un mot de passe.

?> **Note**: `LoginBloc` dépend de `AuthenticationBloc` pour mettre à jour l'état d'authentification lorsqu'un utilisateur a saisi des informations d'identification valides.

Maintenant que nous avons notre `LoginBloc` nous pouvons commencer à travailler sur `LoginPage` et `LoginForm`.

## Page de connexion

Le widget `LoginPage` servira de widget conteneur et fournira les dépendances nécessaires au widget `LoginForm` (`LoginBloc` et `AuthenticationBloc`).

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

?> **Note**: `LoginPage` est un `StatelessWidget'. Le widget `LoginPage` utilise le widget `BlocProvider` pour créer, fermer et fournir le `LoginBloc` au sous-arbre.

?> **Note**: Nous utilisons le `UserRepository` injecté pour créer notre `LoginBloc`.

?> **Note**: Nous utilisons `BlocProvider.of<AuthenticationBloc>(contexte)` à nouveau pour accéder au `AuthenticationBloc` depuis la `LoginPage`.

Ensuite, créons notre `LoginForm`.

## Formulaire de connexion

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

?> **Note**: Notre `LoginForm` utilise le widget `BlocBuilder` pour qu'il puisse être reconstruit chaque fois qu'il y a un nouvel `LoginState`. `BlocBuilder` est un widget Flutter qui nécessite une fonction Bloc et un constructeur. `BlocBuilder` gère la construction du widget en réponse aux nouveaux états. `BlocBuilder` est très similaire à `StreamBuilder` mais possède une API plus simple pour réduire la quantité de code standard nécessaire et diverses optimisations de performance.
             
Il ne se passe pas grand-chose d'autre dans le widget `LoginForm` alors passons à la création de notre indicateur de chargement.

## Indicateur de chargement

```dart
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(),
      );
}
```

Maintenant, il est temps de tout assembler et de créer notre widget principal de l'application dans le fichier `main.dart`.

## Réunir le tout

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

?> **Note**: Encore une fois, nous utilisons `BlocBuilder` afin de réagir aux changements dans `AuthenticationState` de sorte que nous puissions montrer à l'utilisateur soit le `SplashPage`, `LoginPage`, `HomePage`, ou `LoadingIndicator` basé sur l'état actuel `AuthenticationState`.

?> **Note**: Notre application est enveloppée dans un `BlocProvider` qui rend notre instance de `AuthenticationBloc` disponible à tout le sous-arbre widget. BlocProvider est un widget Flutter qui fournit un bloc à ses enfants via `BlocProvider.of(context)`. Il est utilisé comme un widget d'injection de dépendance (DI) pour qu'une seule instance d'un bloc puisse être fournie à plusieurs widgets dans un sous-arbre.
             
Maintenant `BlocProvider.of<AuthenticationBloc>(contexte)` dans notre widget `HomePage` et `LoginPage`devrait faire sens.

Puisque nous avons enveloppé notre `App` dans un `BlocProvider<AuthenticationBloc>` nous pouvons accéder à l'instance de notre `AuthenticationBloc` en utilisant la méthode statique `BlocProvider.of<AuthenticationBloc>(contexte BuildContext)` de n'importe où dans le sous arbre.

A ce stade, nous avons une implémentation de connexion assez solide et nous avons découplé notre couche de présentation de la couche logique métier en utilisant Bloc.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).