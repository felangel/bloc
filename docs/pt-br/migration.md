# Migration Guide

?> **Tip**: Por favor, consulte o [release log](https://github.com/felangel/bloc/releases) para obter mais informações sobre o que mudou em cada versão.

## v7.0.0

### package:bloc

#### ❗ Bloc and Cubit extend BlocBase

##### Rationale

Como desenvolvedor, a relação entre blocs e cubits era um pouco estranha. Quando o cubit foi introduzido pela primeira vez, ele começou como a classe base para blocs, o que fazia sentido porque tinha um subconjunto das funcionalidades e os blocs apenas estenderiam o cubit e definiriam APIs adicionais. Isso veio com algumas desvantagens:

- Todas as APIs teriam que ser renomeadas para aceitar um cubit para acurácia ou deveriam ser mantidas como um bloc para consistência, mesmo que hierarquicamente seja impreciso ([#1708](https://github.com/felangel/bloc/issues/1708), [#1560](https://github.com/felangel/bloc/issues/1560)).

- O Cubit precisaria estender o Stream e implementar EventSink para ter uma base comum em que widgets como BlocBuilder, BlocListener, etc. podem ser implementados ([#1429](https://github.com/felangel/bloc/issues/1429)).

Mais tarde, experimentamos inverter a relação e tornar o bloc a classe base que resolveu parcialmente o primeiro item acima, mas introduziu outros problemas:

- A API cubit está inchada devido às APIs de bloc subjacentes, como mapEventToState, add, etc.([#2228](https://github.com/felangel/bloc/issues/2228))
- Os desenvolvedores podem invocar tecnicamente essas APIs e quebrar coisas
- Ainda temos o mesmo problema de cubit expondo toda a API de fluxo de antes ([#1429](https://github.com/felangel/bloc/issues/1429))

Para resolver esses problemas, introduzimos uma classe base para `Bloc` e` Cubit` chamada `BlocBase` para que os componentes upstream ainda possam interoperar com instâncias de bloc e cubit, mas sem expor toda a API` Stream` e `EventSink` diretamente.

**Resumo**

**BlocObserver**

**v6.1.x**

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(Cubit cubit) {...}

  @override
  void onEvent(Bloc bloc, Object event) {...}

  @override
  void onChange(Cubit cubit, Object event) {...}

  @override
  void onTransition(Bloc bloc, Transition transition) {...}

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {...}

  @override
  void onClose(Cubit cubit) {...}
}
```

**v7.0.0**

```dart
class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {...}

  @override
  void onEvent(Bloc bloc, Object event) {...}

  @override
  void onChange(BlocBase bloc, Object? event) {...}

  @override
  void onTransition(Bloc bloc, Transition transition) {...}

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {...}

  @override
  void onClose(BlocBase bloc) {...}
}
```

**Bloc/Cubit**

**v6.1.x**

```dart
final bloc = MyBloc();
bloc.listen((state) {...});

final cubit = MyCubit();
cubit.listen((state) {...});
```

**v7.0.0**

```dart
final bloc = MyBloc();
bloc.stream.listen((state) {...});

final cubit = MyCubit();
cubit.stream.listen((state) {...});
```

### package:bloc_test

#### ❗seed retorna uma função para suportar valores dinâmicos

##### Justificativa

Para suportar um valor de semente mutável que pode ser atualizado dinamicamente em `setUp`,` seed` retorna uma função.

**Resumo**

**v7.x.x**

```dart
blocTest(
  '...',
  seed: MyState(),
  ...
);
```

**v8.0.0**

```dart
blocTest(
  '...',
  seed: () => MyState(),
  ...
);
```

#### ❗esperar retorna uma função para oferecer suporte a valores dinâmicos e inclui suporte para matchers

##### Justificativa

Para suportar uma expectativa mutável que pode ser atualizada dinamicamente em `setUp`,` expect` retorna uma função. `expect` também suporta` Matchers`.

**Resumo**

**v7.x.x**

```dart
blocTest(
  '...',
  expect: [MyStateA(), MyStateB()],
  ...
);
```

**v8.0.0**

```dart
blocTest(
  '...',
  expect: () => [MyStateA(), MyStateB()],
  ...
);

// It can also be a `Matcher`
blocTest(
  '...',
  expect: () => contains(MyStateA()),
  ...
);
```

#### ❗erros retorna uma função para oferecer suporte a valores dinâmicos e inclui suporte para matchers

##### Justificativa

Para suportar erros mutáveis ​​que podem ser atualizados dinamicamente em `setUp`,` errors` retorna uma função. `errors` também suporta` Matchers`.

**Resumo**

**v7.x.x**

```dart
blocTest(
  '...',
  errors: [MyError()],
  ...
);
```

**v8.0.0**

```dart
blocTest(
  '...',
  errors: () => [MyError()],
  ...
);

// It can also be a `Matcher`
blocTest(
  '...',
  errors: () => contains(MyError()),
  ...
);
```

#### ❗MockBloc and MockCubit

##### Justificativa

Para suportar o stub de várias APIs principais, `MockBloc` e` MockCubit` são exportados como parte do pacote `bloc_test`.
Anteriormente, `MockBloc` tinha que ser usado para instâncias de` Bloc` e `Cubit`, o que não era intuitivo.

**Resumo**

**v7.x.x**

```dart
class MockMyBloc extends MockBloc<MyState> implements MyBloc {}
class MockMyCubit extends MockBloc<MyState> implements MyBloc {}
```

**v8.0.0**

```dart
class MockMyBloc extends MockBloc<MyEvent, MyState> implements MyBloc {}
class MockMyCubit extends MockCubit<MyState> implements MyCubit {}
```

#### ❗Integração com Mocktail

##### Justificativa

 Devido a várias limitações do null-safe [package:mockito](https://pub.dev/packages/mockito) descritas [here](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md#problems-with-typical-mocking-and-stubbing), [package:mocktail](https://pub.dev/packages/mocktail) é usado por `MockBloc` e` MockCubit`. Isso permite que os desenvolvedores continuem usando uma API de mock familiar sem a necessidade de escrever stubs manualmente ou depender da geração de código.

**Resumo**

**v7.x.x**

```dart
import 'package:mockito/mockito.dart';

...

when(bloc.state).thenReturn(MyState());
verify(bloc.add(any)).called(1);
```

**v8.0.0**

```dart
import 'package:mocktail/mocktail.dart';

...

when(() => bloc.state).thenReturn(MyState());
verify(() => bloc.add(any())).called(1);
```

> Por favor, consulte [#347](https://github.com/dart-lang/mockito/issues/347) assim como o [mocktail documentation](https://github.com/felangel/mocktail/tree/main/packages/mocktail) for more information.

### package:flutter_bloc

#### ❗ renomear `cubit` parâmetro para `bloc`

##### Justificativa

Como resultado da refatoração em `package: bloc` para introduzir` BlocBase` que `Bloc` e` Cubit` estendem, os parâmetros de `BlocBuilder`,` BlocConsumer` e `BlocListener` foram renomeados de` cubit` para ` bloc` porque os widgets operam no tipo `BlocBase`. Isso também se alinha ainda mais com o nome da biblioteca e, com sorte, melhora a legibilidade.

**Resumo**

**v6.1.x**

```dart
BlocBuilder(
  cubit: myBloc,
  ...
)

BlocListener(
  cubit: myBloc,
  ...
)

BlocConsumer(
  cubit: myBloc,
  ...
)
```

**v7.0.0**

```dart
BlocBuilder(
  bloc: myBloc,
  ...
)

BlocListener(
  bloc: myBloc,
  ...
)

BlocConsumer(
  bloc: myBloc,
  ...
)
```

### package:hydrated_bloc

#### ❗storageDirectory é necessário ao chamar HydratedStorage.build

##### Justificativa

A fim de tornar `package: hydrated_bloc` um pacote Dart puro, a dependência de [package:path_provider](https://pub.dev/packages/path_provider) foi removido e o parâmetro `storageDirectory` ao chamar` HydratedStorage.build` é necessário e não é mais padronizado como `getTemporaryDirectory`.

**Resumo**

**v6.x.x**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

**v7.0.0**

```dart
import 'package:path_provider/path_provider.dart';

...

HydratedBloc.storage = await HydratedStorage.build(
  storageDirectory: await getTemporaryDirectory(),
);
```

## v6.1.0

### package:flutter_bloc

#### ❗context.bloc e context.repository estão obsoletos em favor de context.read e context.watch

##### Justificativa

`context.read`,` context.watch` e `context.select` foram adicionados para alinhar com o existente [provider](https://pub.dev/packages/provider) 
API com a qual muitos desenvolvedores estão familiarizados e para resolver problemas que foram levantados pela comunidade. Para melhorar a segurança do código e manter a consistência, `context.bloc` foi descontinuado porque pode ser substituído por` context.read` ou `context.watch` dependendo se for usado diretamente no` build`.

**context.watch**

`context.watch` aborda a solicitação para ter um [MultiBlocBuilder](https://github.com/felangel/bloc/issues/538) porque podemos assistir a vários blocos dentro de um único `Builder`, a fim de renderizar a IU com base em vários estados:

```dart
Builder(
  builder: (context) {
    final stateA = context.watch<BlocA>().state;
    final stateB = context.watch<BlocB>().state;
    final stateC = context.watch<BlocC>().state;

    // return a Widget which depends on the state of BlocA, BlocB, and BlocC
  }
);
```

**context.select**

`context.select` permite que os desenvolvedores renderizem / atualizem a IU com base em uma parte de um estado de bloc e endereça a solicitação para ter um [simpler buildWhen](https://github.com/felangel/bloc/issues/1521).

```dart
final name = context.select((UserBloc bloc) => bloc.state.user.name);
```

O trecho acima nos permite acessar e reconstruir o widget apenas quando o nome do usuário atual muda.

**context.read**

Mesmo que pareça que `context.read` seja idêntico a` context.bloc`, existem algumas diferenças sutis, mas significativas. Ambos permitem que você acesse um bloco com um `BuildContext` e não resultam em reconstruções; entretanto, `context.read` não pode ser chamado diretamente dentro de um método` build`. Existem duas razões principais para usar `context.bloc` dentro de` build`:

1. **Para acessar o estado do bloc**

```dart
@override
Widget build(BuildContext context) {
  final state = context.bloc<MyBloc>().state;
  return Text('$state');
}
```

O uso acima está sujeito a erros porque o widget `Text` não será reconstruído se o estado do bloc mudar. Neste cenário, um `BlocBuilder` ou` context.watch` deve ser usado.

```dart
@override
Widget build(BuildContext context) {
  final state = context.watch<MyBloc>().state;
  return Text('$state');
}
```

or

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<MyBloc, MyState>(
    builder: (context, state) => Text('$state'),
  );
}
```

!> Usar `context.watch` na raiz do método` build` resultará na reconstrução de todo o widget quando o estado do bloc mudar. Se o widget inteiro não precisa ser reconstruído, use `BlocBuilder` para embrulhar as partes que devem ser reconstruídas, use um` Builder` com `context.watch` para definir o escopo das reconstruções ou decomponha o widget em widgets menores.

2. **Para acessar o bloco para que um evento possa ser adicionado**

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

O uso acima é ineficiente porque resulta em uma pesquisa de bloco em cada reconstrução, quando o bloco só é necessário quando o usuário toca em `ElevatedButton`. Neste cenário, prefira usar `context.read` para acessar o bloco diretamente onde for necessário (neste caso, no callback` onPressed`).

```dart
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => context.read<MyBloc>().add(MyEvent()),
    ...
  )
}
```

**Resumo**

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

?> Se estiver acessando um bloc para adicionar um evento, execute o acesso do bloc usando `context.read` no callback onde for necessário.

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

?> Use `context.watch` ao acessar o estado do bloc para garantir que o widget seja reconstruído quando o estado mudar.

## v6.0.0

### package:bloc

#### ❗BlocObserver onError recebe Cubit

##### Justificativa

Devido à integração do `Cubit`,` onError` agora é compartilhado entre as instâncias `Bloc` e` Cubit`. Visto que `Cubit` é a base,` BlocObserver` aceitará um tipo `Cubit` em vez de um tipo` Bloc` na substituição `onError`.

**v5.x.x**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}
```

**v6.0.0**

```dart
class MyBlocObserver extends BlocObserver {
  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);
  }
}
```

#### ❗O bloc não emite o último estado na subscription

##### Rationale

Esta mudança foi feita para alinhar `Bloc` e` Cubit` com o comportamento `Stream` embutido no` Dart`. Além disso, conformar este comportamento antigo no contexto de `Cubit` levou a muitos efeitos colaterais não intencionais e complicou as implementações internas de outros pacotes, como` flutter_bloc` e `bloc_test` desnecessariamente (exigindo` skip (1) `, etc ...).

**v5.x.x**

```dart
final bloc = MyBloc();
bloc.listen(print);
```

Anteriormente, o fragmento acima produziria o estado inicial do bloco seguido por mudanças de estado subsequentes.

**v6.x.x**

Na v6.0.0, o fragmento acima não exibe o estado inicial e apenas exibe as alterações de estado subsequentes. O comportamento anterior pode ser alcançado com o seguinte:

```dart
final bloc = MyBloc();
print(bloc.state);
bloc.listen(print);
```

?> **Nota**: Essa mudança afetará apenas o código que depende de assinaturas diretas do bloco. Ao usar `BlocBuilder`,` BlocListener` ou `BlocConsumer`, não haverá nenhuma mudança perceptível no comportamento.

### package:bloc_test

#### ❗MockBloc requer apenas o tipo de estado

##### Justificativa

Não é necessário e elimina código extra ao mesmo tempo que torna o `MockBloc` compatível com o` Cubit`.

**v5.x.x**

```dart
class MockCounterBloc extends MockBloc<CounterEvent, int> implements CounterBloc {}
```

**v6.0.0**

```dart
class MockCounterBloc extends MockBloc<int> implements CounterBloc {}
```

#### ❗whenListen requer apenas o tipo de estado

##### Justificativa

Não é necessário e elimina código extra ao mesmo tempo em que torna `whenListen` compatível com` Cubit`.

**v5.x.x**

```dart
whenListen<CounterEvent,int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

**v6.0.0**

```dart
whenListen<int>(bloc, Stream.fromIterable([0, 1, 2, 3]));
```

#### ❗blocTest não requer tipo de evento

##### Justificativa

Não é necessário e elimina código extra ao mesmo tempo que torna `blocTest` compatível com` Cubit`.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [1] when increment is called',
  build: () async => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [1] when increment is called',
  build: () => CounterBloc(),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[1],
);
```

#### ❗O padrão de skip do blocTest é 0

##### Justificativa

Uma vez que as instâncias `bloc` e` cubit` não emitirão mais o estado mais recente para novas assinaturas, não era mais necessário configurar `skip` para` 1`.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [0] when skip is 0',
  build: () async => CounterBloc(),
  skip: 0,
  expect: const <int>[0],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [] when skip is 0',
  build: () => CounterBloc(),
  skip: 0,
  expect: const <int>[],
);
```

O estado inicial de um bloc ou cubit pode ser testado com o seguinte:

```dart
test('initial state is correct', () {
  expect(MyBloc().state, InitialState());
});
```

#### ❗blocTest torna a compilação síncrona

##### Justificativa

Anteriormente, `build` era feito` async` para que várias preparações pudessem ser feitas para colocar o bloc em teste em um estado específico. Não é mais necessário e também resolve vários problemas devido à latência adicionada entre a compilação e a assinatura internamente. Em vez de fazer uma preparação assíncrona para obter um bloc em um estado desejado, podemos agora definir o estado do bloco encadeando `emit` com o estado desejado.

**v5.x.x**

```dart
blocTest<CounterBloc, CounterEvent, int>(
  'emits [2] when increment is added',
  build: () async {
    final bloc = CounterBloc();
    bloc.add(CounterEvent.increment);
    await bloc.take(2);
    return bloc;
  }
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

**v6.0.0**

```dart
blocTest<CounterBloc, int>(
  'emits [2] when increment is added',
  build: () => CounterBloc()..emit(1),
  act: (bloc) => bloc.add(CounterEvent.increment),
  expect: const <int>[2],
);
```

!> `emit` é visível apenas para teste e nunca deve ser usado fora dos testes.

### package:flutter_bloc

#### ❗Parâmetro de bloco BlocBuilder renomeado para cubit

##### Justificativa

Para fazer o `BlocBuilder` interoperar com as instâncias` bloc` e `cubit`, o parâmetro` bloc` foi renomeado para `cubit` (já que` Cubit` é a classe base).

**v5.x.x**

```dart
BlocBuilder(
  bloc: myBloc,
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocBuilder(
  cubit: myBloc,
  builder: (context, state) {...}
)
```

#### ❗Parâmetro de bloco BlocListener renomeado para cubit

##### Justificativa

Para fazer o `BlocListener` interoperar com as instâncias` bloc` e `cubit`, o parâmetro` bloc` foi renomeado para `cubit` (já que` Cubit` é a classe base).

**v5.x.x**

```dart
BlocListener(
  bloc: myBloc,
  listener: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocListener(
  cubit: myBloc,
  listener: (context, state) {...}
)
```

#### ❗Parâmetro do bloc BlocConsumer renomeado para cubit

##### Justificativa

Para fazer o `BlocConsumer` interoperar com as instâncias` bloc` e `cubit`, o parâmetro` bloc` foi renomeado para `cubit` (já que` Cubit` é a classe base).

**v5.x.x**

```dart
BlocConsumer(
  bloc: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

**v6.0.0**

```dart
BlocConsumer(
  cubit: myBloc,
  listener: (context, state) {...},
  builder: (context, state) {...}
)
```

---

## v5.0.0

### package:bloc

#### ❗initialState foi removido

##### Justificativa

Como desenvolvedor, ter que substituir `initialState` ao criar um bloc apresenta dois problemas principais:

- O `initialState` do bloc pode ser dinâmico e também pode ser referenciado em um momento posterior (mesmo fora do próprio bloc). De certa forma, isso pode ser visto como vazamento de informações do bloc interno para a camada de IU.
- É verboso.

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

?> Para mais informações confira [#1304](https://github.com/felangel/bloc/issues/1304)

#### ❗BlocDelegate renomeado para BlocObserver

##### Justificativa

O nome `BlocDelegate` não era uma descrição precisa do papel que a classe desempenhava. `BlocDelegate` sugere que a classe desempenha um papel ativo, enquanto na realidade o papel pretendido do` BlocDelegate` era ser um componente passivo que simplesmente observa todos os blocos em um aplicativo.

!> Idealmente, não deve haver nenhuma funcionalidade voltada para o usuário ou recursos tratados no `BlocObserver`.

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

#### ❗BlocSupervisor foi removido

##### Justificativa

O `BlocSupervisor` era outro componente que os desenvolvedores precisavam conhecer e interagir com o único propósito de especificar um` BlocDelegate` personalizado. Com a mudança para `BlocObserver`, sentimos que melhorou a experiência do desenvolvedor ao definir o observador diretamente no próprio bloc.

?> 

**v4.x.x**

```dart
BlocSupervisor.delegate = MyBlocDelegate();
```

**v5.0.0**

```dart
Bloc.observer = MyBlocObserver();
```

### package:flutter_bloc

#### ❗Condição BlocBuilder renomeada para buildWhen

##### Justificativa

Ao usar o `BlocBuilder`, anteriormente poderíamos especificar uma` condição` para determinar se o `builder` deve reconstruir.

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o construtor
  },
  builder: (context, state) {...}
)
```

O nome `condição` não é muito autoexplicativo ou óbvio e mais importante, ao interagir com um` BlocConsumer` a API se tornou inconsistente porque os desenvolvedores podem fornecer duas condições (uma para `builder` e outra para` listener`). Como resultado, a API `BlocConsumer` expôs um` buildWhen` e `listenWhen`

```dart
BlocConsumer<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o listener
  },
  listener: (context, state) {...},
  buildWhen: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o builder
  },
  builder: (context, state) {...},
)
```

Para alinhar a API e fornecer uma experiência de desenvolvedor mais consistente, `condition` foi renomeado para` buildWhen`.

**v4.x.x**

```dart
BlocBuilder<MyBloc, MyState>(
  condition: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o builder
  },
  builder: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocBuilder<MyBloc, MyState>(
  buildWhen: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o builder
  },
  builder: (context, state) {...}
)
```

#### ❗Condição BlocListener renomeada para listenWhen

##### Justificativa

Pelas mesmas razões descritas acima, a condição `BlocListener` também foi renomeada.

**v4.x.x**

```dart
BlocListener<MyBloc, MyState>(
  condition: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o listener
  },
  listener: (context, state) {...}
)
```

**v5.0.0**

```dart
BlocListener<MyBloc, MyState>(
  listenWhen: (previous, current) {
    // retorne verdadeiro / falso para determinar se deve chamar o listener
  },
  listener: (context, state) {...}
)
```

### package:hydrated_bloc

#### ❗HydratedStorage e HydratedBlocStorage renomeados

##### Justificativa

 A fim de melhorar a reutilização de código entre [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) e [hydrated_cubit](https://pub.dev/packages/hydrated_cubit), a implementação de armazenamento padrão concreto foi renomeada de `HydratedBlocStorage` para` HydratedStorage`. Além disso, a interface `HydratedStorage` foi renomeada de` HydratedStorage` para `Storage`.

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

#### ❗HydratedStorage desacoplado de BlocDelegate

##### Justificativa

Como mencionado anteriormente, `BlocDelegate` foi renomeado para` BlocObserver` e foi definido diretamente como parte do `bloco` via:

```dart
Bloc.observer = MyBlocObserver();
```

A seguinte alteração foi feita para que:

- Fique consistente com a nova API do observer do bloc
- Mantenha o escopo de armazenamento para apenas `HydratedBloc`
- Desacople o `BlocObserver` do` Storage`

**v4.0.0**

```dart
BlocSupervisor.delegate = await HydratedBlocDelegate.build();
```

**v5.0.0**

```dart
HydratedBloc.storage = await HydratedStorage.build();
```

#### ❗Inicialização simplificada

##### Justificativa

Anteriormente, os desenvolvedores tinham que chamar manualmente `super.initialState ?? DefaultInitialState () `para configurar suas instâncias` HydratedBloc`. Isso é ruim e verboso e também incompatível com as alterações de quebra de `initialState` em` bloc`. Como resultado, na v5.0.0 a inicialização `HydratedBloc` é idêntica à inicialização normal do` Bloc`.

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
