# Flutter Sayğac dərsi

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> Sıradakı dərsdə, Bloc kitabxanasını istifadə edərək, Flutter-də Sayğac düzəldəcəyik.

![demo](../assets/gifs/flutter_counter.gif)

## Quraşdırma

Yeni Flutter proyekti yaradaraq başlayacağıq.

[script](../_snippets/flutter_counter_tutorial/flutter_create.sh.md ':include')

Daha sonra `pubspec.yaml`-dakı kontentləri aşağıdakı kimi əvəzləyirik

[pubspec.yaml](../_snippets/flutter_counter_tutorial/pubspec.yaml.md ':include')

və dependency-lərimizi quraşdırırıq

[script](../_snippets/flutter_counter_tutorial/flutter_packages_get.sh.md ':include')

Sayğac tətbiqimiz sadəcə sayğacın qiymətini azaltmaq/artırmaq üçün 2 düymədən və sayğacın cari qiymətini göstərmək üçün `Text` widget-indən ibarət olacaq. `CounterEvent`-ləri yaratmağa başlayaq.

## Counter Events (Counter Hadisələri)

[counter_event.dart](../_snippets/flutter_counter_tutorial/counter_event.dart.md ':include')

## Counter States (Counter Vəziyyətləri)

Sate-imiz sadəcə integer (tam ədəd) olduğu üçün, əlavə class yaratmağa ehtiyac yoxdur!

## Counter Bloc

[counter_bloc.dart](../_snippets/flutter_counter_tutorial/counter_bloc.dart.md ':include')

?> **Qeyd**: `CounterBloc` elanından görə bilərik ki, `CounterEvent`-lər input kimi və integer-lər isə output kimi istifadə ediləcək.

## Sayğac Tətbiqi

Now that we have our `CounterBloc` fully implemented, we can get started creating our Flutter application.

[main.dart](../_snippets/flutter_counter_tutorial/main.dart.md ':include')

?> **Note**: We are using the `BlocProvider` widget from `flutter_bloc` in order to make the instance of `CounterBloc` available to the entire subtree (`CounterPage`). `BlocProvider` also handles closing the `CounterBloc` automatically so we don't need to use a `StatefulWidget`.

## Counter Page

Finally, all that's left is to build our Counter Page.

[counter_page.dart](../_snippets/flutter_counter_tutorial/counter_page.dart.md ':include')

?> **Note**: We are able to access the `CounterBloc` instance using `BlocProvider.of<CounterBloc>(context)` because we wrapped our `CounterPage` in a `BlocProvider`.

?> **Note**: We are using the `BlocBuilder` widget from `flutter_bloc` in order to rebuild our UI in response to state changes (changes in the counter value).

?> **Note**: `BlocBuilder` takes an optional `bloc` parameter but we can specify the type of the bloc and the type of the state and `BlocBuilder` will find the bloc automatically so we don't need to explicity use `BlocProvider.of<CounterBloc>(context)`.

!> Only specify the bloc in `BlocBuilder` if you wish to provide a bloc that will be scoped to a single widget and isn't accessible via a parent `BlocProvider` and the current `BuildContext`.

That's it! We've separated our presentation layer from our business logic layer. Our `CounterPage` has no idea what happens when a user presses a button; it just adds an event to notify the `CounterBloc`. Furthermore, our `CounterBloc` has no idea what is happening with the state (counter value); it's simply converting the `CounterEvents` into integers.

We can run our app with `flutter run` and can view it on our device or simulator/emulator.

The full source for this example can be found [here](https://github.com/felangel/Bloc/tree/master/packages/flutter_bloc/example).
