# Flutter Login

![intermediate](https://img.shields.io/badge/level-intermediate-orange.svg)

> В следующем руководстве мы собираемся создать `Login Flow` на Flutter, используя библиотеку `Bloc`.

![демо](../assets/gifs/flutter_login.gif)

## Настройка

Мы начнем с создания нового проекта Flutter

[script](../_snippets/flutter_login_tutorial/flutter_create.sh.md ':include')

Сначала нам нужно заменить содержимое файла `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_login_tutorial/pubspec.yaml.md ':include')

а затем установить все наши зависимости

[script](../_snippets/flutter_login_tutorial/flutter_packages_get.sh.md ':include')

## Хранилище

Нам нужно создать `UserRepository` для управления данными пользователя.

[user_repository.dart](../_snippets/flutter_login_tutorial/user_repository.dart.md ':include')

?> **Примечание**: наш пользовательский репозиторий просто имитирует все различные реализации для простоты, но в реальном приложении вы можете добавить [HttpClient](https://pub.dev/packages/http), а также что-то вроде [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) для запроса токенов, чтения/записи связки ключей из/в хранилища(е).

## Auth состояния

Далее нам нужно определить, как мы собираемся управлять состоянием нашего приложения и создать необходимые блоки (компоненты бизнес-логики).

На верхнем уровне нам нужно будет управлять состоянием аутентификации пользователя. Состояние аутентификации пользователя может быть одним из следующих:

- `Uninitialized` - ожидание проверки подлинности пользователя при запуске приложения.
- `Loading` - ожидание сохранения/удаления токена
- `Authenticated` - успешно аутентифицирован
- `Unauthenticated` - не аутентифицирован

Каждое из этих состояний будет влиять на то, что видит пользователь.

Например:

- если состояние аутентификации было НЕ определено, пользователь может видеть заставку.
- если состояние аутентификации загружается, пользователь может видеть индикатор выполнения.
- если состояние аутентификации было определено, пользователь может увидеть домашний экран.
- если состояние аутентификации было НЕ определено, пользователь может увидеть форму входа в систему.

> Очень важно определить, какими будут различные состояния, прежде чем погрузиться в реализацию.

Теперь, когда мы определили наши состояния аутентификации, мы можем реализовать наш класс `AuthenticationState`

[authentication_state.dart](../_snippets/flutter_login_tutorial/authentication_state.dart.md ':include')

?> **Примечание**: Пакет [Equatable](https://pub.dev/packages/equatable) используется для сравнения двух экземпляров `AuthenticationState`. По умолчанию `==` возвращает true, только если два объекта являются одним и тем же экземпляром.

## Auth события

Теперь, когда мы определили наш `AuthenticationState`, нам нужно определить `AuthenticationEvents`, на который будет реагировать наш `AuthenticationBloc`.

Нам понадобится:

- событие `AuthenticationStarted`, чтобы уведомить блок о том, что ему нужно проверить, аутентифицирован ли пользователь в настоящее время или нет.
- событие `AuthenticationLoggedIn`, чтобы уведомить блок о том, что пользователь успешно вошел в систему.
- событие `AuthenticationLoggedOut`, чтобы уведомить блок о том, что пользователь успешно вышел из системы.

[authentication_event.dart](../_snippets/flutter_login_tutorial/authentication_event.dart.md ':include')

?> **Примечание**: пакет `meta` используется для аннотирования параметров `AuthenticationEvent` как `@ required`. Это заставит анализатор `dart` предупреждать разработчиков, если они не предоставляют требуемые параметры.

## Auth блок

Теперь, когда у нас определены `AuthenticationState` и `AuthenticationEvents`, мы можем приступить к реализации `AuthenticationBloc`, который будет управлять проверкой и обновлением пользовательского `AuthenticationState` в ответ на `AuthenticationEvents`.

Мы начнем с создания нашего класса `AuthenticationBloc`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_constructor.dart.md ':include')

?> **Примечание**: Из определения класса мы уже знаем, что этот блок будет преобразовывать `AuthenticationEvents` в `AuthenticationStates`.

?> **Примечание**: наш `AuthenticationBloc` зависит от `UserRepository`.

Мы можем начать с переопределения `initialState` в состояние `AuthenticationInitial ()`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_initial_state.dart.md ':include')

Теперь все, что осталось это реализовать `mapEventToState`.

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc_map_event_to_state.dart.md ':include')

Великолепно! Наш финальный `AuthenticationBloc` должен выглядеть так:

[authentication_bloc.dart](../_snippets/flutter_login_tutorial/authentication_bloc.dart.md ':include')

Теперь, когда наш `AuthenticationBloc` полностью реализован, давайте приступим к работе на уровне представления.

## Экран заставки

Первое, что нам понадобится - это виджет `SplashPage`, который будет служить нашией заставкой, а наш `AuthenticationBloc` определяет, вошел ли пользователь в систему или нет.

[splash_page.dart](../_snippets/flutter_login_tutorial/splash_page.dart.md ':include')

## Домашняя страница

Затем нам нужно создать нашу `HomePage`, чтобы мы могли перенаправить пользователя на нее после успешного входа в систему.

[home_page.dart](../_snippets/flutter_login_tutorial/home_page.dart.md ':include')

?> **Примечание**: Это первый класс, в котором мы используем `flutter_bloc`. Мы коротко затронем `BlocProvider.of<AuthenticationBloc>(context)` выражение, но пока нам достаточно знать, что это позволит нашему `HomePage` получить доступ к `AuthenticationBloc`.

?> **Примечание**: мы добавляем событие `AuthenticationLoggedOut` к нашему `AuthenticationBloc`, когда пользователь нажимает кнопку выхода из системы.

Далее нам нужно создать `LoginPage` и `LoginForm`.

Поскольку `LoginForm` будет обрабатывать ввод пользователя (нажатие кнопки входа) и иметь некоторую бизнес-логику (получение токена для заданного имени пользователя/пароля), нам нужно будет создать `LoginBloc`.

Как и в случае с `AuthenticationBloc`, нам нужно определить `LoginState` и `LoginEvents`. Давайте начнем с `LoginState`.

## Login состояния

[login_state.dart](../_snippets/flutter_login_tutorial/login_state.dart.md ':include')

Состояния могут выглядет так:

- `LoginInitial` - является начальным состоянием LoginForm.
- `LoginInProgress` - состояние LoginForm, когда мы проверяем учетные данные
- `LoginFailure` - состояние LoginForm, когда попытка входа не удалась.

Теперь, когда мы определили `LoginState`, давайте взглянем на класс `LoginEvent`.

## Login события

[login_event.dart](../_snippets/flutter_login_tutorial/login_event.dart.md ':include')

`LoginButtonPressed` будет добавлено, когда пользователь нажал кнопку входа в систему. Это сообщит `LoginBloc`, что ему необходимо запросить токен для заданных учетных данных.

Теперь мы можем реализовать наш `LoginBloc`.

## Login блок

[login_bloc.dart](../_snippets/flutter_login_tutorial/login_bloc.dart.md ':include')

?> **Примечание**: `LoginBloc` зависит от `UserRepository` для аутентификации пользователя с использованием имени пользователя и пароля.

?> **Примечание**: `LoginBloc` зависит от `AuthenticationBloc` для обновления `AuthenticationState`, когда пользователь ввел действительные учетные данные.

Теперь, когда у нас есть `LoginBloc`, мы можем начать работать с `LoginPage` и `LoginForm`.

## Login страница

Виджет `LoginPage` будет служить нашим контейнерным виджетом и предоставит необходимые зависимости для виджета `LoginForm` (`LoginBloc` и `AuthenticationBloc`).

[login_page.dart](../_snippets/flutter_login_tutorial/login_page.dart.md ':include')

?> **Примечание**: `LoginPage` является `StatelessWidget`. Виджет `LoginPage` использует виджет `BlocProvider` для создания, закрытия и предоставления `LoginBloc` для поддерева.

?> **Примечание**: мы используем введенный `UserRepository` для создания нашего `LoginBloc`.

?> **Примечание**: Мы снова используем `BlocProvider.of<AuthenticationBloc>(context)` для доступа к `AuthenticationBloc` из `LoginPage`.

Далее, давайте продолжим и создадим нашу `LoginForm`.

## Login форма

[login_form.dart](../_snippets/flutter_login_tutorial/login_form.dart.md ':include')

?> **Примечание**: наша `LoginForm` использует виджет `BlocBuilder`, чтобы он мог перестраиваться при появлении нового `LoginState`. `BlocBuilder` это виджет Flutter, для которого требуется блок и функция построения. `BlocBuilder` обрабатывает создание виджета в ответ на новые состояния. `BlocBuilder` очень похож на `StreamBuilder`, но имеет более простой API для уменьшения необходимого количества стандартного кода с различными оптимизациями по производительности.

В виджете `LoginForm` больше ничего не происходит, поэтому давайте перейдем к созданию индикатора загрузки.

## Индикатор загрузки

[loading_indicator.dart](../_snippets/flutter_login_tutorial/loading_indicator.dart.md ':include')

Теперь пришло время собрать все вместе и создать наш основной виджет приложения в `main.dart`.

## Собираем все вместе

[main.dart](../_snippets/flutter_login_tutorial/main.dart.md ':include')

?> **Примечание**: опять же, мы используем `BlocBuilder`, чтобы реагировать на изменения в `AuthenticationState`, чтобы мы могли показать пользователю либо `SplashPage`, `LoginPage`, `HomePage`, либо `LoadingIndicator` на основе текущего `AuthenticationState`.

?> **Примечание**: Наше приложение обернуто в `BlocProvider`, который делает наш экземпляр `AuthenticationBloc` доступным для всего поддерева виджетов. `BlocProvider` это виджет Flutter, который предоставляет блок своим дочерним элементам через `BlocProvider.of(context)`. Он используется как виджет внедрения зависимостей (DI), так что один экземпляр блока может быть предоставлен нескольким виджетам в поддереве.

Теперь `BlocProvider.of<AuthenticationBloc>(context)` в нашем виджете `HomePage` и `LoginPage` должен иметь смысл.

Поскольку мы обернули наш `App` в `BlocProvider<AuthenticationBloc>`, мы можем получить доступ к экземпляру нашего `AuthenticationBloc`, используя статический метод `BlocProvider.of<AuthenticationBloc>(BuildContext context)` из любого места в поддереве.

На данный момент у нас есть довольно солидная реализация входа в систему и мы отделили наш уровень представления от уровня бизнес-логики с помощью `Bloc`.

Полный исходный код этого примера можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/flutter_login).
