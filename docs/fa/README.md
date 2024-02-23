<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

یک کتابخانه مدیریت وضعیت قابل پیش‌بینی که به پیاده‌سازی الگوی طراحی BLoC کمک می‌کند. [الگوی طراحی BLoC](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).


| Package                                                                                    | Pub                                                                                                                  |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                         | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                               |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)               | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)                     |
| [bloc_concurrency](https://github.com/felangel/bloc/tree/master/packages/bloc_concurrency) | [![pub package](https://img.shields.io/pub/v/bloc_concurrency.svg)](https://pub.dev/packages/bloc_concurrency)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc)         | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc)               |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc)         | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc)               |
| [hydrated_bloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc)       | [![pub package](https://img.shields.io/pub/v/hydrated_bloc.svg)](https://pub.dev/packages/hydrated_bloc)             |
| [replay_bloc](https://github.com/felangel/bloc/tree/master/packages/replay_bloc)           | [![pub package](https://img.shields.io/pub/v/replay_bloc.svg)](https://pub.dev/packages/replay_bloc)                 |
| [sealed_flutter_bloc](https://github.com/felangel/sealed_flutter_bloc)                     | [![pub package](https://img.shields.io/pub/v/sealed_flutter_bloc.svg)](https://pub.dev/packages/sealed_flutter_bloc) |

---

## حامیان

حامیان برتر ما در زیر نشان داده شده اند! [[اسپانسر شوید](https://github.com/sponsors/felangel)]

<table>
    <tbody>
        <tr>
            <td align="center" style="background-color: white">
                <a href="https://verygood.ventures"><img src="https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png" width="225"/></a>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://www.miquido.com/flutter-development-company/?utm_source=github&utm_medium=sponsorship&utm_campaign=bloc-silver-tier&utm_term=flutter-development-company&utm_content=miquido-logo"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/miquido_logo.png" width="225"/></a>
            </td>
        </tr>
        <tr>
            <td align="center" style="background-color: white">
                <a href="https://bit.ly/parabeac_flutterbloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/parabeac_logo.png" width="225"/></a>
            </td>
            <td align="center" style="background-color: white">
                <a href="https://www.netguru.com/services/flutter-app-development?utm_campaign=%5BS%5D%5BMob%5D%20Flutter&utm_source=github&utm_medium=sponsorship&utm_term=bloclibrary"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/netguru_logo.png" width="225"/></a>
            </td>
        </tr>
    </tbody>
</table>

---

## نمای کلی

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" width="500" alt="Bloc Architecture"></img>

هدف این کتابخانه این است که جداسازی _ارائه_ از _منطق تجاری_ را آسان کند، این هدف امکان آزمایش و قابلیت استفاده مجدد را تسهیل می‌کند.

## مستندات

- [مستندات رسمی](https://bloclibrary.dev)
- [بسته Bloc](https://github.com/felangel/bloc/tree/master/packages/bloc/README.md)
- [بسته آزمون Bloc](https://github.com/felangel/bloc/tree/master/packages/bloc_test/README.md)
- [بسته همروندی Bloc](https://github.com/felangel/bloc/tree/master/packages/bloc_concurrency/README.md)
- [بسته فلاتر Bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc/README.md)
- [بسته انگولار Bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc/README.md)
- [بسته Hydrated Bloc](https://github.com/felangel/bloc/tree/master/packages/hydrated_bloc/README.md)
- [بسته Replay Bloc](https://github.com/felangel/bloc/tree/master/packages/replay_bloc/README.md)
- [بسته Sealed Flutter Bloc](https://github.com/felangel/sealed_flutter_bloc/blob/master/README.md)

## مهاجرت

- [راهنمای مهاجرت](https://bloclibrary.dev/#/migration)

## مثال ها

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

### دارت

- [Counter](https://github.com/felangel/bloc/tree/master/packages/bloc/example) - مثالی از چگونگی ایجاد `CounterBloc` (Dart خالص).

### فلاتر

- [Counter](https://bloclibrary.dev/#/fluttercountertutorial) - یک مثال برای ایجاد `CounterBloc` و پیاده‌سازی اپلیکیشن کلاسیک شمارنده در فلاتر.
- [Form Validation](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - یک نمونه از استفاده از بسته‌های `bloc` و `flutter_bloc` برای اجرای اعتبارسنجی فرم.
- [Bloc with Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - یک نمونه از نحوه اتصال یک `bloc` به یک `Stream` و به‌روزرسانی رابط کاربری (UI) در پاسخ به داده‌هایی که از `Stream` دریافت می‌شود.
- [Complex List](https://github.com/felangel/bloc/tree/master/examples/flutter_complex_list) - مثالی از نحوه مدیریت لیستی از آیتم ها و حذف ناهمزمان آیتم ها در یک زمان با استفاده از `block` و `flutter_block`.
- [Infinite List](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement an infinite scrolling list.
- [Login Flow](https://bloclibrary.dev/#/flutterlogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a Login Flow.
- [Firebase Login](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - an example of how to use the `bloc` and `flutter_bloc` packages to implement login via Firebase.
- [Github Search](https://bloclibrary.dev/#/flutterangulargithubsearch) - an example of how to create a Github Search Application using the `bloc` and `flutter_bloc` packages.
- [Weather](https://bloclibrary.dev/#/flutterweathertutorial) - an example of how to create a Weather Application using the `bloc` and `flutter_bloc` packages. The app uses a `RefreshIndicator` to implement "pull-to-refresh" as well as dynamic theming.
- [Todos](https://bloclibrary.dev/#/fluttertodostutorial) - an example of how to create a Todos Application using the `bloc` and `flutter_bloc` packages.
- [Timer](https://bloclibrary.dev/#/fluttertimertutorial) - an example of how to create a Timer using the `bloc` and `flutter_bloc` packages.
- [Shopping Cart](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - an example of how to create a Shopping Cart Application using the `bloc` and `flutter_bloc` packages based on [flutter samples](https://github.com/flutter/samples/tree/master/provider_shopper).
- [Dynamic Form](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - an example of how to use the `bloc` and `flutter_bloc` packages to implement a dynamic form which pulls data from a repository.
- [Wizard](https://github.com/felangel/bloc/tree/master/examples/flutter_wizard) - an example of how to build a multi-step wizard using the `bloc` and `flutter_bloc` packages.
- [Fluttersaurus](https://github.com/felangel/fluttersaurus) - an example of how to use the `bloc` and `flutter_bloc` packages to create a thesaurus app -- made for Bytconf Flutter 2020.
- [I/O Photo Booth](https://github.com/flutter/photobooth) - an example of how to use the `bloc` and `flutter_bloc` packages to create a virtual photo booth web app -- made for Google I/O 2021.
- [I/O Pinball](https://github.com/flutter/pinball) - an example of how to use the `bloc` and `flutter_bloc` packages to create a pinball web app -- made for Google I/O 2022.

### وب

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - an example of how to use a `CounterBloc` in an AngularDart app.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - an example of how to create a Github Search Application using the `bloc` and `angular_bloc` packages.

### فلاتر و وب

- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search) - an example of how to create a Github Search Application and share code between Flutter and AngularDart.

## مقالات

- [Bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - An intro to the bloc package with high level architecture and examples.
- [Login tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - How to create a full login flow using the bloc and flutter_bloc packages.
- [Unit testing with bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - How to unit test the blocs created in the flutter login tutorial.
- [Infinite list tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - How to create an infinite list using the bloc and flutter_bloc packages.
- [Code sharing with bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - How to share code between a mobile application written with Flutter and a web application written with AngularDart.
- [Weather app tutorial with flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - How to build a weather app which supports dynamic theming, pull-to-refresh, and interacting with a REST API using the bloc and flutter_bloc packages.
- [Todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - How to build a todos app using the bloc and flutter_bloc packages.
- [Firebase login tutorial with flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - How to create a fully functional login/sign up flow using the bloc and flutter_bloc packages with Firebase Authentication and Google Sign In.
- [Flutter timer tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - How to create a timer app using the bloc and flutter_bloc packages.
- [Firestore todos tutorial with flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - How to create a todos app using the bloc and flutter_bloc packages that integrates with cloud firestore.

## کتاب ها

- [Flutter Complete Reference](https://fluttercompletereference.com/) - A book about the Dart programming language (version 2.10, with null safety support) and the Flutter framework (version 1.20). It covers the bloc package (version 6.0.3) in all flavors: bloc, flutter_bloc hydrated_bloc, replay_bloc, bloc_test and cubit.

## افزونه‌ها

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - extends IntelliJ/Android Studio with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - extends VSCode with support for the Bloc library and provides tools for effectively creating Blocs for both Flutter and AngularDart apps.

## جامعه

برای کسب اطلاعات بیشتر، به پیوندهای زیر مراجعه کنید که توسط اعضای جامعه ارائه شده‌اند.

### بسته ها

- [Bloc.js](https://github.com/felangel/bloc.js) - A port of the `bloc` state management library from Dart to JavaScript, by [Felix Angelov](https://github.com/felangel).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - A Web, Mobile Firebase Auth Plugin, by [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - An easy way to create forms with BLoC pattern without writing a lot of boilerplate code, by [Giancarlo](https://github.com/GiancarloCode).
- [Flame Bloc](https://pub.dev/packages/flame_bloc) - Bloc integration for the Flame game engine, by [Flame Engine](https://github.com/flame-engine).

### فیلم های آموزشی

- [Bloc Library: Basics and Beyond 🚀](https://youtu.be/knMvKPKBzGE) - Talk given at [Flutter Europe](https://fluttereurope.dev) about the basics of the bloc library, by [Felix Angelov](https://github.com/felangel).
- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=hTExlt1nJZI) - Introduction to the Bloc Library, by [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - How to build a Youtube Search app which interacts with an API using the bloc and flutter_bloc packages, by [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Updated Tutorial on the Flutter Bloc Package, by [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutorial on how to use the flutter_bloc package to implement dynamic theming, by [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutorial on how to use the hydrated_bloc package to automatically persist app state, by [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Introduction to state management using the flutter_bloc package, by [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - How to build a Football Player Search app which interacts with an API using the bloc and flutter_bloc packages, by [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Learning the flutter_bloc package live, by [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - Tutorial on how to unit test blocs using the bloc_test package, by [Reso Coder](https://resocoder.com).
- [Bloc - from Zero to Hero](https://www.youtube.com/playlist?list=PLptHs0ZDJKt_T-oNj_6Q98v-tBnVf-S_o) - Playlist which includes everything needed to get started with bloc, by [Flutterly](https://www.youtube.com/channel/UC5PYcSe3to4mtm3SPCUmjvw).
- [Bloc (Full Course, 11+ Hours) - Flutter State Management Course](https://youtu.be/Mn254cnduOY) - 11+ hour video tutorial on Bloc and Flutter Bloc. In this video you will learn how to create fully fledged production-ready apps with Bloc and Firebase as your backend, by [Vandad Nahavandipoor](https://www.youtube.com/channel/UC8NpGP0AOQ0kX9ZRcohiPeQ).

### منابع نوشتاری

- [DevonFw Flutter Guide](https://github.com/devonfw-forge/devonfw4flutter) - A guide on building structured & scalable applications with Flutter and BLoC, by [Sebastian Faust](https://github.com/Fasust)
- [Using Google´s Flutter Framework for the Development of a Large-Scale Reference Application](https://epb.bibl.th-koeln.de/frontdoor/index/index/docId/1498) - Scientific paper describing how to build [a large-scale Flutter application](https://github.com/devonfw-forge/devonfw4flutter-mts-app) with BLoC, by [Sebastian Faust](https://github.com/Fasust)

### افزونه‌ها

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - A VSCode extension inspired by [Reso Coder's](https://resocoder.com) clean architecture tutorials, which helps quickly scaffold features, by [Kiritchouk Clément](https://github.com/KiritchoukC).

## نگهدارنده ها

- [Felix Angelov](https://github.com/felangel)
