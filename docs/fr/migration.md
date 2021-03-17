# Guide de migration

?> **Conseil** : Pour plus d'informations sur ce qui a changé à chaque mise à jour, veuillez vous référer à [l'historique des versions](https://github.com/felangel/bloc/releases).

## v6.1.0

### package:flutter_bloc

#### ❗context.bloc et context.repository sont dépréciés en faveur de context.read et context.watch

##### Raisons

`context.read`,` context.watch` et `context.select` ont été ajoutés pour s'aligner sur l'API existante [provider](https://pub.dev/packages/provider) que de nombreux développeurs connaissent et répondre à des questions déjà résolues par la communauté. Pour améliorer la sécurité du code et maintenir la cohérence, `context.bloc` est obsolète car il peut être remplacé par` context.read` ou `context.watch` en fonction de son utilisation directe dans` build`.

**context.watch**

`context.watch` répond à la demande d'avoir un [MultiBlocBuilder](https://github.com/felangel/bloc/issues/538) en observant plusieurs blocs dans un seul` Builder` et ainsi pouvoir redessiner l'interface utilisateur selon plusieurs états :

```dart
Builder(
  builder: (context) {
    final stateA = context.watch<BlocA>().state;
    final stateB = context.watch<BlocB>().state;
    final stateC = context.watch<BlocC>().state;

    // retourne un widget qui dépend de l'état de BlocA, BlocB et BlocC
  }
);
```

**context.select**

`context.select` permet aux développeurs de dessiner / mettre à jour l'interface utilisateur en fonction d'une partie d'un état de bloc et répond à la demande d'avoir un [buildWhen plus simple](https://github.com/felangel/bloc/issues/1521).

```dart
final name = context.select((UserBloc bloc) => bloc.state.user.name);
```

L'extrait de code ci-dessus nous permet d'accéder et de reconstruire le widget uniquement lorsque le nom de l'utilisateur change.

**context.read**

Même si `context.read` ressemble beaucoup à` context.bloc`, il existe des différences subtiles mais significatives. Les deux vous permettent d'accéder à un bloc avec un `BuildContext` et n'entraînent pas de reconstructions; cependant, `context.read` ne peut pas être appelé directement dans une méthode` build`. Il y a deux raisons principales d'utiliser `context.bloc` dans` build`:

1. **Pour accéder à l'état du bloc**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

L'utilisation ci-dessus est sujette aux erreurs car le widget `Text` ne sera pas reconstruit si l'état du bloc change. Dans ce scénario, un `BlocBuilder` ou un` context.watch` doit être utilisé.

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

ou

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) => Text('$state'),
  );
}
```

!> L'utilisation de `context.watch` à la racine de la méthode` build` entraînera la reconstruction du widget entier lorsque l'état du bloc change. Si le widget entier n'a pas besoin d'être reconstruit, utilisez `BlocBuilder` pour envelopper les parties à reconstruire, utilisez un` Builder` avec `context.watch` pour étendre les reconstructions, ou décomposez le widget en widgets plus petits.

2. **Pour accéder au bloc afin qu'un événement puisse être ajouté**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

L'utilisation ci-dessus est inefficace car elle entraîne une recherche de bloc à chaque reconstruction lorsque le bloc n'est nécessaire que lorsque l'utilisateur appuie sur le `ElevatedButton`. Dans ce scénario, préférez utiliser `context.read` pour accéder au bloc directement là où il est nécessaire (dans ce cas, dans le callback` onPressed`).

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

**Résumé**

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final bloc = context.bloc<MyBloc>();
  return ElevatedButton(
    onPressed: () => bloc.add(MyEvent()),
    ...
  )
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

?> Si vous accédez à un bloc pour ajouter un événement, accédez au bloc en utilisant `context.read` dans lea fonction de rappel (callback) là où il est nécessaire.

**v6.0.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

**v6.1.x**

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

?> Utilisez `context.watch` lors de l'accès à l'état du bloc afin de vous assurer que le widget est reconstruit lorsque l'état change.


## v5.0.0

### package:bloc

#### ❗initialState a été supprimé

##### Raisons

En tant que développeur, devoir override `initialState` lors de la création d'un bloc présente deux problèmes majeurs:

- L'`initialState` du bloc peut être dynamique et renvoyer à un point plus tard dans le temps (même en dehors du bloc lui-même). D'une certaine manière, cela peut être vue comme faire fuiter des informations contenues dans le bloc à l'intérieur de la couche d'UI.
- C'est verbeux.

**v4.x.x**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  ...
}
```

**v5.0.0**

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```

?> Pour plus d'informations, rendez vous ici (ENG) [#1304](https://github.com/felangel/bloc/issues/1304)

#### ❗BlocDelegate renommé BlocObserver

##### Raisons

Le nom `BlocDelegate` n'était pas une description précise du rôle que la class jouait. `BlocDelegate` suggère que la class a un rôle actif alors qu'en réalité son rôle était d'être un composant passif qui ne fait qu'observer tous les blocs dans une application.
!> Idéalement, il ne devrait pas avoir de fonctionnalités avec laquelle l'utilisateur intéragit à l'intérieur d'un `BlocObserver`.

**v4.x.x**

```dart
class MyBlocDelegate extends BlocDelegate {
  ...
}
```

**v5.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  ...
}
```

#### ❗BlocSupervisor a été supprimé

##### Raisons

`BlocSupervisor` était un autre composant que les développeurs devaient connaître et intéragir avec pour seul but de spécifier un custom `BlocDelegate`.
En changeant `BlocObserver` nous avons améliorer l'expérience développeur en mettant en place l'obsever directement à l'intérieur même du bloc.

?> Ce changement nous permet également de découpler d'autres modules complémentaires comme `HydratedStorage` depuis le `BlocObserver`.

**v4.x.x**

```dart
BlocSupervisor.delegate = MyBlocDelegate();
```

**v5.0.0**

```dart
Bloc.observer = MyBlocObserver();
```

### package:flutter_bloc

#### ❗"condition" dans BlocBuilder renommé buildWhen

##### Raisons

Quand on utilise `BlocBuilder`, nous pouvions spécifier une `condition` pour déterminer si le `builder` doit se reconstruire.

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

Le nom `condition` n'est pas vraiment explicite ou évident et plus important encore, quand on intéragit avec un `BlocConsumer` l'API devenait inconsistante car les développeurs peuvent fournir deux conditions 
(une pour `builder` et une pour `listener`). Par conséquent, l'API `BlocConsumer` expose un `buildWhen` et `listenWhen`

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...},
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...},
)
```
Dans le but d'aligner l'API et de fournir une meilleure expérience de développement, `condition` a été renommée `buildWhen`.

**v4.x.x**

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) {
    // return true/false to determine whether to call builder
  },
  builder: (context, state) {...}
)
```

#### ❗Le paramètre "condition" dans BlocListener renommé listenWhen

##### Raisons

Pour les mêmes raisons que décrites précédemment, la condition du `BlocListener` a aussi été renommée.

**v4.x.x**

```dart
BlocListener<MyBloc, MyState>(
  condition: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether to call listener
  },
  listener: (context, state) {...}
)
```

### package:hydrated_bloc

#### HydratedStorage et HydratedBlocStorage rennomés

##### Raisons

Dans le but d'améliorer le code réutiliser entre [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) et [hydrated_cubit](https://pub.dev/packages/hydrated_cubit), l'implémentation concrète du stockage par défaut a été rennomé passant de `HydratedBlocStorage` à `HydratedStorage`. En plus, l'interface `HydratedStorage` est passé de `HydratedStorage` à `Storage`.

**v4.0.0**

```dart
class MyHydratedStorage implements HydratedStorage {
  ...
}
```

**v5.0.0**

```dart
class MyHydratedStorage implements Storage {
  ...
}
```

#### HydratedStorage découplé de BlocDelegate

##### Raisons

Comme mentionné précédemment, `BlocDelegate` a été renommé `BlocObserver` et est défini directement comme une part du `bloc` via:

```dart
Bloc.observer = MyBlocObserver();
```

Les changements ont été effectué pour:

- Rester consistent avec la nouvelle API du bloc observer
- Garder la visée du stockage juste pour `HydratedBloc`
- Découpler le `BlocObserver` depuis `Storage`

**v4.0.0**

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build();
```

**v5.0.0**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

#### ❗Une initialisation simplifiée

##### Raisons

Précédemment, les développeurs devaient appeller manuellement `super.initialState ?? DefaultInitialState()` dans le but de setup leurs instances d'`HydratedBloc`. 
C'est ennuyant et verbeux et aussi incompatible avec les gros changements de `initialState` dans `bloc`. Par conséquent, dans v5.0.0 l'initialisation d'`HydratedBloc` est identique à une initialisation d'un `Bloc` normal.

**v4.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  @override
  int get initialState => super.initialState ?? 0;
}
```

**v5.0.0**

```dart
class CounterBloc extends HydratedBloc<CounterEvent, int> {
  CounterBloc() : super(0);

  ...
}
```
