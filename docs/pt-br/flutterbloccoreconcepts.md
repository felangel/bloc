# Principais Conceitos do Flutter Bloc

?> Por favor leia e compreenda cuidadosamente as seções a seguir antes de trabalhar com [bloc](https://pub.dev/packages/flutter_bloc).

## Bloc Widgets

### BlocBuilder

**BlocBuilder** é um widget Flutter que requer uma função `Bloc` e `builder`. O BlocBuilder trata da construção do widget em resposta a novos estados. O `BlocBuilder` é muito semelhante ao` StreamBuilder`, mas possui uma API mais simples para reduzir a quantidade de código padrão necessário. A função `builder` será potencialmente chamada muitas vezes e deve ser uma [função pura] (https://en.wikipedia.org/wiki/Pure_function) que retorna um widget em resposta ao estado.

Veja `BlocListener` se você quiser "fazer" qualquer coisa em resposta a alterações de estado, como navegação, exibição de um diálogo, etc ...

Se o parâmetro bloc for omitido, o `BlocBuilder` executará automaticamente uma pesquisa usando o` BlocProvider` e o atual `BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Especifique o Bloc apenas se você deseja fornecer um Bloc que terá o escopo definido em um único widget e não possa ser acessado através do pai `BlocProvider` e do atual` BuildContext`.

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Se você deseja um controle refinado sobre quando a função do construtor é chamada, você pode fornecer uma condição opcional ao `BlocBuilder`. A condição pega o estado anterior do bloc e o atual estado do bloc e retorna um valor booleano. Se `condition` retornar true,`builder` será chamado com `state` e o widget será reconstruído. Se `condition` retornar false, o `builder` não será chamado com `state` e nenhuma reconstrução ocorrerá.

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### BlocProvider

**BlocProvider** é um widget Flutter que fornece um Bloc para seus filhos via `BlocProvider.of<T>(context)`. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um Bloc possa ser fornecida a vários widgets em uma subárvore.

Na maioria dos casos, o `BlocProvider` deve ser usado para criar novos `blocs`, que serão disponibilizados para o restante da subárvore. Nesse caso, como o BlocProvider é responsável pela criação do bloc, ele automaticamente tratará do fechamento do bloc.

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

Em alguns casos, o BlocProvider pode ser usado para fornecer um bloc existente para uma nova parte da árvore de widgets. Isso será mais comumente usado quando um bloc existente precisar ser disponibilizado para uma nova rota. Nesse caso, o `BlocProvider` não fechará o bloc automaticamente, pois não o criou.

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

então, a partir de `ChildA` ou` ScreenA`, podemos recuperar o `BlocA` com:

```dart
BlocProvider.of<BlocA>(context)
```

### MultiBlocProvider

**MultiBlocProvider** é um widget Flutter que mescla vários widgets `BlocProvider` em um.
O `MultiBlocProvider` melhora a legibilidade e elimina a necessidade de aninhar vários` BlocProviders`.
Usando o `MultiBlocProvider`, podemos ir de:

```dart
BlocProvider<BlocA>(
  create: (BuildContext context) => BlocA(),
  child: BlocProvider<BlocB>(
    create: (BuildContext context) => BlocB(),
    child: BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
      child: ChildA(),
    )
  )
)
```

para:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

### BlocListener

**BlocListener** é um widget Flutter que pega um `BlocWidgetListener` e um `Bloc` opcional e invoca o `listener` em resposta a alterações de estado no bloc. Deve ser usado para funcionalidades que precisam ocorrer uma vez por alteração de estado, como navegação, mostrar um `SnackBar`, mostrar um` Diálogo`, etc ...

`listener` é chamado apenas uma vez para cada alteração de estado (**NÃO** incluindo` initialState`), diferente do `builder` no` BlocBuilder` e é uma função `void`.

Se o parâmetro bloc for omitido, o `BlocListener` executará automaticamente uma pesquisa usando o` BlocProvider` e o atual `BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

Especifique o bloc apenas se desejar fornecer um bloc que, de outra forma, não poderá ser acessado via `BlocProvider` e pelo atual` BuildContext`.

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

Se você deseja um controle refinado sobre quando a função listener é chamada, você pode fornecer uma condição opcional ao` BlocListener`. A condição pega o estado anterior do bloc e o atual estado do bloc e retorna um valor booleano. Se `condition` retornar true,` listener` será chamado com `state`. Se `condition` retornar falso,`listener` não será chamado com `state`.

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```

### MultiBlocListener

**MultiBlocListener** é um widget Flutter que mescla vários widgets `BlocListener` em um.
O `MultiBlocListener` melhora a legibilidade e elimina a necessidade de aninhar vários` BlocListeners`.
Usando o `MultiBlocListener`, podemos ir de:

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {},
  child: BlocListener<BlocB, BlocBState>(
    listener: (context, state) {},
    child: BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
      child: ChildA(),
    ),
  ),
)
```

para:

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

### BlocConsumer

**BlocConsumer** expõe um `construtor` e um` ouvinte` para reagir a novos estados. `BlocConsumer` é análogo a um` BlocListener` e `BlocBuilder` aninhado, mas reduz a quantidade de clichê necessária. O `BlocConsumer` deve ser usado apenas quando for necessário reconstruir a interface do usuário e executar outras reações às alterações de estado no` bloc`. O `BlocConsumer` pega um` BlocWidgetBuilder` e `BlocWidgetListener` necessário e um `bloc` opcional, `BlocBuilderCondition` e `BlocListenerCondition`.

Se o parâmetro `bloc` for omitido, o `BlocConsumer` executará automaticamente uma pesquisa usando
`BlocProvider` e o atual `BuildContext`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

Um opcional `listenWhen` e` buildWhen` podem ser implementados para um controle mais granular sobre quando `listener` e `builder` são chamados. O `listenWhen` e o `buildWhen` serão invocados em cada alteração de estado do `bloc`. Cada um deles assume o `state` anterior e o atual` state` e deve retornar um `bool` que determina se a função` builder` e / ou `listener` será ou não invocada. O `state` anterior será inicializado com o` state` do `bloc` quando o` BlocConsumer` for inicializado. `listenWhen` e `buildWhen` são opcionais e, se não forem implementados, serão padronizados como `true`.

```dart
BlocConsumer<BlocA, BlocAState>(
  listenWhen: (previous, current) {
    // return true/false to determine whether or not
    // to invoke listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  buildWhen: (previous, current) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

### RepositoryProvider

**RepositoryProvider** é um widget Flutter que fornece um repositório para seus filhos via `RepositoryProvider.of<T>(context)`. Ele é usado como um widget de injeção de dependência (DI) para que uma única instância de um repositório possa ser fornecida a vários widgets em uma subárvore. O `BlocProvider` deve ser usado para fornecer blocs, enquanto o` RepositoryProvider` deve ser usado apenas para repositórios.

```dart
RepositoryProvider(
  builder: (context) => RepositoryA(),
  child: ChildA(),
);
```

então, no `ChildA`, podemos recuperar a instância do` Repository` com:

```dart
RepositoryProvider.of<RepositoryA>(context)
```

### MultiRepositoryProvider

**MultiRepositoryProvider** é um widget Flutter que mescla vários widgets `RepositoryProvider` em um.
O `MultiRepositoryProvider` melhora a legibilidade e elimina a necessidade de aninhar vários `RepositoryProvider`.
Usando o `MultiRepositoryProvider`, podemos ir de:

```dart
RepositoryProvider<RepositoryA>(
  builder: (context) => RepositoryA(),
  child: RepositoryProvider<RepositoryB>(
    builder: (context) => RepositoryB(),
    child: RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
      child: ChildA(),
    )
  )
)
```

para:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider<RepositoryA>(
      builder: (context) => RepositoryA(),
    ),
    RepositoryProvider<RepositoryB>(
      builder: (context) => RepositoryB(),
    ),
    RepositoryProvider<RepositoryC>(
      builder: (context) => RepositoryC(),
    ),
  ],
  child: ChildA(),
)
```

## Uso

Vamos dar uma olhada em como usar o `BlocBuilder` para conectar um widget da `CounterPage` a um `CounterBloc`.

### counter_bloc.dart

```dart
enum CounterEvent { increment, decrement }

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

### counter_page.dart

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

Nesse ponto, separamos com êxito nossa camada de apresentação da nossa camada de lógica de negócios. Observe que o widget `CounterPage` não sabe nada sobre o que acontece quando um usuário toca nos botões. O widget simplesmente diz ao `CounterBloc` que o usuário pressionou o botão de incremento ou decremento.
