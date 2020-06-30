# Flutter бесконечный список

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> В этом руководстве мы собираемся реализовать приложение, которое извлекает данные по сети и загружает их когда пользователь выполняет прокрутку, используя Flutter и библиотеку `bloc`.

![demo](../assets/gifs/flutter_infinite_list.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_infinite_list_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_infinite_list_tutorial/pubspec.yaml.md ':include')

а затем установить все наши зависимости

[script](../_snippets/flutter_infinite_list_tutorial/flutter_packages_get.sh.md ':include')

## REST API

Для этого демонстрационного приложения мы будем использовать [jsonplaceholder](http://jsonplaceholder.typicode.com) в качестве источника данных.

?> `jsonplaceholder` - это онлайн REST API, который обслуживает поддельные данные; это очень полезно для создания прототипов.

Откройте новую вкладку в своем браузере и посетите страницу https://jsonplaceholder.typicode.com/posts?_start=0&_limit=2, чтобы узнать что возвращает API.

[posts.json](../_snippets/flutter_infinite_list_tutorial/posts.json.md ':include')

?> **Примечание:** в нашем URL мы указали начало и ограничение в качестве параметров для запроса GET.

Отлично, теперь когда мы знаем как будут выглядеть наши данные, давайте создадим модель.

## Модель данных

Создайте `post.dart` и давайте приступим к созданию модели нашего объекта `Post`.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post.dart.md ':include')

`Post` это просто класс с `id`, `title`, and `body`.

?> Мы переопределяем функцию `toString`, чтобы иметь собственное строковое представление нашего `Post` на будущее.

?> Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать `Posts`; по умолчанию оператор равенства возвращает true, если этот и другие являются одинаковыми экземплярами.

Теперь, когда у нас есть объектная модель `Post`, давайте приступим к работе с компонентом Business Logic (`bloc`).

## События

Прежде чем мы углубимся в реализацию, нам нужно определить, что будет делать наш `PostBloc`.

На верхнем уровне он будет реагировать на пользовательский ввод (прокрутку) и извлекать больше сообщений, чтобы их отображал уровень презентации. Давайте начнем с создания нашего `Event`.

Наш `PostBloc` будет отвечать только на одно событие; `PostFetched`, которое будет добавляться уровнем представления всякий раз, когда ему нужно представить больше сообщений. Поскольку наше событие `PostFetched` является типом `PostEvent`, мы можем создать `bloc/post_event.dart` и реализовать событие следующим образом.

[post_event.dart](../_snippets/flutter_infinite_list_tutorial/post_event.dart.md ':include')

Напомним, что наш `PostBloc` будет получать `PostEvents` и преобразовывать их в `PostStates`. Мы определили все наши `PostEvents` (PostFetched), так что теперь давайте определим наш `PostState`.

## Состояния

Наш уровень представления должен иметь несколько видов информации, чтобы правильно соотвествовать:

- `PostInitial` - сообщит слою представления, что ему нужно визуализировать индикатор загрузки, пока загружается начальная часть сообщений.

- `PostSuccess` - сообщит слою представления, что у него есть контент для рендеринга
  - `posts` - будет списком объектов `List<Post>`, который будет отображен
  - `hasReachedMax` - сообщит слою представления, достигло ли оно максимального количества постов
- `PostFailure` - сообщит слою представления, что при получении сообщений произошла ошибка

Теперь мы можем создать `bloc/post_state.dart` и реализовать это приблизительно так:

[post_state.dart](../_snippets/flutter_infinite_list_tutorial/post_state.dart.md ':include')

?> Мы реализовали `copyWith`, чтобы мы могли скопировать экземпляр `PostSuccess` и выборочно обновить его свойства (это пригодится позже).

Теперь, когда у нас реализованы наши `Events` и `States`, мы можем создать наш `PostBloc`.

Чтобы было удобно импортировать наши состояния и события с помощью одного импорта, мы можем создать `bloc/bloc.dart`, который экспортирует их все (мы добавим наш экспорт`post_bloc.dart` в следующем разделе).

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc_initial.dart.md ':include')

## Блок

Для простоты наш `PostBloc` будет иметь прямую зависимость от `http client`; однако в финальном приложении вы можете вместо этого внедрить клиент API и использовать паттерн репозитория [по ссылке](ru/architecture.md).

Давайте создадим `post_bloc.dart` и создадим наш пустой `PostBloc`.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial.dart.md ':include')

?> **Примечание:** только в объявлении класса мы можем сказать, что наш `PostBloc` будет принимать `PostEvents` в качестве ввода и вывода `PostStates`.

Мы можем начать с реализации `initialState`, который будет состоянием нашего `PostBloc` до добавления каких-либо событий.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_initial_state.dart.md ':include')

Затем нам нужно реализовать `mapEventToState`, который будет запускаться каждый раз, когда добавляется `PostEvent`.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_map_event_to_state.dart.md ':include')

Наш `PostBloc` будет производить `yield` всякий раз, когда появляется новое состояние, потому что он возвращает `Stream <PostState>`. Проверьте [Основные понятия](ru/coreconcepts?id=streams-Потоки) для получения дополнительной информации о `Streams` и других основах.

Теперь каждый раз, когда добавляется `PostEvent` и если это событие `PostFetched`, а также есть еще сообщения для извлечения, наш `PostBloc` будет извлекать следующие 20 сообщений.

API вернет пустой массив, если мы попытаемся извлечь больше максимального количества записей (100), поэтому, если мы вернем пустой массив, наш блок сделает `yield currentState` и, кроме того, мы установим для `hasReachedMax` значение true.

Если мы не можем получить сообщения, мы выдаем исключение и `yield PostFailure ()`.

Если мы можем получить сообщения, мы возвращаем `PostSuccess()`, который принимает весь список сообщений.

Одна из оптимизаций, которую мы можем сделать - это `debounce Events` (отменить события), чтобы избежать ненужного спама в нашем API. Мы можем сделать это, переопределив метод `transform` в нашем `PostBloc`.

?> **Примечание:** Переопределение позволяет нам преобразовать `Stream<Event>` до вызова `mapEventToState`. Это позволяет применять такие операции, как Different(), debounceTime() и т.д.

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc_transform_events.dart.md ':include')

Наш готовый `PostBloc` теперь должен выглядеть так:

[post_bloc.dart](../_snippets/flutter_infinite_list_tutorial/post_bloc.dart.md ':include')

Не забудьте обновить `bloc/bloc.dart` и включить наш `PostBloc`!

[bloc.dart](../_snippets/flutter_infinite_list_tutorial/bloc.dart.md ':include')

Великолепно! Теперь, когда мы закончили реализацию бизнес логики, нам остался только уровень представления.

## Представление

В нашем `main.dart` мы можем начать с реализации нашей основной функции и вызова `runApp` для рендеринга корневого виджета.

В нашем виджете `App` мы используем `BlocProvider` для создания и предоставления экземпляра `PostBloc` для поддерева. Также мы добавляем событие `PostFetched`, чтобы при загрузке приложения оно запрашивало начальные данные.

[main.dart](../_snippets/flutter_infinite_list_tutorial/main.dart.md ':include')

Далее нам нужно реализовать наш виджет `HomePage`, который будет представлять наши сообщения и подключаться к нашему `PostBloc`.

[home_page.dart](../_snippets/flutter_infinite_list_tutorial/home_page.dart.md ':include')

?> `HomePage` является `StatefulWidget` потому, что он должен поддерживать `ScrollController`. В `initState` мы добавляем слушателя к нашему `ScrollController`, чтобы мы могли реагировать на события прокрутки. Мы также обращаемся к нашему экземпляру `PostBloc` через `BlocProvider.of<PostBloc>(context)`.

В дальнейшем наш метод `build` возвращает `BlocBuilder`. `BlocBuilder` - это виджет Flutter из пакета [flutter_bloc](https://pub.dev/packages/flutter_bloc), который обрабатывает создание виджета в ответ на новые состояния блока. Каждый раз, когда изменяется наше состояние `PostBloc`, наша функция конструктора будет вызываться с новым `PostState`.

!> Нам нужно помнить о необходимости убирать за собой и избавляться от нашего `ScrollController` при удалении `StatefulWidget`.

Всякий раз, когда пользователь прокручивает, мы вычисляем как далеко от нижней части страницы мы находимся и если расстояние ≤ нашего `_scrollThreshold`, мы добавляем событие `PostFetched`, чтобы загрузить больше сообщений.

Далее нам нужно реализовать наш виджет `BottomLoader`, который будет указывать пользователю, что мы загружаем больше постов.

[bottom_loader.dart](../_snippets/flutter_infinite_list_tutorial/bottom_loader.dart.md ':include')
Наконец, нам нужно реализовать наш `PostWidget`, который будет отображать отдельный пост.

[post.dart](../_snippets/flutter_infinite_list_tutorial/post_widget.dart.md ':include')

На этом этапе мы должны иметь возможность запустить наше приложение, и все должно работать; тем не менее, есть еще одна вещь, которую мы можем сделать.

Еще один дополнительный бонус от использования библиотеки `bloc` - это то, что мы можем иметь доступ ко всем `Transitions` в одном месте.

> Переход из одного состояния в другое называется `Transition`.

?> `Transition` состоит из текущего состояния, события и следующего состояния.

Несмотря на то, что в этом приложении у нас есть только один блок, в больших приложениях довольно часто можно видеть множество блоков, управляющих различными частями состояния приложения.

Если мы хотим иметь возможность что-то делать в ответ на все `Transitions`, мы можем просто создать наш собственный `BlocDelegate`.

[simple_bloc_delegate.dart](../_snippets/flutter_infinite_list_tutorial/simple_bloc_delegate.dart.md ':include')

?> Все, что нам нужно сделать, это расширить `BlocDelegate` и переопределить метод `onTransition`.

Чтобы указать `Bloc` использовать наш `SimpleBlocDelegate`, нам просто нужно настроить нашу основную функцию.

[main.dart](../_snippets/flutter_infinite_list_tutorial/bloc_delegate_main.dart.md ':include')

Теперь, когда мы запускаем наше приложение, каждый раз, когда происходит блок `Transition`, мы можем видеть переход, напечатанный на консоли.

?> На практике вы можете создавать разные `BlocDelegates` и, поскольку каждое изменение состояния сохраняется, мы можем очень легко оборудовать наши приложения и отслеживать все взаимодействия пользователей и изменения состояния в одном месте!

Вот и все, что нужно сделать! Теперь мы успешно реализовали бесконечный список во Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес логики.

Наша `HomePage` не знает откуда берутся сообщения и как они извлекаются. И наоборот, наш `PostBloc` не знает как отображается `State`, он просто конвертирует события в состояния.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_infinite_list).
