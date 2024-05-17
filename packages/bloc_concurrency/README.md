<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/logos/bloc_concurrency.png" height="100" alt="Bloc Concurrency" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc_concurrency"><img src="https://img.shields.io/pub/v/bloc_concurrency.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

A Dart package that exposes custom event transformers inspired by [ember concurrency](https://github.com/machty/ember-concurrency). Built to work with [bloc](https://pub.dev/packages/bloc).

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

---

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table style="background-color: white; border: 1px solid black">
    <tbody>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.monterail.com/services/flutter-development/?utm_source=bloc&utm_medium=logo&utm_campaign=flutter"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/monterail.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/stream.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.miquido.com/flutter-development-company/?utm_source=github&utm_medium=sponsorship&utm_campaign=bloc-silver-tier&utm_term=flutter-development-company&utm_content=miquido-logo"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/miquido.png" width="225"/></a>
            </td>
        </tr>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://bit.ly/parabeac_flutterbloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/parabeac.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.netguru.com/services/flutter-app-development?utm_campaign=%5BS%5D%5BMob%5D%20Flutter&utm_source=github&utm_medium=sponsorship&utm_term=bloclibrary"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/netguru.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://www.porada.app/"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/porada.png" width="225"/></a>
            </td>            
        </tr>
    </tbody>
</table>

---

## Event Transformers

![Event Transformers](https://raw.githubusercontent.com/felangel/bloc/master/assets/diagrams/bloc_concurrency.png)

`bloc_concurrency` provides an opinionated set of event transformers:

- `concurrent` - process events concurrently
- `sequential` - process events sequentially
- `droppable` - ignore any events added while an event is processing
- `restartable` - process only the latest event and cancel previous event handlers

## Usage

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>(
      (event, emit) async {
        await Future.delayed(Duration(seconds: 1));
        emit(state + 1);
      },
      /// Specify a custom event transformer from `package:bloc_concurrency`
      /// in this case events will be processed sequentially.
      transformer: sequential(),
    );
  }
}
```

## Dart Versions

- Dart 2: >= 2.12

## Maintainers

- [Felix Angelov](https://github.com/felangel)
