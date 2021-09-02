<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/feat/bloc-v7.2.0/docs/assets/bloc_concurrency_logo_full.png" height="100" alt="Bloc Concurrency" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc_concurrency"><img src="https://img.shields.io/pub/v/bloc_concurrency.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/workflows/build/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://github.com/tenhobi/effective_dart"><img src="https://img.shields.io/badge/style-effective_dart-40c4ff.svg" alt="style: effective dart"></a>
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

<table>    
    <tbody>
        <tr>
            <td align="center">
                <a href="https://verygood.ventures"><img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/vgv_logo.png" width="120"/></a>
            </td>
            <td align="center">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=https://github.com/felangel/bloc&utm_medium=github&utm_content=developer&utm_term=flutter" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/flutter/tutorial/?utm_source=https://github.com/felangel/bloc&utm_medium=github&utm_content=developer&utm_term=flutter" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>            
        </tr>
    </tbody>
</table>

---

## Event Transformers

`bloc_concurrency` provides an opinionated set of event transformers:

- `concurrent` - process events concurrently
- `sequential` - process events sequentially
- `droppable` - ignore any events added while an event is processing
- `restartable` - process only the latest event and cancel previous event handlers

## Usage

```dart
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

abstract class CounterEvent {}

class CounterIncremented extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncremented>(
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
