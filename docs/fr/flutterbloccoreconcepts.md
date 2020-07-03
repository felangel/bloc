# Flutter Bloc Core Concepts

?> Assurez vous d'avoir lu attentivement et d'avoir compris ces sections avec de travailler avec [flutter_bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** est un widget Flutter qui nécessite un `Bloc` et une fonction `builder`. `BlocBuilder` gère la construction du widget en réponse aux nouveaux states. `BlocBuilder` est très similaire à `StreamBuilder` mais il a une API plus simple pour réduire la charge de code "passe-partout" (boilerplate) requise. La fonction `builder` peut potentiellement être appelée plusieurs fois et devrait être une [fonction pure](https://en.wikipedia.org/wiki/Pure_function) qui retourne un widget en réponse au state.

Voir `BlocListener` si vous voulez faire quelque chose en réponse au changement de state comme la navigation, afficher une boite de dialogue...

Si vous oubliez le paramètre bloc, `BlocBuilder` va automatiquement faire un lookup(va chercher) en utilisant `BlocProvider` et le `BuildContext` actuel.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder.dart.md ':include')

Spécifiez le bloc seulement si vous voulez fournir un bloc qui aura pour portée un seul widget et qui n'est pas accessible par un parent `BlocProvider` ou le `BuildContext` actuel.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_explicit_bloc.dart.md ':include')

Si vous voulez avoir plus de controle sur la fonction builder lorsqu'elle est appelée, vous pouvez fournir une `buildWhen` optionnelle au `BlocBuilder`. La `buildWhen` prend le state précédent du bloc et le compare au state du bloc actuel pour retourner un boolean. Si la `buildWhen` renvoie true, `builder` va être appelé avec `state` et le widget sera reconstruit. Si `buildWhen` retourne false, `builder` ne sera pas appelé avec `state` et la reconstruction n'aura pas lieu.

[bloc_builder.dart](../_snippets/flutter_bloc_core_concepts/bloc_builder_condition.dart.md ':include')

### BlocProvider

**BlocProvider** est un widget Flutter qui fournit un bloc a son enfant(children) via `BlocProvider.of<T>(context)`. C'est utilisé comme un widget à injection dépendante (dependency injection) pour qu'une seule instance d'un bloc puisse être distribué à plusieurs widgets à l'intérieur d'un sous-arbre (subtree).

La plus part du temps, `BlocProvider` devrait être utilisé pour créer de nouveaux `blocs` qui seront rendus disponibles au reste du subtree. Dans ce cas, puisque `BlocProvider` est responsable pour la création des blocs, il va automatiquement gérer la fermeture des blocs.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider.dart.md ':include')

Dans certains cas, `BlocProvider` peut-être utilisé pour fournir un bloc existant a une nouvelle portion dans notre widget tree (arbre). Cette pratique est souvent utilisée quand nous avons un `bloc` déjà existant qui a besoin d'être disponible à une nouvelle route. Dans ce cas, `BlocProvider` ne fermera pas automatiquement le bloc puisqu'il ne l'a pas crée.

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_value.dart.md ':include')

ensuite depuis `ChildA` ou `ScreenA` nous pouvons récupérer le `BlocA` avec:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/bloc_provider_lookup.dart.md ':include')

### MultiBlocProvider

**MultiBlocProvider** est widget Flutter qui fusionne de multiples widgets `BlocProvider` widgets en un seul.
`MultiBlocProvider` améliorer la lecture et élimine le besoin d'encapsuler plusieurs `BlocProviders`.
En utilisant `MultiBlocProvider` nous passons de:

[bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_provider.dart.md ':include')

à:

[multi_bloc_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_provider.dart.md ':include')

### BlocListener

**BlocListener** est un widget Flutter qui prend un `BlocWidgetListener`, un optionnel `Bloc` et il invoque le `listener` en réponse à tout changement de state dans le bloc. Il devrait être utilisé pour les fonctionnalités qui ont besoin de se produire une fois à chaque changement de state comme la navigation, afficher une `SnackBar`, afficher une `Dialog`, etc...

`listener` est appelé à chaque changement de state(**SANS** inclure `initialState`) à l'inverse de `builder` dans `BlocBuilder` et sa fonction `void`.

Si le paramètre bloc n'est pas renseigné, `BlocListener` va automatiquement faire un lookup(va chercher) en utilisant `BlocProvider` et le `BuildContext` actuel.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener.dart.md ':include')

Spécifié le bloc seulement si vous voulez fournir un bloc qui n'est pas accessible via `BlocProvider` et le `BuildContext` actuel.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_explicit_bloc.dart.md ':include')

Si vous voulez avoir plus de contrôle lorsque la fonction listener est appelé, vous pouvez utiliser une `listenWhen` optionnele au `BlocListener`. La `listenWhen` prend le précédent state du bloc et celui du bloc actuel pour retourner un boolean. Si `listenWhen` renvoie true, `listener` sera appelé avec `state`. Si `listenWhen` renvoie false, `listener` ne sera pas appelé avec `state`.

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/bloc_listener_condition.dart.md ':include')

### MultiBlocListener

**MultiBlocListener** est un widget Flutter qui fusionne plus widgets `BlocListener` en un seul.
`MultiBlocListener` améliore la lecture et élimine le besoin d'encapsuler plusieurs `BlocListeners`.
En utilisant `MultiBlocListener` nous passons de:

[bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/nested_bloc_listener.dart.md ':include')

à:

[multi_bloc_listener.dart](../_snippets/flutter_bloc_core_concepts/multi_bloc_listener.dart.md ':include')

### BlocConsumer

**BlocConsumer** expose un `builder` et `listener` dans le but de réagir aux nouveaux states. `BlocConsumer` est comparable à une imbrication de `BlocListener` et `BlocBuilder` mais réduit le montant de boilerplate[traduction](https://www.google.com/search?q=boilerplate+IT&rlz=1C1CHBF_frFR865FR865&oq=boilerp&aqs=chrome.0.69i59l2j69i57j0l5.46422j1j4&sourceid=chrome&ie=UTF-8) nécessaire. `BlocConsumer` devrait être utilisé uniquement quand cela est nécessaire d'à la fois reconstruire l'UI et éxecuter trop réactions liés aux changements de states dans le `bloc`. `BlocConsumer` a comme paramètre requis `BlocWidgetBuilder` et `BlocWidgetListener` ainsi qu'un optionnel `bloc`, `BlocBuilderCondition`, et `BlocListenerCondition`.

Si le paramètre `bloc` est oublié, `BlocConsumer` va automatiquement faire un lookup(va chercher) en utilisant `BlocProvider` et le `BuildContext` actuel.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer.dart.md ':include')

Les paramètres optionnels `listenWhen` et `buildWhen` peuvent être implémentés pour un meilleur controle lorsque `listener` et `builder` sont appelés. Le `listenWhen` et `buildWhen` seront invoqués sur chaque changement du `bloc` `state`. Ils prennent chacun la valeur du précédent `state` et de l'actuel `state` et ils doivent retourner un `bool` qui détermine si oui ou non les fonctions `builder` et/ou `listener` doivent être invoquées. L'ancien `state` sera initialisé au `state` du `bloc` quand le `BlocConsumer` sera initialisé. `listenWhen` et `buildWhen` sont optionnels et si ils ne sont pas implémentés, ils retourneront `true` par défaut.

[bloc_consumer.dart](../_snippets/flutter_bloc_core_concepts/bloc_consumer_condition.dart.md ':include')

### RepositoryProvider

**RepositoryProvider** est un widget Flutter qui fournit un répertoire a son enfant (children) via `RepositoryProvider.of<T>(context)`. Il est utilisé par un widget à injection dépendante pour qu'une seule instance d'un répertoire puisse être fournit à plusieurs widgets dans le sous-arbre (subtree). `BlocProvider` devrait être utilisé pour fournir des blocs tandis que `RepositoryProvider` doit uniquement utilisé pour les répertoires.

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider.dart.md ':include')

ensuite depuis `ChildA` we can récupérer l'instance de `Repository` avec:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/repository_provider_lookup.dart.md ':include')

### MultiRepositoryProvider

**MultiRepositoryProvider** est un widget Flutter qui fusionne de multiples `RepositoryProvider` widgets en un seul.
`MultiRepositoryProvider` améliore la lecture et élimine la nécessité d'imbriquer plusieurs `RepositoryProvider`.
En utilisant `MultiRepositoryProvider` nous passons de:

[repository_provider.dart](../_snippets/flutter_bloc_core_concepts/nested_repository_provider.dart.md ':include')

à:

[multi_repository_provider.dart](../_snippets/flutter_bloc_core_concepts/multi_repository_provider.dart.md ':include')

## Utilisation

Regardons comment utiliser `BlocBuilder` pour récupérer (hook up) le widget `CounterPage` à un `CounterBloc`.

### counter_bloc.dart

[counter_bloc.dart](../_snippets/flutter_bloc_core_concepts/counter_bloc.dart.md ':include')

### counter_page.dart

[counter_page.dart](../_snippets/flutter_bloc_core_concepts/counter_page.dart.md ':include')

A présent, nous avons réussi à séparer la couche de présention à celle de notre business logique. Vous pouvez remarquer que le widget `CounterPage` connaît tout à propos de ce qu'il se passe lorsque l'utilisateur appuie sur un des boutons. Ce widget va simplement informer `CounterBloc` que l'utilisateur à appuyer sur soit le bouton d'incrémentation ou sur le bouton de décrémentation.
