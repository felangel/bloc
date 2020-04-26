# Flutter счетчик

![начинающий](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы построим счетчик во Flutter, используя библиотеку `Bloc`.

![демо](../assets/gifs/flutter_counter.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

а затем установить все зависимости

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Наше приложение счетчик будет иметь две кнопки для увеличения/уменьшения значения счетчика и виджет `Text` для отображения текущего значения. Приступим к разработке `CounterEvents`.

## События

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Состояния

Поскольку состояние нашего счетчика может быть представлено целым числом, нам не нужно создавать собственный класс!

## Блок

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Примечание**: в объявлении класса мы можем сказать, что наш `CounterBloc` будет принимать `CounterEvents` в качестве входных и выходных целых чисел.

## Приложение

Теперь, когда наш `CounterBloc` полностью реализован, мы можем приступить к созданию приложения Flutter.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Примечание**: Мы используем виджет `BlocProvider` из `flutter_bloc`, чтобы сделать экземпляр `CounterBloc` доступным для всего поддерева (`CounterPage`). `BlocProvider` также автоматически закрывает `CounterBloc`, поэтому нам не нужно использовать `StatefulWidget`.

## Страница

Наконец все, что осталось - это создать нашу страницу счетчика.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Примечание**: мы можем получить доступ к экземпляру `CounterBloc`, используя `BlocProvider.of<CounterBloc>(context)`, потому что мы обернули наш `CounterPage` в `BlocProvider`.

?> **Примечание**: Мы используем виджет `BlocBuilder` из `flutter_bloc`, чтобы перестроить наш пользовательский интерфейс в ответ на изменения состояния (изменения в значении счетчика).

?> **Примечание**: `BlocBuilder` принимает необязательный параметр `bloc`, но мы можем указать тип блока и тип состояния так, что `BlocBuilder` автоматически найдет блок, поэтому нам не нужно в явном виде использовать `BlocProvider.of<CounterBloc>(context)`.

!> Указывайте блок в `BlocBuilder` только если вы хотите предоставить блок, который будет ограничен одним виджетом и недоступен через родительский `BlocProvider` и текущий `BuildContext`.

Это оно! Мы отделили наш уровень представления от нашего уровня бизнес-логики. Наш `CounterPage` не знает что происходит, когда пользователь нажимает кнопку; он просто добавляет событие для уведомления `CounterBloc`. Кроме того, наш `CounterBloc` не имеет представления о том, что происходит с состоянием (значение счетчика); он просто преобразует `CounterEvents` в целые числа.

Мы можем запустить наше приложение с `flutter run` и посмотреть его на нашем устройстве или симуляторе/эмуляторе.

Исходные тексты для этого примера можно найти [по ссылке](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
