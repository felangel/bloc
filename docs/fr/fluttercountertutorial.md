# Tutoriel Compteur Flutter

![débutant](https://img.shields.io/badge/level-beginner-green.svg)

> Dans le tutoriel qui suit, nous allons construire une application Compteur en utilisant Flutter et la librairie Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Installation

Nous allons commencer par créer un tout nouveau projet Flutter

```sh
flutter create flutter_counter
```

Continuons en renplaçant tout le contenu du `pubspec.yaml` avec

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

et ensuite nous allons installer toutes les dépendances

```sh
flutter packages get
```

## Structure du projet

  ```
 ├── lib
 │   ├── app.dart
 │   ├── counter
 │   │   ├── counter.dart
 │   │   ├── cubit
 │   │   │   └── counter_cubit.dart
 │   │   └── view
 │   │       ├── counter_page.dart
 │   │       └── counter_view.dart
 │   ├── counter_observer.dart
 │   └── main.dart
 ├── pubspec.lock
 ├── pubspec.yaml
 ```

  L'application utilise une structure de répertoires basée sur les fonctionnalités. Si votre projet grossit, ce découpage par fonctionnalités permet de les garder autonomes. Dans cet exemple, nous n'aurons que la fonctionnalité du compteur mais dans des applications plus complexes, nous pouvons avoir des centaines de fonctionnalités différentes.

## BlocObserver

La première chose que nous allons regarder et comment créer un `BlocObserver` qui va nous aider à observer tous les changements de states (d'états) dans l'application.

Crééons `lib/counter_observer.dart`:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

Dans ce cas, nous surchargeons uniquement `onChange` pour surveiller tous les changements de states.

?> **Note**: `onChange` fonctionne de la même manière pour les instances `Bloc` et `Cubit`.

## main.dart

Ensuite, nous allons remplacer le contenu du `main.dart` avec:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

Nous initialisations le `CounterObserver` que nous venons de créer et nous appelons `runApp` avec le widget `CounterApp` que l'on verra juste après.

## Counter App

`CounterApp` sera un widget `MaterialApp` et le paramètre `home` instanciera notre `CounterPage`.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **Note**: Nous étendons `MaterialApp` car `CounterApp` _est_ un `MaterialApp`. Dans la plus part des cas, nous allons simplement créer des instances `StatelessWidget` ou `StatefulWidget` et nous allons composer nos widgets à l'intérieur du `build` mais dans ce cas précis il n'y a pas de widgets à composer donc il est plus simple de juste étendre `MaterialApp`.

Passons maintenant à `CounterPage` !

## Counter Page

Le widget `CounterPage` va créer un `CounterCubit` (nous l'étudierons plus en détails juste après) et il va le fournir au `CounterView`.

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **Note**: Il est important de séparer ou découper la création d'un `Cubit` de la conception d'un `Cubit` dans le but d'avoir un code bien plus testable et réutilisable.

## Counter Cubit

La class `CounterCubit` va exposer deux méthodes:

- `increment`: ajoute 1 au state actuel
- `decrement`: retire 1 au state actuel

Le type du state de `CounterCubit` est un simple `int` et son state initial est `0`.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **Conseil**: Utilisez la [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) pour créer vos cubits automatiquement.

Ensuite, regardons le `CounterView` qui sera responsable pour consommer le state et intéragir avec le `CounterCubit`.

## Counter View

Le `CounterView` est responsable de l'affichage du compteur et va afficher deux FloatingActionButtons pour ajouter/soustraire le compteur.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

Un `BlocBuilder` est utilisé pour envelopper le widget `Text` dans le but d'actualiser le texte peu importe quand le state du `CounterCubit` change. En plus, `context.read<CounterCubit>()` est utilisé pour chercher l'instance `CounterCubit` la plus proche.

?> **Note**: Seulement le widget `Text` est enveloppé dans un `BlocBuilder` car c'est le seul widget qui a besoin d'être reconstruit en réponse aux changements de states qui ont lieu dans le `CounterCubit`. Évitez d'envelopper des widgets non nécessaires qui n'ont pas besoin de se reconstruire quand un state change.

## Barrel (regroupement de modules)

  Créons enfin un fichier `counter.dart` pour exporter tous les fichiers de notre fonctionnalité compteur et ainsi faciliter leur import plus tard.

  [counter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/counter.dart ':include')

C'est tout ! Nous avons séparé la couche de présentation de celle qui s'occupe de la logique. Le `CounterView` n'a aucune idée de ce qui ce passe quand un utilisateur presse le boutton; cela notifie juste le `CounterCubit`. D'autant plus que le `CounterCubit` n'a pas idée de ce qui se passe à l'intérieur du state (la valeur du compteur); cela envoie simplement des nouveaux states en réponse aux méthodes qui sont appelées.

Nous pouvons lancer notre appli avec `flutter run` et la voir sur notre simulateur/émulateur.

L'entiéreté du code source (qui inclut les tests unitaires et de widgets) pour cet exemple, est trouvable [ici](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter).
