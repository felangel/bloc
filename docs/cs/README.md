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

Prediktivní knihovna pro state management, která pomáhá implementovat [návrhový vzor BLoC](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Balíček                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Přehled

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Architektura Blocu" />

Cílem této knihovne je umožnit jednoduše rozdělit _prezenční_ a _logickou_ část, usnadňující testování a opětovné použití.

V rámci této dokumentace se budeme držet originálního názvu `Bloc` (čti _blok_). V případech, kdy budeme potřebovat skloňovat, budeme toto slovo skloňovat podle vzoru slova _blok_. Ikdyž to mnohdy nebude nejideálnější použití, zachováme tím použití originálního názvu, což zabrání nedorozumění.

## Dokumentace

- [Officiální dokumentace](https://bloclibrary.dev/#/cs/)
- [Balíček Bloc](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Balíček Flutter Bloc](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Balíček Angular Bloc](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Migrace

- [Vylepšení z v0.x na v2.x](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Ukázky

<div style="text-align: center">
    <table>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/fluttercountertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_counter.gif" width="200"/>
                </a>
            </td>            
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/flutterinfinitelisttutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_infinite_list.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/flutterfirebaselogintutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_firebase_login.gif" width="200" />
                </a>
            </td>
        </tr>
        <tr>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/flutterangulargithubsearch">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_github_search.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/flutterweathertutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_weather.gif" width="200"/>
                </a>
            </td>
            <td style="text-align: center">
                <a href="https://bloclibrary.dev/#/cs/fluttertodostutorial">
                    <img src="https://bloclibrary.dev/assets/gifs/flutter_todos.gif" width="200"/>
                </a>
            </td>
        </tr>
    </table>
</div>

### Dart

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - ukázka jak vytvořit `CounterBloc` (v čistém Dartu).

### Flutter

- [Počítadlo](https://bloclibrary.dev/#/cs/fluttercountertutorial) - ukázka jak vytvořit `CounterBloc` k implementaci klasické Flutter aplikace počítadla.
- [Validace formuláře](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - ukázka jak použít balíčky `bloc` a `flutter_bloc` pro implementaci validaci formulářů.
- [Bloc se Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - ukázka jak propojit `bloc` se `Streamem` a překreslit UI v reakci na data ze `Stream`.
- [Nekonečný List](https://bloclibrary.dev/#/cs/flutterinfinitelisttutorial) - ukázka jak použít balíčky `bloc` a `flutter_bloc` k implementaci nekonečného skrolovacího listu.
- [Přihlašování](https://bloclibrary.dev/#/cs/flutterlogintutorial) - ukázka jak použít balíčky `bloc` a `flutter_bloc` k implementaci přihlašování.
- [Firebase přihlášování](https://bloclibrary.dev/#/cs/flutterfirebaselogintutorial) - ukázka jak použít balíčky `bloc` a `flutter_bloc` k implementaci přihlašování pomocí Firebase.
- [Github vyhledávání](https://bloclibrary.dev/#/cs/flutterangulargithubsearch) - ukázka jak vytvořit aplikaci na Github vyhledávání použitím balíčků `bloc` a `flutter_bloc`.
- [Počasí](https://bloclibrary.dev/#/cs/flutterweathertutorial) - ukázka jak vytvořit aplikaci počasí použitím balíčků `bloc` a `flutter_bloc`. Aplikace používá `RefreshIndicator` k implementaci "zatáhnout pro obnovení" a také dynamické motivy.
- [Plánovač](https://bloclibrary.dev/#/cs/fluttertodostutorial) - ukázka jak vytvořit aplikaci plánování použitím balíčků `bloc` a `flutter_bloc`.
- [Časovač](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - ukázka jak vytvořit časovač použitím balíčků `bloc` a `flutter_bloc`.
- [Firestore plánovač](https://bloclibrary.dev/#/cs/flutterfirestoretodostutorial) - ukázka jak vytvořit aplikaci plánovaní použitím balíčků `bloc` a `flutter_bloc`, s využitím Cloud Firestore.
- [Nákupní košík](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - ukázka jak vytvořit aplikaci nákupního košíku použitím balíčků `bloc` a `flutter_bloc` založených na [flutter ukázkách](https://github.com/flutter/samples/tree/master/provider_shopper).

### Web

- [Počítadlo](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - ukázka jak použít `CounterBloc` v AngularDart aplikaci.
- [Github vyhledávání](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - ukázka jak vytvořit aplikaci na GitHub vyhledávání použitím balíčků `bloc` a `angular_bloc`.

### Flutter + Web

- [Github vyhledávání](https://github.com/felangel/Bloc/tree/master/examples/github_search) - ukázka jak vytvořit aplikaci na GitHub vyhledávání se sdílením kódu mezi Flutterem a AngularDartem.

## Články (anglicky)

- [bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - Úvod do balíčku bloc s vysoceúrovňovou architekturou a ukázkami.
- [login tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - Jak vytvořit plněhodnotné přihlašování pomocí balíčků bloc a flutter_bloc.
- [unit testing with bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - Jak psát unit testy pro blocy vytvořené v tutoriálu na flutter přihlašování.
- [infinite list tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - Jak vytvořit nekonečný list s použitím balíčků bloc and flutter_bloc.
- [code sharing with bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - Jak sdílet kód mezi mobilní aplikací psanou ve Flutteru a webovou aplikací psanou v AngularDartu.
- [weather app tutorial with flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - Jak vytvořit aplikaci počasí, která podporuje dynamické motivy, "zatáhnou pro obdovení", a interagující s REST API použitím balíčků bloc a flutter_bloc.
- [todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - Jak vytvořit aplikaci plánovače pomocí balíčků bloc a flutter_bloc.
- [firebase login tutorial with flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - Jak vytvořit plně funkční přihlašování a registraci pomocí balíčků bloc a flutter_bloc s Firebase Authentication and Google Sign In.
- [flutter timer tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - Jak vytvořit aplikaci časovače pomocí balíčků bloc a flutter_bloc.
- [firestore todos tutorial with flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - Jak vytvořit aplikaci plánovače s použitím balíčků bloc and flutter_bloc, které integruje s cloud firestore.
- [Dynamický formulář](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - Jak použít balíčky `bloc` a `flutter_bloc` k implementaci dynamického formuláře, který stahuje data z repozitáře.

## Rozšíření

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - rozšiřuje IntelliJ/Android Studio o podporu Bloc knihovny a poskytuje nástroje na efektivní vytváření Bloců pro jak Flutter, tak i AngularDart aplikace.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - rozšiřuje VSCode o podporu Bloc knihovny a poskytuje nástroje pro efektivní vytváření Bloců pro jak Flutter, tak i AngularDart aplikace.

## Komunita

Více se dozvíte na následujících odkazech, které vytvořila komunita.

### Balíčky

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - Rozšíření knihovny `bloc` pro state management, které automaticky uchovává a obnovuje `bloc` stavy, od [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - Port knihovny `bloc` pro state management z Dartu do JavaScriptu, od [Felix Angelov](https://github.com/felangel).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - Generátor kódu, který činí práci s bloky jednoduší, od [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - Firebase plugin pro weby a mobily, od [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - Jednoduchý způsob vytváření formulářů s použitím BLoCu a bez psaní velkého množství zbytečného kódu, od [Giancarlo](https://github.com/GiancarloCode).

### Video tutoriály (anglicky)

- [Bloc Library: Basics and Beyond 🚀](https://youtu.be/knMvKPKBzGE) - Talk given at [Flutter Europe](https://fluttereurope.dev) about the basics of the bloc library, by [Felix Angelov](https://github.com/felangel).
- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=LeLrsnHeCZY) - Úvod do knihovny Bloc, od [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - Jak vytvořit aplikaci na Youtube vyhledávání, která interaguje s API s použitím balíčků bloc a flutter_bloc, od [Reso Coder](https://resocoder.com).
- [Bloc Library (Updated) – Painless State Management for Flutter](https://www.youtube.com/watch?v=nQMfaQeCL6M) - Aktualizovaný tutoriál na knihovnu Bloc, od [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Aktualizovaný tutoriál na balíček Flutter Bloc, od [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutoriál o používání balíčku flutter_bloc k implementaci dynamických motivů, od [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutoriál o používání balíčku hydrated_bloc k automatickému uchovávání stavu aplikace, od [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Úvod do state managementu použitím balíčku flutter_bloc, od [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - Jak vytvořit aplikaci na vyhledávání fotbalových hráčů, která interaguje s API s použitím balíčků bloc a flutter_bloc, od [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Učení se flutter_bloc naživo, od [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - Tutorial on how to unit test blocs using the bloc_test package, by [Reso Coder](https://resocoder.com)

### Rozšíření

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - VSCode rozšíření inspirováno [Reso Coderovým](https://resocoder.com) tutoriálem o Clean Architecture, který umožňuje rychle vytvářet featury, od [Kiritchouk Clément](https://github.com/KiritchoukC).

## Správci

- [Felix Angelov](https://github.com/felangel)
