# Tutoriel Flutter d'un Compteur 

![débutant](https://img.shields.io/badge/level-beginner-green.svg)

> Dans ce tutoriel, nous allons construire un compteur avec Flutter en utilisant la bibliothèque Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Configuration

Nous commencerons par créer un nouveau projet Flutter

```bash
flutter create flutter_counter
```

Nous pouvons  remplacer le contenu de `pubspec.yaml` par

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^1.0.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

et ensuite installer toutes nos dépendances

```bash
flutter packages get
```

Notre application de compteur va juste avoir deux boutons pour incrémenter/décrémenter la valeur du compteur et un widget `Text` pour afficher la valeur courante. Commençons à concevoir les `CounterEvents`.

## Counter Events

```dart
enum CounterEvent { increment, decrement }
```

## Counter States

Puisque l'état de notre compteur peut être représenté par un entier, nous n'avons pas besoin de créer une classe personnalisée !

## Counter Bloc

```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

?> **Note**: À partir de la déclaration de la classe, nous pouvons dire que notre `CounterBloc` prendra `CounterEvents` comme entrée et sortira des entiers.

## Counter App

Maintenant que notre `CounterBloc` est complètement implémenté, nous pouvons commencer à créer notre application Flutter.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        builder: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Note**: Nous utilisons le widget `BlocProvider` de `flutter_bloc` afin de rendre l'instance de `CounterBloc` disponible pour tout le sous-arbre (`CounterPage`). Le `BlocProvider` gère également la fermeture automatique du `CounterBloc` pour que nous n'ayons pas besoin d'utiliser un `StatefulWidget`.

## Counter Page

Enfin, il ne nous reste plus qu'à construire notre `Counter Page`.

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

?> **Note**: Nous pouvons accéder à l'instance `CounterBloc` en utilisant `BlocProvider.of<CounterBloc>(contexte)` parce que nous avons enveloppé notre `CounterPage` dans un `BlocProvider`.

?> **Note**: Nous utilisons le widget `BlocBuilder` de `flutter_bloc` afin de reconstruire notre interface utilisateur en réponse aux changements d'état (changements de compteur).

?> **Note**: `BlocBuilder` prend un paramètre optionnel `bloc` mais nous pouvons spécifier le type du bloc et le type de l'état et `BlocBuilder` trouvera le bloc automatiquement donc nous n'avons pas besoin d'utiliser `BlocProvider.of<CounterBloc>(contexte)`.

!> Ne spécifiez le bloc dans `BlocBuilder` que si vous souhaitez fournir un bloc qui sera mis à la portée d'un seul widget et qui n'est pas accessible via un `BlocProvider` parent et le `BuildContext` courant.

Ca y est ! Nous avons séparé notre couche de présentation de notre couche logique métier. Notre `CounterPage` n'a aucune idée de ce qui se passe quand un utilisateur appuie sur un bouton ; il ajoute simplement un événement pour avertir le `CounterBloc`. De plus, notre `CounterBloc` n'a aucune idée de ce qui se passe avec l'état (valeur du compteur) ; il s'agit simplement de convertir les `CounterEvents` en entiers.


Nous pouvons exécuter notre application avec `flutter run` et la visualiser sur notre appareil ou simulateur/émulateur.

La source complète de cet exemple se trouve à l'adresse suivante [ici](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
