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

A predictable state management library that helps implement the 一个可预测并控制状态的库用来实现 [BLoC design pattern 设计模式](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Overview 总览

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

The goal of this library is to make it easy to separate _presentation_ from _business logic_, facilitating testability and reusability. 本库的目的是用来轻松实现将逻辑层从展示层中分离，促进可测试性和复用性。

## Documentation 文档

- [Official Documentation 官方文档](https://bloclibrary.dev)
- [Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Flutter Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Angular Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Migration 迁移

- [Upgrade from v0.x to v2.x 从v0.x 升级到 v2.x](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Examples 例子：

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/fluttercountertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_counter.gif" width="200"/>
                </a>
            </td>            
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/flutterinfinitelisttutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_infinite_list.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/flutterfirebaselogintutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_firebase_login.gif" width="200" />
                </a>
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/flutterangulargithubsearch">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_github_search.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/flutterweathertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_weather.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/fluttertodostutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_todos.gif" width="200"/>
                </a>
            </td>
        </tr>
    </table>
</div>

### Dart

- [Counter 计数器](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - an example of how to create a `CounterBloc` 一个制作计数器的示例 (pure dart).

### Flutter

- [Counter 计数器](https://bloclibrary.dev/#/fluttercountertutorial) - an example of how to create a `CounterBloc` to implement the classic Flutter Counter app. 使用Flutter制作一个 经典`计数器Bloc` 的示例
- [Form Validation 表单验证（Form Validation）](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - an example of how to use the `bloc` and `flutter_bloc` packages to implement form validation. 如何使用 `bloc` 和 `flutter_bloc` 的包来实现表单验证的示例
- [Bloc with Stream Bloc 和 Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - an example of how to hook up a `bloc` to a `Stream` and update the UI in response to data from the `Stream`. 如何将 `bloc`和`stream`相互关联并且实时更新界面，这里使用的数据是来自 `Stream`的
- [Infinite List 无限列表](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement an infinite scrolling list. 如何使用 `bloc` 和 `flutter_bloc` 的包来实现一个无限可滚动的列表的示例
- [Login Flow 登陆流程](https://bloclibrary.dev/#/flutterlogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow. 一个使用 `bloc` 和 `flutter_bloc` 的包来实现的登陆流程示例
- [Firebase Login 使用Firebase的登陆](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement login via Firebase. 如何使用 `bloc` 和 `flutter_bloc`的包来实现通过firebase登陆的示例
- [Github Search Github 搜索](https://bloclibrary.dev/#/flutterangulargithubsearch) - an example of how to create a Github Search Application using the `bloc` and `flutter_bloc` packages. 如何使用 `bloc` 和 `flutter_bloc`的包来制作一个Github 搜索程序的示例
- [Weather 天气](https://bloclibrary.dev/#/flutterweathertutorial) - an example of how to create a Weather Application using the `bloc` and `flutter_bloc` packages. The app uses a `RefreshIndicator` to implement "pull-to-refresh" as well as dynamic theming. 如何使用 `bloc` 和 `flutter_bloc` 的包来制作一个天气预报的程序， 这个程序使用了 `RefreshIndicator` 从而实现了“下拉更新”，同时还有动态主题展示。
- [Todos 备忘录](https://bloclibrary.dev/#/fluttertodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages. 如何使用 `bloc` 和 `flutter_bloc`的包来制作一个备忘录程序的示例
- [Timer 计时器](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - an example of how to create a Timer using the `bloc` and `flutter_bloc` packages. 如何使用 `bloc` 和 `flutter_bloc` 的包来制作一个计时器的示例
- [Firestore Todos 使用 Firebase 制作备忘录](https://bloclibrary.dev/#/flutterfirestoretodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages that integrates with cloud firestore.  如何使用 `bloc` 和 `flutter_bloc`的包并整合 Firebase 来制作一个备忘录程序的示例
- [Shopping Cart 购物车](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - an example of how to create a Shopping Cart Application using the `bloc` and `flutter_bloc` packages based on [flutter samples](https://github.com/flutter/samples/tree/master/provider_shopper). 如何使用 `bloc` 和 `flutter_bloc`的包来制作一个购物车的示例
- [Dynamic Form 动态表单](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a dynamic form which pulls data from a repository. 如何使用 `bloc` 和 `flutter_bloc`的包来实现动态表单从而使得表单中的数据来自于一个存储库

### Web 网页

- [Counter 计数器](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - an example of how to use a `CounterBloc` in an AngularDart app. 如何使用 `CounterBloc`在一个 `AngularDart`的程序中
- [Github Search Github 搜索](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages. 如何使用 `bloc` 和 `angular_bloc` 的包来实现一个 Github搜索的程序

### Flutter + Web 

- [Github Search Github 搜索](https://github.com/felangel/Bloc/tree/master/examples/github_search) - an example of how to create a Github Search Application and share code between Flutter and AngularDart. 如何创建一个Github 搜索的程序并且将其代码分享于 Flutter 和 AngularDart 之间

## Articles 文章

- [bloc package bloc的包](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - An intro to the bloc package with high level architecture and examples. 一篇介绍bloc包并有着高度的结构讲解和示例的文章
- [login tutorial with flutter_bloc 用 flutter_bloc 的登陆教程](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - How to create a full login flow using the bloc and flutter_bloc packages. 如何使用 `bloc` 和 `flutter_bloc` 的包来创建一个完整的登陆流程的文章
- [unit testing with bloc 单元测试和bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - How to unit test the blocs created in the flutter login tutorial.   如何做blocs的单元测试在`登陆教程`的文章
- [infinite list tutorial with flutter_bloc 无限列表的教程和 flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - How to create an infinite list using the bloc and flutter_bloc packages. 如何使用`bloc`和`flutter_bloc`的包来创建一个无限列表的教程
- [code sharing with bloc 代码分享和bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - How to share code between a mobile application written with Flutter and a web application written with AngularDart. 如何在`Flutter`的移动端程序和`AngularDart`的网页程序中分享代码
- [weather app tutorial with flutter_bloc 天气预报程序的教程和 flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - How to build a weather app which supports dynamic theming, pull-to-refresh, and interacting with a REST API using the bloc and flutter_bloc packages. 如何制作一个天气预报的程序使用`bloc`和`flutter_bloc`,这个程序支持动态主题现实，下拉更新以及响应一个`REST API`.
- [todos app tutorial with flutter_bloc 备忘录程序的教程和 flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - How to build a todos app using the bloc and flutter_bloc packages. 如何使用`bloc`和`flutter_bloc`的包来制作一个备忘录的教程
- [firebase login tutorial with flutter_bloc | firebase 登陆的教程和 flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - How to create a fully functional login/sign up flow using the bloc and flutter_bloc packages with Firebase Authentication and Google Sign In. 如何使用`bloc`和`flutter_bloc`的包来制作一个功能全面的用户注册登陆的程序，并且实现`Firebase验证`和`谷歌登陆`的教程
- [flutter timer tutorial with flutter_bloc 计时器教程和 flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - How to create a timer app using the bloc and flutter_bloc packages. 如何使用`bloc`和`flutter_bloc`来制作一个计时器程序的教程
- [firestore todos tutorial with flutter_bloc 备忘录教程使用 Firebase 和 flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - How to create a todos app using the bloc and flutter_bloc packages that integrates with cloud firestore. 如何使用`bloc`和`flutter_bloc`的包并整合`Firebase`来制作一个备忘录的教程

## Extensions 插件

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - extends IntelliJ/Android Studio with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps. 扩展了IntelliJ/Android Studio的Bloc库和providers工具的插件支持，从而可以在`Flutter`和`AngularDart`的程序中更加便捷的使用`Blocs`
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - extends VSCode with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps. 扩展了VSCode的插件支持，从而可以在`Flutter`和`AngularDart`的程序中更加便捷的使用`Blocs`

## Community 社区

Learn more at the following links, which have been contributed by the community.
通过以下链接，了解更多关于社区的贡献

### Packages 包

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - An extension to the `bloc` state management library which automatically persists and restores `bloc` states, by [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - A port of the `bloc` state management library from Dart to JavaScript, by [Felix Angelov](https://github.com/felangel).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - A code generator that makes working with bloc easier, by [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - A Web, Mobile Firebase Auth Plugin, by [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - An easy way to create forms with BLoC pattern without writing a lot of boilerplate code, by [Giancarlo](https://github.com/GiancarloCode).

### Video Tutorials 视屏教程

- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=hTExlt1nJZI) - Introduction to the Bloc Library, by [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - How to build a Youtube Search app which interacts with an API using the bloc and flutter_bloc packages, by [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Updated Tutorial on the Flutter Bloc Package, by [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutorial on how to use the flutter_bloc package to implement dynamic theming, by [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutorial on how to use the hydrated_bloc package to automatically persist app state, by [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Introduction to state management using the flutter_bloc package, by [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - How to build a Football Player Search app which interacts with an API using the bloc and flutter_bloc packages, by [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Learning the flutter_bloc package live, by [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - Tutorial on how to unit test blocs using the bloc_test package, by [Reso Coder](https://resocoder.com).

### Extensions 扩展

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - A VSCode extension inspired by [Reso Coder's](https://resocoder.com) clean architecture tutorials, which helps quickly scaffold features, by [Kiritchouk Clément](https://github.com/KiritchoukC).

## Maintainers 维护者

- [Felix Angelov](https://github.com/felangel)
