# Recepty: Navigace

> V tomto receptu se podíváme na použítí `BlocBuilderu` a/nebo `BlocListeneru` k navigaci. Prozkoumáme dva přístupy: Přímou navigaci a Navigaci routami.

## Přímá navigace

> V tétu ukázce se podíváme na to, jak použít `BlocBuilder` k zobrazení dané stránky (widgetu) jako odezvu na změnu stavu v blocu bez použití routy.

![demo](../assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

Pojďme si udělat `MyBloc`, který bude přijímat `MyEventy` a produkovat `MyStaty`.

#### MyEvent

Pro jednoduchost bude naše aplikace reagovat pouze na dva `MyEventy`: `eventA` a `eventB`.

```dart
enum MyEvent { eventA, eventB }
```

#### MyState

Náš `MyBloc` může mít jeden ze dvou `MyStavů`:

- `StateA` - stav blocu, když je vekreslena `PageA`.
- `StateB` - stav blocu, když je vekreslena `PageB`.

```dart
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}
```

#### MyBloc

Náš `MyBloc` by měl vypadat nějak takto:

```dart
import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}
```

### UI vrstva

Nyní se pojďme podívat na to, jak propojit `MyBloc` k widgetu a zobrazit jinou stránku v závislosti na stavu blocu.

```dart
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(),
      child: MyApp(),
    ),
  );
}

enum MyEvent { eventA, eventB }

@immutable
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<MyBloc, MyState>(
        builder: (_, state) => state is StateA ? PageA() : PageB(),
      ),
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page A'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go to PageB'),
          onPressed: () {
            BlocProvider.of<MyBloc>(context).add(MyEvent.eventB);
          },
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page B'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Go to PageA'),
          onPressed: () {
            BlocProvider.of<MyBloc>(context).add(MyEvent.eventA);
          },
        ),
      ),
    );
  }
}
```

?> Používáme `BlocBuilder` widget abychom vykreslili správný widget v reakci na změnu stavu našeho `MyBlocu`.

?> Používáme `BlocProvider` widget abychom zpřístupnili naší instanci `MyBloc` celému stromu widgetů.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09).

## Navigace routami

> V této ukázce se podíváme na to, jak použít `BlocListener` k navigaci na danou stránku (widget) v reakci na změnu stavu v blocu použitím routy.

![demo](../assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

Použijeme `MyBloc` z předešlého příkladu.

### UI vrstva

Podívejme se na to, jak routovat na jinou stránku v závislosti na stavu `MyBlocu`.

```dart
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => MyBloc(),
      child: MyApp(),
    ),
  );
}

enum MyEvent { eventA, eventB }

@immutable
abstract class MyState {}

class StateA extends MyState {}

class StateB extends MyState {}

class MyBloc extends Bloc<MyEvent, MyState> {
  @override
  MyState get initialState => StateA();

  @override
  Stream<MyState> mapEventToState(MyEvent event) async* {
    switch (event) {
      case MyEvent.eventA:
        yield StateA();
        break;
      case MyEvent.eventB:
        yield StateB();
        break;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => PageA(),
        '/pageB': (context) => PageB(),
      },
      initialRoute: '/',
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MyBloc, MyState>(
      listener: (context, state) {
        if (state is StateB) {
          Navigator.of(context).pushNamed('/pageB');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Page A'),
        ),
        body: Center(
          child: RaisedButton(
            child: Text('Go to PageB'),
            onPressed: () {
              BlocProvider.of<MyBloc>(context).add(MyEvent.eventB);
            },
          ),
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page B'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Pop'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
```

?> Používáme `BlocListener` widget abychom přidali novou routu v reakci na změnu stavu v našem `MyBlocu`.

!> Pro jednoduchost přidáváme událost pouze pro navigaci. V reálné aplikaci byste však konkrétní události pro navigaci nevytvářeli. Pokud pro spuštění navigace není nutná žádná logika, měli byste vždy přímo navigovat v reakci na vstup uživatele (v `onPressed` callbacku atp.). Navigujte v závislosti na změně stavu pouze když je vyžadována nějaká logika k určení, kam navigovat.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd).
