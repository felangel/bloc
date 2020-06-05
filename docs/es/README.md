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

Una librería de administración de estado predecible que ayuda a implementar el [patrón de diseño BLoC](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Visión general

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

El objetivo de esta librería es facilitar la separación de la _presentación_ de la _lógica empresarial_, facilitando el testeo (testing) y la reutilización.

## Documentación

- [Documentación oficial](https://bloclibrary.dev)
- [Paquete Bloc](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Paquete Flutter Bloc](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Paquete Angular Bloc ](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Migración

- [Actualizar de v0.x a v2.x](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Ejemplos

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

- [Counter](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - Un ejemplo de cómo crear un `CounterBloc` (dart puro).

### Flutter

- [Contador](https://bloclibrary.dev/#/fluttercountertutorial) - Implementación de ejemplo de la clásica aplicación de contador (`CounterBloc`) en Flutter.
- [Validación de formularios](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - Aprende a validar formularios con los paquetes `bloc` y `flutter_bloc`.
- [Bloc con Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - Descubre como conectar un `bloc` a un flujo de eventos asincronos (`Stream`) y actualizar la interfaz del usuario según su respuesta.
- [Lista Compleja](https://github.com/felangel/bloc/tree/master/examples/flutter_complex_list) - Aprende a manejar una lista de elementos y borrar asincrónicamente uno a la vez utilizando las librerias `bloc` y `flutter_bloc`.
- [Lista Infinita](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - Un ejemplo de cómo usar los paquetes `bloc` y `flutter_bloc` para implementar una lista de desplazamiento infinita.
- [Flujo de Inicio de Sesión](https://bloclibrary.dev/#/flutterlogintutorial) - Un ejemplo de cómo utilizar los paquetes `bloc` y `flutter_bloc` para implementar un flujo de inicio de sesión.
- [Autenticación con Firebase](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - Tutorial para implementar una interfaz de inicio de sesión a través de Firebase utilizando los paquetes de `bloc` y `flutter_bloc` .
- [Búsqueda de Github](https://bloclibrary.dev/#/flutterangulargithubsearch) - Tutorial práctico para crear una aplicación de búsqueda de Github usando los paquetes `bloc` y `flutter_bloc`.
- [Clima](https://bloclibrary.dev/#/flutterweathertutorial) - Construye una plicación meteorológica (`Weather`) utilizando los paquetes `bloc` y `flutter_bloc`. La aplicación utiliza un indicador (`RefreshIndicator`) para implementar la técnica "desliza para refrescar" (del inglés "pull-to-refresh")", así como temas dinámicos.
- [Todos](https://bloclibrary.dev/#/fluttertodostutorial) - un ejemplo sencillo de una aplicación para mostrar una lista quehaceres (TODO) utilizando los paquetes `bloc` y `flutter_bloc`.
- [Temporizador](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - Crea un temporizador básico utilizando los paquetes `bloc` y `flutter_bloc`.
- [Todos con Firestore](https://bloclibrary.dev/#/flutterfirestoretodostutorial) - Construya tu aplicación de lista quehaceres (TODO) con integración en Cloud Firestore utilizando los paquetes `bloc` y `flutter_bloc`.
- [Carro de Compras](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - Un ejemplo de cómo crear una aplicación de carrito de compras utilizando los paquetes `bloc` y `flutter_bloc` basado en [ejemplos de flutter](https://github.com/flutter/samples/tree/master/provider_shopper).
- [Formulario Dinámico](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - Un ejemplo de cómo usar los paquetes `bloc` y `flutter_bloc` para implementar un formulario dinámico que extrae datos de un repositorio.
- [Asistente](https://github.com/felangel/bloc/tree/master/examples/flutter_wizard) - Construye un asistente de varios pasos utilizandolos paquetes `bloc` y `flutter_bloc`.
- [GraphQL](https://github.com/felangel/bloc/tree/master/examples/flutter_graphql_jobs) - Domina la última tecnología para realizar consultas en tu servidor con `graphql` en conjunto a los paquetes `bloc` y `flutter_bloc` para extraer datos de [api.graphql.jobs](https://api.graphql.jobs).


### Web

- [Counter](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - Un ejemplo de cómo usar un `CounterBloc` en una aplicación AngularDart.
- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - Un ejemplo de cómo crear una aplicación de búsqueda de Github utilizando los paquetes `bloc` y `angular_bloc`.

### Flutter + Web

- [Github Search](https://github.com/felangel/Bloc/tree/master/examples/github_search) - Un ejemplo de cómo crear una aplicación de búsqueda de Github y compartir código entre Flutter y AngularDart.

## Artículos (Inglés)

- [bloc package](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - Una introducción al paquete de bloc con arquitectura de alto nivel y ejemplos.
- [login tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - Cómo crear un flujo de inicio de sesión completo utilizando los paquetes bloc y flutter_bloc.
- [unit testing with bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - Cómo testear los blocs creados en el tutorial de inicio de sesión de flutter.
- [infinite list tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - Cómo crear una lista infinita usando los paquetes bloc y flutter_bloc.
- [code sharing with bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - Cómo compartir código entre una aplicación móvil escrita con Flutter y una aplicación web escrita con AngularDart.
- [weather app tutorial with flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - Cómo crear una aplicación meteorológica que tenga temas dinámicos, hala-para-refrescar(pull-to-refresh) e interactuar con una REST API utilizando los paquetes bloc y flutter_bloc.
- [todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - Cómo construir una aplicación de quehaceres (TODOS) usando los paquetes bloc y flutter_bloc.
- [firebase login tutorial with flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - Cómo crear un flujo de inicio de sesión / registro totalmente funcional utilizando los paquetes bloc y flutter_bloc con Firebase Authentication y Google Sign In.
- [flutter timer tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - Cómo crear una aplicación de temporizador usando los paquetes bloc y flutter_bloc.
- [firestore todos tutorial with flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - Cómo crear una aplicación de todos utilizando los paquetes bloc y flutter_bloc que se integran con cloud firestore.

## Extensiones

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - extiende IntelliJ / Android Studio con soporte para la librería Bloc y proporciona herramientas para crear efectivamente Blocs para aplicaciones Flutter y AngularDart.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - extiende VSCode con soporte para la librería Bloc y proporciona herramientas para crear efectivamente blocs para aplicaciones Flutter y AngularDart.

## Comunidad

Obtenga más información en los siguientes enlaces, que han sido aportados por la comunidad.

### Paquetes

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - Una extensión de la librería de administración de estado `bloc` que persiste y restaura automáticamente los estados `bloc`, por [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - Un puerto de la librería de administración de estado `bloc` de Dart a JavaScript, por [Felix Angelov](https://github.com/felangel).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - Un generador de código que facilita el trabajo con blocs, por [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - Un complemento de autenticación web, Firebase móvil, por [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - Una manera fácil de crear formularios con el patrón BLoC sin escribir mucho código repetitivo, por [Giancarlo](https://github.com/GiancarloCode).

### Tutoriales en vídeo (Inglés)

- [Bloc Library: Basics and Beyond 🚀](https://youtu.be/knMvKPKBzGE) - Conferencia impartida en [Flutter Europe](https://fluttereurope.dev) acerca de los conceptos básicos de la librería de Bloc, por [Felix Angelov](https://github.com/felangel).
- [Flutter Bloc Library Tutorial](https://www.youtube.com/watch?v=hTExlt1nJZI) - Introducción a la Librería de blocs, por [Reso Coder](https://resocoder.com).
- [Flutter Youtube Search](https://www.youtube.com/watch?v=BJY8nuYUM7M) - Cómo construir una aplicación de búsqueda de Youtube que interactúa con una API usando los paquetes bloc y flutter_bloc, por [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Updated Tutorial](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Tutorial actualizado sobre el paquete Flutter Bloc, por [Reso Coder](https://resocoder.com).
- [Dynamic Theming with flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutorial sobre cómo usar el paquete flutter_bloc para implementar temas dinámicos, por [Reso Coder](https://resocoder.com).
- [Persist Bloc State in Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutorial sobre cómo usar el paquete hydrated_bloc para mantener automáticamente el estado de la aplicación, por [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Introducción a la gestión de estado utilizando el paquete flutter_bloc, por [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - Cómo construir una aplicación de búsqueda de jugadores de fútbol que interactúa con una API utilizando los paquetes bloc y flutter_bloc, por [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Aprender el paquete flutter_bloc en vivo, por [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - Tutorial sobre cómo unir blocs de prueba usando el paquete bloc_test, por [Reso Coder](https://resocoder.com).

### Extensiones

- [Feature Scaffolding for VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - Una extensión VSCode inspirada en los tutoriales de arquitectura limpia de [Reso Coder's](https://resocoder.com), que ayuda rápidamente a las funciones de andamio, por [Kiritchouk Clément](https://github.com/KiritchoukC).

## Mantenedores

- [Felix Angelov](https://github.com/felangel)
