# Concepts de base

?> Veuillez lire attentivement et comprendre les sections suivantes avant de travailler avec [bloc](https://pub.dev/packages/bloc).

Il y a plusieurs concepts fondamentaux qui sont essentiels pour comprendre comment utiliser Bloc.

Dans les prochaines sections, nous allons discuter en détail de chacun d'entre eux ainsi que de la façon dont ils s'appliqueraient à une application du monde réel : une contre-application.

## Événements

> Les événements sont la contribution d'un Bloc. Elles sont généralement distribuées en réponse aux interactions de l'utilisateur telles que les pressions sur les boutons ou les événements du cycle de vie tels que les chargements de pages.

Lors de la conception d'une application, nous devons prendre du recul et définir comment les utilisateurs vont interagir avec elle. Dans le contexte de notre application compteur, nous aurons deux boutons pour incrémenter et décrémenter notre compteur.

Lorsqu'un utilisateur tape sur l'un de ces boutons, quelque chose doit se produire pour notifier le "cerveau" de notre application afin qu'il puisse répondre à l'entrée de l'utilisateur; c'est là que les événements entrent en jeu.

Nous devons être capables de notifier les "cerveaux" de notre application à la fois d'un incrément et d'un décrément, donc nous devons définir ces événements.

```dart
enum CounterEvent { increment, decrement }
```

Dans ce cas, nous pouvons représenter les événements à l'aide d'un `enum' mais pour des cas plus complexes il peut être nécessaire d'utiliser une `class' surtout s'il est nécessaire de transmettre des informations au bloc.

A ce stade, nous avons défini notre premier événement ! Notez que nous n'avons pas utilisé Bloc de quelque façon que ce soit jusqu'à présent et qu'il n'y a pas de magie ; c'est tout simplement du code Dart.

## États

> Les états sont la sortie d'un Bloc et représentent une partie de l'état de votre application. Les composants de l'interface utilisateur peuvent être notifiés des états et redessiner des parties d'eux-mêmes en fonction de l'état actuel.

Jusqu'à présent, nous avons défini les deux événements auxquels notre application va répondre : `CounterEvent.increment` et `CounterEvent.decrement`.

Nous devons maintenant définir comment représenter l'état de notre application.

Puisque nous construisons un compteur, notre état est très simple : c'est juste un entier qui représente la valeur courante du compteur.

Nous verrons plus loin des exemples plus complexes d'état, mais dans ce cas, un type primitif convient parfaitement comme représentation de l'état.

## Transitions

> Le passage d'un état à un autre s'appelle une Transition. Une transition se compose de l'état actuel, de l'événement et de l'état suivant.

Lorsqu'un utilisateur interagit avec notre application compteur, il déclenche les événements `Increment` et `Decrement` qui mettent à jour l'état du compteur. Tous ces changements d'état peuvent être décrits comme une série de  `Transitions`.

Par exemple, si un utilisateur ouvrait notre application et tapait sur le bouton d'incrémentation une fois que nous verrions la `Transition` suivante.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Parce que chaque changement d'état est enregistré, nous sommes en mesure d'instrumenter très facilement nos applications et de suivre toutes les interactions utilisateur et les changements d'état dans un seul endroit. De plus, cela rend possible des choses comme le débogage de  type "time-travel".

## Streams

Consultez la documentation officielle[Dart Documentation](https://www.dartlang.org/tutorials/language/streams) pour plus d'informations sur `Streams`.

> Un "stream" est une séquence de données asynchrones.

Bloc est construit sur les bases de [RxDart](https://pub.dev/packages/rxdart) ; cependant, il fait abstraction tous les détails d'implémentation spécifiques de `RxDart`.

Pour utiliser Bloc, il est critique d'avoir une bonne compréhension des `Streams` et de son fonctionnement.

> Si vous n'êtes pas familier avec `Streams`, pensez simplement à un tuyau avec de l'eau qui le traverse. Le tuyau est le `Stream` et l'eau est la donnée asynchrone.

Nous pouvons créer un `Stream` en Dart en écrivant une fonction `async*`.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

En marquant une fonction comme `async*` nous pouvons utiliser le mot-clé `yield` et retourner un `Stream` de données. Dans l'exemple ci-dessus, nous retournons un `Stream` d'entiers jusqu'au paramètre entier `max`.

Chaque fois que nous utilisons `yield` dans une fonction `async*`, nous poussons cette donnée à travers le `Stream`.

Nous pouvons consommer le `Stream` ci-dessus de plusieurs manières. Si nous voulions écrire une fonction pour retourner la somme d'un `Stream` d'entiers il pourrait ressembler à quelque chose comme :

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

En marquant la fonction ci-dessus comme `async` nous pouvons utiliser le mot-clé `await` et retourner un `Future` d'entiers. Dans cet exemple, nous attendons chaque valeur du flux et retournons la somme de tous les entiers du flux.

On peut tout mettre ensemble comme ça :

```dart
void main() async {
    /// Initialize a stream of integers 0-9
    Stream<int> stream = countStream(10);
    /// Compute the sum of the stream of integers
    int sum = await sumStream(stream);
    /// Print the sum
    print(sum); // 45
}
```

## Blocs

> Un Bloc (Business Logic Component) est un composant qui convertit un `Stream` d'évvènements entrants `Events` en un `Stream` d'états sortants `States`. Pensez à un Bloc comme étant des "cerveaux" décrit ci-dessus.

> Chaque Bloc doit étendre la classe de base `Bloc` qui fait partie du paquet de base du bloc.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

Dans l'extrait de code ci-dessus, nous déclarons notre `CounterBloc` comme un Bloc qui convertit `CounterEvents` en `ints`.

> Chaque Bloc doit définir un état initial qui est l'état avant que les événements n'aient été reçus.

Dans ce cas, nous voulons que notre compteur commence à `0`.

```dart
@override
int get initialState => 0;
```

> Chaque Bloc doit implémenter une fonction appelée `mapEventToState`. La fonction prend l'événement entrant `event` comme argument et doit retourner un `Stream` de nouveaux états`states` qui est consommé par la couche de présentation. Nous pouvons accéder à l'état courant du bloc à tout moment en utilisant la propriété `currentState`.

```dart
@override
Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
}
```

A ce stade, nous avons un `CounterBloc` qui fonctionne parfaitement.

```dart
import 'package:bloc/bloc.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield currentState - 1;
        break;
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}
```

Les blocs ignorent les états dupliqués. Si un bloc donne `State state` où `currentState == state`, alors aucune transition n'aura lieu et aucun changement ne sera apporté au `Stream<State>`.

A ce stade, vous vous demandez probablement _"Comment puis-je avertir un Bloc d'un événement ?"_.

> Chaque Bloc a une méthode `dispatch`. `Dispatch` " prend un `event` et déclenche `mapEventToState`. `Dispatch` peut être appelée à partir de la couche de présentation ou à partir du Bloc et informe le Bloc d'un nouvel `event`.

Nous pouvons créer une application simple qui compte de 0 à 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.dispatch(CounterEvent.increment);
    }
}
```

Les `Transitions` dans l'extrait de code ci-dessus seraient

```json
{
    "currentState": 0,
    "event": "CounterEvent.increment",
    "nextState": 1
}
{
    "currentState": 1,
    "event": "CounterEvent.increment",
    "nextState": 2
}
{
    "currentState": 2,
    "event": "CounterEvent.increment",
    "nextState": 3
}
```

Malheureusement, dans l'état actuel, nous ne pourrons voir aucune de ces transitions à moins de passer outre `onTransition`.

> `onTransition` est une méthode qui peut être écrasée pour gérer chaque bloc local `Transition`. On appelle `onTransition` juste avant la mise à jour du `state` d'un Bloc.

?> **Tip**: `onTransition` est un excellent endroit pour ajouter des logging/analytiques spécifiques aux blocs.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Maintenant que nous avons pris le pas sur la `onTransition`, nous pouvons faire ce que nous voulons quand une `onTransition` se produit.

Tout comme nous pouvons gérer les `Transitions` au niveau des blocs, nous pouvons également gérer les `Exceptions`.

> `onError` est une méthode qui peut être surchargée pour gérer chaque `Exception` de Bloc local. Par défaut, toutes les exceptions seront ignorées et la fonctionnalité `Bloc` ne sera pas affectée.

?> **Note**: L'argument stacktrace peut être `null` si le flux d'état a reçu une erreur sans `StackTrace`.

?> **Tip**: `onError` est un excellent endroit pour ajouter la gestion des erreurs spécifiques aux blocs.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Maintenant que nous avons écrasé `onError`, nous pouvons faire ce que nous voulons à chaque fois qu'une `Exception` est levée.

## BlocDelegate

Un avantage supplémentaire de l'utilisation du Bloc, c'est que nous pouvons avoir accès à toutes les " Transitions " en un seul endroit. Même si dans cette application nous n'avons qu'un seul Bloc, il est assez courant dans les grandes applications d'avoir plusieurs blocs gérant différentes parties de l'état de l'application.

Si nous voulons pouvoir faire quelque chose en réponse à toutes les `Transitions`, nous pouvons simplement créer notre propre `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Note**: Tout ce que nous avons à faire est d'étendre `BlocDelegate` et de remplacer la méthode `onTransition`.

Pour dire à Bloc d'utiliser notre `SimpleBlocDelegate`, il nous suffit d'ajuster notre fonction `main`.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.dispatch(CounterEvent.increment);
  }
}
```

Si nous voulons pouvoir faire quelque chose en réponse à tous les `Events` envoyés, nous pouvons aussi remplacer la méthode `onEvent` dans notre `SimpleBlocDelegate`.

```dart
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
}
```

Si nous voulons pouvoir faire quelque chose en réponse à toutes les `Exceptions` jetées dans un Bloc, nous pouvons aussi écraser la méthode `onError` dans notre `SimpleBlocDelegate`.

```dart
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
    print('$error, $stacktrace');
  }
}
```

?> **Note**: Le `BlocSupervisor` est un singleton qui supervise tous les Blocs et délègue des responsabilités au `BlocDelegate`.
