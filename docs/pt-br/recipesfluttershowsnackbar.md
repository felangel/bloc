# Receitas: Exibir SnackBar com o BlocListener

> Nesta receita, veremos como usar o `BlocListener` para exibir um `SnackBar` em resposta a uma alteração de estado em um bloco.

![demo](../assets/gifs/recipes_flutter_snack_bar.gif)

## Bloc

Vamos construir um `DataBloc` básico que manipulará o `DataEvents` e produzirá o `DataStates`.

### DataEvent

Para ficar mais simples, nosso `DataBloc` responderá apenas a um único `DataEvent` chamado `FetchData`.

```dart
import 'package:meta/meta.dart';
@immutable
abstract class DataEvent {}
class FetchData extends DataEvent {}
```

### DataState

Nosso `DataBloc` pode ter entre um e três `DataStates` diferentes:

- `Inicial` - o estado inicial antes de adicionar um evento
- `Loading` - o estado do Bloc enquanto ele está "buscando dados de forma assíncrona"
- `Success` - o estado do Bloc quando ele "buscou dados" com sucesso

```dart
import 'package:meta/meta.dart';
@immutable
abstract class DataState {}
class Initial extends DataState {}
class Loading extends DataState {}
class Success extends DataState {}
```

### DataBloc

Nosso `DataBloc` deve ficar assim:

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

?> **Nota:** Nós estamos usando `Future.delayed` para simular a latência.

## UI Layer

Agora vamos dar uma olhada em como conectar nosso `DataBloc` a um widget e mostrar um `SnackBar` como resposta a um estado de sucesso.

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

?> Nós usamos o widget `BlocListener` para **FAZER AS COISAS** como resposta as alterações de estado em nosso `DataBloc`.

?> Nós usamos o widget `BlocBuilder` para **RENDERIZAR OS WIDGETS** como resposta as mudanças de estado em nosso `DataBloc`.

!> **NUNCA** "fazemos as coisas" em resposta a alterações de estado no método `builder` do `BlocBuilder` porque esse método só pode ser chamado várias vezes pela estrutura do Flutter. O método `builder` deve ser uma [função pura](https://en.wikipedia.org/wiki/Pure_function) que retorna um widget como resposta ao estado do Bloc.

O código completo desta receita você encontra [aqui](https://gist.github.com/felangel/1e5b2c25b263ad1aa7bbed75d8c76c44).
