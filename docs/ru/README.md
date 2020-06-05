<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="60" alt="Bloc" />

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/felangel/bloc)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Flutter Website](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

Предсказуемая библиотека управления состоянием, которая помогает реализовать [BLoC design pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Обзор

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

Цель этой библиотеки - упростить разделение _представления_ от _бизнес логики_, облегчая тестируемость с возможностю повторного использования.

## Документация

- [Официальная документация](https://bloclibrary.dev)
- [Пакет Bloc](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Пакет Flutter Bloc](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Пакет Angular Bloc](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Миграция

- [Upgrade from v0.x to v2.x ](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Примеры

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/fluttercountertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_counter.gif" width="200"/>
                </a>
            </td>            
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/flutterinfinitelisttutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_infinite_list.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/flutterfirebaselogintutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_firebase_login.gif" width="200" />
                </a>
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/flutterangulargithubsearch">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_github_search.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/flutterweathertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_weather.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/ru/fluttertodostutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_todos.gif" width="200"/>
                </a>
            </td>
        </tr>
    </table>
</div>

### Dart

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - пример как создать CounterBloc (чистый dart).

### Flutter

- [Counter](https://bloclibrary.dev/#/ru/fluttercountertutorial) - пример как создать CounterBloc для реализации классического приложения Flutter Counter.
- [Form Validation](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - пример использования пакетов `bloc` и `flutter_bloc` для реализации проверки формы.
- [Bloc with Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - пример как подключить `Bloc` к `Stream` и обновить пользовательский интерфейс в ответ на данные из `Stream`.
- [Infinite List](https://bloclibrary.dev/#/ru/flutterinfinitelisttutorial) - пример использования пакетов `bloc` и `flutter_bloc` по реализации прокрутки бесконечного списка.
- [Login Flow](https://bloclibrary.dev/#/ru/flutterlogintutorial) - пример использования пакетов `bloc` и `flutter_bloc` по реализации входа в систему.
- [Firebase Login](https://bloclibrary.dev/#/ru/flutterfirebaselogintutorial) - пример использования пакетов `bloc` и `flutter_bloc` для входа в систему Firebase.
- [Github Search](https://bloclibrary.dev/#/ru/flutterangulargithubsearch) - пример как создать поисковое приложение Github с использованием пакетов `bloc` и `flutter_bloc`.
- [Weather](https://bloclibrary.dev/#/ru/flutterweathertutorial) - пример как создать приложение Weather с использованием пакетов `bloc` и `flutter_bloc`. Приложение использует `RefreshIndicator` для реализации "pull-to-refresh", а также динамическое создание тем.
- [Todos](https://bloclibrary.dev/#/ru/fluttertodostutorial) - пример как создать приложение Todos с использованием пакетов `bloc` и `flutter_bloc`.
- [Timer](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - пример как создать Timer, используя пакеты `bloc` и `flutter_bloc`.
- [Firestore Todos](https://bloclibrary.dev/#/ru/flutterfirestoretodostutorial) - пример как создать приложение Todos, используя пакеты `bloc` и `flutter_bloc`, которые интегрируются с облачным сервисом Firestore.
- [Shopping Cart](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - пример как создать приложение Shopping Cart с использованием пакетов `bloc` и `flutter_bloc` на основе [Flutter Samples](https://github.com/flutter/samples/tree/master/provider_shopper).
- [Dynamic Form](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - пример использования пакетов `bloc` и `flutter_bloc` по реализации динамической формы, которая извлекает данные из хранилища.

### Web

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - пример как использовать CounterBloc в приложении AngularDart.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - пример как создать поисковое приложение Github с использованием пакетов `bloc` и `angular_bloc`.

### Flutter + Web

- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search) - пример создания поискового приложения Github с разделяемым кодом между Flutter и AngularDart.

## Статьи

- [bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - введение в пакет `bloc` с высокоуровневой архитектурой и примерами.
- [login tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - Как создать полный цикл входа в систему с помощью пакетов `bloc` и `flutter_bloc`.
- [unit testing with bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - как выполнить модульное тестирование блоков, созданных в руководстве по входу в систему.
- [infinite list tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - как создать бесконечный список, используя пакеты `bloc` и `flutter_bloc`.
- [code sharing with bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - как разделять код между мобильным приложением, написанным на Flutter, и веб-приложением, написанным на AngularDart.
- [weather app tutorial with flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - как создать приложение Weather, которое поддерживает динамическое создание тем, обновление и взаимодействие с REST API с использованием пакетов `bloc` и `flutter_bloc`.
- [todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - как создать приложение Todos, используя пакеты `bloc` и `flutter_bloc`.
- [firebase login tutorial with flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - как создать полный функционал по входу/регистрации, используя пакеты `bloc` и `flutter_bloc` с Firebase Authentication и Google Sign In.
- [flutter timer tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - как создать приложение Timer с использованием пакетов `bloc` и `flutter_bloc`.
- [firestore todos tutorial with flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - как создать приложение Todos, используя пакеты `bloc` и `flutter_bloc`, которое интегрировано с облачным сервисом Firestore.

## Расширения

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - расширяет IntelliJ/Android Studio поддержкой библиотеки `Bloc` и предоставляет инструменты для эффективного создания блоков для приложений Flutter и AngularDart.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - расширяет VSCode поддержкой библиотеки `Bloc` и предоставляет инструменты для эффективного создания блоков для приложений Flutter и AngularDart.

## Сообщество

Узнайте больше по следующим ссылкам, которые были предоставлены сообществом.

### Пакеты

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - расширение библиотеки управления состояниями `bloc`, которая автоматически сохраняет и восстанавливает состояния `bloc` [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - порт библиотеки управления состоянием `bloc` из Dart в JavaScript [Felix Angelov](https://github.com/felangel).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - генератор кода, который облегчает работу с блоком [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - A Web, Mobile Firebase Auth Plugin, by [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - простой способ создания форм с шаблоном BLoC без написания большого количества стандартного кода [Giancarlo](https://github.com/GiancarloCode).

### Видео руководства

- [Bloc Library: Basics and Beyond 🚀](https://youtu.be/knMvKPKBzGE) - Talk given at [Flutter Europe](https://fluttereurope.dev) about the basics of the bloc library, by [Felix Angelov](https://github.com/felangel).
- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=hTExlt1nJZI) - введение в библиотеку `Bloc` [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - как создать приложение поиска Youtube, которое взаимодействует с API с помощью пакетов `bloc` и `flutter_bloc` [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - обновленное руководство по Flutter Bloc package [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - руководство по использованию `flutter_bloc` пакета по реализации динамических тем [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - руководство по использованию пакета `hydrated_bloc` для автоматического сохранения состояния приложения [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - введение в управление состоянием с использованием пакета `flutter_bloc` [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - как создать приложение для поиска футболиста, которое взаимодействует с API с помощью пакетов `bloc` и `flutter_bloc` [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - изучение пакета `flutter_bloc` в режиме реального времени [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - руководство по модульному тестированию `bloc` с использованием пакета `bloc_test` [Reso Coder](https://resocoder.com).

### Расширения

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - расширение VSCode, основанное на руководствах по чистой архитектуре [Reso Coder](https://resocoder.com), которое помогает быстро создавать новые шаблоны [Kiritchouk Clément](https://github.com/KiritchoukC).

## Сопровождающие

- [Felix Angelov](https://github.com/felangel)
