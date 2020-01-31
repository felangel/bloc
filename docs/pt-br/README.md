<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="60" alt="Bloc" />

[![build](https://github.com/felangel/bloc/workflows/build/badge.svg)](https://github.com/felangel/bloc/actions)
[![codecov](https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg)](https://codecov.io/gh/felangel/bloc)
[![Star on GitHub](https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/felangel/bloc)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart)
[![Flutter.io](https://img.shields.io/badge/flutter-website-deepskyblue.svg)](https://flutter.io/docs/development/data-and-backend/state-mgmt/options#bloc--rx)
[![Awesome Flutter](https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true)](https://github.com/Solido/awesome-flutter#standard)
[![Flutter Samples](https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true)](http://fluttersamples.com)
[![Discord](https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue)](https://discord.gg/Hc5KD3g)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

---

Uma biblioteca previsível de gerenciamento de estado que ajuda a implementar o [padrão de projeto BLoC](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Visão geral

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

O objetivo dessa biblioteca é tornar fácil separar _apresentação_ da _lógica de negócio_, facilitando a testabilidade e reusabilidade.

## Documentação

- [Documentação oficial](https://felangel.github.io/bloc)
- [Package Bloc](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Package Flutter Bloc](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Package Angular Bloc](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Exemplos

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/fluttercountertutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_counter.gif" width="200"/>
                </a>
            </td>            
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterinfinitelisttutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_infinite_list.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterfirebaselogintutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_firebase_login.gif" width="200" />
                </a>
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterangulargithubsearch">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_github_search.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/flutterweathertutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_weather.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://felangel.github.io/bloc/#/fluttertodostutorial">
                    <img src="https://felangel.github.io/bloc/assets/gifs/flutter_todos.gif" width="200"/>
                </a>
            </td>
        </tr>
    </table>
</div>

### Dart

- [Contador](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - exemplo de como criar um `CounterBloc` (dart puro).

### Flutter

- [Counter](https://felangel.github.io/bloc/#/fluttercountertutorial) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app.
- [Form Validation](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - an example of how to use the `bloc` and `flutter_bloc` packages to implement form validation.
- [Bloc with Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - an example of how to hook up a `bloc` to a `Stream` and update the UI in response to data from the `Stream`.
- [Infinite List](https://felangel.github.io/bloc/#/flutterinfinitelisttutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement an infinite scrolling list.
- [Login Flow](https://felangel.github.io/bloc/#/flutterlogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow.
- [Firebase Login](https://felangel.github.io/bloc/#/flutterfirebaselogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement login via Firebase.
- [Github Search](https://felangel.github.io/bloc/#/flutterangulargithubsearch) - an example of how to create a Github Search Application using the `bloc` and `flutter_bloc` packages.
- [Weather](https://felangel.github.io/bloc/#/flutterweathertutorial) - an example of how to create a Weather Application using the `bloc` and `flutter_bloc` packages. The app uses a `RefreshIndicator` to implement "pull-to-refresh" as well as dynamic theming.
- [Todos](https://felangel.github.io/bloc/#/fluttertodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages.
- [Timer](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - an example of how to create a Timer using the `bloc` and `flutter_bloc` packages.
- [Firestore Todos](https://felangel.github.io/bloc/#/flutterfirestoretodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages that integrates with cloud firestore.
- [Shopping Cart](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - an example of how to create a Shopping Cart Application using the `bloc` and `flutter_bloc` packages based on [flutter samples](https://github.com/flutter/samples/tree/master/provider_shopper).

### Web

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - an example of how to use a `CounterBloc` in an AngularDart app.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

### Flutter + Web

- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search) - an example of how to create a Github Search Application and share code between Flutter and AngularDart.

## Articles

- [bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - An intro to the bloc package with high level architecture and examples.
- [login tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - How to create a full login flow using the bloc and flutter_bloc packages.
- [unit testing with bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - How to unit test the blocs created in the flutter login tutorial.
- [infinite list tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - How to create an infinite list using the bloc and flutter_bloc packages.
- [code sharing with bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - How to share code between a mobile application written with Flutter and a web application written with AngularDart.
- [weather app tutorial with flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - How to build a weather app which supports dynamic theming, pull-to-refresh, and interacting with a REST API using the bloc and flutter_bloc packages.
- [todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - How to build a todos app using the bloc and flutter_bloc packages.
- [firebase login tutorial with flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - How to create a fully functional login/sign up flow using the bloc and flutter_bloc packages with Firebase Authentication and Google Sign In.
- [flutter timer tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - How to create a timer app using the bloc and flutter_bloc packages.
- [firestore todos tutorial with flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - How to create a todos app using the bloc and flutter_bloc packages that integrates with cloud firestore.

## Extensions

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - extends IntelliJ/Android Studio with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - extends VSCode with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps.

## Community

Learn more at the following links, which have been contributed by the community.

### Packages

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - An extension to the `bloc` state management library which automatically persists and restores `bloc` states, by [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - A port of the `bloc` state management library from Dart to JavaScript, by [Felix Angelov](https://github.com/felangel).
- [Flutter Bloc Extensions](https://pub.dev/packages/flutter_bloc_extensions) - Collection of helper widgets built on top of `flutter_bloc`, by [Ondřej Kunc](https://github.com/OndrejKunc).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - A code generator that makes working with bloc easier, by [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - A Web, Mobile Firebase Auth Plugin, by [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - An easy way to create forms with BLoC pattern without writing a lot of boilerplate code, by [Giancarlo](https://github.com/GiancarloCode).

### Video Tutorials

- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=LeLrsnHeCZY) - Introduction to the Bloc Library, by [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - How to build a Youtube Search app which interacts with an API using the bloc and flutter_bloc packages, by [Reso Coder](https://resocoder.com).
- [Bloc Library (Updated) – Painless State Management for Flutter](https://www.youtube.com/watch?v=nQMfaQeCL6M) - Updated Tutorial on the Bloc Library, [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Updated Tutorial on the Flutter Bloc Package, by [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutorial on how to use the flutter_bloc package to implement dynamic theming, by [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutorial on how to use the hydrated_bloc package to automatically persist app state, by [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Introduction to state management using the flutter_bloc package, by [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - How to build a Football Player Search app which interacts with an API using the bloc and flutter_bloc packages, by [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Learning the flutter_bloc package live, by [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)

## Maintainers

- [Felix Angelov](https://github.com/felangel)
