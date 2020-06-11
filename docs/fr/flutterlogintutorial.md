# Tutoriel Flutter Connexion

![intermédiaire](https://img.shields.io/badge/level-intermediate-orange.svg)

> Dans le tutoriel suivant, nous allons construire un flux de connexion dans Flutter en utilisant la bibliothèque Bloc.

![demo](../assets/gifs/flutter_login.gif)

## Configuration

Nous commencerons par créer un tout nouveau projet Flutter

[script](../_snippets/flutter_login_tutorial/flutter_create.sh.md ':include')

Nous pouvons alors remplacer le contenu de `pubspec.yaml` par

[pubspec.yaml](../_snippets/flutter_login_tutorial/pubspec.yaml.md ':include')

et ensuite installer toutes nos dépendances

[script](../_snippets/flutter_login_tutorial/flutter_packages_get.sh.md ':include')

## Répertoire utilisateur

Nous allons devoir créer un `UserRepository` qui nous aide à gérer les données d'un utilisateur.

[user_repository.dart](../_snippets/flutter_login_tutorial/user_repository.dart.md ':include')

?> **Note**: Notre référentiel utilisateur se moque des différentes implémentations pour des raisons de simplicité, mais dans une application réelle, vous pouvez injecter un [HttpClient](https://pub.dev/packages/http) ainsi que quelque chose comme [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) afin de demander des tokens et de les lire/écrire dans un trousseau de clés.

## Etats d'authentification

Ensuite, nous allons devoir déterminer comment nous allons gérer l'état de notre application et créer les blocs nécessaires (composants logiques métier).

A un haut niveau, nous allons devoir gérer l'état d'authentification de l'utilisateur. L'état d'authentification d'un utilisateur peut être l'un des suivants :

- AuthenticationInitial - en attendant de voir si l'utilisateur est authentifié ou non au démarrage de l'application.
- AuthenticationInProgress - attente pour persister/supprimer un jeton
- AuthenticationSuccess - authentifié avec succès
- AuthenticationFailure - non authentifié

Chacun de ces états aura une implication sur ce que l'utilisateur voit.

Par exemple :

- si l'état d'authentification n'a pas été initialisé, l'utilisateur peut voir un écran de démarrage.
- si l'état d'authentification était en cours de chargement, l'utilisateur peut voir un indicateur de progression.
- si l'état d'authentification a été authentifié, l'utilisateur peut voir un écran d'accueil.
- si l'état d'authentification n'était pas authentifié, l'utilisateur peut voir un formulaire de connexion.

> Il est essentiel d'identifier ce que seront les différents états avant de se plonger dans la mise en œuvre.

Maintenant que nous avons identifié nos états d'authentification, nous pouvons implémenter notre classe `AuthenticationState`.

[authentication_state.dart](../_snippets/flutter_login_tutorial/authentication_state.dart.md ':include')

?> **Note**: The [`equatable`](https://pub.dev/packages/equatable) package is used in order to be able to compare two instances of `AuthenticationState`. By default, `==` returns true only if the two objects are the same instance.

## Événements d'authentification

Maintenant que nous avons défini notre `AuthenticationState`, nous devons définir les `AuthenticationEvents` auxquels notre `AuthenticationBloc` va réagir.
Nous en aurons besoin :

- un événement `AuthenticationStarted` pour avertir le bloc qu'il doit vérifier si l'utilisateur est actuellement authentifié ou non.
- un événement `AuthenticationLoggedIn` pour notifier au bloc que l'utilisateur s'est connecté avec succès.
- a événement `AuthenticationLoggedOut` pour avertir le bloc que l'utilisateur s'est déconnecté avec succès.

[authentication_event.dart](../_snippets/flutter_login_tutorial/authentication_event.dart.md ':include')

?> **Note**: le paquet `meta` est utilisé pour annoter les paramètres `AuthenticationEvent` comme `@required`. L'analyseur dart avertira les développeurs s'ils ne fournissent pas les paramètres requis.

## Bloc d'authentification

Maintenant que nous avons défini nos `AuthenticationState` et `AuthenticationEvents`, nous pouvons commencer à travailler sur l'implémentation du `AuthenticationBloc` qui va gérer la vérification et la mise à jour du `AuthenticationState` d'un utilisateur en réponse aux `AuthenticationEvents`.

Nous allons commencer par créer notre classe `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Note**: Rien qu'en lisant la définition de classe, nous savons déjà que ce bloc va convertir `AuthenticationEvents` en `AuthenticationStates`.

?> **Note**: Notre `AuthenticationBloc` dépend du `UserRepository`.

Nous pouvons commencer par remplacer l'état `initialState` par l'état `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Maintenant, il ne reste plus qu'à mettre en œuvre `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Super ! Notre `AuthenticationBloc` final devrait ressembler à ce qui suit

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc.dart.md ':include')

Maintenant que notre `AuthenticationBloc` est complètement implémenté, commençons à travailler sur la couche présentation.

## Ecran d'accueil

La première chose dont nous aurons besoin est un widget `SplashPage` qui servira d'écran d'accueil pendant que notre `AuthenticationBloc` détermine si un utilisateur est connecté ou non.

[splash_page.dart](../_snippets/flutter_login_tutorial/splash_page.dart.md ':include')

## Page d'accueil

Ensuite, nous devrons créer notre `HomePage` pour que nous puissions y naviguer les utilisateurs une fois qu'ils se sont connectés avec succès.

[home_page.dart](../_snippets/flutter_login_tutorial/home_page.dart.md ':include')

?> **Note**: C'est la première classe dans laquelle nous utilisons `flutter_bloc`. Nous entrerons dans `BlocProvider.of<AuthenticationBloc>(contexte)` prochainement mais pour l'instant nous savons juste qu'il permet à notre `HomePage` d'accéder à notre `AuthenticationBloc`.

?> **Note**: Nous ajoutons un événement `AuthenticationLoggedOut` à notre `AuthenticationBloc` lorsqu'un utilisateur appuie sur le bouton Logout.

Ensuite, nous devons créer une `LoginPage` et un `LoginForm`.

Parce que le `LoginForm` devra gérer l'entrée des utilisateurs (Bouton de connexion appuyé) et aura besoin d'une logique métier (obtenir un jeton pour un nom d'utilisateur/mot de passe donné), nous devrons créer un `LoginBloc`.

Tout comme nous l'avons fait pour le `AuthenticationBloc`, nous devrons définir le `LoginState`, et `LoginEvents`. Commençons par `LoginState'.

## États de connexion

[login_state.dart](../_snippets/flutter_login_tutorial/login_state.dart.md ':include')

`LoginInitial` est l'état initial du LoginForm.

`LoginInProgress` est l'état du LoginForm lorsque nous validons les informations d'identification

`LoginFailure` est l'état du LoginForm lorsqu'une tentative de connexion a échoué.

Maintenant que nous avons défini `LoginState`, jetons un coup d'oeil à la classe `LoginEvent`.

## Évènements de connexion

[login_event.dart](../_snippets/flutter_login_tutorial/login_event.dart.md ':include')

`LoginButtonPressed` sera ajouté lorsqu'un utilisateur appuiera sur le bouton de connexion. Il informera le `LoginBloc` qu'il doit demander un jeton pour les informations d'identification données.

Nous pouvons maintenant implémenter notre `LoginBloc`.

## Bloc de connexion

[login_bloc.dart](../_snippets/flutter_login_tutorial/login_bloc.dart.md ':include')

?> **Note**: `LoginBloc` dépend de `UserRepository' pour authentifier un utilisateur avec un nom d'utilisateur et un mot de passe.

?> **Note**: `LoginBloc` dépend de `AuthenticationBloc` pour mettre à jour l'état d'authentification lorsqu'un utilisateur a saisi des informations d'identification valides.

Maintenant que nous avons notre `LoginBloc` nous pouvons commencer à travailler sur `LoginPage` et `LoginForm`.

## Page de connexion

Le widget `LoginPage` servira de widget conteneur et fournira les dépendances nécessaires au widget `LoginForm` (`LoginBloc` et `AuthenticationBloc`).

[login_page.dart](../_snippets/flutter_login_tutorial/login_page.dart.md ':include')

?> **Note**: `LoginPage` est un `StatelessWidget`. Le widget `LoginPage` utilise le widget `BlocProvider` pour créer, fermer et fournir le `LoginBloc` au sous-arbre.

?> **Note**: Nous utilisons le `UserRepository` injecté pour créer notre `LoginBloc`.

?> **Note**: Nous utilisons `BlocProvider.of<AuthenticationBloc>(contexte)` à nouveau pour accéder au `AuthenticationBloc` depuis la `LoginPage`.

Ensuite, créons notre `LoginForm`.

## Formulaire de connexion

[login_form.dart](../_snippets/flutter_login_tutorial/login_form.dart.md ':include')

?> **Note**: Notre `LoginForm` utilise le widget `BlocBuilder` pour qu'il puisse être reconstruit chaque fois qu'il y a un nouvel `LoginState`. `BlocBuilder` est un widget Flutter qui nécessite une fonction Bloc et un constructeur. `BlocBuilder` gère la construction du widget en réponse aux nouveaux états. `BlocBuilder` est très similaire à `StreamBuilder` mais possède une API plus simple pour réduire la quantité de code standard nécessaire et diverses optimisations de performance.

Il ne se passe pas grand-chose d'autre dans le widget `LoginForm` alors passons à la création de notre indicateur de chargement.

## Indicateur de chargement

[loading_indicator.dart](../_snippets/flutter_login_tutorial/loading_indicator.dart.md ':include')

Maintenant, il est temps de tout assembler et de créer notre widget principal de l'application dans le fichier `main.dart`.

## Réunir le tout

[main.dart](../_snippets/flutter_login_tutorial/main.dart.md ':include')

?> **Note**: Encore une fois, nous utilisons `BlocBuilder` afin de réagir aux changements dans `AuthenticationState` de sorte que nous puissions montrer à l'utilisateur soit le `SplashPage`, `LoginPage`, `HomePage`, ou `LoadingIndicator` basé sur l'état actuel `AuthenticationState`.

?> **Note**: Notre application est enveloppée dans un `BlocProvider` qui rend notre instance de `AuthenticationBloc` disponible à tout le sous-arbre widget. BlocProvider est un widget Flutter qui fournit un bloc à ses enfants via `BlocProvider.of(context)`. Il est utilisé comme un widget d'injection de dépendance (DI) pour qu'une seule instance d'un bloc puisse être fournie à plusieurs widgets dans un sous-arbre.

Maintenant `BlocProvider.of<AuthenticationBloc>(contexte)` dans notre widget `HomePage` et `LoginPage`devrait faire sens.

Puisque nous avons enveloppé notre `App` dans un `BlocProvider<AuthenticationBloc>` nous pouvons accéder à l'instance de notre `AuthenticationBloc` en utilisant la méthode statique `BlocProvider.of<AuthenticationBloc>(contexte BuildContext)` de n'importe où dans le sous arbre.

A ce stade, nous avons une implémentation de connexion assez solide et nous avons découplé notre couche de présentation de la couche logique métier en utilisant Bloc.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
