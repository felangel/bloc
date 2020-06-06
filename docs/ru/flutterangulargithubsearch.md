# Flutter + AngularDart Github поиск

![advanced](https://img.shields.io/badge/level-advanced-red.svg)

> В следующем руководстве мы создадим приложение Github Search во Flutter и AngularDart, чтобы продемонстрировать, как мы можем совместно использовать слои данных и бизнес-логики между двумя проектами.

![demo](../assets/gifs/flutter_github_search.gif)

![demo](../assets/gifs/angular_github_search.gif)

## Библиотека Common Github Search

> Библиотека Common Github Search будет содержать модели, поставщика данных, хранилище, а также блок, который будет использоваться совместно AngularDart и Flutter.

### Настройка

Мы начнем с создания нового каталога для нашего приложения.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup1.sh.md ':include')

Далее мы создадим каркас для библиотеки `common_github_search`.

[setup.sh](../_snippets/flutter_angular_github_search/common/setup2.sh.md ':include')

Нам нужно создать `pubspec.yaml` с необходимыми зависимостями.

[pubspec.yaml](../_snippets/flutter_angular_github_search/common/pubspec.yaml.md ':include')

Наконец, нам нужно установить все зависимости.

[pub_get.sh](../_snippets/flutter_angular_github_search/common/pub_get.sh.md ':include')

Вот и все по настройке проекта! Теперь мы можем приступить к созданию пакета `common_github_search`.

### Клиент

> `GithubClient` будет предоставлять необработанные данные из [Github API](https://developer.github.com/v3/).

?> **Примечание:** Вы можете увидеть пример того, как будут выглядеть данные, которые мы получаем обратно [здесь](https://api.github.com/search/repositories?q=dartlang).

Давайте создадим `github_client.dart`.

[github_client.dart](../_snippets/flutter_angular_github_search/common/github_client.dart.md ':include')

?> **Примечание:** `GithubClient` просто делает сетевой запрос к API поиска GitHub в репозитории и преобразовывает результат в `SearchResult` или `SearchResultError` как `Future`.

Далее нам нужно определить наши модели `SearchResult` и `SearchResultError`.

#### Модель результатов поиска

Создайте файл `search_result.dart`.

[search_result.dart](../_snippets/flutter_angular_github_search/common/search_result.dart.md ':include')

?> **Примечание:** Реализация `SearchResult` зависит от `SearchResultItem.fromJson`, который мы еще не реализовали.

?> **Примечание:** мы не включаем свойства, которые не будут использоваться в нашей модели.

#### Элемент результатов поиска

Далее мы создадим `search_result_item.dart`.

[search_result_item.dart](../_snippets/flutter_angular_github_search/common/search_result_item.dart.md ':include')

?> **Примечание:** опять же, реализация `SearchResultItem` зависит от `GithubUser.fromJson`, который мы еще не реализовали.

#### Модель пользователя

Далее мы создадим `github_user.dart`.

[github_user.dart](../_snippets/flutter_angular_github_search/common/github_user.dart.md ':include')

На этом этапе мы завершили реализацию `SearchResult` и его зависимостей, поэтому далее мы перейдем к `SearchResultError`.

#### Модель ошибки результата поиска

Далее мы создадим `search_result_error.dart`.

[search_result_error.dart](../_snippets/flutter_angular_github_search/common/search_result_error.dart.md ':include')

`GithubClient` завершен, поэтому далее мы перейдем к `GithubCache`, который будет отвечать за [запоминание](https://en.wikipedia.org/wiki/Memoization) для оптимизации производительности.

### Кеш

> `GithubCache` будет отвечать за запоминание всех прошлых запросов, чтобы мы могли избежать ненужных сетевых запросов к Github API. Это также поможет улучшить производительность нашего приложения.

Создадим `github_cache.dart`.

[github_cache.dart](../_snippets/flutter_angular_github_search/common/github_cache.dart.md ':include')

Теперь мы готовы создать наш `GithubRepository`!

### Хранилище

> Репозиторий Github отвечает за создание абстракции между уровнем данных (`GithubClient`) и уровнем бизнес-логики (`Bloc`). Это также то место, где мы собираемся использовать наш `GithubCache`.

Создайте `github_repository.dart`.

[github_repository.dart](../_snippets/flutter_angular_github_search/common/github_repository.dart.md ':include')

?> **Примечание:** `GithubRepository` зависит от `GithubCache` и `GithubClient` и абстрагирует базовую реализацию. Наше приложение никогда не должно знать о том, как данные извлекаются или откуда они поступают поскольку это не должно волновать. Мы можем изменить работу репозитория в любое время и до тех пор, пока мы не изменим интерфейс, нам не нужно менять какой-либо клиентский код.

На этом этапе мы завершили уровень поставщика данных и уровень хранилища, поэтому мы готовы перейти к уровню бизнес-логики.

### Событие

> Наш блок будет уведомлен когда пользователь введет имя репозитория, которое мы будем представлять как `TextChanged` `GithubSearchEvent`.

Создайте `github_search_event.dart`.

[github_search_event.dart](../_snippets/flutter_angular_github_search/common/github_search_event.dart.md ':include')

?> **Примечание:** Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `GithubSearchEvent`; по умолчанию оператор равенства возвращает true, если и только если этот и другие являются одинаковыми экземплярами.

### Состояние

Уровень представления должен иметь несколько частей информации для правильного представления:

- `SearchStateEmpty` - сообщит уровню представления, что пользователь не предоставил информации
- `SearchStateLoading` - сообщит уровню представления, что он должен отображать индикатор загрузки
- `SearchStateSuccess` - сообщит уровню представления, что у него есть данные для представления

- `items`- будет `List<SearchResultItem>`, который будет отображаться

- `SearchStateError` - сообщит уровню представления, что при загрузке репозиториев произошла ошибка

- `error`- будет точной ошибкой, которая произошла

Теперь мы можем создать `github_search_state.dart` и реализовать его следующим образом.

[github_search_state.dart](../_snippets/flutter_angular_github_search/common/github_search_state.dart.md ':include')

?> **Note:** We extend [`Equatable`](https://pub.dev/packages/equatable) so that we can compare instances of `GithubSearchState`; by default, the equality operator returns true if and only if this and other are the same instance.

Now that we have our Events and States implemented, we can create our `GithubSearchBloc`.

?> **Примечание:** Мы расширяем [`Equatable`](https://pub.dev/packages/equatable), чтобы мы могли сравнивать экземпляры `GithubSearchState`; по умолчанию оператор равенства возвращает true, если и только если этот и другие являются одинаковыми экземплярами.

Теперь, когда у нас реализованы наши `Events` и `States`, мы можем создать наш `GithubSearchBloc`.

### Блок

Создадим `github_search_bloc.dart`

[github_search_bloc.dart](../_snippets/flutter_angular_github_search/common/github_search_bloc.dart.md ':include')

?> **Примечание:** `GithubSearchBloc` преобразует `GithubSearchEvent` в `GithubSearchState` и зависит от `GithubRepository`.

?> **Примечание:** Мы переопределяем метод `transformEvents` для [debounce](http://reactivex.io/documentation/operators/debounce.html) `GithubSearchEvents`.

?> **Примечание:** Мы переопределяем `onTransition` для логирования каждый раз, когда происходит изменение состояния.

Потрясающие! Мы все сделали с пакетом `common_github_search`.

Готовый продукт должен выглядеть [следующим образом](https://github.com/felangel/Bloc/tree/master/examples/github_search/common_github_search).

Далее мы будем работать над реализацией Flutter.

## Flutter Github поиск

> Flutter Github Search будет приложением Flutter, которое повторно использует модели, поставщиков данных, репозитории и блоки из `common_github_search` для реализации Github Search.

### Настройка

Начнем с создания нового проекта Flutter в каталоге `github_search` на том же уровне, что и `common_github_search`.

[flutter_create.sh](../_snippets/flutter_angular_github_search/flutter/flutter_create.sh.md ':include')

Далее нам нужно обновить `pubspec.yaml`, чтобы включить все необходимые зависимости.

[pubspec.yaml](../_snippets/flutter_angular_github_search/flutter/pubspec.yaml.md ':include')

?> **Примечание:** Мы включаем вновь созданную библиотеку `common_github_search` в качестве зависимости.

Теперь нам нужно установить зависимости.

[flutter_packages_get.sh](../_snippets/flutter_angular_github_search/flutter/flutter_packages_get.sh.md ':include')

Это все для настройки проекта и, поскольку пакет `common_github_search` содержит уровень данных, а также уровень бизнес-логики все, что нам нужно построить - это уровень представления.

### Форма поиска

Нам нужно создать форму с виджетом `SearchBar` и `SearchBody`.

- `SearchBar` будет отвечать за ввод данных пользователем.
- `SearchBody` будет отвечать за отображение результатов поиска, индикаторов загрузки и ошибок.

Давайте создадим `search_form.dart`.

> `SearchForm` будет `StatelessWidget`, который отображает виджеты `SearchBar` и `SearchBody`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form.dart.md ':include')

Далее мы реализуем `_SearchBar`.

### Панель поиска

> `SearchBar` также будет `StatefulWidget`, потому что ему нужно будет поддерживать свой собственный `TextController`, чтобы мы могли отслеживать, что пользователь ввел в качестве ввода.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_bar.dart.md ':include')

?> **Примечание:** `_SearchBar` обращается к `GitHubSearchBloc` через `BlocProvider.of<GithubSearchBloc>(context)` и уведомляет блок о событиях `TextChanged`.

Мы закончили с `_SearchBar`, теперь начнем `_SearchBody`.

### Тело поиска

> `SearchBody` - это StatelessWidget, который будет отвечать за отображение результатов поиска, ошибок и индикаторов загрузки. Это будет потребитель `GithubSearchBloc`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_body.dart.md ':include')

?> **Примечание:** `_SearchBody` также обращается к `GithubSearchBloc` через `BlocProvider` и использует `BlocBuilder` для перерендеринга в ответ на изменения состояния.

Если наше состояние равно `SearchStateSuccess`, мы отображаем `_SearchResults`, который мы будем реализовывать следующим.

### Результаты поиска

> `SearchResults` является `StatelessWidget`, который принимает `List<SearchResultItem>` и отображает их в виде списка `SearchResultItems`.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_results.dart.md ':include')

?> **Примечание:** Мы используем `ListView.builder`, чтобы создать прокручиваемый список `SearchResultItem`.

Пришло время реализовать `_SearchResultItem`.

### Элемент результата поиска

> `SearchResultItem` является `StatelessWidget` и отвечает за отображение информации для одного результата поиска. Он также отвечает за обработку взаимодействия с пользователем и переход к URL-адресу хранилища по касанию пользователя.

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_result_item.dart.md ':include')

?> **Примечание:** мы используем пакет [url_launcher](https://pub.dev/packages/url_launcher) для доступа к внешним URL.

### Собираем все вместе

На данный момент `search_form.dart` должен выглядеть так:

[search_form.dart](../_snippets/flutter_angular_github_search/flutter/search_form_complete.dart.md ':include')

Теперь осталось только реализовать основное приложение в `main.dart`.

[main.dart](../_snippets/flutter_angular_github_search/flutter/main.dart.md ':include')

?> **Примечание:** `GithubRepository` создается в `main` и внедряется в `App`. `SearchForm` обернута в `BlocProvider`, который отвечает за инициализацию, закрытие и обеспечение доступности экземпляра `GithubSearchBloc` для виджета `SearchForm` и его дочерних элементов.

Вот и все, что нужно сделать! Теперь мы успешно внедрили поисковое приложение Github на Flutter, используя пакеты [bloc](https://pub.dev/packages/bloc) и [flutter_bloc](https://pub.dev/packages/flutter_bloc) и мы успешно отделили наш уровень представления от нашей бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search/flutter_github_search).

Наконец, мы собираемся создать наше приложение AngularDart Github Search.

## AngularDart Github поиск

> AngularDart Github Search будет приложением AngularDart, которое повторно использует модели, поставщиков данных, репозитории и блоки из `common_github_search` для реализации Github Search.

### Настройка

Нам нужно начать с создания нового проекта AngularDart в каталоге `github_search` на том же уровне, что и `common_github_search`.

[stagehand.sh](../_snippets/flutter_angular_github_search/angular/stagehand.sh.md ':include')

!> Активируйте `stagehand`, запустив `pub global activate stagehand`

Затем мы можем заменить содержимое `pubspec.yaml` на:

[pubspec.yaml](../_snippets/flutter_angular_github_search/angular/pubspec.yaml.md ':include')

### Форма поиска

Как и в приложении Flutter, нам нужно создать `SearchForm` с компонентами `SearchBar` и `SearchBody`.

> Компонент `SearchForm` будет реализовывать `OnInit` и `OnDestroy`, потому что ему нужно будет создать и закрыть `GithubSearchBloc`.

- `SearchBar` будет отвечать за ввод данных пользователем.
- `SearchBody` будет отвечать за отображение результатов поиска, индикаторов загрузки и ошибок.

Давайте создадим `search_form_component.dart`.

[search_form_component.dart](../_snippets/flutter_angular_github_search/angular/search_form_component.dart.md ':include')

?> **Примечание:** `GithubRepository` внедряется в `SearchFormComponent`.

?> **Примечание:** `GithubSearchBloc` создается и закрывается с помощью `SearchFormComponent`.

Шаблон `search_form_component.html` будет выглядеть так:

[search_form_component.html](../_snippets/flutter_angular_github_search/angular/search_form_component.html.md ':include')

Далее мы реализуем компонент `SearchBar`.

### Панель поиска

> SearchBar - это компонент, который будет отвечать за ввод данных пользователем и уведомлять `GithubSearchBloc` об изменениях текста.

Создадим `search_bar_component.dart`.

[search_bar_component.dart](../_snippets/flutter_angular_github_search/angular/search_bar_component.dart.md ':include')

?> **Примечание:** `SearchBarComponent` зависит от `GitHubSearchBloc`, поскольку он отвечает за уведомление блока о событиях `TextChanged`.

Далее мы можем создать `search_bar_component.html`.

[search_bar_component.html](../_snippets/flutter_angular_github_search/angular/search_bar_component.html.md ':include')

Мы закончили с `SearchBar`, теперь займемся `SearchBody`.

### Тело поиска

> `SearchBody` - это компонент, который будет отвечать за отображение результатов поиска, ошибок и индикаторов загрузки. Это будет потребитель `GithubSearchBloc`.

Создадим `search_body_component.dart`

[search_body_component.dart](../_snippets/flutter_angular_github_search/angular/search_body_component.dart.md ':include')

?> **Примечание:** `SearchBodyComponent` зависит от `GithubSearchState`, который предоставляется `GithubSearchBloc` с использованием блока `angular_bloc`.

Создадим `search_body_component.html`

[search_body_component.html](../_snippets/flutter_angular_github_search/angular/search_body_component.html.md ':include')

Если наше состояние `isSuccess`, мы визуализируем `SearchResults`, который мы будем реализовывать следующим.

### Результаты поиска

> `SearchResults` - это компонент, который берет `List<SearchResultItem>` и отображает в виде списка `SearchResultItems`.

Создадим `search_results_component.dart`

[search_results_component.dart](../_snippets/flutter_angular_github_search/angular/search_results_component.dart.md ':include')

Далее мы создадим `search_results_component.html`.

[search_results_component.html](../_snippets/flutter_angular_github_search/angular/search_results_component.html.md ':include')

?> **Примечание:** мы используем `ngFor`, чтобы создать список компонентов `SearchResultItem`.

Пришло время реализовать `SearchResultItem`.

### Элемент результата поиска

> `SearchResultItem` - это компонент, который отвечает за отображение информации для одного результата поиска. Он также отвечает за обработку взаимодействия с пользователем и переход к URL-адресу хранилища по касанию пользователя.

Создадим `search_result_item_component.dart`.

[search_result_item_component.dart](../_snippets/flutter_angular_github_search/angular/search_result_item_component.dart.md ':include')

и соответствующий шаблон в `search_result_item_component.html`.

[search_result_item_component.html](../_snippets/flutter_angular_github_search/angular/search_result_item_component.html.md ':include')

### Собираем все вместе

У нас есть все компоненты и теперь пришло время собрать их все вместе в `app_component.dart`.

[app_component.dart](../_snippets/flutter_angular_github_search/angular/app_component.dart.md ':include')

?> **Примечание:** мы создаем `GithubRepository` в `AppComponent` и внедряем его в компонент `SearchForm`.

Вот и все, что нужно сделать! Теперь мы успешно внедрили поисковое приложение Github в AngularDart с использованием пакетов `bloc` и `angular_bloc` и успешно отделили уровень представления от бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search).

## Резюме

В этом руководстве мы создали приложение Flutter и AngularDart, в то же время обмениваясь всеми моделями, поставщиками данных и блоками.

Единственной вещью, которую мы фактически должны были написать дважды, был уровень представления (UI), который является удивительным с точки зрения эффективности и скорости разработки. Кроме того, веб-приложения и мобильные приложения довольно часто имеют разные пользовательские интерфейсы и стили и этот подход действительно демонстрирует, насколько легко создавать два приложения, которые выглядят совершенно по-разному, но имеют одни и те же слои данных и бизнес-логики.

Полный исходный код можно найти [здесь](https://github.com/felangel/Bloc/tree/master/examples/github_search).
