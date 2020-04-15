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

[BLoC design pattern](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc)-i həyata keçirməyə kömək edən gözlənilən vəziyyətin idarə edilməsi kitabxanası.

| Paketlər                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## İcmal

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

Kitabxananın məqsədi _presentation_-ın (dizaynın) _businesss logic_-dən (hesablama və məntiqi hissədən) ayrılmasının, test edilə bilinməsinin və təkrar istifadənin asanlaşdırılmasıdır.


## Dokumentasiya

- [Rəsmi Dokumentasiya](https://bloclibrary.dev)
- [Bloc Paketi](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Flutter Bloc Paketi](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Angular Bloc Paketi](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Migrasiya

- [Versiyanın v0.x-dən v2.x-ə yüksəldilməsi](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Nümunələr

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

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - `CounterBloc`-un yaradılması ilə bağlı nümunə (sırf dart).

### Flutter

- [Sayğac](https://bloclibrary.dev/#/fluttercountertutorial) - Klassik Flutter Counter tətbiqinin həyəta keçirilməsi üçün  `CounterBloc`-un necə yaradılması haqqında nümunə.
- [Form Təsdiqləmə](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) -  form təsdiqləməni həyata keçirmək üçün `bloc` və `flutter_bloc`-un necə istifadə edilməsi haqqında nümunə. 
- [Stream ilə Bloc](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - `bloc`-un `Stream`-ə necə qoşulması və `Stream`-dən gələn məlumata əsasən İstifadəçi İnterfeysinin yenilənməsi haqqında nümunə.
- [Sonsuz List](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - sonsuz listin həyatə keçirilməsi üçün `bloc` and `flutter_bloc`-un necə istifadə edilməsi haqqında nümunə.
- [Login prosesi](https://bloclibrary.dev/#/flutterlogintutorial) - Login prosesini həyata keçirmək üçün `bloc` və `flutter_bloc` paketlərini necə istifadə etmək haqqında nümunə.
- [Firebase Login](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - Firebase ilə login prosesini həyata keçirmək üçün `bloc` və `flutter_bloc` paketlərindən necə istifadə etmək haqqında nümunə.
- [Github-da Axtarış](https://bloclibrary.dev/#/flutterangulargithubsearch) - `bloc` və `flutter_bloc` paketlərini istifadə edərək Github-da Axtarış Tətbiqinin necə yaradılması haqqında nümunə.
- [Hava](https://bloclibrary.dev/#/flutterweathertutorial) - `bloc` və `flutter_bloc` paketlərini istifadə edərək Hava tətbiqinin yaradılması haqqında nümunə. Tətbiq  aşağı sürükləməklə yenilənmə üçün `RefreshIndicator` və dinamik mövzu (theme) dəyişilməsini istifadə edir.
- [Todo-lar](https://bloclibrary.dev/#/fluttertodostutorial) -`bloc` və `flutter_bloc` paketlərindən istifadə edərək Todo-lar Tətbiqinin necə yaradılması haqqında nümunə.
- [Taymer](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - `bloc` və `flutter_bloc` paketlərindən istifadə edərək Taymerin necə yaradılması haqqında nümunə.
- [Firestore Todo-lar](https://bloclibrary.dev/#/flutterfirestoretodostutorial) `bloc` və `flutter_bloc` paketlərindən istifadə edərək və onları cloud firestore-a inteqrasiya edərək Todo-lar Tətbiqinin necə yaradılması haqqında nümunə.
- [Alış-veriş səbəti](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - [flutter nümunələri](https://github.com/flutter/samples/tree/master/provider_shopper) əsasında `bloc` və `flutter_bloc` paketlərini istifadə edərək Alış-Veriş Səbəti tətbiqinin necə yaradılması haqqında nümunə.
- [Dinamik Form](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - `bloc` və `flutter_bloc` paketlərini istifadə edərək repository-dən məlumatı əldə edən dinamik formun həyata keçirilməsi haqqında nümunə.

### Veb

- [Sayğac](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - `CounterBloc`un AngularDart tətbiqində necə istifadə olunması haqqında nümunə.
- [Github-da Axtarış](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - `bloc` və `angular_bloc` paketlərini istifadə edərək Github-da Axtarış Tətbiqinin necə yaradılması haqqında nümunə.

### Flutter + Veb

- [Github-da Axtarış](https://github.com/felangel/Bloc/tree/master/examples/github_search) - Github-da Axtarış Tətbiqinin yaradılması və kodun Flutter və AngularDart arasında bölüşdürülməsi haqqında nümunə.

## Məqalələr

- [bloc paketi](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - Yuxarı səviyyəli arxitektura və nümunələr ilə bloc paketinə giriş.
- [flutter_bloc ilə login dərsi](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - bloc və flutter_bloc paketlərini istifadə edərək tam login prosesinin necə yaradılması.
- [bloc ilə unit testing](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - flutter login dərsində yaradılan bloc-ların necə unit test edilməsi.
- [flutter_bloc ilə sonsuz list dərsi](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - bloc və flutter_bloc paketlərini istifadə edərək sonsuz listin necə yaradılması.
- [bloc ilə kodun bölüşdürülməsi](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) Flutter ilə yazılan mobil tətbiq və AngularDart ilə yazılan veb tətbiq arasında kodun necə bölüşdürülməsi.
- [flutter_bloc ilə hava tətbiqi dərsi](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - bloc və flutter_bloc paketlərini istifadə edərək, dinamik mövzu (theme) dəyişdirilməsini, aşağı sürükləyərək yenilənməni və REST APİ ilə əlaqəni özündə cəmləşdirən hava tətbiqinin necə yaradılması.
- [flutter_bloc ilə todo-lar tətbiqi dərsi](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - bloc və flutter_bloc paketlərini istifadə edərək, todo-lar tətbiqinin necə yaradılması.
- [flutter_bloc ilə firebase login dərsi](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - bloc və flutter_bloc paketlərini istifadə edərək, Firebase İdentifikasiyası və Google Sign İn ilə  tam funksional login/qeydiyyat prosesinin necə yaradılması.
- [flutter_bloc ilə flutter taymer dərsi](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - bloc və flutter_bloc paketlərini istifadə edərək, timer tətbiqinin necə yaradılması.
- [flutter_bloc ilə firestore todos dərsi](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - bloc və flutter_bloc paketlərini istifadə edərək və onları cloud firesotre ilə inteqrasiya edərək,  todolar tətbiqinin necə yaradılması.

## Extension-lar

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - İntelliJ və Android Studio-un imkanlarını Bloc kitabxanası üçün genişlədirir və Flutter və AngularDart tətbiqlərində Bloc-ların effektiv şəkildə yaradılması üçün ləvazimatlar təmin edir.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) -  VSCode-un imkanlarını Bloc kitabxanası üçün genişlədirir və Flutter və AngularDart tətbiqlərində Bloc-ların effektiv şəkildə yaradılması üçün ləvazimatlar təmin edir.

## İcma

İcma tərəfindən yaradılan aşağıdakı linklər ilə daha çox öyrən.

### Paketlər

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - [Felix Angelov](https://github.com/felangel) tərəfindən hazırlanan, avtomatik olaraq `bloc`-un vəziyyətlərini davam etdirən və bərpa edən `bloc`-da vəziyyətin idarə edilməsi kitabxanası üçün extension.
- [Bloc.js](https://github.com/felangel/bloc.js) - [Felix Angelov](https://github.com/felangel) tərəfindən hazırlanan, Dart-dan Javascript-ə, `bloc`-da vəziyyətin idarə edilməsi kitabxanasının portu.
- [Bloc Kod Generatoru](https://pub.dev/packages/bloc_code_generator) - [Adson Leal](https://github.com/adsonpleal) tərəfindən hazırlanan, bloc-la işləməyi asanlaşdıran kod generatoru.
- [Firebase Auth](https://pub.dev/packages/fb_auth) - [Rody Davis](https://github.com/AppleEducate) tərəfindən hazırlanan veb, mobil Firebase Auth Plugin-i.
- [Form Bloc](https://pub.dev/packages/form_bloc) - [Giancarlo](https://github.com/GiancarloCode) tərəfindən hazırlanan, Bloc pattern ilə çox qarışıq kodlar yazmadan, form-ların yaradılmasının sadə yolu.

### Video Dərslər

- [Flutter Bloc Kitabxanası Dərsi](https://www.youtube.com/watch?v=hTExlt1nJZI) - [Reso Coder](https://resocoder.com) tərəfindən, Bloc kitabxanasına giriş.
- [Flutter Youtube Axtarışı](https://www.youtube.com/watch?v=BJY8nuYUM7M) - [Reso Coder](https://resocoder.com) tərəfindən, bloc və flutter_bloc paketlərini istifadə edərək,  API ilə əlaqəli Youtube Axtarış tətbiqinin yaradılması.
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - [Reso Coder](https://resocoder.com) tərəfindən, Flutter Bloc Paketi haqqqında yenilənmiş dərs.
- [flutter_bloc ilə dinamik mövzu (theme) dəyişmə](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - [Reso Coder](https://resocoder.com) tərəfindən, dinamik mövzu dəyişmənin həyata keçirilməsi üçün flutter_bloc paketinin necə istifadə olunması haqqında dərs.
- [Flutter-də Davamlı Bloc Vəziyyəti](https://www.youtube.com/watch?v=vSOpZd_FFEY) - [Reso Coder](https://resocoder.com) tərəfindən, avtomatik olaraq, tətbiqin vəziyyətinin davam etdirilməsi üçün hydrated_bloc paketinin necə istifadə olunması haqqında dərs.
- [Vəziyyətin idarə olunmasının əsasları](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - [Techie Blossom](https://techieblossom.com) tərəfindən, flutter_bloc paketi istifadə edərək, vəziyyətin idarə olunmasına giriş.
- [Flutter Futbolçu Axtarışı](https://www.youtube.com/watch?v=S2KmxzgsTwk) - [Techie Blossom](https://techieblossom.com) tərəfindən, bloc və flutter_bloc paketlərini istifadə edərək, API ilə işləyən Futbolçu Axtarışı tətbiqinin necə yaradılması.
- [Flutter Bloc Paketinin öyrənilməsi](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ) tərəfindən, flutter_bloc paketinin canlı olaraq öyrənilməsi.
- [Bloc Test Dərsi](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - [Reso Coder](https://resocoder.com) tərəfindən, bloc_test paketini istifadə edərək, bloc-ların necə unit test olunması haqqında dərs.
- [Bloc Dərsləri](https://www.youtube.com/watch?v=F2fmfB_ZxK0&list=PLKLWpjPq8Lfhg3J49fXM4Z_X23WPe7bQ5) - [Kənan Yusubov](https://github.com/KenanYusubov) tərəfindən hazırlanmış Bloc haqqında 5 video dərs.

### Extension-lar

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) -[Reso Coder's](https://resocoder.com)-in Clean Arxitektura dərslərindən ilhamlanaraq, [Kiritchouk Clément](https://github.com/KiritchoukC) tərəfindən yaradılan, sürətli şəkildə özəlliklərin (features) skeletinin qurulması üçün VSCode extension-u.

## Maintainer-lər

- [Felix Angelov](https://github.com/felangel)
