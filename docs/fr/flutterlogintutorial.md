# Tutoriel Flutter page de connexion

![intermédiaire](https://img.shields.io/badge/level-intermediate-orange.svg)

> Dans ce tutoriel, nous allons construire une page de connexion dans Flutter en utilisant la librairie Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Installation du projet

> Nous commencerons par installer un tout nouveau projet flutter.

```sh
flutter create flutter_login
```

Ensuite nous pouvons installer les dépendances.

```sh
flutter packages get
```

## Répertoire d'authentication

La première chose que nous allons faire est de créer un package `authentication_repository` qui sera responsable de gérer l'authentification.

Nous commencerons par créer un dossier `packages/authentication_repository` à la racine du projet et il contiendra tous les packages internes.
At a high level, the directory structure should look like this:

```sh
├── android
├── ios
├── lib
├── packages
│   └── authentication_repository
└── test
```

Ensuite, créeons  un `pubspec.yaml` pour le package `authentication_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/pubspec.yaml ':include')

?> **Note**: `package:authentication_repository` sera un pure package Dart et par simplicité nous allons avoir uniquement une dépence sur [package:meta](https://pub.dev/packages/meta) pour quelques annotations.

Prochaine étape, nous devons implémenter la classe `AuthenticationRepository` qui elle même sera utilisé dans `lib/src/authentication_repository.dart`.

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/src/authentication_repository.dart ':include')

L' `AuthenticationRepository` expose un `Stream` qui met à jour les `AuthenticationStatus`  ce qui sera utilisé pour notifié l'application quand un utilisateur se connecte ou se déconnecte.

En plus, il y a les méthodes `logIn` et `logOut`  qui sont réduites pour la simplicité mais qui peuvent facilement être étendus pour être utilisé avec l'authentification via  `FirebaseAuth` par exemple ou avec n'importe quel autre fournisseur d'authentification.

?> **Note**: Puisque nous maintenons un `StreamController` en interne, la méthode `dispose` est utilisé pour que le controller puisse être fermé quand il n'est plus utile.
Enfin, nous avons besoins de créer `lib/authentication_repository.dart` qui contiendra les exports publics:

[authentication_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/authentication_repository/lib/authentication_repository.dart ':include')

C'est tout pour l'`AuthenticationRepository`, nous allons maintenant passer au `UserRepository`.

## Répetoire utilisateur

Comme pour l'`AuthenticationRepository`, nous allons créer un package `user_repository` à l'intérieur de notre dossier `packages`.

```sh
├── android
├── ios
├── lib
├── packages
│   ├── authentication_repository
│   └── user_repository
└── test
```

Ensuite, nous allons créer le fichier `pubspec.yaml` pour le `user_repository`:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/pubspec.yaml ':include')

Le `user_repository` sera responsable de gérer tout ce qui concerne l'utilisateur et il va exposer les APIs nécessaires pour intéragir avec l'utilisateur courant.

La première chose que nous allons définir est le modèle de l'utilisateur à l'intérieur de `lib/src/models/user.dart`:

[user.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/user.dart ':include')

Par simplicité, un utilisateur possède uniquement un `id` comme propriété mais dans la vraie vie il pourrait avoir des champs additionnels comme `firstName`, `lastName`, `avatarUrl`, etc...

?> **Note**: [package:equatable](https://pub.dev/packages/equatable) est utilisé pour activiter les comparaisons entre les objets de type `User`.
Ensuite, nous pouvons créer un `models.dart` dans `lib/src/models` qui va exporter tous les modèles pour que l'on puisse utiliser un seul import pour l'ensemble des modèles présent dans le dossier.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/models/models.dart ':include')

Maintenant que les modèles ont été définis, nous pouvons implémenter la classe `UserRepository`.

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/src/user_repository.dart ':include')

Pour cet exemple assez simple, l'`UserRepository` exposera une seule méthode `getUser` qui permettra de récupérer l'utilisateur courant. Encore une fois nous faisons le minimum mais c'est ici que nous pourrions faire des requêtes à notre backend pour obtenir plus d'informations sur l'utilisateur.

Nous en avons preque fini avec le package `user_repository` -- la seule chose qui nous reste à faire est de créer le fichier `user_repository.dart` dans `lib` qui défini les publics imports:

[user_repository.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/packages/user_repository/lib/user_repository.dart ':include')

Maintenant nous avons les packages `authentication_repository` et `user_repository` complétés, nous pouvons nous concentrer sur l'application Flutter.

## Installation des dépendances

Commençons par mettre à jour le `pubspec.yaml` généré à la racine de notre projet:

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/pubspec.yaml ':include')

Nous pouvons installer les dépendances en utilisant la commande suivante:

```sh
flutter packages get
```

## Bloc Authentification

Le `AuthenticationBloc` sera responsable pour réagir aux changements de state lors de l'authentification (exposé par `AuthenticationRepository`) et il enverra des states auxquels nous réagirons dans la couche de présentation.

L'implémentation pour le `AuthenticationBloc` est à l'intérieur de `lib/authentication` car nous traitons l'authentification comme une feature dans couche d'application.

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

?> **Tip**: Utilisez l'extension [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) pour créer des blocs automatiquements.

### authentication_event.dart

> Les instances de `AuthenticationEvent` seront les données envoyées à l'`AuthenticationBloc` qui seront traitées pour envoyer les nouvelles instances d'`AuthenticationState`.

Dans cette application, le bloc `AuthenticationBloc` réagira à deux événements différents:

- `AuthenticationStatusChanged`: notifie que le bloc que le statut d'authenfication de l'utilisateur a changé
- `AuthenticationLogoutRequested`: notifie le bloc qu'une requête pour se déconnecter a été envoyé

[authentication_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_event.dart ':include')

Ensuite, analysons `AuthenticationState`.

### authentication_state.dart

> Les instances d'`AuthenticationState` sont les rendus du `AuthenticationBloc` et elles seront utilisées par la couche de présentation.

La classe `AuthenticationState` possède trois constructeurs:

- `AuthenticationState.unknown()`: le state par défaut qui indique le bloc ne sait pas encore si l'utilisateur est connecté ou non.

- `AuthenticationState.authenticated()`: le state qui indique que l'utilisateur est actuellement connecté.

- `AuthenticationState.unauthenticated()`: le state qui indique l'utilisateur n'est actuellement pas connecté.

[authentication_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_state.dart ':include')

Maintenant que nous avons vu les implémentations de `AuthenticationEvent` et `AuthenticationState` allons voir l'`AuthenticationBloc`.

### authentication_bloc.dart

> L'`AuthenticationBloc` gère le state d'authentification de l'application qui est utilisé pour déterminer des choses telles que si l'utilisateur doit commencé sur la page de connexion ou sur la page d'accueil.

[authentication_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/authentication/bloc/authentication_bloc.dart ':include')

L'`AuthenticationBloc` a une dépendance sur `AuthenticationRepository` et `UserRepository` et il défini le state initial comme étant `AuthenticationState.unknown()`.

Dans le corps du constructeur, l'`AuthenticationBloc` suit le `status` du stream du répertoire `AuthenticationRepository` et ajoute un événement `AuthenticationStatusChanged`  en interne en réponse à un nouveau `AuthenticationStatus`.

!> L'`AuthenticationBloc` surcharge `close` dans le but de dispose à la fois `StreamSubscription` mais aussi `AuthenticationRepository`.

Ensuite, `mapEventToState` s'occupe de transformer un `AuthenticationEvent` arrivant en une nouvelle instance d'`AuthenticationState`.

Quand un événement `AuthenticationStatusChanged` est ajouté, si le statut associé est `AuthenticationStatus.authenticated`, l'`AuthentictionBloc` va requêter l'utilisateur `UserRepository`.

## main.dart

Ensuite, nous allons remplacer le `main.dart` par défaut avec:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/main.dart ':include')

?> **Note**: Nous injectons une seule instance de `AuthenticationRepository` et `UserRepository` dans le widget `App` (ce que nous allons faire juste après).

## App

`app.dart` va contenir la racine de notre widget `App` pour l'entière application.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/app.dart ':include')

?> **Note**: `app.dart` est partagé en deux parties `App` et `AppView`. `App` est responsable pour créer/fournir l'`AuthenticationBloc` qui sera utilisé par l'`AppView`. Ce découpement nous permettra de facilement de tester à la fois les widgets `App` et `AppView`.

?> **Note**: `RepositoryProvider` est utilisé pour fournir une seule instance d'`AuthenticationRepository` à l'entière application, ce qui sera pratique dans le futur.

`AppView` est un `StatefulWidget` car il va posséder une `GlobalKey` qui sera utilisé pour accèder au `NavigatorState`. Par défaut, `AppView` affichera `SplashPage` (que nous verrons plus tard) et il utilisera le `BlocListener` pour naviguer vers différentes pages en fonction des changements dans l'`AuthenticationState`.

## Splash

> Le splash est une fonctionnalité qui va juste contenir une simple vue qui sera affiché dès que l'application se lance et jusqu'à ce que l'app déternime si l'utilisateur est authentifié ou non.

```sh
lib
└── splash
    ├── splash.dart
    └── view
        └── splash_page.dart
```

[splash_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/splash/view/splash_page.dart ':include')

?> **Tip**: `SplashPage` expose une route static `Route` ce qui rend la navigation vraiment aisé via `Navigator.of(context).push(SplashPage.route())`;

## Page de connexion

> La fonctionnalité de connexion contient une `LoginPage`, `LoginForm` et un `LoginBloc` qui autorise les utilisateurs à rentrer un pseudonyme et un mot de passe pour se connecter dans l'application.

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

Nous utilisons le package [package:formz](https://pub.dev/packages/formz) pour créer des modèles standards et réutilisables pour l'`username` et le `password`.

#### Username (pseudonyme)

[username.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/username.dart ':include')

Par simplicité, nous validons l'username juste pour être sur qu'il n'est pas vide mais en preatique nous pourrions vérifier les caractères spéciaux, la longueur, etc...

#### Mot de passe

[password.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/password.dart ':include')

Encore une fois, nous vérifions juste que le mot de passe n'est pas vide.

#### Modèle baril

Comme avant, il y a un fichier baril `models.dart` à créer ce qui permet l'import des modèles `Username` et `Password` en un seul import.

[models.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/models/models.dart ':include')

### Login Bloc (Bloc de connexion)

> Le `LoginBloc` gère les states du `LoginForm` et prend soint de valider l'username et le mot de passe ainsi que le state du formulaire.

#### login_event.dart

Dans cette application il y a trois types de `LoginEvent`:

- `LoginUsernameChanged`: notifie le bloc que l'username a été modifié.
- `LoginPasswordChanged`: notifie le bloc que le mot de passe a été modifié.
- `LoginSubmitted`: notifie le bloc que le formulaire a été soumis.

[login_event.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_event.dart ':include')

#### login_state.dart

Le `LoginState` va contenir le status du formulaire ainsi que le contenu de l'username et du mot de passe.
[login_state.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_state.dart ':include')

?> **Note**: Les modèles `Username` et `Password` sont utilisés comme une partie du `LoginState` et le status est aussi une partie du [package:formz](https://pub.dev/packages/formz).

#### login_bloc.dart

> Le bloc `LoginBloc` va réagir aux intéractions de l'utilisateur dans le `LoginForm` et va gérer la validation et la soumission du formulaire.

[login_bloc.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/bloc/login_bloc.dart ':include')

Le `LoginBloc` a une dépendance sur le répertoire `AuthenticationRepository` car lorsque le formulaire est soumis, il invoque `logIn`. Le state initial du bloc est `pure` ce qui veut dire que ni les champs ni le formulaire n'a été touché ou aucune intéraction n'a eu lieu.

Peu importe quand soit `username` ou `password` change, le bloc va créer une variante 'sale' du modèle `Username`/`Password` et va mettre à jour le status du formulaire via l'API `Formz.validate`.

Quand l'événement `LoginSubmitted` est ajouté, si le status du formulaire est valide, le bloc va faire un appel à `logIn` et va mettre à jour le status en fonction du retour de la requête.

Maintenant, regardons à quoi ressemble la page `LoginPage` et `LoginForm`.

### Page de connexion (login page)

> La `LoginPage` va également exposer une route `Route` ainsi que créer et fournir le `LoginBloc` au `LoginForm`.

[login_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_page.dart ':include')

?> **Note**: `context.read` est utilisé pour récuperer l'instance de `AuthenticationRepository` via le `BuildContext`.

### Formulaire de connexion (login form)

> Le `LoginForm` gère de notifier le `LoginBloc` des événements de l'utilisateur ainsi que de répondre aux changements de states en utilisant `BlocBuilder` et `BlocListener`.

[login_form.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/login/view/login_form.dart ':include')

`BlocListener` est utilisé pour afficher une `SnackBar` dans le cas où la connexion échoue. En plus de cela, `BlocBuilder` les widgets utilisés pour construire chaque `TextField` sont aussi utilisés pour utiliser la propriété `buildWhen` qui permet d'optimiser la reconstruction de la page. La fonction de rappel `onChanged` est utilisée pour notifié le `LoginBloc` des changements du pseudonyme/mot de passe.

Le widget `_LoginButton` est uniquement activé si le statut du formulaire est valide et un `CircularProgressIndicator` est affiché à sa place lorsque le formulaire est soumis.

## Accueil (home)

> Après une requête `logIn` réussite, le state de `AuthenticationBloc` va passer à `authenticated` et l'utilisateur pourra naviguer vers la page d'accueil `HomePage` où nous afficherons l'`id` de l'utilisateur ainsi qu'un bouton de déconnexion.

```sh
├── lib
│   ├── home
│   │   ├── home.dart
│   │   └── view
│   │       └── home_page.dart
```

### Page d'accueil (home page)

La `HomePage` peut accèder à l'id de l'utilisateur courant via `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` et l'afficher via un widget `Text`. En plus, quand le bouton de déconnexion est tappé, un événement  `AuthenticationLogoutRequested` est ajouté au `AuthenticationBloc`.

[home_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_login/lib/home/view/home_page.dart ':include')

?> **Note**: `context.select((AuthenticationBloc bloc) => bloc.state.user.id)` déclenchera des mises à jour si l'utilisateur change.

A présent nous avons un système de connexion assez solide et nous avons découper la couche présentation de la couche logique grâce à Bloc.

Tout le code source de cet exemple (incluant les tests unitaires et de widgets) être touvable [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
