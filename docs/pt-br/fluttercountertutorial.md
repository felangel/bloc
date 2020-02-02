# Tutorial Flutter Counter

![iniciante](https://img.shields.io/badge/level-beginner-green.svg)

> No tutorial a seguir, criaremos um contador no Flutter usando a biblioteca Bloc.

![demo](../assets/gifs/flutter_counter.gif)

## Setup

Começaremos criando um novo projeto Flutter

```bash
flutter create flutter_counter
```

Podemos então prosseguir e substituir o conteúdo de `pubspec.yaml` por

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: ">=2.0.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

e instale todas as nossas dependências

```bash
flutter packages get
```

Nosso aplicativo de contador terá apenas dois botões para aumentar / diminuir o valor do contador e um widget `Text` para exibir o valor atual. Vamos começar a projetar os `CounterEvents`.

## Eventos Counter

```dart
enum CounterEvent { increment, decrement }
```

## Estados Counter

Como o estado do nosso contador pode ser representado por um número inteiro, não precisamos criar uma classe personalizada!

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

?> **Nota**: Apenas a partir da declaração da classe, podemos dizer que o nosso `CounterBloc` aceitará o` CounterEvents` como números inteiros de entrada e saída.

## Counter App

Agora que temos nosso `CounterBloc` totalmente implementado, podemos começar a criar nosso aplicativo Flutter.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Nota**: Estamos usando o widget `BlocProvider` do `flutter_bloc` para tornar a instância do `CounterBloc` disponível para toda a subárvore (`CounterPage`). O `BlocProvider` também controla o fechamento do `CounterBloc` automaticamente, para que não seja necessário usar um `StatefulWidget`.

## Counter Page

Finalmente, tudo o que resta é criar nossa página de contador.

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

?> **Nota**: Podemos acessar a instância do `CounterBloc` usando o `BlocProvider.of<CounterBloc>(context)` porque envolvemos nossa `CounterPage` em um `BlocProvider`.

?> **Nota**: Estamos usando o widget `BlocBuilder` do `flutter_bloc` para reconstruir nossa interface do usuário em resposta a alterações de estado (alterações no valor do contador).

?> **Nota**: `BlocBuilder` usa um parâmetro opcional `bloc`, mas podemos especificar o tipo do blocc e o tipo do estado, e o `BlocBuilder` encontrará o bloc automaticamente, assim não precisamos explicitar use `BlocProvider.of<CounterBloc>(context)`.

!> Especifique apenas o bloc no `BlocBuilder` se desejar fornecer um bloc com escopo definido para um único widget e que não possa ser acessado pelo pai` BlocProvider` e pelo atual `BuildContext`.

É isso aí! Separamos nossa camada de apresentação da nossa camada de lógica de negócios. Nossa `CounterPage` não faz ideia do que acontece quando um usuário pressiona um botão; apenas adiciona um evento para notificar o `CounterBloc`. Além disso, nosso `CounterBloc` não faz ideia do que está acontecendo com o estado (valor do contador); é simplesmente converter os `CounterEvents` em números inteiros.

Podemos executar nosso aplicativo com `flutter run` e podemos vê-lo em nosso dispositivo ou simulador / emulador.

O código fonte completo deste exemplo pode ser encontrado [aqui](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
