# Тестирование

> Блок был спроектирован так, чтобы его было очень легко тестировать.

Для простоты давайте напишем тесты для `CounterBloc`, который мы создали в [Основных понятиях](ru/coreconcepts.md).

Напомним, что реализация `CounterBloc` выглядит следующим образом:

[counter_bloc.dart](../_snippets/testing/counter_bloc.dart.md ':include')

Прежде чем мы начнем писать тесты, нам нужно добавить среду тестирования в качестве зависимости.

Нам нужно добавить [test](https://pub.dev/packages/test) и [bloc_test](https://pub.dev/packages/bloc_test) в наш `pubspec.yaml`.

[pubspec.yaml](../_snippets/testing/pubspec.yaml.md ':include')

Давайте начнем с создания файла `counter_bloc_test.dart` для тестирования `CounterBloc` и импортируем пакет для тестирования.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_imports.dart.md ':include')

Далее нам нужно создать `main`, а также тестовую группу.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **Примечание**: группы предназначены для организации отдельных тестов, а также для создания контекста, в котором вы можете использовать общие `setUp` и `tearDown` для всех отдельных тестов.

Давайте начнем с создания экземпляра нашего `CounterBloc`, который будет использоваться во всех наших тестах.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_setup.dart.md ':include')

Теперь мы можем начать писать наши индивидуальные тесты.

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **Примечание**: Мы можем запустить все наши тесты с помощью команды `pub run test`.

В этот момент мы должны пройти наш первый тест успешно! Теперь давайте напишем более сложный тест, используя пакет [bloc_test](https://pub.dev/packages/bloc_test).

[counter_bloc_test.dart](../_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

Мы должны запустить тесты и увидеть, что все прошло успешно.

Это все, что нужно сделать. Тестирование должно быть быстрым и мы должны чувствовать уверенность при внесении изменений и рефакторинга нашего кода.

Вы можете обратиться к [приложению Todos](https://github.com/brianegan/flutter_architecture_samples/tree/master/bloc_library) для примера полностью протестированного приложения.
