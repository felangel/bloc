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

一个可预测并控制状态的库来实现 [处理组件间业务逻辑(BLoC)的设计模式](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## 总览

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

本库的目的是用来轻松实现将逻辑层从展示层中分离，促进其可测试性和复用性。

## 文档

- [官方文档](https://bloclibrary.dev)
- [Bloc Package的文档](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Flutter Bloc Package的文档](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Angular Bloc Package的文档](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## 版本迁移

- [从v0.x版本 升级到 v2.x版本](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## 范例：

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

- [计数器](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - 一个制作计数器的示例 (纯 dart).

### Flutter

- [计数器](https://bloclibrary.dev/#/fluttercountertutorial) - 使用Flutter制作一个 经典`计数器Bloc` 的示例
- [表单验证（Form Validation)](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) -  如何使用 `bloc`和`flutter_bloc`的包来实现表单验证的示例
- [Bloc 和 Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - 如何将 `bloc`和`stream`相互关联并且实时更新界面，这里使用的数据是来自 `Stream`的
- [无限列表](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - 如何使用`bloc`和`flutter_bloc`的包来实现一个无限可滚动的列表的示例
- [登陆流程](https://bloclibrary.dev/#/flutterlogintutorial) - 一个使用`bloc`和`flutter_bloc`的包来实现的登陆流程的示例
- [使用Firebase实现登陆](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - 如何使用`bloc`和`flutter_bloc`的包来实现通过Firebase登陆的示例
- [Github 搜索](https://bloclibrary.dev/#/flutterangulargithubsearch) - 如何使用`bloc`和`flutter_bloc`的包来制作一个Github搜索程序的示例
- [天气预报](https://bloclibrary.dev/#/flutterweathertutorial) - 如何使用`bloc`和`flutter_bloc`的包来制作一个天气预报的程序， 这个程序使用了`RefreshIndicator`从而实现了“下拉更新”，同时还有动态主题展示。
- [备忘录](https://bloclibrary.dev/#/fluttertodostutorial) - 如何使用`bloc`和`flutter_bloc`的包来制作一个备忘录程序的示例
- [计时器](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - 如何使用`bloc`和`flutter_bloc`的包来制作一个计时器的示例
- [使用 Firebase 制作备忘录](https://bloclibrary.dev/#/flutterfirestoretodostutorial) - 如何使用`bloc`和`flutter_bloc`的包并整合 Firebase 来制作一个备忘录程序的示例
- [购物车](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - 如何使用 `bloc` 和 `flutter_bloc`的包来制作一个购物车的示例 - 可参考(https://github.com/flutter/samples/tree/master/provider_shopper)
- [动态表单（Dynamic Form )](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - 如何使用`bloc`和`flutter_bloc`的包来实现动态表单从而使得表单中的数据来自于一个存储库

### Web

- [计数器](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - 在一个 `AngularDart`的程序中如何使用 `CounterBloc`
- [Github 搜索](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - 如何使用 `bloc` 和 `angular_bloc` 的包来实现一个Github搜索的程序

### Flutter + Web 

- [Github 搜索](https://github.com/felangel/Bloc/tree/master/examples/github_search) - 如何创建一个Github搜索的程序并且将其代码分享于 Flutter 和 AngularDart 之间

## 文章

- [bloc的包](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - 一篇介绍bloc包并有着高度的结构讲解和示例的文章
- [使用 flutter_bloc 的登陆教程](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - 如何使用`bloc`和`flutter_bloc`的包来创建一个完整的登陆流程的文章
- [单元测试和bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - 如何在`登陆教程`中做blocs的单元测试
- [无限列表的教程和 flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - 如何使用`bloc`和`flutter_bloc`的包来创建一个无限列表的教程
- [代码分享和bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - 如何在`Flutter`的移动端程序和`AngularDart`的网页程序中分享代码
- [天气预报程序的教程和 flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - 如何制作一个天气预报的程序使用`bloc`和`flutter_bloc`,这个程序支持动态主题现实，下拉更新以及响应一个`REST API`.
- [备忘录程序的教程和 flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - 如何使用`bloc`和`flutter_bloc`的包来制作一个备忘录的教程
- [Firebase 登陆的教程和 flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - 如何使用`bloc`和`flutter_bloc`的包来制作一个功能全面的用户注册登陆的程序，并且实现`Firebase验证`和`谷歌登陆`的教程
- [计时器教程和 flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - 如何使用`bloc`和`flutter_bloc`来制作一个计时器程序的教程
- [备忘录教程使用 Firebase 和 flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - 如何使用`bloc`和`flutter_bloc`的包并整合`Firebase`来制作一个备忘录的教程

## 插件

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - 扩展了`IntelliJ/Android Studio`的`Bloc`库和`providers`工具的插件支持，从而可以在`Flutter`和`AngularDart`的程序中更加便捷的使用`Blocs`
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - 扩展了VSCode的插件支持，从而可以在`Flutter`和`AngularDart`的程序中更加便捷的使用`Blocs`

## 社区

通过以下链接，了解更多关于社区的贡献

### 包

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - 对`bloc`状态管理库的扩展，该库可以自动保存并恢复`bloc`的状态,作者：[Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - `bloc`状态管理库的一部分，从Dart到JavaScript，作者：[Felix Angelov](https://github.com/felangel)
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - 一个代码生成工具将使用`bloc`变得更加简单，作者：[Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - 一个网页，移动端`Firebase`身份验证的插件,作者：[Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - 一个简单的方式在`bloc`的模式下创建表单，这样将避免大量的样板代码,作者：[Giancarlo](https://github.com/GiancarloCode).

### 视屏教程

- [Bloc Library: Basics and Beyond 🚀](https://youtu.be/knMvKPKBzGE) - [Felix Angelov](https://github.com/felangel)在 [Flutter Europe](https://fluttereurope.dev) 上关于基础Bloc库的讲座.
- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=hTExlt1nJZI) - 
Bloc库的教程, 作者： [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - 如何使用Bloc和flutter_bloc软件包构建与API交互的Youtube Search应用, 作者： [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Flutter Bloc软件包的更新教程, 作者： [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - 关于如何使用flutter_bloc包实现动态主题的教程, 作者： [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - 关于如何使用hydrated_bloc软件包自动保持应用状态的教程, 作者： [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - 使用flutter_bloc软件包进行状态管理的简介, 作者 [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - 如何构建使用bloc和flutter_bloc软件包与API交互的Football Player搜索应用, 作者： [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - 实时学习flutter_bloc软件包, 作者： [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - 有关如何使用bloc_test包对bloc进行单元测试的教程, 作者： [Reso Coder](https://resocoder.com).

### 扩展

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - 一个基于VSCode的插件，灵感来源于[Reso Coder's](https://resocoder.com) 干净的架构教程，可帮助快速搭建scaffold功能, 作者： [Kiritchouk Clément](https://github.com/KiritchoukC).

## 维护者

- [Felix Angelov](https://github.com/felangel)
