# Flutter счетчик

![начинающий](https://img.shields.io/badge/level-beginner-green.svg)

> В следующем руководстве мы построим счетчик во Flutter, используя библиотеку `Bloc`.

![демо](../assets/gifs/flutter_counter.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

```bash
flutter create flutter_counter
```

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

```yaml
name: flutter_counter
description: A new Flutter project.
version: 1.0.0+1

environment:
  sdk: '>=2.0.0 <3.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^3.2.0
  meta: ^1.1.6

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

а затем установить все зависимости

```bash
flutter packages get
```

Наше приложение счетчик будет иметь две кнопки для увеличения/уменьшения значения счетчика и виджет `Text` для отображения текущего значения. Приступим к разработке `CounterEvents`.

## События

```dart
enum CounterEvent { increment, decrement }
```

## Состояния

Поскольку состояние нашего счетчика может быть представлено целым числом, нам не нужно создавать собственный класс!

## Блок

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

?> **Примечание**: в объявлении класса мы можем сказать, что наш `CounterBloc` будет принимать `CounterEvents` в качестве входных и выходных целых чисел.

## Приложение

Теперь, когда наш `CounterBloc` полностью реализован, мы можем приступить к созданию приложения Flutter.

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BlocProvider<CounterBloc>(
        create: (context) => CounterBloc(),
        child: CounterPage(),
      ),
    );
  }
}
```

?> **Примечание**: Мы используем виджет `BlocProvider` из `flutter_bloc`, чтобы сделать экземпляр `CounterBloc` доступным для всего поддерева (`CounterPage`). `BlocProvider` также автоматически закрывает `CounterBloc`, поэтому нам не нужно использовать `StatefulWidget`.

## Страница

Наконец все, что осталось - это создать нашу страницу счетчика.

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

?> **Примечание**: мы можем получить доступ к экземпляру `CounterBloc`, используя `BlocProvider.of<CounterBloc>(context)`, потому что мы обернули наш `CounterPage` в `BlocProvider`.

?> **Примечание**: Мы используем виджет `BlocBuilder` из `flutter_bloc`, чтобы перестроить наш пользовательский интерфейс в ответ на изменения состояния (изменения в значении счетчика).

?> **Примечание**: `BlocBuilder` принимает необязательный параметр `bloc`, но мы можем указать тип блока и тип состояния так, что `BlocBuilder` автоматически найдет блок, поэтому нам не нужно в явном виде использовать `BlocProvider.of<CounterBloc>(context)`.

!> Указывайте блок в `BlocBuilder` только если вы хотите предоставить блок, который будет ограничен одним виджетом и недоступен через родительский `BlocProvider` и текущий `BuildContext`.

Это оно! Мы отделили наш уровень представления от нашего уровня бизнес-логики. Наш `CounterPage` не знает что происходит, когда пользователь нажимает кнопку; он просто добавляет событие для уведомления `CounterBloc`. Кроме того, наш `CounterBloc` не имеет представления о том, что происходит с состоянием (значение счетчика); он просто преобразует `CounterEvents` в целые числа.

Мы можем запустить наше приложение с `flutter run` и посмотреть его на нашем устройстве или симуляторе/эмуляторе.

Исходные тексты для этого примера можно найти [по ссылке](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
