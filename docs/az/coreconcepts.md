# Əsas Konseptlər

?> Zəhmət olmasa, [bloc](https://pub.dev/packages/bloc)-la işləməzdən öncə, aşağıdakı bölmələri diqqətli şəkildə oxuyub, anladığınıza əmin olun.

Bloc istifadə etmək üçün, bir sıra vacib konseptləri anlamaq lazımdır.

Növbəti bölmələrdə, bu əsas konseptlərin hər biri haqqında ətraflı müzakirə aparacaq və onların real tətbiqlərdə necə tətbiq oluna bilməsini sayğac tətbiqi ilə görəcəyik.

## Hadisələr (Events)

> Hadisələr Bloc-un girişidir (input). Bunlar, adətən istifadəçinin tətbiq ilə qarşılıqlı əlaqəsinə - hər hansı düyməyə basılmaya, lifecycle hadisələrinə (məsələn səhifənin yüklənməsi) cavab olaraq, Bloc-a əlavə olunur.

Bir tətbiqi tərtib edərkən, əvvəlcə istifadəçinin onu necə istifadə edəcəyini müəyyən etməliyik. Bizim sayğac tətbiqində sayğacı azaltmaq və artırmaq üçün iki düymə olacaq.

İstifadəçi düymələrdən birinə basan zaman, bizim tətbiqimizin beynini (əsas hissəsini) xəbərdar edə bilməliyik və bu xəbərdarlığa əasən istifadəçiyə cavab verilə bilər; elə buna görə də, bizim hadisələrə (events) ehtiyacımız var.

Sayğac tətbiqimizdə, tətbiqinin əsas hissəsini həm artırma, həm də azaltma üçün xəbərdar edə bilməliyik, buna görə də,  bunu hadisələri müəyyənləşdirməyə ehtiyacımız var.

```dart
enum CounterEvent { increment, decrement }
```

Bu tətbiqdə, hadisələrimiz sadə olduğu üçün biz `enum` istifadə etdik, amma daha mürəkkəb hallarda, əsasən də bloc-a hər hansı informasiyanı ötürmək lazım olduqda, `class`-dan istifadə etmək lazım gəlir.

Bu nöqtədə, ilk hidəsimizi müəyyən etdik!. Diqqət edin ki, biz indiyə qədər Bloc istifadə etməkdir və burada heç bir sehr yoxdur; bu sadəcə Dart kodlarıdır.

## Vəziyyətlər (States)

> Vəziyyətlər Bloc-un çıxışıdır (output) və tətbiqin vəziyyətini göstərir. İstifadəçi interfeysinin komponentləri bu vəziyyətləri əsasən xəbərdar edilə və cari vəziyyətə uyğun olaraq, özlərinin lazım olan hissələrini yeniləyə bilərlər.

Beləliklə, bizim tətbiqin cavab verəcəyi iki hadisəni - `CounterEvent.increment` və `CounterEvent.decrement`-i müəyyən etdik.

İndi isə, biz tətbiqimizin vəziyyətini necə nümayiş etdirəcəyimizi müəyyən etməliyik.

Biz, sayğac düzəltdiyimiz üçün, vəziyyət (state) sadədir: bu sayğacın cari qiymətini göstərən tam ədəddir (integer).

Biz daha mürəkkəb nümunələr görəcəyik, amma bu halda, primitiv tip, tətbiqin vəziyyətini göstərmək üçün uyğundur.

## Transitions

> The change from one state to another is called a Transition. A Transition consists of the current state, the event, and the next state.

As a user interacts with our counter app they will trigger `Increment` and `Decrement` events which will update the counter's state. All of these state changes can be described as a series of `Transitions`.

For example, if a user opened our app and tapped the increment button once we would see the following `Transition`.

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

Because every state change is recorded, we are able to very easily instrument our applications and track all user interactions & state changes in one place. In addition, this makes things like time-travel debugging possible.

## Streams

?> Check out the official [Dart Documentation](https://dart.dev/tutorials/language/streams) for more information about `Streams`.

> A stream is a sequence of asynchronous data.

Bloc is built on top of [RxDart](https://pub.dev/packages/rxdart); however, it abstracts all of the `RxDart` specific implementation details.

In order to use Bloc, it is criticial to have a solid understanding of `Streams` and how they work.

> If you're unfamiliar with `Streams` just think of a pipe with water flowing through it. The pipe is the `Stream` and the water is the asynchronous data.

We can create a `Stream` in Dart by writing an `async*` function.

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

By marking a function as `async*` we are able to use the `yield` keyword and return a `Stream` of data. In the above example, we are returning a `Stream` of integers up to the `max` integer parameter.

Every time we `yield` in an `async*` function we are pushing that piece of data through the `Stream`.

We can consume the above `Stream` in several ways. If we wanted to write a function to return the sum of a `Stream` of integers it could look something like:

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

By marking the above function as `async` we are able to use the `await` keyword and return a `Future` of integers. In this example, we are awaiting each value in the stream and returning the sum of all integers in the stream.

We can put it all together like so:

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

> A Bloc (Business Logic Component) is a component which converts a `Stream` of incoming `Events` into a `Stream` of outgoing `States`. Think of a Bloc as being the "brains" described above.

> Every Bloc must extend the base `Bloc` class which is part of the core bloc package.

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

In the above code snippet, we are declaring our `CounterBloc` as a Bloc which converts `CounterEvents` into `ints`.

> Every Bloc must define an initial state which is the state before any events have been received.

In this case, we want our counter to start at `0`.

```dart
@override
int get initialState => 0;
```

> Every Bloc must implement a function called `mapEventToState`. The function takes the incoming `event` as an argument and must return a `Stream` of new `states` which is consumed by the presentation layer. We can access the current bloc state at any time using the `state` property.

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

At this point, we have a fully functioning `CounterBloc`.

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

!> Blocs will ignore duplicate states. If a Bloc yields `State nextState` where `state == nextState`, then no transition will occur and no change will be made to the `Stream<State>`.

At this point, you're probably wondering _"How do I notify a Bloc of an event?"_.

> Every Bloc has a `add` method. `Add` takes an `event` and triggers `mapEventToState`. `Add` may be called from the presentation layer or from within the Bloc and notifies the Bloc of a new `event`.

We can create a simple application which counts from 0 to 3.

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

!> By default, events will always be processed in the order in which they were added and any newly added events are enqueued. An event is considered fully processed once `mapEventToState` has finished executing.

The `Transitions` in the above code snippet would be

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

Unfortunately, in the current state we won't be able to see any of these transitions unless we override `onTransition`.

> `onTransition` is a method that can be overridden to handle every local Bloc `Transition`. `onTransition` is called just before a Bloc's `state` has been updated.

?> **Tip**: `onTransition` is a great place to add bloc-specific logging/analytics.

```dart
@override
void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
}
```

Now that we've overridden `onTransition` we can do whatever we'd like whenever a `Transition` occurs.

Just like we can handle `Transitions` at the bloc level, we can also handle `Exceptions`.

> `onError` is a method that can be overriden to handle every local Bloc `Exception`. By default all exceptions will be ignored and `Bloc` functionality will be unaffected.

?> **Note**: The stacktrace argument may be `null` if the state stream received an error without a `StackTrace`.

?> **Tip**: `onError` is a great place to add bloc-specific error handling.

```dart
@override
void onError(Object error, StackTrace stackTrace) {
  print('$error, $stackTrace');
}
```

Now that we've overridden `onError` we can do whatever we'd like whenever an `Exception` is thrown.

## BlocDelegate

One added bonus of using Bloc is that we can have access to all `Transitions` in one place. Even though in this application we only have one Bloc, it's fairly common in larger applications to have many Blocs managing different parts of the application's state.

If we want to be able to do something in response to all `Transitions` we can simply create our own `BlocDelegate`.

```dart
class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }
}
```

?> **Note**: All we need to do is extend `BlocDelegate` and override the `onTransition` method.

In order to tell Bloc to use our `SimpleBlocDelegate`, we just need to tweak our `main` function.

```dart
void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  CounterBloc bloc = CounterBloc();

  for (int i = 0; i < 3; i++) {
    bloc.add(CounterEvent.increment);
  }
}
```

If we want to be able to do something in response to all `Events` added, we can also override the `onEvent` method in our `SimpleBlocDelegate`.

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

If we want to be able to do something in response to all `Exceptions` thrown in a Bloc, we can also override the `onError` method in our `SimpleBlocDelegate`.

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

?> **Note**: `BlocSupervisor` is a singleton which oversees all Blocs and delegates responsibilities to the `BlocDelegate`.
