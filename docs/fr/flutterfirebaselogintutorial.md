# Tutoriel formulaire de connexion Flutter avec Firebase

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> Dans ce tutorial, nous allons voir comment créer une formulaire de connexion Firebase en utilisant la bibliothèque Bloc dans Flutter.

![demo](../assets/gifs/flutter_firebase_login.gif)

## Installation

Commençons par créer un tout nouveau projet Flutter.

[flutter_create.sh](../_snippets/flutter_firebase_login_tutorial/flutter_create.sh.md ':include')

Nous pouvons ensuite remplacer le contenu du fichier `pubspec.yaml` par :

[pubspec.yaml](../_snippets/flutter_firebase_login_tutorial/pubspec.yaml.md ':include')

Notez que nous spécifions un fichier contenant les assets pour tous les assets locales de notre application.
Créez un dossier `assets` à la racine du projet et ajoutez le [flutter logo](https://github.com/felangel/bloc/blob/master/examples/flutter_firebase_login/assets/flutter_logo.png) asset (nous l'utiliserons plus tard).

ensuite installez toutes les dependencies : 

[flutter_packages_get.sh](../_snippets/flutter_firebase_login_tutorial/flutter_packages_get.sh.md ':include')

La dernière chose que l'on doit faire est suivre [firebase_auth usage instructions](https://pub.dev/packages/firebase_auth#usage) 
dans le but de relier notre l'application et d'activer [google_signin](https://pub.dev/packages/google_sign_in).

## User Repository

Comme dans [flutter login tutorial](./flutterlogintutorial.md), nous allons créer notre `UserRepository` q.qui sera responsable de l'abstraction des implémentations futures sous jacentes, tel que la récupération d'informations sur l'utilisateur connecté.

Commençons par créer `user_repository.dart`.

Premièrement, nous allons définir la class `UserRepository` et implémenter son constructeur. On peut directement constater que `UserRepository` aura une dépendance sur `FirebaseAuth` et `GoogleSignIn`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository_constructor.dart.md ':include')

?> **Note:** Si `FirebaseAuth` et/ou `GoogleSignIn` ne sont pas injectés à `UserRepository`, alors nous les instancions nous mêmes. Cela nous permet d'injecter des instances mock pour pouvoir facilement tester `UserRepository`.

 `signInWithGoogle` sera la première méthode que nous allons implémenter et elle authentifiera l'utilisateur en utilisant le `GoogleSignIn` package.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_google.dart.md ':include')

Ensuite nous allons implémenter `signInWithCredentials` méthode qui permettra à l'utilisateur d'utiliser ses propres identifiants en utilisant `FirebaseAuth`.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_in_with_credentials.dart.md ':include')

Ensuite, nous avons besoin d'implémenter `signUp` méthode qui va permettre aux utilisateurs de se créer un compte si ils n'ont pas choisi Google Sign in.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_up.dart.md ':include')

Implémentons ensuite `signOut`méthode pour que les utilisateurs puissent se déconnecter et que l'on supprime les informations de leur profil.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/sign_out.dart.md ':include')

Enfin, nous avons besoin de deux méthodes supplémentaires : isSignedIn, pour vérifier si un utilisateur est connecté, et getUser pour récupérer ses informations.

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/is_signed_in_and_get_user.dart.md ':include')

?> **Note:** `getUser` retourne uniquement l'adresse mail de l'utilisateur connecté pour faire simple mais nous pourrions définir notre propre modèle User et lui ajouter beaucoup plus d'informations sur l'utilisateur dans le cas des applications plus complexes.

Notre fichier `user_repository.dart` terminé devrait ressembler à ceci :

[user_repository.dart](../_snippets/flutter_firebase_login_tutorial/user_repository.dart.md ':include')

Ensuite, nous allons construire notre `AuthenticationBloc` qui sera responsable de gérer le `AuthenticationState`de l'application qui lui réagira aux`AuthenticationEvents`.

## Authentication States (Les états d'authentification)

Nous avons besoin de déterminer comment nous allons gérer le state ("état") de notre application et créer les blocs (business logic components) nécessaires.
A un haut niveau, nous allons devoir gérer l'Authentification state de l'utilisateur. Le state d'un utilisateur peut être l'un parmis la liste suivante : 

- AuthenticationInitial - attend de voir si l'utilisateur est authentifié ou non quand l'application commence.
- AuthenticationSuccess - l'authentification est un succès.
- AuthenticationFailure - non authentifié.

Chacun de ces états (states) modifiera ce que l'utilisateur verra.

Par exemple :
- si l'authentification state est AuthenticationInitial, l'utilisateur pourrait voir un splash screen.
- si l'authentification state est AuthenticationSuccess, l'utilisateur pourrait voir la page d'accueil.
- si l'authentification state est AuthenticationFailure, l'utilisateur pourrait voir un formulaire de connexion.

> Il est important d'identifier quels seront les différents états (states) avant de plonger dans leur implémentation. 

Maintenant que les états(states) d'authentification sont identifiés, nous pouvons implémenter notre classe `AuthenticationState`.

Créer une dossier/répertoire appelé `authentication_bloc` dans lequel nous allons créer nos fichiers d'authentification bloc.

[authentication_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_dir.sh.md ':include')

?> **Conseil:** Vous pouvez utiliser le plugin [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) ou [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) pour générer les fichiers automatiquement.

[authentication_state.dart](../_snippets/flutter_firebase_login_tutorial/authentication_state.dart.md ':include')

?> **Note**: Le package [`equatable`](https://pub.dev/packages/equatable) est utilisé dans le but de permettre de comparer deux instances de `AuthenticationState`. Par défaut, `==` renvoie true seulement si deux objets réfèrent à la même instance.

?> **Note**: `toString` est "overridden" pour faciliter la lecture d'un `AuthenticationState` quand on l'affiche dans la console ou dans `Transitions`.

!> Puisque nous utilisons `Equatable` pour pouvoir comparer deux instances de `AuthenticationState`, nous avons besoin de passer toutes les propriétés de la superclass. Sans `List<Object> get props => [displayName]`, nous ne pourrions pas comparer proprement différentes instances de  `AuthenticationSuccess`.

## Authentication Events (les événements d'authentification)

Maintenant que nous avons notre `AuthenticationState` de définie, nous allons définir `AuthenticationEvents` auquel notre `AuthenticationBloc`réagira.

Nous allons avoir besoin :

- d'un événement `AuthenticationStarted` pour notifier le bloc qu'il a besoin de vérifier si l'utilisateur est actuellement authentifié ou non.
- d'un événement `AuthenticationLoggedIn` pour notifier le bloc que l'utilisateur s'est connecté avec succès.
- d'un événement `AuthenticationLoggedOut` pour notifier le bloc que l'utilisateur s'est déconnecté avec succès.

[authentication_event.dart](../_snippets/flutter_firebase_login_tutorial/authentication_event.dart.md ':include')

## Authentication Bloc (Le bloc d'authentification)

Maintenant que nous avons notre `AuthenticationState` et `AuthenticationEvents` de définis, nous pouvons travailler sur l'implémentation de `AuthenticationBloc` qui va s'occuper de vérifier et d'actualiser l'`AuthenticationState` d'un utilisateur en réponse à `AuthenticationEvents`.

Nous allons commencer par créer notre classe `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Note**: Juste en lisant la classe, nous savons déjà que le bloc convertira `AuthenticationEvents` en `AuthenticationStates`.

?> **Note**: Notre `AuthenticationBloc` a des dépendances avec `UserRepository`.

Nous pouvons commencer par surcharger `initialState` à l'état (state) `AuthenticationInitial()`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Maintenant il nous reste plus qu'à implémenter `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Les fonctions privées `_mapLoggedInToState()` ou `_mapLoggedOutToState()` sont crées en dehors de `mapEventToState` pour convertir chaque `AuthenticationEvent` en son propre `AuthenticationState` et dans le but de garder `mapEventToState` le plus propre et facile à lire possible.


?> **Note:** Nous utilisions `yield*` (yield-each) dans `mapEventToState` pour séparer les event handler dans leurs propres fonctions. `yield*` insert tous les élements de la sous-séquence dans la séquence actuellement construite, comme si nous avions un yield individuel pour chaque élément.

Notre `authentication_bloc.dart` devrait ressembler à ceci maintenant :

[authentication_bloc.dart](../_snippets/flutter_firebase_login_tutorial/authentication_bloc.dart.md ':include')

Maintenant que nous avons notre `AuthenticationBloc` entièrement implenté, nous pouvons maintenant travailler sur la couche de présentation.

## App

Nous allons commencer par supprimer tout le contenu de `main.dart` et implémenter notre fonction main.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main1.dart.md ':include')

Nous envelopons notre widget `App` entière dans un `BlocProvider` dans le but de mettre l'`AuthenticationBloc` disponible partout dans l'arbre du widget.

?> `WidgetsFlutterBinding.ensureInitialized()` est requis dans Flutter v1.9.4+ avant d'utiliser n'importe quel plugin si le code est exécuée avant runApp.

?> `BlocProvider` gère aussi la fermeture `AuthenticationBloc` automatiquement donc nous n'avons pas besoin de nous en occuper.

Ensuite, nous allons implémenter notre widget `App`.

> `App` sera un `StatelessWidget` et réagira à `AuthenticationBloc` state et affichera le widget approprié.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main2.dart.md ':include')

Nous utilisons `BlocBuilder` dans le but d'afficher l'UI en fonction du  `AuthenticationBloc` state.
`SplashScreen`,

À  l'heure actuelle nous n'avons pas de widget à afficher mais nous y reviendrons plus tard quand nous allons créer `SplashScreen`, `LoginScreen`, et `HomeScreen`.

## Bloc Delegate

Avant de rentrer dans le vif du sujet, c'est toujours une bonne pratique d'implémenter notre propre `BlocDelegate` ce qui nous permet d'override `onTransition` et `onError` ce qui va nous aider à voir tous les changements d'état (state) des blocs (les transifitions) et les erreurs à une seule et même place!

Créez `simple_bloc_delegate.dart` et implémentons rapidement notre delegate.

[simple_bloc_delegate.dart](../_snippets/flutter_firebase_login_tutorial/simple_bloc_delegate.dart.md ':include')

Maintenant nous pouvons connecter (hook up) notre `BlocDelegate` dans notre `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main3.dart.md ':include')

## Splash Screen (Ecran d'atterrissage)

Ensuite, nous allons créer un `SplashScreen` widget qui s'affichera pendant qu'`AuthenticationBloc` détermine si un utilisateur est connecté ou non.

Créeons `splash_screen.dart` et implémentons le!

[splash_screen.dart](../_snippets/flutter_firebase_login_tutorial/splash_screen.dart.md ':include')

Comme vous pouvez le voir, ce widget est super minimaliste et nous pourrions y ajouter des images ou des animations dans le but de le rendre plus esthétique à regarder. 

Maintenant, rattachons le à `main.dart`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main4.dart.md ':include')

Maintenant peu importe quand notre `AuthenticationBloc` a un `state` de `AuthenticationInitial` nous allons afficher le widget `SplashScreen`!

## Home Screen (Page d'accueil)

Ensuite, nous allons avoir besoin de créer notre `HomeScreen` pour que l'on puisse diriger l'utilisateur une fois qu'il a réussi à se connecter. Dans ce cas, notre `HomeScreen` va permettre à l'utilisateur de se déconnecter mais également de lui montre son email actuel.

Créons `home_screen.dart` et commençons.

[home_screen.dart](../_snippets/flutter_firebase_login_tutorial/home_screen.dart.md ':include')

`HomeScreen` est `StatelessWidget` qui requiert `name` d'être injecté pour qu'il puisse afficher le message de bienvenue. Il utilise aussi `BlocProvider` pour accèder à `AuthenticationBloc` via `BuildContext` pour que lorsqu'un utilisateur presse le boutton se déconnecter, nous puissions ajouter l'évenement `AuthenticationLoggedOut`.

Maintenant nous allons actualiser `App` pour afficher `HomeScreen` si l'`AuthenticationState` est `AuthenticationSuccess`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main5.dart.md ':include')

## Login States (Les états de connexion)

Nous pouvons enfin commencer à travailler sur l'environnement de connexion. Nous allons commencer par identifier différents `LoginStates` que nous aurons.

Créez un dossier `login` et créer le schéma classique du dossier bloc et ses fichiers.

[login_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/login_bloc_dir.sh.md ':include')

Notre `login/bloc/login_state.dart` devrait ressembler à ceci:

[login_state.dart](../_snippets/flutter_firebase_login_tutorial/login_state.dart.md ':include')

Les états (states) que nous allons utiliser sont:

`initial` est le state initial de LoginForm.

`loading` est le state du LoginForm quand nous procédons à la validation des identifiants.

`failure` est le state LoginForm si la connexion a échoué.

`success` est le state du LoginForm si la connexion est un succès.

Nous avons aussi défini les fonctions `copyWith` et une fonction `update` par commodité (nous allons nous en servir bientôt).

Maintenant que le `LoginState` est défini, jetons un coup d'oeil sur la class `LoginEvent`.

## Login Events (Evénements de connexion)

Ouvrez `login/bloc/login_event.dart` et définissons et implémentons nos événements.

[login_event.dart](../_snippets/flutter_firebase_login_tutorial/login_event.dart.md ':include')

Les événements que nous avons définis sont:

`LoginEmailChanged` - notifie le bloc que l'email a changé

`LoginPasswordChanged` - notifie le bloc que l'utilisateur a changé le mot de passe

`LoginWithGooglePressed` - notifie le bloc que l'utilisateur a pressé le bouton Google Sign In

`LoginWithCredentialsPressed` - notifie le bloc que l'utilisateur a pressé le bouton classique de connexion

## Login Barrel File (Fichier Baril pour la connexion)

Avant d'implémenter `LoginBloc`, assurons nous que notre fichier baril est prêt pour que nous puissions importer facilement tous les fichiers reliés à notre Bloc de connexion en un seul import.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_barrel.dart.md ':include')

## Login Bloc (Bloc de connexion)

Il est temps d'implémenter notre `LoginBloc`. Comme toujours, nous avons besoin d'étendre `Bloc` et définir notre `initialState` et notre `mapEventToState`.

[login_bloc.dart](../_snippets/flutter_firebase_login_tutorial/login_bloc.dart.md ':include')

**Note:** Nous allons override `transformEvents` dans le but debounce les événements `LoginEmailChanged` et `LoginPasswordChanged` pour que les utilisateurs aient le temps d'arrêter d'écrire avant de valider l'input.

Nous utilisons une classe `Validators` pour valider l'email et le mot de passe, nous allons l'implémenter maintenant.

## Validators

Créons  `validators.dart` et implémentons notre validation pour notre email et notre mot de passe.

[validators.dart](../_snippets/flutter_firebase_login_tutorial/validators.dart.md ':include')

On ne fait rien de spécial ici. Nous utilisons du code Dart qui utilise des expressions régulières pour valider l'email et le mot de passe. Maintenant, vous devriez avoir une une classe `LoginBloc` entièrement fonctionnelle que l'on peut rattacher à notre UI.

## Login Screen (Écran de connexion)

Maintenant que nous avons fini le `LoginBloc`, il est temps de créer notre widget `LoginScreen` qui sera responsable de créer et de fermer le `LoginBloc` et aussi à fournir le Scaffold pour notre widget `LoginForm`.

Créez `login/login_screen.dart` et implémentons le.

[login_screen.dart](../_snippets/flutter_firebase_login_tutorial/login_screen.dart.md ':include')

Encore une fois, étendons `StatelessWidget`et utilisons un `BlocProvider` pour initialiser et fermer le `LoginBloc` aussi bien que pour permettre à l'instance `LoginBloc` d'être disponible pour tous les widgets à l'intérieur du sous-arbre (sub-tree).

Maintenant, nous allons devoir implémenter le widget `LoginForm` qui sera responsable de l'affichage du formulaire et de la soumission des bouttons dans le but que l'utilisateur puisse s'authentifier.

## Login Form (Formulaire de connexion)

Créez `login/login_form.dart` et construisons notre formulaire.

[login_form.dart](../_snippets/flutter_firebase_login_tutorial/login_form.dart.md ':include')

Notre widget `LoginForm` est un `StatefulWidget` car il a besoin de maintenir ses propres `TextEditingControllers` pour les champs e-mail et mot de passe.

Nous utilisions un widget `BlocListener` pour exécuter en une fois les actions en réponse aux changements de states (états). Dans ce cas, nous allons afficher différentes `SnackBar`  en réponse aux states (états) d'attente ou d'échec. En plus de cela, si la soumission est une réussite, nous allons utiliser la méthode `listener` pour notifier l'`AuthenticationBloc` que l'utilisateur a réussi à se connecter en cas de succès.

?> **Tip:** Allez voir la [SnackBar Recette](recipesfluttershowsnackbar.md) pour plus d'informations.

On utilise le widget `BlocBuilder` dans le but de reconstruire l'UI en réponse aux différents `LoginStates`.

Peu importe si l'email ou le mot de passe change, nous ajoutons un événement au `LoginBloc`dans le but qu'il valide l'état actuel du formulaire (current form state) et qu'il retourne le nouvel état du formulaire (new form state)

?> **Note:** Nous utilisons `Image.asset` pour charger le logo de Flutter via notre dossier assets.

Maintenant, vous devriez remarquez que nous n'avons pas implémenté `LoginButton`, `GoogleLoginButton`, ni `CreateAccountButton`. C'est ce que nous allons faire dès à présent.

## Login Button (Bouton de connexion)

Créez `login/login_button.dart` et implémentons rapidement notre widget `LoginButton`.

[login_button.dart](../_snippets/flutter_firebase_login_tutorial/login_button.dart.md ':include')

Encore une fois, rien de spécial dans ce code; nous avons juste un `StatelessWidget` qui a un peu de style et un `onPressed` callback (fonction de rappel) pour que l'on puisse exécuté une fonction `VoidCallback` personnalisée à chaque fois que le bouton est pressé. 

## Google Login Button (Boutton de connexion Google)

Créez `login/google_login_button.dart` et travaillons sur notre Google Sign In.

[google_login_button.dart](../_snippets/flutter_firebase_login_tutorial/google_login_button.dart.md ':include')

Encore une fois, il n'y a rien de spécial dans ce snippet. Nous avons un autre `StatelessWidget`; par contre cette fois nous n'exposons pas une fonction de rappel (callback) sur `onPressed`.
A la place, nous allons le gérer à l'intérieur et nous ajoutons l'event (événement) `LoginWithGooglePressed` à notre `LoginBloc` qui va lui gérer le processus du Google Sign In.

?> **Note:** Nous utilisons [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) pour l'icône Google.

## Créer le bouton 'Créer un compte'

Le dernier des trois boutons est `CreateAccountButton`. Commençons par créer `login/create_account_button.dart` et  mettons nous au travail !

[create_account_button.dart](../_snippets/flutter_firebase_login_tutorial/create_account_button.dart.md ':include')

Dans ce cas, encore une fois nous un `StatelessWidget`et encore une fois nous gérons la fonction de rappel (callback) à l'intérieur du widget. Cette fois, toutefois, nous allons lui ajouter une nouvelle route en réponse au click sur le bouton pour rediriger vers `RegisterScreen`. Allons-y!

## Register States (Etats d'enregistrement)

Comme pour le login (connexion), nous allons avoir besoin de définir notre `RegisterState` avant de procéder.

Créez un dossier `register` et créez un standard dossier bloc avec ses fichiers comme ci-dessous:

[register_bloc_dir.sh](../_snippets/flutter_firebase_login_tutorial/register_bloc_dir.sh.md ':include')

Notre `register/bloc/register_state.dart` devrait ressembler à ceci:

[register_state.dart](../_snippets/flutter_firebase_login_tutorial/register_state.dart.md ':include')

?> **Note:** Le `RegisterState` est très similaire au `LoginState` et nous pourrions créer un seul événement (state) et le partager entre les deux fichiers; cependant, il est très probable que Le Login (connexion) et le Register(inscription) auront des divergences et donc la plus part du temps il vaut mieux les séparer.
Ensuite passons à la class `RegisterEvent`.

## Register Events (Evénements d'inscription)

Ouvrez `register/bloc/register_event.dart` et implémentons nos événements.

[register_event.dart](../_snippets/flutter_firebase_login_tutorial/register_event.dart.md ':include')

?> **Note:** Encore une fois, l'implémentation du `RegisterEvent` ressemble fortement à celui du `LoginEvent` mais puisqu'il s'agit de deux features indépendantes nous les gardons séparées l'une de l'autre.

## Register Barrel File (Fichier baril pour l'inscription)

Encore une fois, tout comme pour le login, nous avons besoin de créer un fichier baril pour exporter tous les fichiers relatifs à notre bloc d'inscription (register bloc).
Ouvrez `bloc.dart` dans le dossier `register/bloc` et exportez les trois fichiers.

[bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_barrel.dart.md ':include')

## Register Bloc (Bloc d'inscription)

Maintenant, ouvrons `register/bloc/register_bloc.dart` et implémentons `RegisterBloc`.

[register_bloc.dart](../_snippets/flutter_firebase_login_tutorial/register_bloc.dart.md ':include')

Comme avant, nous avons besoin d'étendre `Bloc`, d'implémenter `initialState` et `mapEventToState`. Accessoirement, nous overridons `transformEvents` encore une fois pour que l'on puisse donner aux utilisateurs le temps de rentrer des informations avant de valider le formulaire.

Maintenant que notre `RegisterBloc` est entièrement fonctionnel, nous avons juste à construire l'interface.

## Register Screen (L'écran d'inscription)

Comme pour `LoginScreen`, notre `RegisterScreen` sera un `StatelessWidget` responsable de l'initialisation et de la fermeture `RegisterBloc`. Il fournira également le Scaffold pour `RegisterForm`.

Créons `register/register_screen.dart` et implémentons le.

[register_screen.dart](../_snippets/flutter_firebase_login_tutorial/register_screen.dart.md ':include')

## Register Form (Formulaire d'inscription)

Ensuite, créons le `RegisterForm` qui fournira les champs du formulaire pour qu'un utilisateur puisse créer son compte.
Créons `register/register_form.dart` et construisons le.

[register_form.dart](../_snippets/flutter_firebase_login_tutorial/register_form.dart.md ':include')

Encore une fois, nous avons besoin de gérer les `TextEditingController` pour les champs textes de notre `RegisterForm`, il a donc besoin d'être un `StatefulWidget`.En plus de cela, nous utilisons un `BlocListener` encore une fois dans le but d'exécuter actions en un temps (one-time actions) en réponse aux changements d'états (states) comme par exemple monter une `SnackBar` quand l'inscription est en cours ou si elle échoue. Nous ajoutons également l'évenement (event) `AuthenticationLoggedIn` à l'`AuthenticationBloc` si l'inscription a été un succès pour qu'on puisse connecter directement l'utilisateur.

?> **Note:** Nous utilisons `BlocBuilder` dans le but que notre UI puisse répondre aux changements dans le `RegisterBloc` state.

Ensuite, construisons notre widget `RegisterButton`.

## Register Button (Bouton d'inscription)

Créons `register/register_button.dart` et commençons.

[register_button.dart](../_snippets/flutter_firebase_login_tutorial/register_button.dart.md ':include')

C'est très similaire à l'installation faite pour `LoginButton`, le `RegisterButton` a du code pour changer son style et il expose une fonction  `VoidCallback` pour que l'on puisse gérer le moment où l'utilisateur va appuyer sur le bouton du Widget parent.

Tout ce qui nous reste à faire est d'actualiser notre widget `App` dans `main.dart` pour afficher le `LoginScreen` si le `AuthenticationState` est `AuthenticationFailure`.

[main.dart](../_snippets/flutter_firebase_login_tutorial/main6.dart.md ':include')

Maintenant nous avons un formulaire de connexion assez robuste utilisant Firebase et nous avons notre couche de présentation qui est séparée de notre couche de business logic tout cela en utilisant la bibliothèque Bloc.

Le code source entier de cette exemple est trouvable [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_firebase_login).
