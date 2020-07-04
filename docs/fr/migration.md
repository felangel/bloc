# Migration vers la version v5.0.0

> Informations détaillants comment migrer vers v5.0.0 de la librairie bloc. Pour plus d'informations sur ce qui a changé a chaque sortie, veuillez vous référer aux [log de sorties](https://github.com/felangel/bloc/releases).

## package:bloc

### initialState a été supprimé

#### Raison

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

### BlocDelegate renommé BlocObserver

#### Raisons

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

### BlocSupervisor a été supprimé

#### Raisons

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

## package:flutter_bloc

### "condition" dans BlocBuilder renommé buildWhen

#### Raisons

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

### Le paramètre "condition" dans BlocListener renommé listenWhen

#### Raisons

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

## package:hydrated_bloc

### HydratedStorage et HydratedBlocStorage rennomés

#### Raisons

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

### HydratedStorage découplé de BlocDelegate

#### Raisons

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

### Une initialisation simplifiée

#### Raisons

Précédemment, les développeurs devaient appeller manuellement `super.initialState ?? DefaultInitialState()` dans le but de setup leurs instances d'`HydratedBloc`. 
C'est ennuyant et verbeux et aussi incompatible avec les gros changements de `initialState` dans `bloc`. Par conséquent, dans v5.0.0 l'initialisation d'`HydratedBloc` est identique qu'une initialisation d'un `Bloc` normal.

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
