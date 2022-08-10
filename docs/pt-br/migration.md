# Guia de Migração

?> 💡 **Dica**: Por favor, consulte o [release log](https://github.com/felangel/bloc/releases) para obter mais informações sobre o que mudou em cada versão.


## v8.1.0

### package:bloc


#### ✨ Reintroduz as APIs `Bloc.observer` e `Bloc.transformer`

!> No bloc v8.1.0, `BlocOverrides` foi descontinuado em favor das APIs `Bloc.observer` e `Bloc.transformer`.

##### Justificativa

A API `BlocOverrides` foi introduzida na v8.0.0 em uma tentativa de oferecer suporte a configurações específicas do escopo do bloc, como `BlocObserver`, `EventTransformer` e `HydratedStorage`. Em aplicativos Dart puros, as mudanças funcionaram bem; no entanto, em aplicativos Flutter a nova API causou mais problemas do que resolveu.

A API `BlocOverrides` foi inspirada em APIs semelhantes em Flutter/Dart:

- [HttpOverrides](https://api.flutter.dev/flutter/dart-io/HttpOverrides-class.html)
- [IOOverrides](https://api.flutter.dev/flutter/dart-io/IOOverrides-class.html)

**Problemas**

Embora não tenha sido a principal razão para essas mudanças, a API `BlocOverrides` introduziu complexidade adicional para os desenvolvedores. Além de aumentar a quantidade de aninhamento e linhas de código necessárias para obter o mesmo efeito, a API `BlocOverrides` exigia que os desenvolvedores tivessem um conhecimento sólido de [Zones](https://api.dart.dev/stable/2.17.6/dart-async/Zone-class.html) no Dart. `Zones` não é um conceito amigável para iniciantes e a falha em entender como as Zones funcionam pode levar à introdução de bugs (como observadores não inicializados, transformadores, instâncias de armazenamento).

Por exemplo, muitos desenvolvedores teriam algo como:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BlocOverrides.runZoned(...);
}
```

O código acima, embora pareça inofensivo, pode realmente levar a muitos bugs difíceis de rastrear. Qualquer que seja a zona `WidgetsFlutterBinding.ensureInitialized` inicialmente chamada, será a zona na qual os eventos de gesto são tratados (por exemplo, os callbacks `onTap`, `onPressed`) devido a `GestureBinding.initInstances`. Este é apenas um dos muitos problemas causados pelo uso de `zoneValues`.

Além disso, o Flutter faz muitas coisas nos bastidores que envolvem bifurcação/manipulação de Zones (especialmente ao executar testes) que podem levar a comportamentos inesperados (e em muitos casos, comportamentos que estão fora do controle do desenvolvedor -- veja os problemas abaixo).

Devido ao uso do [runZoned](https://api.flutter.dev/flutter/dart-async/runZoned.html), a transição para a API `BlocOverrides` levou à descoberta de vários bugs/limitações no Flutter (especificamente em torno de Testes de Widget e Integração):

- https://github.com/flutter/flutter/issues/96939
- https://github.com/flutter/flutter/issues/94123
- https://github.com/flutter/flutter/issues/93676

que afetou muitos desenvolvedores usando a biblioteca bloc:

- https://github.com/felangel/bloc/issues/3394
- https://github.com/felangel/bloc/issues/3350
- https://github.com/felangel/bloc/issues/3319

**v8.0.x**

```dart
void main() {
  BlocOverrides.runZoned(
    () {
      // ...
    },
    blocObserver: CustomBlocObserver(),
    eventTransformer: customEventTransformer(),
  );
}
```

**v8.1.0**

```dart
void main() {
  Bloc.observer = CustomBlocObserver();
  Bloc.transformer = customEventTransformer();

  // ...
}
```

## v8.0.0

### package:bloc

#### ❗✨ Introduz nova API de `BlocOverrides`

!> Com a versão v8.0.0 do Bloc, `Bloc.observer` e `Bloc.transformer` foram substituídos pela API de `BlocOverrides`.

##### Justificativa

Na API antiga comumente se sobrescrevia `BlocObserver` e `EventTransformer` dependia de um singleton global tanto para`BlocObserver` quanto para `EventTransformer`.

Como resultado disso, não era possível:

- Ter várias implementações de `BlocObserver` ou `EventTransformer` com escopos diferentes para partes distintas da aplicação
- Ter `BlocObserver` ou `EventTransformer` sobrescritos com o escopo de um pacote
  - Se um pacote dependesse de `package:bloc` e registrasse seu próprio `BlocObserver`, qualquer consumidor do pacote teria que sobrescrever o `BlocObserver` do pacote ou se reportar ao `BlocObserver` do pacote.

Também era mais difícil testar por causa do estado global compartilhado entre os testes.

Bloc v8.0.0 introduz uma classe `BlocOverrides` que permite aos desenvolvedores sobrescreverem `BlocObserver` e/ou `EventTransformer` para uma `Zone` específica ao invés de depender de um singleton mutável global.

**v7.x.x**

```dart
void main() {
  Bloc.observer = CustomBlocObserver();
  Bloc.transformer = customEventTransformer();

  // ...
}
```

**v8.0.0**

```dart
void main() {
  BlocOverrides.runZoned(
    () {
      // ...
    },
    blocObserver: CustomBlocObserver(),
    eventTransformer: customEventTransformer(),
  );
}
```

Instâncias de `Bloc` usarão `BlocObserver` e/ou `EventTransformer` para a `Zone` atual via `BlocOverrides.current`. Se não houver `BlocOverrides` para a zona, eles usarão os padrões internos existentes (sem mudança no comportamento/funcionalidade).

Isso permite que cada `Zone` funcione independente com seu próprio `BlocOverrides`.

```dart
BlocOverrides.runZoned(
  () {
    // BlocObserverA e eventTransformerA
    final overrides = BlocOverrides.current;

    // Blocs nesta zone se reportam ao BlocObserverA
    // e utilizam eventTransformerA como transformer padrão.
    // ...

    // Posteriormente...
    BlocOverrides.runZoned(
      () {
        // BlocObserverB e eventTransformerB
        final overrides = BlocOverrides.current;

        // Blocs nesta zone se reportam ao BlocObserverB
        // e utilizam eventTransformerB como transformer padrão.
        // ...
      },
      blocObserver: BlocObserverB(),
      eventTransformer: eventTransformerB(),
    );
  },
  blocObserver: BlocObserverA(),
  eventTransformer: eventTransformerA(),
);
```

#### ❗✨ Melhoria no tratamento de erros e relatórios

!> Com a versão v8.0.0 do Bloc, `BlocUnhandledErrorException` foi removido. Além disso, quaisquer exceções não detectadas são sempre relatadas para `onError` e relançadas (independentemente do modo de debug ou release). A API `addError` relata erros para `onError`, mas não trata os erros relatados como exceções não detectadas.

##### Justificativa

Os objetivos desta mudança são:

- tornar as exceções internas não tratadas extremamente óbvias, ao mesmo tempo que preserva a funcionalidade do bloc
- suportar `addError` sem interromper o fluxo de controle

Anteriormente, o tratamento de erros e os reports variavam dependendo se o aplicativo estava sendo executado no modo de debug ou de release. Além disso, os erros relatados por meio de `addError` eram tratados como exceções não detectadas no modo de debug, o que levou a uma experiência ruim do desenvolvedor ao usar a API `addError` (especificamente ao escrever testes de unidade).

Na versão v8.0.0, `addError` pode ser usado com segurança para relatar erros e `blocTest` pode ser usado para verificar se os erros são relatados. Todos os erros ainda são relatados para `onError`, no entanto, apenas exceções não detectadas são relançadas (independentemente do modo de debug ou de release).

#### ❗🧹 Tornar `BlocObserver` abstrata

!> Na versão v8.0.0 do Bloc, `BlocObserver` foi convertido em uma classe `abstract`, o que significa que uma instância de `BlocObserver` não pode ser instanciada.

##### Justificativa

`BlocObserver` pretendia ser uma interface. Visto que a implementação padrão da API é autônoma, `BlocObserver` agora é uma classe `abstrata` para comunicar claramente que a classe deve ser estendida e não instanciada diretamente.

**v7.x.x**

```dart
void main() {
  // Era possível criar uma instância da classe base.
  final observer = BlocObserver();
}
```

**v8.0.0**

```dart
class MyBlocObserver extends BlocObserver {...}

void main() {
  // Não é possível instanciar a classe base.
  final observer = BlocObserver(); // ERROR

  // Herde `BlocObserver` então.
  final observer = MyBlocObserver(); // OK
}
```

#### ❗✨ `add` lança `StateError` se o bloc estiver fechado

!> Na versão v8.0.0 do bloc, chamar `add` em um bloc fechado resultará em um `StateError`.

##### Justificativa

Anteriormente, era possível chamar `add` em um bloc fechado e o erro interno seria engolido, tornando difícil depurar porque o evento adicionado não estava sendo processado. Para tornar este cenário mais visível, na versão v8.0.0, chamar `add` em um bloc fechado lançará um `StateError` que será relatado como uma exceção não capturada e propagado para `onError`.

#### ❗✨ `emit` lança `StateError` se o bloc estiver fechado

!> Na versão v8.0.0 do bloc, chamar `emit` em um bloc fechado resultará em um `StateError`.

##### Justificativa

Anteriormente, era possível chamar `emit` dentro de um bloc fechado e nenhuma mudança de estado ocorreria, mas também não haveria indicação do que deu errado, dificultando a depuração. Para tornar este cenário mais visível, na v8.0.0, chamar `emit` dentro de um bloc fechado lançará um `StateError` que será relatado como uma exceção não capturada e propagado para `onError`.

#### ❗🧹 Removidas APIs Deprecated

!> Na versão v8.0.0 do bloc, todas as APIs deprecated foram removidas.

##### Resumo

- `mapEventToState` removido em favor de `on<Event>`
- `transformEvents` removido em favor da API `EventTransformer`
- typedef `TransitionFunction` removido em favor da API `EventTransformer`
- `listen` removido em favor de `stream.listen`

### package:bloc_test

#### ✨ `MockBloc` e `MockCubit` não precisam mais utilizar `registerFallbackValue`

!> Na versão v9.0.0 do bloc_test, os desenvolvedores não precisam mais chamar explicitamente `registerFallbackValue` ao usar `MockBloc` ou `MockCubit`.

##### Resumo

`registerFallbackValue` só é necessário ao usar o matcher `any()` do `package: mocktail` para um tipo personalizado. Anteriormente, `registerFallbackValue` era necessário para cada `Event` e `State` ao usar `MockBloc` ou `MockCubit`.

**v8.x.x**

```dart
class FakeMyEvent extends Fake implements MyEvent {}
class FakeMyState extends Fake implements MyState {}
class MyMockBloc extends MockBloc<MyEvent, MyState> implements MyBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeMyEvent());
    registerFallbackValue(FakeMyState());
  });

  // Tests...
}
```

**v9.0.0**

```dart
class MyMockBloc extends MockBloc<MyEvent, MyState> implements MyBloc {}

void main() {
  // Tests...
}
```

### package:hydrated_bloc

#### ❗✨ Introduz a nova API `HydratedBlocOverrides`

!> Na versão v8.0.0 do hydrated_bloc, `HydratedBloc.storage` foi removido em favor da API `HydratedBlocOverrides`.

##### Justificativa

Anteriormente, um singleton global era usado para substituir a implementação de `Storage`.

Como resultado, não era possível ter várias implementações `Storage` com escopos diferentes para partes distintas do aplicativo. Também era mais difícil testar por causa do estado global compartilhado entre os testes.

`HydratedBloc` v8.0.0 introduz uma classe `HydratedBlocOverrides` que permite aos desenvolvedores sobrescrever `Storage` para uma `Zone` específica ao invés de confiar em um singleton mutável global.

**v7.x.x**

```dart
void main() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );

  // ...
}
```

**v8.0.0**

```dart
void main() {
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );

  HydratedBlocOverrides.runZoned(
    () {
      // ...
    },
    storage: storage,
  );
}
```

Instâncias de `HydratedBloc` usarão o `Storage` para a `Zone` atual via `HydratedBlocOverrides.current`.

Isso permite que cada `Zone` funcione independentemente com seus próprios `BlocOverrides`.

## v7.2.0

### package:bloc

#### ✨ Introduz nova API `on<Event>`

!> No bloc v7.2.0, `mapEventToState` foi descontinuado em favor do `on<Event>`. `mapEventToState` será removido no bloc v8.0.0.

##### Justificativa

A API `on<Event>` foi introduzida como parte da [[Proposta] Substituir mapEventToState por on<Event> no Bloc](https://github.com/felangel/bloc/issues/2526). Devido a [um problema no Dart](https://github.com/dart-lang/sdk/issues/44616) nem sempre é óbvio qual será o valor do `state` ao lidar com geradores assíncronos aninhados (`async*`). Embora existam maneiras de contornar o problema, um dos princípios básicos da biblioteca bloc é ser previsível. A API `on<Event>` foi criada para tornar a biblioteca a mais segura possível para uso e para eliminar qualquer incerteza quando se trata de mudanças de estado.

?> 💡 **Dica**: Para maiores informações, [leia a proposta completa](https://github.com/felangel/bloc/issues/2526).

**Resumo**

`on<E>` permite você registrar um manipulador de eventos para todos os eventos do tipo `E`. Por padrão, os eventos serão processados simultaneamente quando usar `on<E>` ao contrário de `mapEventToState` que processa eventos `sequencialmente`.

**v7.1.0**

```dart
abstract class CounterEvent {}
class Increment extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    if (event is Increment) {
      yield state + 1;
    }
  }
}
```

**v7.2.0**

```dart
abstract class CounterEvent {}
class Increment extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
  }
}
```

#### ✨ Introduz nova API `EventTransformer`

!> No bloc v7.2.0, `transformEvents` foi descontinuado em favor da API `EventTransformer`. `transformEvents` será removido no bloc v8.0.0.

##### Justificativa

A API `on<Event>` abriu a porta para ser capaz de fornecer um transformador de evento personalizado por manipulador de evento. Um novo typedef `EventTransformer` foi introduzido, o que permite aos desenvolvedores transformar o fluxo de eventos de entrada para cada manipulador de eventos em vez de especificar um único transformador de eventos para todos os eventos.

**Resumo**

Um `EventTransformer` é responsável por pegar o fluxo de entrada de eventos junto com um` EventMapper` (seu manipulador de eventos) e retornar um novo fluxo de eventos.

```dart
typedef EventTransformer<Event> = Stream<Event> Function(Stream<Event> events, EventMapper<Event> mapper)
```

O `EventTransformer` padrão processa todos os eventos simultaneamente e se parece com:

```dart
EventTransformer<E> concurrent<E>() {
  return (events, mapper) => events.flatMap(mapper);
}
```

?> 💡 **Dica**: Confira [package: bloc_concurrency] (https://pub.dev/packages/bloc_concurrency) para um conjunto opinativo de transformadores de eventos personalizados

**v7.1.0**

```dart
@override
Stream<Transition<MyEvent, MyState>> transformEvents(events, transitionFn) {
  return events
    .debounceTime(const Duration(milliseconds: 300))
    .flatMap(transitionFn);
}
```

**v7.2.0**

```dart
/// Define a custom `EventTransformer`
EventTransformer<MyEvent> debounce<MyEvent>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

MyBloc() : super(MyState()) {
  /// Apply the custom `EventTransformer` to the `EventHandler`
  on<MyEvent>(_onEvent, transformer: debounce(const Duration(milliseconds: 300)))
}
```

#### ⚠️ API `transformTransitions` descontinuada

!> No bloc v7.2.0, `transformTransitions` foi descontinuada em favor de sobrescrever a API` stream`. `transformTransitions` será removida no bloc v8.0.0.

##### Justificativa

O getter de `stream` no `Bloc` torna mais fácil sobrepor o fluxo de saída de estados, portanto, não vale a pena manter uma API `transformTransitions` separada.

**Resumo**

**v7.1.0**

```dart
@override
Stream<Transition<Event, State>> transformTransitions(
  Stream<Transition<Event, State>> transitions,
) {
  return transitions.debounceTime(const Duration(milliseconds: 42));
}
```

**v7.2.0**

```dart
@override
Stream<State> get stream => super.stream.debounceTime(const Duration(milliseconds: 42));
```

## v7.0.0

### package:bloc

#### ❗ Bloc e Cubit estendem BlocBase

##### Justificativa

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
