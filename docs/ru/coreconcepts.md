# Основные понятия

?> Пожалуйста, внимательно прочитайте и поймите следующие разделы прежде чем работать с [bloc](https://pub.dev/packages/bloc).

Есть несколько основных понятий, которые имеют решающее значение для понимания того, как использовать `Bloc`.

В следующих разделах мы подробно обсудим каждый из них, а также обсудим как они будут применяться к реальному приложению: счетчику.

## Events (События)

> События являются входом в `bloc`. Они обычно добавляются в ответ на действия пользователя, такие как нажатия кнопок или события жизненного цикла по загрузке страниц.

При разработке приложения нам нужно сделать шаг назад и определить, как пользователи будут взаимодействовать с ним. В контексте нашего приложения у нас будет две кнопки для увеличения и уменьшения счетчика.

Когда пользователь нажимает на одну из кнопок, что-то должно произойти, чтобы уведомить «мозги» нашего приложения и оно могло реагировать на ввод пользователя; это то место где события вступают в игру.

Нам нужно иметь возможность по уведомлению «мозгов» нашего приложения об увеличении и уменьшении, поэтому нам нужно определить эти события.

```dart
enum CounterEvent { increment, decrement }
```

В этом случае мы можем представлять события с помощью `enum`, но для более сложных случаев может потребоваться использование `class`, особенно если это необходимо для передачи информации в блок.

На данный момент мы определили наше первое событие! Обратите внимание, что мы до сих пор не использовали `bloc` и никакой магии не происходит; это простой код Dart.

## States (Состояния)

> Состояния являются выходом блока и представляют часть состояния вашего приложения. Компоненты пользовательского интерфейса могут получать уведомления о состояниях и перерисовывать свои части в зависимости от текущего состояния.

Пока мы определили два события, на которые наше приложение будет реагировать: `CounterEvent.increment` и `CounterEvent.decrement`.

Теперь нам нужно определить, как представлять состояние нашего приложения.

Поскольку мы создаем счетчик, наше состояние очень простое: это просто целое число, которое представляет текущее значение счетчика.

Позже мы увидим более сложные примеры состояния, но в этом случае примитивный тип идеально подходит в качестве представления состояния.

## Transitions (Переходы)

> Переход из одного состояния в другое называется переходом. Переход состоит из текущего состояния, события и следующего состояния.

Когда пользователь взаимодействует с нашим приложением счетчика, он запускает события `Increment` и `Decrement`, которые обновляют состояние счетчика. Все эти изменения состояния можно описать как серию `Transitions`.

Например, если пользователь открыл наше приложение и нажал кнопку увеличения, мы увидим следующий `Transition`.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Поскольку каждое изменение состояния сохраняется, мы можем очень легко контролировать наши приложения и отслеживать все взаимодействия с пользователем & изменения состояния в одном месте. Кроме того, это позволяет производить `time-travel` отладку.

## Streams (Потоки)

?> Обратитесь к официальной [Dart Documentation](https://dart.dev/tutorials/language/streams) для получения дополнительной информации о `Streams`.

> Поток - это последовательность асинхронных данных.

Блок построен поверх [RxDart](https://pub.dev/packages/rxdart), однако он абстрагирует все подробности реализации `RxDart`.

Чтобы использовать `Bloc`, важно иметь четкое понимание `Streams` и того, как они работают.

> Если вы не знакомы со «Streams», просто подумайте о трубе, по которой течет вода. Труба - это «Stream», а вода - это асинхронные данные.

Мы можем создать `Stream` в Dart, написав `async*` функцию.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

Помечая функцию как `async*`, мы можем использовать ключевое слово `yield` и возвращать поток данных. В приведенном выше примере мы возвращаем `Stream` целых чисел вплоть до целочисленного параметра `max`.

Каждый раз, когда мы производим `yield` в функции `async*`, мы проталкиваем этот фрагмент данных через `Stream`.

Мы можем использовать вышеприведенный `Stream` несколькими способами. Если бы мы хотели написать функцию, возвращающую сумму целых чисел из `Stream`, это могло бы выглядеть примерно так:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

Помечая вышеуказанную функцию как `async`, мы можем использовать ключевое слово `await` и возвращать `Future` целых чисел. В этом примере мы ожидаем каждое значение в потоке и возвращаем из него сумму всех целых чисел.

Мы можем собрать все это вместе вот так:

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

## Blocs (Блоки)

> Блок (Business Logic Component) - это компонент, который преобразует `Stream` входящих `Events` в `Stream` исходящих `States`. Думайте о Блоке как о `мозгах`, описанных выше.
> Каждый блок должен расширять базовый класс `Bloc`, который является частью пакета основного блока.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

В приведенном выше фрагменте кода мы объявляем наш `CounterBloc` как блок, который преобразует `CounterEvents` в `ints`.

> Каждый блок должен определять начальное состояние, которое доджно быть определено до момента когда будут получены какие-либо события.

В этом случае мы хотим, чтобы наш счетчик начинался с `0`.

```dart
@override
int get initialState => 0;
```

> Каждый `bloc` должен реализовывать функцию с именем `mapEventToState`. Функция принимает входящее `event` в качестве аргумента и должна возвращать `Stream` новых `states`, который используется уровнем представления. Мы можем получить доступ к текущему состоянию блока в любое время, используя свойство `state`.

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

На данный момент у нас есть полностью функционирующий `CounterBloc`.

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

!> Блоки будут игнорировать повторяющиеся состояния. Если блок выдает `State nextState`, где `state == nextState`, тогда никакого перехода не произойдет и в `Stream<State>` не будет внесено никаких изменений.

В этот момент вы, вероятно, задаетесь вопросом: _Как я могу уведомить блок о событии?_.

> Каждый блок имеет метод `add`. `Add` принимает `event` и запускает `mapEventToState`. `Add` может вызываться из уровня представления или из блока и уведомлять блок о новом `event`.

Мы можем создать простое приложение, которое считает от 0 до 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

!> По умолчанию события всегда будут обрабатываться в том порядке, в котором они были добавлены, а все вновь добавленные события помещаются в очередь. Событие считается полностью обработанным после завершения выполнения `mapEventToState`.

`Transitions` в приведенном фрагменте кода будут:

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

К сожалению, в текущем состоянии мы не сможем увидеть ни один из этих переходов, если не переопределим `onTransition`.

> `onTransition` - это метод, который можно переопределить для обработки каждого локального блока `Transition`. `onTransition` вызывается незадолго до того, как состояние блока было обновлено.

?> **Совет**: `onTransition` - отличное место для добавления блочного логирования/аналитики.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Теперь, когда мы переопределили `onTransition`, мы можем делать все, что нам необходимо каждый раз когда происходит `Transition`.

Точно так же, как мы можем обрабатывать `Transitions` на уровне блока, мы также можем обрабатывать `Exceptions`.

> `onError` - это метод, который можно переопределить для обработки каждого исключения локального блока. По умолчанию все исключения будут игнорироваться и функциональность `Bloc` не будет затронута.

?> **Примечание**: аргумент stacktrace может иметь значение `null`, если поток состояния получил ошибку без `StackTrace`.

?> **Совет**: `onError` - отличное место для добавления обработки ошибок, специфичных для блоков.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Теперь, когда мы переопределили `onError`, мы можем делать все, что необходимо каждый раз, когда выдается `Exception`.

## BlocDelegate (Блок делегат)

Еще один дополнительный бонус от использования `Bloc` - это то, что мы можем иметь доступ ко всем `Transitions` в одном месте. Несмотря на то, что в этом приложении у нас есть только один блок, в больших приложениях довольно часто может быть много блоков, управляющих различными частями состояния приложения.

Если мы хотим иметь возможность что-то делать в ответ на все `Transitions`, мы можем просто создать наш собственный `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Примечание**: Все, что нам нужно сделать, это расширить `BlocDelegate` и переопределить метод `onTransition`.

Чтобы указать `Bloc` использовать наш `SimpleBlocDelegate`, нам просто нужно настроить нашу функцию `main`.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

Если мы хотим иметь возможность что-то делать в ответ на все предопределенные события, мы также можем переопределить метод `onEvent` в нашем `SimpleBlocDelegate`.

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

Если мы хотим иметь возможность что-то делать в ответ на все `Exceptions`, сгенерированные в блоке, мы также можем переопределить метод `onError` в нашем `SimpleBlocDelegate`.

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

?> **Примечание**: `BlocSupervisor` - это синглтон, который наблюдает за всеми блоками и делегирует обязанности `BlocDelegate`.
