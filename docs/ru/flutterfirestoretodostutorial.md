# Flutter Firestore задачи

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы создадим реактивное приложение Todos, которое подключается к Firestore. Мы построим все на основе примера [flutter todos](ru/fluttertodostutorial.md), но не будем вдаваться в подробности пользовательского интерфейса, поскольку они будут одинаковыми.

![demo](../assets/gifs/flutter_firestore_todos.gif)

Единственное, что мы мы сделаем - это рефакторинг существующего [примера todos](https://github.com/felangel/Bloc/tree/master/examples/flutter_todos) на уровне хранилища и частичто слоя блока.

Мы начнем со слоя репозитория с `TodosRepository`.

## Todos хранилище

Создайте новый пакет на корневом уровне нашего приложения под названием `todos_repository`.

?> **Примечание:** Причина, по которой хранилище является автономным пакетом состоит в том, чтобы проиллюстрировать, что хранилище должно быть отделено от приложения и может быть повторно использовано в нескольких приложениях.

Внутри `todos_repository` создайте следующую структуру папок/файлов.

[todos_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/todos_repository_dir.sh.md ':include')

### Зависимости

`pubspec.yaml` должен выглядеть так:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/todos_repository_pubspec.yaml.md ':include')

?> **Примечание:** Мы сразу видим, что наш `todos_repository` зависит от `firebase_core` и `cloud_firestore`.

### Корневой пакет

`Todos_repository.dart` непосредственно внутри `lib` должен выглядеть следующим образом:

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository_library.dart.md ':include')

?> Здесь экспортируются все наши публичные классы. Если мы хотим, чтобы класс был закрытым для пакета, мы обязательно должны его опустить.

### Сущности

> Объекты представляют данные, предоставленные нашим поставщиком данных.

Файл `entity.dart` - это индексный файл, который экспортирует `todo_entity.dart`.
файл.

[entities.dart](../_snippets/flutter_firestore_todos_tutorial/entities_barrel.dart.md ':include')

`TodoEntity` является представлением нашего `Todo` внутри Firestore. Создайте `todo_entity.dart` и давайте его реализуем.

[todo_entity.dart](../_snippets/flutter_firestore_todos_tutorial/todo_entity.dart.md ':include')

`ToJson` и `fromJson` являются стандартными методами для преобразования в/из json.
`FromSnapshot` и `toDocument` относятся к Firestore.

?> **Примечание:** Firestore автоматически создаст идентификатор для документа, когда мы его вставим. Поэтому мы не будем дублировать данные, сохраняя идентификатор в дополнительном поле.

### Модели

> Модели будут содержать простые классы dart, с которыми мы будем работать в нашем приложении Flutter. Разделение между моделями и сущностями позволяет нам в любое время переключать поставщика данных и нам нужно только изменить преобразования `toEntity` и `fromEntity` на уровне модели.

`models.dart` - это еще один индексный файл.
Внутри `todo.dart` давайте поместим следующий код.

[todo.dart](../_snippets/flutter_firestore_todos_tutorial/todo.dart.md ':include')

### Хранидище задач

> `TodosRepository` - это наш абстрактный базовый класс, который мы можем расширять всякий раз, когда хотим интегрироваться с другим `TodosProvider`.

Давайте создадим `todos_repository.dart`

[todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/todos_repository.dart.md ':include')

?> **Примечание:** Поскольку у нас есть интерфейс, теперь легко добавить другой тип хранилища данных. Если, например, мы хотим использовать что-то вроде [sembast](https://pub.dev/flutter/packages?q=sembast), все, что нам нужно сделать - это создать отдельный репозиторий для обработки кода, специфичного для sembast.

#### Firebase хранилище задач

> `FirebaseTodosRepository` управляет интеграцией с Firestore и реализует наш интерфейс `TodosRepository`.

Давайте откроем `firebase_todos_repository.dart` и реализуем его!

[firebase_todos_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_todos_repository.dart.md ':include')

Вот и все для нашего `TodosRepository`, теперь нам нужно создать простой `UserRepository` для управления аутентификацией наших пользователей.

## Хранилище пользователей

Создайте новый пакет на корневом уровне нашего приложения под названием `user_repository`.

Внутри `user_repository` создайте следующую структуру папок/файлов.

[user_repository_dir.sh](../_snippets/flutter_firestore_todos_tutorial/user_repository_dir.sh.md ':include')

### Зависимости

`Pubspec.yaml` должен выглядеть так:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/user_repository_pubspec.yaml.md ':include')

?> **Примечание:** Мы можем сразу увидеть, что наш `user_repository` зависит от `firebase_auth`.

### Корневой пакет

`user_repository.dart` непосредственно внутри `lib` должен выглядеть следующим образом:

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository_library.dart.md ':include')

### Хранилище пользователей

> `UserRepository` - это наш абстрактный базовый класс, который мы можем расширять всякий раз, когда хотим интегрироваться с другим провайдером.

Давайте создадим `user_repository.dart`

[user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/user_repository.dart.md ':include')

#### Firebase хранилище пользователей

> `FirebaseUserRepository` управляет интеграцией с Firebase и реализует наш интерфейс `UserRepository`.

Давайте откроем `firebase_user_repository.dart` и реализуем его!

[firebase_user_repository.dart](../_snippets/flutter_firestore_todos_tutorial/firebase_user_repository.dart.md ':include')

Вот и все для нашего `UserRepository`. Далее нам нужно настроить приложение Flutter для использования наших новых репозиториев.

## Flutter приложение

### Настройка

Давайте создадим новое приложение Flutter под названием `flutter_firestore_todos`. Мы можем заменить содержимое `pubspec.yaml` следующим:

[pubspec.yaml](../_snippets/flutter_firestore_todos_tutorial/pubspec.yaml.md ':include')

?> **Примечание:** Мы добавляем `todos_repository` и `user_repository` в качестве внешних зависимостей.

### Auth блок

Поскольку наши пользователи должны иметь возможность войти в систему, нам нужно создать `AuthenticationBloc`.

?> Если вы еще не ознакомились с [Flutter Firebase Login](ru/flutterfirebaselogintutorial.md), я настоятельно рекомендую проверить его сейчас, потому что мы просто собираемся повторно использовать тот же `AuthenticationBloc`.

#### Auth события

[authentication_event.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_event.dart.md ':include')

#### Auth состояния

[authentication_state.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_state.dart.md ':include')

#### Auth блок

[authentication_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/authentication_bloc.dart.md ':include')

Теперь, когда `AuthenticationBloc` закончен, нам нужно изменить `TodosBloc` из исходного [пособия по Todos](ru/fluttertodostutorial.md), чтобы использовать новый `TodosRepository`.

### Todos блок

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/todos_bloc.dart.md ':include')

Основное различие между новым `TodosBloc` и оригинальным заключается в том, что теперь все основано на `Stream`, а не на `Future`.

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_load_todos_to_state.dart.md ':include')

?> Когда мы загружаем задачи, мы подписываемся на `TodosRepository` и каждый раз, когда появляется новая задача, мы добавляем событие `TodosUpdated`. Затем мы обрабатываем все `TodosUpdates` через:

[todos_bloc.dart](../_snippets/flutter_firestore_todos_tutorial/map_todos_updated_to_state.dart.md ':include')

## Собираем все вместе

Последнее, что нам нужно изменить, это наш `main.dart`.

[main.dart](../_snippets/flutter_firestore_todos_tutorial/main.dart.md ':include')

Основным отличием, которое следует отметить является тот факт, что мы завернули все наше приложение в `MultiBlocProvider`, который инициализирует и предоставляет `AuthenticationBloc` и `TodosBloc`. Затем мы только визуализируем приложение todos если для `AuthenticationState` установлено `Authenticated` с использованием `BlocBuilder`. Все остальное остается тем же, что и в предыдущем `учебнике todos`.

Вот и все, что нужно сделать! Теперь мы успешно внедрили приложение todos для Firestore во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили уровень представления от бизнес-логики, а также создали приложение, которое обновляется в режиме реального времени.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_firestore_todos).
