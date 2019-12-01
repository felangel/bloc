# Recepty: Zobrazení SnackBaru s BlocListenerem

> V tomto receptu se podíváme na to, jak použít `BlocListener` k zobrazení `SnackBaru` v reakci na změnu stavu blocu.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Pojďme si udělat základní `DataBloc`, který bude zpracovávat `DataEventy` a produkovat `DataStaty`.

### DataEvent

Pro jednoduchost bude náš `DataBloc` reagovat pouze na jeden `DataEvent`, který pojmenujeme `FetchData`.

```dart
import 'package:meta/meta.dart';

@immutable
abstract class DataEvent {}

class FetchData extends DataEvent {}
```

### DataState

Náš `DataBloc` může mít jeden z tří různých `DataStatů`:

- `Initial` - počáteční stav před přidáním jakýchkoli událostí
- `Loading` - stav blocu zatímco se asynchroně "načítají data"
- `Success` - stav blocu když se data úspěšně "načetla"

```dart
import 'package:meta/meta.dart';

@immutable
abstract class DataState {}

class Initial extends DataState {}

class Loading extends DataState {}

class Success extends DataState {}
```

### DataBloc

Náš `DataBloc` by měl vypadat nějak takto:

```dart
import 'package:bloc/bloc.dart';

class DataBloc extends Bloc<DataEvent, DataState> {
  @override
  DataState get initialState => Initial();

  @override
  Stream<DataState> mapEventToState(
    DataEvent event,
  ) async* {
    if (event is FetchData) {
      yield Loading();
      await Future.delayed(Duration(seconds: 2));
      yield Success();
    }
  }
}
```

?> **Poznámka:** Používáme `Future.delayed` abychom simulovali latenci.

## UI vrstva

Nyní se pojďme podívat jak připojit `DataBloc` wiget a zobrazit `Snackbar` v reakci na stav úspěchu.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataBloc(),
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dataBloc = BlocProvider.of<DataBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: BlocListener<DataBloc, DataState>(
        listener: (context, state) {
          if (state is Success) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text('Success'),
              ),
            );
          }
        },
        child: BlocBuilder<DataBloc, DataState>(
          builder: (context, state) {
            if (state is Initial) {
              return Center(child: Text('Press the Button'));
            }
            if (state is Loading) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is Success) {
              return Center(child: Text('Success'));
            }
          },
        ),
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.play_arrow),
            onPressed: () {
              dataBloc.add(FetchData());
            },
          ),
        ],
      ),
    );
  }
}
```

?> Používáme `BlocListener` widget abychom **DĚLALI VĚCI** v reakci na změny stavu našeho `DataBlocu`.

?> Používáme `BlocBuilder` widget abychom **VYKRESLOVALI WIDGETY** v závislosti na změně stavu našeho `DataBlocu`.

!> **NIKDY** bychom neměli "dělat věci" v závislosti na změně stavu v `builder` metodě `BlocBuilderu`, protože tato metoda může být zavolána Flutter frameworkem mnohokrát. `builder` metoda by měla být vez vedlejších účinků ([pure funkce](https://en.wikipedia.org/wiki/Pure_function)), která vrací widget v reakci na stav blocu.

Celý zdrojový kód pro tento recept můžete najít [zde](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).
