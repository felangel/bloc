# AngularDart счетчик

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы построим Counter в AngularDart с использованием библиотеки Bloc.

![demo](../assets/gifs/angular_counter.gif)

## Настройка

Мы начнем с создания нового проекта AngularDart с использованием [stagehand](https://github.com/dart-lang/stagehand).

[script](../_snippets/angular_counter_tutorial/stagehand.sh.md ':include')

!> Активируйте stagehand, запустив `pub global activate stagehand`

Затем мы заменим содержимое `pubspec.yaml` на:

[pubspec.yaml](../_snippets/angular_counter_tutorial/pubspec.yaml.md ':include')

а затем установим все зависимости

[script](../_snippets/angular_counter_tutorial/install.sh.md ':include')

Наше приложение-счетчик будет иметь две кнопки для увеличения/уменьшения значения счетчика и элемент для отображения текущего значения. Приступим к разработке `CounterEvents`.

## Counter события

[counter_event.dart](../_snippets/angular_counter_tutorial/counter_event.dart.md ':include')

## Counter состояния

Поскольку состояние нашего счетчика может быть представлено целым числом, нам не нужно создавать собственный класс!

## Counter блок

[counter_bloc.dart](../_snippets/angular_counter_tutorial/counter_bloc.dart.md ':include')

?> **Примечание**: из объявления класса мы можем сказать, что наш `CounterBloc` будет принимать `CounterEvents` в качестве входных и выходных целых чисел.

## Counter приложение

Теперь, когда `CounterBloc` полностью реализован, мы можем приступить к созданию компонента приложения `AngularDart`.

`app.component.dart` должен выглядеть так:

[app.component.dart](../_snippets/angular_counter_tutorial/app_component.dart.md ':include')

и `app.component.html` должен выглядеть так:

[app.component.html](../_snippets/angular_counter_tutorial/app_component.html.md ':include')

## Counter страница

Наконец все, что осталось, это построить `Counter` компонент.

`counter_page_component.dart` должен выглядеть так:

[counter_page_component.dart](../_snippets/angular_counter_tutorial/counter_page_component.dart.md ':include')

?> **Примечание**: мы можем получить доступ к экземпляру `CounterBloc` с помощью системы внедрения зависимостей `AngularDart`. Поскольку мы зарегистрировали его как `Provider`, AngularDart может правильно определить `CounterBloc`.

?> **Примечание**: Мы закрываем `CounterBloc` в `ngOnDestroy`.

?> **Примечание**: мы импортируем `BlocPipe`, чтобы использовать его в нашем шаблоне.

Наконец, наш `counter_page_component.html` должен выглядеть так:

[counter_page_component.html](../_snippets/angular_counter_tutorial/counter_page_component.html.md ':include')

?> **Примечание**: мы используем `BlocPipe`, чтобы мы могли отображать наше состояние counterBloc по мере его обновления.

Это оно! Мы отделили уровень представления от уровня бизнес-логики. `CounterPageComponent` не знает что происходит, когда пользователь нажимает кнопку; он просто добавляет событие для уведомления `CounterBloc`. Кроме того, `CounterBloc` не имеет представления о том, что происходит с состоянием (значение счетчика); это просто преобразование `CounterEvents` в целые числа.

Мы можем запустить приложение с `webdev serve` и просматривать его локально [по ссылке](http://localhost:8080).

Полные исходные тексты этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/angular_counter).
