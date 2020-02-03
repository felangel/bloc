# AngularDart счетчик

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы построим Counter в AngularDart с использованием библиотеки Bloc.

![demo](../assets/gifs/angular_counter.gif)

## Настройка

Мы начнем с создания нового проекта AngularDart с использованием [stagehand](https://github.com/dart-lang/stagehand).

```bash
stagehand web-angular
```

!> Активируйте stagehand, запустив `pub global activate stagehand`

Затем мы заменим содержимое `pubspec.yaml` на:

```yaml
name: angular_counter
description: A web app that uses angular_bloc

environment:
  sdk: ">=2.6.0 <3.0.0"

dependencies:
  angular: ^5.3.0
  angular_components: ^0.13.0
  angular_bloc: ^3.0.0

dev_dependencies:
  angular_test: ^2.0.0
  build_runner: ">=1.6.2 <2.0.0"
  build_test: ^0.10.2
  build_web_compilers: ">=1.2.0 <3.0.0"
  test: ^1.0.0
```

а затем установим все зависимости

```bash
pub get
```

Наше приложение-счетчик будет иметь две кнопки для увеличения/уменьшения значения счетчика и элемент для отображения текущего значения. Приступим к разработке `CounterEvents`.

## Counter события

```dart
enum CounterEvent { increment, decrement }
```

## Counter состояния

Поскольку состояние нашего счетчика может быть представлено целым числом, нам не нужно создавать собственный класс!

## Counter блок

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

?> **Примечание**: из объявления класса мы можем сказать, что наш `CounterBloc` будет принимать `CounterEvents` в качестве входных и выходных целых чисел.

## Counter приложение

Теперь, когда `CounterBloc` полностью реализован, мы можем приступить к созданию компонента приложения `AngularDart`.

`app.component.dart` должен выглядеть так:

```dart
import 'package:angular/angular.dart';

import 'package:angular_counter/src/counter_page/counter_page_component.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  directives: [CounterPageComponent],
)
class AppComponent {}
```

и `app.component.html` должен выглядеть так:

```html
<counter-page></counter-page>
```

## Counter страница

Наконец все, что осталось, это построить `Counter` компонент.

`counter_page_component.dart` должен выглядеть так:

```dart
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

import 'package:angular_bloc/angular_bloc.dart';

import './counter_bloc.dart';

@Component(
  selector: 'counter-page',
  templateUrl: 'counter_page_component.html',
  styleUrls: ['counter_page_component.css'],
  directives: [MaterialFabComponent],
  providers: [ClassProvider(CounterBloc)],
  pipes: [BlocPipe],
)
class CounterPageComponent implements OnDestroy {
  final CounterBloc counterBloc;

  CounterPageComponent(this.counterBloc) {}

  @override
  void ngOnDestroy() {
    counterBloc.close();
  }

  void increment() {
    counterBloc.add(CounterEvent.increment);
  }

  void decrement() {
    counterBloc.add(CounterEvent.decrement);
  }
}
```

?> **Примечание**: мы можем получить доступ к экземпляру `CounterBloc` с помощью системы внедрения зависимостей `AngularDart`. Поскольку мы зарегистрировали его как `Provider`, AngularDart может правильно определить `CounterBloc`.

?> **Примечание**: Мы закрываем `CounterBloc` в `ngOnDestroy`.

?> **Примечание**: мы импортируем `BlocPipe`, чтобы использовать его в нашем шаблоне.

Наконец, наш `counter_page_component.html` должен выглядеть так:

```html
<div class="counter-page-container">
  <h1>Counter App</h1>
  <h2>Current Count: {{ counterBloc | bloc }}</h2>
  <material-fab class="counter-fab-button" (trigger)="increment()"
    >+</material-fab
  >
  <material-fab class="counter-fab-button" (trigger)="decrement()"
    >-</material-fab
  >
</div>
```

?> **Примечание**: мы используем `BlocPipe`, чтобы мы могли отображать наше состояние counterBloc по мере его обновления.

Это оно! Мы отделили уровень представления от уровня бизнес-логики. `CounterPageComponent` не знает что происходит, когда пользователь нажимает кнопку; он просто добавляет событие для уведомления `CounterBloc`. Кроме того, `CounterBloc` не имеет представления о том, что происходит с состоянием (значение счетчика); это просто преобразование `CounterEvents` в целые числа.

Мы можем запустить приложение с `webdev serve` и просматривать его локально [по ссылке](http://localhost:8080).

Полные исходные тексты этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
