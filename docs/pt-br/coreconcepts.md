# Principais Conceitos

?> Por favor leia e compreenda cuidadosamente as seções a seguir antes de trabalhar com [bloc](https://pub.dev/packages/bloc).

Existem vários conceitos essenciais que são críticos para entender como usar o Bloc.

Nas próximas seções, discutiremos cada uma delas em detalhes, bem como trabalharemos como elas se aplicariam a um aplicativo do mundo real: um aplicativo de contador.

## Eventos

> Eventos são a entrada para um bloc. Eles são geralmente adicionados em resposta a interações do usuário, como pressionar botões ou eventos do ciclo de vida, como carregamentos de páginas.

Ao projetar um aplicativo, precisamos dar um passo atrás e definir como os usuários irão interagir com ele. No contexto do nosso aplicativo de contador, teremos dois botões para aumentar e diminuir nosso contador.

Quando um usuário toca em um desses botões, algo precisa acontecer para notificar os "cérebros" do nosso aplicativo, para que ele possa responder à entrada do usuário; é aqui que os eventos entram em cena.

Precisamos ser capazes de notificar os "cérebros" de nossos aplicativos sobre um incremento e um decremento, portanto, precisamos definir esses eventos.

```dart
enum CounterEvent { increment, decrement }
```

Nesse caso, podemos representar os eventos usando um `enum`, mas para casos mais complexos, pode ser necessário usar uma` classe`, especialmente se for necessário passar informações ao bloc.

Neste ponto, definimos o nosso primeiro evento! Observe que não usamos o Bloc de nenhuma maneira até agora e não há mágica acontecendo; é apenas código Dart simples.

## States

> Os estados são a saída de um bloc e representam uma parte do estado do seu aplicativo. Os componentes da interface do usuário podem ser notificados sobre os estados e redesenhar partes deles com base no estado atual.

Até agora, definimos os dois eventos aos quais nosso aplicativo responderá: `CounterEvent.increment` e `CounterEvent.decrement`.

Agora precisamos definir como representar o estado do nosso aplicativo.

Como estamos construindo um contador, nosso estado é muito simples: é apenas um número inteiro que representa o valor atual do contador.

Veremos exemplos mais complexos de estado posteriormente, mas, neste caso, um tipo primitivo é perfeitamente adequado como representação de estado.

## Transições

> A mudança de um estado para outro é chamada de transição. Uma transição consiste no estado atual, no evento e no próximo estado.

À medida que o usuário interage com o nosso aplicativo de contador, eles acionam os eventos `Increment` e `Decrement` que atualizarão o estado do contador. Todas essas mudanças de estado podem ser descritas como uma série de `Transições`.

Por exemplo, se um usuário abrisse nosso aplicativo e tocasse no botão de incremento, veríamos a seguinte `Transição`.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Como todas as alterações de estado são registradas, somos capazes de instrumentar com facilidade nossos aplicativos e rastrear todas as interações do usuário e alterações de estado em um único local. Além disso, isso possibilita coisas como depuração de viagens no tempo.

## Streams

Confira a documentação oficial [Documentação Dart](https://dart.dev/tutorials/language/streams) para mais informações sobre `Streams`.

> Um fluxo é uma sequência de dados assíncronos.

Bloc é construído em cima do [RxDart](https://pub.dev/packages/rxdart); no entanto, ele abstrai todos os detalhes de implementação específicos do `RxDart`.

Para usar o Bloc, é essencial ter uma sólida compreensão de `Streams` e como elas funcionam.

> Se você não estiver familiarizado com o `Streams`, pense em um cano com água fluindo através dele. O tubo é a `Stream` e a água são os dados assíncronos.

Podemos criar uma `Stream` no Dart escrevendo uma função `async*`.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

Marcando uma função como `async*`, podemos usar a palavra-chave `yield` e retornar um `fluxo` de dados. No exemplo acima, estamos retornando uma `Stream` de números inteiros até o parâmetro inteiro `max`.

Toda vez que "produzimos" em uma função `async*`, estamos enviando esse dado através da `Stream`.

Podemos consumir a `Stream` acima de várias maneiras. Se quiséssemos escrever uma função para retornar a soma de uma `Stream` de números inteiros, poderia ser algo como:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

Ao marcar a função acima como `async`, podemos usar a palavra-chave `await` e retornar um `Future` de números inteiros. Neste exemplo, estamos aguardando cada valor da Stream e retornando a soma de todos os números inteiros.

Podemos juntar tudo assim:

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

> Um Bloc (Business Logic Component - componente da lógica de negócios) é um componente que converte uma `Stream` de `eventos` recebidos em uma `Stream` de `estados` de saída. Pense em um bloc como sendo os "cérebros" descritos acima.

> Todo bloc deve estender a classe base do bloc, que faz parte do pacote principal do bloc.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

No trecho de código acima, estamos declarando nosso `CounterBloc` como um Bloc que converte` CounterEvents` em `ints`.

> Todo Bloc deve definir um estado inicial que é o estado antes que qualquer evento seja recebido.

Nesse caso, queremos que nosso contador comece com `0`.

```dart
@override
int get initialState => 0;
```

> Todo Bloc deve implementar uma função chamada `mapEventToState`. A função aceita o `evento` recebido como argumento e deve retornar uma `Stream` de novos `estados` que são consumidos pela camada de apresentação. Podemos acessar o estado atual do Bloc a qualquer momento usando a propriedade `state`.

```dart
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
```

Neste ponto, temos um `CounterBloc` em pleno funcionamento.

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
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

Blocs ignoram estados duplicados. Se um bloc produzir `State nextState` onde` state == nextState`, nenhuma transição ocorrerá e nenhuma alteração será feita no `Stream <State>`.

Neste ponto, você provavelmente está se perguntando _"Como notifico um Bloc de um evento?"_.

Todo Bloc tem um método `add`. O `Add` pega um `event` e dispara o `mapEventToState`. O `Add` pode ser chamado a partir da camada de apresentação ou de dentro do Bloc e notifica o bloc de um novo `evento`.

Podemos criar uma aplicação simples que conta de 0 a 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

!> Por padrão, os eventos sempre serão processados ​​na ordem em que foram adicionados e quaisquer eventos adicionados recentemente são enfileirados. Um evento é considerado totalmente processado após a conclusão da execução do `mapEventToState`.

As `Transições` no trecho de código acima seriam

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

Infelizmente, no estado atual, não poderemos ver nenhuma dessas transições a menos que substituamos `onTransition`.

> `onTransition` é um método que pode ser substituído para lidar com todas as `Transition` do Bloc locais. O `onTransition` é chamado logo antes do `State` de um bloc ser atualizado.

?> **Dica**: `onTransition` é um ótimo local para adicionar log de informações do Bloc / informações analíticas

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Agora que substituímos o `onTransition`, podemos fazer o que quisermos sempre que ocorrer uma `Transition`.

Assim como podemos lidar com `Transitions` no nível do Bloc, também podemos lidar com `Exceptions`.

> `onError` é um método que pode ser substituído para lidar com todas as `Exceptions` do Bloc local. Por padrão, todas as exceções serão ignoradas e a funcionalidade do `Bloc` não será afetada.

?> **Nota**: O argumento stacktrace pode ser `null` se o fluxo de estados recebeu um erro sem um `StackTrace`.

?> **Dica**: `onError` é um ótimo local para adicionar manipulação de erro específica de bloc.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Agora que substituímos o `onError`, podemos fazer o que quisermos sempre que uma `Exception` for lançada.

## BlocDelegate

Um bônus adicional ao usar o Bloc é que podemos ter acesso a todas as `Transitions` em um só lugar. Embora neste aplicativo tenha apenas um Bloc, é bastante comum em aplicativos maiores ter muitos Blocs gerenciando diferentes partes do estado do aplicativo.

Se quisermos fazer algo em resposta a todas as `Transitions`, podemos simplesmente criar nosso próprio` BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Nota**: Tudo o que precisamos fazer é estender o `BlocDelegate` e substituir o método` onTransition`.

Para dizer ao Bloc para usar nosso `SimpleBlocDelegate`, precisamos apenas ajustar nossa função `main`.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

Se quisermos fazer algo em resposta a todos os `Events` adicionados, também podemos substituir o método `onEvent` no nosso `SimpleBlocDelegate`.

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

Se quisermos fazer algo em resposta a todas as `Exceptions` lançadas em um Bloc, também podemos substituir o método `onError` em nosso `SimpleBlocDelegate`.

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

?> **Nota**: `BlocSupervisor` é um singleton que supervisiona todos os Blocs e delega responsabilidades ao` BlocDelegate`.
