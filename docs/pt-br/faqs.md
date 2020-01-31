# Dúvidas Frequentes

## Estado não está atualizando

❔ **Dúvida**: Estou dando yield num estado no meu bloco, mas a interface do usuário não está atualizando. O que estou fazendo de errado?

💡 **Resposta**: Se você estiver usando o Equatable, certifique-se de passar todas as propriedades para o props getter.

✅ **BOM**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // pass all properties to props
}
```

❌ **RUIM**

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [];
}
```

```dart
abstract class MyState extends Equatable {
    const MyState();
}

class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => null;
}
```

Além disso, verifique se você está dando yield numa nova instância do estado em seu bloco.

✅ **BOM**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // always create a new instance of the state you are going to yield
    yield state.copyWith(property: event.property);
}
```

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    final data = _getData(event.info);
    // always create a new instance of the state you are going to yield
    yield MyState(data: data);
}
```

❌ **RUIM**

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    // never modify/mutate state
    state.property = event.property;
    // never yield the same instance of state
    yield state;
}
```

## Quando usar Equatable

❔ **Pergunta**: Quando devo usar o Equatable?

💡 **Resposta**:

```dart
@override
Stream<MyState> mapEventToState(MyEvent event) async* {
    yield StateA('hi');
    yield StateA('hi');
}
```

No cenário acima, se `StateA` estender `Equatable`, apenas uma alteração de estado ocorrerá (o segundo rebuild será ignorado).
Em geral, você deve usar o `Equatable` se quiser otimizar seu código para reduzir o número de reconstruções.
Você não deve usar o `Equatable` se desejar que o mesmo estado seja consecutivo para disparar várias transições.

Além disso, o uso de `Equatable` facilita muito o teste de blocos, já que podemos esperar instâncias específicas de estados de bloco em vez de usar `Matchers` ou `Predicates`.

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        MyStateA(),
        MyStateB(),
    ],
)
```

Sem o `Equatable`, o teste acima falharia e precisaria ser reescrito como:

```dart
blocTest(
    '...',
    build: () => MyBloc(),
    act: (bloc) => bloc.add(MyEvent()),
    expect: [
        isA<MyStateA>(),
        isA<MyStateB>(),
    ],
)
```

## Bloc vs Redux

❔ **Pergunta**: Qual é a diferença entre Bloc e Redux?

💡 **Resposta**:

BLoC é um padrão de design definido pelas seguintes regras:

1. A entrada e saída do BLoC são fluxos e sumidouros simples.
2. As dependências devem ser injetáveis ​​e a Plataforma agnóstica.
3. Nenhuma ramificação de plataforma é permitida.
4. A implementação pode ser o que você quiser, desde que siga as regras acima.

As diretrizes da interface do usuário são:

1. Cada componente "suficientemente complexo" possui um BLoC correspondente.
2. Os componentes devem enviar entradas "como estão".
3. Os componentes devem mostrar as saídas o mais próximo possível de "como estão".
4. Todas as ramificações devem ser baseadas em saídas booleanas simples de BLoC.

A Biblioteca Bloc implementa o BLoC Design Pattern e visa abstrair o RxDart para simplificar a experiência do desenvolvedor.

Os três princípios do Redux são:

1. Fonte única da verdade
2. Estado é somente leitura
3. Alterações são feitas com funções puras

A biblioteca bloc viola o primeiro princípio; com o estado do bloco é distribuído por vários blocos.
Além disso, não há conceito de middleware no bloc e o bloc é projetado para facilitar muito as alterações de estado assíncronas, permitindo emitir vários estados para um único evento.

## Bloc vs Provider

❔ **Pergunta**: Qual é a diferença entre Bloc e Provider?

💡 **Resposta**: O `provider` é projetado para injeção de dependência (envolve o` InheritedWidget`).
Você ainda precisa descobrir como gerenciar seu estado (via `ChangeNotifier`,`Bloc`, `Mobx`, etc ...).
A Biblioteca de Blocs usa o `provedor` internamente para facilitar o fornecimento e o acesso aos blocos em toda a árvore de widgets.

## Navegação com Bloc

❔ **Pergunta**: Como faço para navegar com o Bloc?

💡 **Resposta**: Confira https://bloclibrary.dev/#/recipesflutternavigation

## BlocProvider.of() não encontra o bloco

❔ **Pergunta**: Ao usar o `BlocProvider.of(context)`, ele não pode encontrar o bloco. Como posso consertar isso?

💡 **Resposta**: Você não pode acessar um bloc no mesmo contexto em que ele foi fornecido, portanto, você deve garantir que `BlocProvider.of()` seja chamado dentro de um filho `BuildContext`.

✅ **BOM**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: MyChild();
  );
}

class MyChild extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      },
    )
    ...
  }
}
```

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: Builder(
      builder: (context) => RaisedButton(
        onPressed: () {
          final blocA = BlocProvider.of<BlocA>(context);
          ...
        },
      ),
    ),
  );
}
```

❌ **RUIM**

```dart
@override
Widget build(BuildContext context) {
  BlocProvider(
    create: (_) => BlocA(),
    child: RaisedButton(
      onPressed: () {
        final blocA = BlocProvider.of<BlocA>(context);
        ...
      }
    )
  );
}
```

## Estrutura de projeto

❔ **Pergunta**: Como devo estruturar meu projeto?

💡 **Resposta**: Embora não haja realmente uma resposta certa/errada para esta pergunta, algumas referências recomendadas são:

- [Flutter Architecture Samples - Brian Egan](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library)
- [Flutter Shopping Card Example](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart)
- [Flutter TDD Course - ResoCoder](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)

O mais importante é ter uma estrutura de projeto **consistente** e **intencional**.
