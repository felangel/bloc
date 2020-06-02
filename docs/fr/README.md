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

Une librairie pour gérer le state de notre application en implémentant le [paterne BLoC](https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc).

| Package                                                                            | Pub                                                                                                    |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| [bloc](https://github.com/felangel/bloc/tree/master/packages/bloc)                 | [![pub package](https://img.shields.io/pub/v/bloc.svg)](https://pub.dev/packages/bloc)                 |
| [bloc_test](https://github.com/felangel/bloc/tree/master/packages/bloc_test)       | [![pub package](https://img.shields.io/pub/v/bloc_test.svg)](https://pub.dev/packages/bloc_test)       |
| [flutter_bloc](https://github.com/felangel/bloc/tree/master/packages/flutter_bloc) | [![pub package](https://img.shields.io/pub/v/flutter_bloc.svg)](https://pub.dev/packages/flutter_bloc) |
| [angular_bloc](https://github.com/felangel/bloc/tree/master/packages/angular_bloc) | [![pub package](https://img.shields.io/pub/v/angular_bloc.svg)](https://pub.dev/packages/angular_bloc) |

## Aperçu

<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_architecture.png" alt="Bloc Architecture" />

Le but de cette architecte est de facilité la séparation entre _présentation_ et _la business logic_, facilitant à la fois les test et sa réutilisation.

## Documentation

- [Documentation officielle](https://bloclibrary.dev)
- [Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/bloc/README.md)
- [Flutter Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/README.md)
- [Angular Bloc Package](https://github.com/felangel/Bloc/tree/master/packages/angular_bloc/README.md)

## Migration

- [Upgrade from v0.x to v2.x ](https://dev.to/mhadaily/upgrade-to-bloc-library-v1-0-0-for-flutter-and-angular-dart-2np0)

## Exemples

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

- [Compteur](https://github.com/felangel/Bloc/tree/master/packages/bloc/example) - un exemple pour créer un `CounterBloc` (dart pur).

### Flutter

- [Compteur](https://bloclibrary.dev/#/fluttercountertutorial) - un exemple pour montrer comment créer un `CounterBloc` pour implémenter la classique application compteur de Flutter.
- [Validation d'un formulaire](https://github.com/felangel/bloc/tree/master/examples/flutter_form_validation) - un exemple pour apprendre à utiliser les packages `bloc` et `flutter_bloc` pour implémenter la validation d'un formulaire.
- [Bloc avec Stream](https://github.com/felangel/bloc/tree/master/examples/flutter_bloc_with_stream) - un exemple sur comment relier un `bloc` à un `Stream` et actualiser son UI en réponse aux données venant du `Stream`.
- [Liste infinie](https://bloclibrary.dev/#/flutterinfinitelisttutorial) - un exemple pour utiliser les packages `bloc` et `flutter_bloc` pour implémenter une liste avec un scroll infini.
- [Espace de connexion](https://bloclibrary.dev/#/flutterlogintutorial) - un exemple pour apprendre à utiliser les packages `bloc` et `flutter_bloc` pour implémenter un espace de connexion.
- [Connexion avec Firebase](https://bloclibrary.dev/#/flutterfirebaselogintutorial) - un exemple sur comment utiliser les packages `bloc` et `flutter_bloc`pour implémenter un formulaire de connexion avec Firebase.
- [Recherche Gihub](https://bloclibrary.dev/#/flutterangulargithubsearch) - un exemple sur comment créer une application de recherche sur Github en utilisant les packages `bloc` et `flutter_bloc`.
- [Météo](https://bloclibrary.dev/#/flutterweathertutorial) - un exemple pour créer une application météorologique en utilisant les packages `bloc` et `flutter_bloc`. L'app utiliser un `RefreshIndicator` pour implémenter un "tirer pour rafraichir la page" ainsi qu'un thème dynamique.
- [Liste de choses à faire](https://bloclibrary.dev/#/fluttertodostutorial) - un exemple pour créer une application "Liste de choses à faire" en utilisant les packages `bloc` et `flutter_bloc`.
- [Minuteur](https://github.com/felangel/bloc/tree/master/examples/flutter_timer) - un exemple pour créer un Minuteur en utilisant les packages `bloc` et `flutter_bloc`.
- [Liste de choses à faire avec Firestore](https://bloclibrary.dev/#/flutterfirestoretodostutorial) - un exemple pour créer une application "Liste de choses à faire" en utilisant les packages `bloc` et `flutter_bloc` qui intègre le cloud firestore.
- [Panier Shopping](https://github.com/felangel/bloc/tree/master/examples/flutter_shopping_cart) - un exemple pour créer une application contenant un panier de Shopping en utilisant les packages `bloc`et `flutter_bloc` basé sur les [flutter samples](https://github.com/flutter/samples/tree/master/provider_shopper).
- [Formulaire dynamique](https://github.com/felangel/bloc/tree/master/examples/flutter_dynamic_form) - un exemple pour créer utiliser les packages `bloc` et `flutter_bloc` afin d'implémenter un formulaire dynamique qui extrait des données depuis un répertoire.

### Web

- [Compteur](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) - un exemple qui montre comment utiliser un example  `CounterBloc` dans une application AngularDart.
- [Recherche Github](https://github.com/felangel/Bloc/tree/master/examples/github_search/angular_github_search) - un exemple qui montre comment créer une Application de recherche Github en utilisant les packages `bloc` et `angular_bloc`.

### Flutter + Web

- [Recherche Github](https://github.com/felangel/Bloc/tree/master/examples/github_search) - un exemple pour apprendre comment créer une Application de recherche Github et en partageant le code entre Flutter et AngularDart.

## Articles

- [package bloc](https://medium.com/flutter-community/flutter-bloc-package-295b53e95c5c) - Une introduction sur le package bloc avec une architecture de haut niveau et des exemples.
- [tutoriel pour un formulaire de connexion avec Flutter](https://medium.com/flutter-community/flutter-login-tutorial-with-flutter-bloc-ea606ef701ad) - Comment créer un espace de connexion de A à Z en utilisant les packages bloc et flutter_bloc.
- [test unitaire avec bloc](https://medium.com/@felangelov/unit-testing-with-bloc-b94de9655d86) - Comment faire des tests unitaires pour les blocs créés dans le tutoriel pour le formulaire de connexion Flutter.
- [Liste infinie avec flutter_bloc](https://medium.com/flutter-community/flutter-infinite-list-tutorial-with-flutter-bloc-2fc7a272ec67) - Comment créer une liste infinie en utilisant les packages bloc et flutter_bloc.
- [Partager son code avec bloc](https://medium.com/flutter-community/code-sharing-with-bloc-b867302c18ef) - Comment partager son code entre une application mobile écrite avec Flutter et une application web écrite avec AngularDart.
- [Tutoriel Application météorologique avec flutter_bloc](https://medium.com/flutter-community/weather-app-with-flutter-bloc-e24a7253340d) - Comment construire une application météorologique qui supporte un thème dynamique, tirer pour rafraichir, et qui intéragit avec une REST API en utilisant les packages bloc et flutter_bloc.
- [todos app tutorial with flutter_bloc](https://medium.com/flutter-community/flutter-todos-tutorial-with-flutter-bloc-d9dd833f9df3) - How to build a todos app using the bloc and flutter_bloc packages.
- [Formulaire de connexion/inscription firebase et flutter_bloc](https://medium.com/flutter-community/firebase-login-with-flutter-bloc-47455e6047b0) - Comment construire un formulaire de connexion et d'inscription entièrement fonctionnel en utilisant les packages bloc et flutter_bloc avec l'Authentification Firebase et Google Sign In.
- [tutoriel minuteur flutter avec flutter_bloc](https://medium.com/flutter-community/flutter-timer-with-flutter-bloc-a464e8332ceb) - Comment créer une application minuteur en utilisant les packages bloc et flutter_bloc.
- [tutoriel liste de choses à faire avec firestore et flutter_bloc](https://medium.com/flutter-community/firestore-todos-with-flutter-bloc-7b2d5fadcc80) - Comment créer une application qui liste des choses à faire en utilisant les packages bloc et flutter_bloc qui intègrent le cloud firestore.

## Extensions

- [IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc-code-generator) - étend IntelliJ/Android Studio avec du support pour la librairie Bloc et fournit des outils pour créer efficacement des Blocs pour à la fois des applications Flutter et AngularDart.
- [VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc#overview) - étend VSCode avec du support pour la librairie Bloc et fournit des outils pour créer efficacement des Blocs pour à la fois des applications Flutter et AngularDart.

## Communauté

Apprennez en plus en suivant les liens qui ont été apportés par la communauté.

### Packages

- [Hydrated Bloc](https://pub.dev/packages/hydrated_bloc) - Une extension à la librairie `bloc` state management qui va automatiquement rendre persistant et restaurer les `bloc` states, par [Felix Angelov](https://github.com/felangel).
- [Bloc.js](https://github.com/felangel/bloc.js) - Pour exporter la librairie `bloc` et son state management depuis Dart jusqu'à Javascript, par [Felix Angelov](https://github.com/felangel).
- [Bloc Code Generator](https://pub.dev/packages/bloc_code_generator) - Un générateur de code qui permet de travailler plus facilement avec bloc, par [Adson Leal](https://github.com/adsonpleal).
- [Firebase Auth](https://pub.dev/packages/fb_auth) - Un plugin pour créer une authentification Web et Mobile avec Firebase, par [Rody Davis](https://github.com/AppleEducate).
- [Form Bloc](https://pub.dev/packages/form_bloc) - Faciliter la création des formulaires avec le paterne BloC sans avoir besoin d'écrire beaucoup de code "futile" (boilerplate), par [Giancarlo](https://github.com/GiancarloCode).

### Vidéos tutoriels

- [Librarie Bloc: Basiques et au-delà 🚀](https://youtu.be/knMvKPKBzGE) - Conférence donnée à [Flutter Europe](https://fluttereurope.dev) à propos des basiques de la librarie bloc, par [Felix Angelov](https://github.com/felangel).
- [Tutoriel Flutter sur la Librairie Bloc](https://www.youtube.com/watch?v=hTExlt1nJZI) - Introduction à la Librarie Bloc, par [Reso Coder](https://resocoder.com).
- [Flutter Recherche Youtube](https://www.youtube.com/watch?v=BJY8nuYUM7M) - Comment construire une application Recherche Youtube qui intéragit avec une API en utilisant les packages bloc et flutter_bloc, par [Reso Coder](https://resocoder.com).
- [Flutter Bloc - AUTOMATIC LOOKUP - v0.20 (and Up), Tutoriel à jour](https://www.youtube.com/watch?v=_vOpPuVfmiU) - Tutoriel à jour sur le Package Flutter Bloc, par [Reso Coder](https://resocoder.com).
- [Thème dynamique avec flutter_bloc](https://www.youtube.com/watch?v=YYbhkg-W8Mg) - Tutoriel pour utiliser le package flutter_bloc afin d'implémenter un thème dynamique, par [Reso Coder](https://resocoder.com).
- [Persistant Bloc State dans Flutter](https://www.youtube.com/watch?v=vSOpZd_FFEY) - Tutoriel pour apprendre à utiliser le package hydrated_bloc pour automatiquement rendre persistant le state de notre application, par [Reso Coder](https://resocoder.com).
- [State Management Foundation](https://www.youtube.com/watch?v=S2KmxzgsTwk&t=731s) - Introduction to state management using the flutter_bloc package, by [Techie Blossom](https://techieblossom.com).
- [Flutter Football Player Search](https://www.youtube.com/watch?v=S2KmxzgsTwk) - How to build a Football Player Search app which interacts with an API using the bloc and flutter_bloc packages, by [Techie Blossom](https://techieblossom.com).
- [Learning the Flutter Bloc Package](https://www.youtube.com/watch?v=eAiCPl3yk9A&t=1s) - Learning the flutter_bloc package live, by [Robert Brunhage](https://www.youtube.com/channel/UCSLIg5O0JiYO1i2nD4RclaQ)
- [Bloc Test Tutorial](https://www.youtube.com/watch?v=S6jFBiiP0Mc) - Tutorial on how to unit test blocs using the bloc_test package, by [Reso Coder](https://resocoder.com).

### Ressources écrites

- [DevonFw Flutter Guide](https://github.com/devonfw-forge/devonfw4flutter) - Un guide pour créer des applications structurées et évolutives avec Flutter et BLoC, par [Sebastian Faust](https://github.com/Fasust)
- [Utiliser le Framework de Google Flutter pour le développement d'une grande-évolutive Application](https://epb.bibl.th-koeln.de/frontdoor/index/index/docId/1498) - Papier scientifique qui décrit comment construire [une grande-évolutive application Flutter](https://github.com/devonfw-forge/devonfw4flutter-mts-app) avec BLoC, par [Sebastian Faust](https://github.com/Fasust)

### Extensions

- [Echafaudage (Scaffolding) pour VSCode](https://marketplace.visualstudio.com/items?itemName=KiritchoukC.flutter-clean-architecture) - Une extension VSCode inspiré de [Reso Coder](https://resocoder.com) et ses tutoriels sur une architecture propre, cela va vous aider à créer rapidement les dossiers pour votre feature, par [Kiritchouk Clément](https://github.com/KiritchoukC).

## Mainteneurs

- [Felix Angelov](https://github.com/felangel)
