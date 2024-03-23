# آموزش شمارنده در فلاتر

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> در آموزش زیر، قصد داریم با استفاده از کتابخانه Bloc، یک شمارنده در فلاتر ایجاد کنیم.

![demo](./assets/gifs/flutter_counter.gif)

## موضوعات کلیدی

- مشاهده تغییرات وضعیت با استفاده از [BlocObserver](/coreconcepts?id=blocobserver).
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider)، ویجت فلاتری که یک bloc را به فرزندانش ارائه می‌دهد.
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder)، ویجت فلاتری که به ساخت ویجت در پاسخ به وضعیت‌های جدید می‌پردازد.
- استفاده از Cubit به جای Bloc. [چه فرقی می کنند؟](/coreconcepts?id=cubit-vs-bloc)
- اضافه کردن رویدادها با استفاده از [context.read](/migration?id=❗contextbloc-and-contextrepository-are-deprecated-in-favor-of-contextread-and-contextwatch).⚡

## راه اندازی

ما با ایجاد یک پروژه جدید فلاتر شروع می‌کنیم.

```sh
flutter create flutter_counter
```

سپس می‌توانیم ادامه دهیم و محتوای `pubspec.yaml` را با موارد زیر جایگزین کنیم

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

و سپس تمام وابستگی های ما را نصب کنید

```sh
flutter packages get
```

## ساختار پروژه

```
├── lib
│   ├── app.dart
│   ├── counter
│   │   ├── counter.dart
│   │   ├── cubit
│   │   │   └── counter_cubit.dart
│   │   └── view
│   │       ├── counter_page.dart
│   │       ├── counter_view.dart
│   │       └── view.dart
│   ├── counter_observer.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
```

این برنامه از یک ساختار ویژگی‌محور (Feature-driven) استفاده می‌کند. این ساختار, پروژه را قابل مقیاس کرده و با داشتن ویژگی های مستقل از هم (Self-contained), قادر به توسعه آن می‌شود. در این مثال، فقط یک قابلیت وجود دارد (خود شمارنده)، اما در برنامه‌های پیچیده‌تر می‌توان صدها قابلیت مختلف داشت.

## BlocObserver

چیزی که اولین بار نگاه می‌کنیم، ایجاد یک `BlocObserver` است که به ما در مشاهده تمام تغییرات وضعیت در برنامه کمک می‌کند.

بیایید `lib/counter_observer.dart` را ایجاد کنیم:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

در این حالت، تنها `onChange` را دوباره بازنویسی (Override) می‌کنیم تا تمام تغییرات وضعیتی که رخ می‌دهد را ببینیم.

?> **نکته**: `onChange` برای هر دو نمونه از `Bloc` و `Cubit` به یک شکل عمل می‌کند.

## main.dart

بعداز آن، بیایید محتوای `main.dart` را با محتوای زیر جایگزین کنیم:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

ما `CounterObserver` را که به تازگی ایجاد کرده‌ایم راه اندازی (Initializing) می‌کنیم و `runApp` را با ویجت `CounterApp` فراخوانی می‌کنیم که در ادامه به بررسی آن خواهیم پرداخت.

## برنامه شمارنده

بیایید `lib/app.dart` را ایجاد کنیم:

`CounterApp` یک `MaterialApp` خواهد بود و `home` را به عنوان `CounterPage` مشخص می‌کند.

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **توجه**: ما `MaterialApp` را گسترش می‌دهیم زیرا `CounterApp` یک `MaterialApp` است. در بیشتر موارد، ما نمونه‌های `StatelessWidget` یا `StatefulWidget` ایجاد می‌کنیم و ویجت‌ها را در `build` ترکیب می‌کنیم اما در این حالت هیچ ویجتی برای ترکیب وجود ندارد، بنابراین ساده‌تر است که فقط `MaterialApp` را گسترش دهیم.

بیایید نگاهی به `CounterPage` بیندازیم!

## صفحه شمارنده

بیایید `lib/counter/view/counter_page.dart` را ایجاد کنیم:

ویجت `CounterPage` مسئول ایجاد `CounterCubit` است (که در ادامه آن را مشاهده خواهیم کرد) و آن را به `CounterView` ارائه می‌دهد.

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **توجه**: مهم است که ایجاد یک `Cubit` را از مصرف یک `Cubit` جدا کنید یا آن را از هم مجزا کنید تا کدی داشته باشید که بسیار قابل تست و قابل استفاده مجدد باشد.

## شمارنده کوبیت

بیایید `lib/counter/cubit/counter_cubit.dart` را ایجاد کنیم.

The `CounterCubit` class will expose two methods:

- `increment`: adds 1 to the current state
- `decrement`: subtracts 1 from the current state

The type of state the `CounterCubit` is managing is just an `int` and the initial state is `0`.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **Tip**: Use the [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) or [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) to create new cubits automatically.

Next, let's take a look at the `CounterView` which will be responsible for consuming the state and interacting with the `CounterCubit`.

## Counter View

Let's create `lib/counter/view/counter_view.dart`:

The `CounterView` is responsible for rendering the current count and rendering two FloatingActionButtons to increment/decrement the counter.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

A `BlocBuilder` is used to wrap the `Text` widget in order to update the text any time the `CounterCubit` state changes. In addition, `context.read<CounterCubit>()` is used to look-up the closest `CounterCubit` instance.

?> **Note**: Only the `Text` widget is wrapped in a `BlocBuilder` because that is the only widget that needs to be rebuilt in response to state changes in the `CounterCubit`. Avoid unnecessarily wrapping widgets that don't need to be rebuilt when a state changes.

## Barrel

Create `lib/counter/view/view.dart`:

Add `view.dart` to export all public facing parts of counter view.

[view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/view.dart ':include')


Let's create `lib/counter/counter.dart`:

Add `counter.dart` to export all the public facing parts of the counter feature.

[counter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/counter.dart ':include')

That's it! We've separated the presentation layer from the business logic layer. The `CounterView` has no idea what happens when a user presses a button; it just notifies the `CounterCubit`. Furthermore, the `CounterCubit` has no idea what is happening with the state (counter value); it's simply emitting new states in response to the methods being called.

We can run our app with `flutter run` and can view it on our device or simulator/emulator.

The full source (including unit and widget tests) for this example can be found [here](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter).
