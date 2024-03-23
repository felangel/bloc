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

ما `CounterObserver` را که به تازگی ایجاد کرده‌ایم, را راه اندازی (Initializing) می‌کنیم و `runApp` را با ویجت `CounterApp` فراخوانی می‌کنیم که در ادامه به بررسی آن خواهیم پرداخت.

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

کلاس `CounterCubit` دو متد را ارائه می‌دهد:

- `افزایش`: یک واحد به وضعیت فعلی اضافه می‌کند.
- `کاهش`: یک واحد از وضعیت فعلی کم می‌کند.

نوع وضعیتی که `CounterCubit` در حال مدیریت آن است، فقط یک `int` است و وضعیت اولیه آن `0` است.

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

**نکته**: برای ایجاد خودکار cubit جدید، از [افزونه VSCode](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) یا [پلاگین IntelliJ](https://plugins.jetbrains.com/plugin/12129-bloc) استفاده کنید.

بعداز آن، بیایید به `CounterView` نگاهی بیندازیم که مسئول مصرف وضعیت (تغییرات را مشاهده کرده و بر اساس آن عملی انجام میدهد. مثلا میتواند مقدار وضعیت را نشان دهد) و تعامل با `CounterCubit` خواهد بود.

## نمای شمارنده

بیایید `lib/counter/view/counter_view.dart` را ایجاد کنیم:

`CounterView` مسئول رندر کردن شمارنده فعلی و نمایش دو دکمه شناور (FloatingActionButtons) برای افزایش/کاهش شمارنده است.

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

یک `BlocBuilder` برای اعمال وضعیت روی ویجت `Text` استفاده می‌شود تا هر بار که وضعیت `CounterCubit` تغییر کند، متن و ویجت به‌روز شود. علاوه بر این، از `context.read<CounterCubit>()` برای جستجو نمونه نزدیکترین `CounterCubit` استفاده می‌شود.

?> **توجه**: فقط ویجت `Text` در `BlocBuilder` قرار داده شده است زیرا تنها ویجتی است که باید در پاسخ به تغییرات وضعیت `CounterCubit` مجدداً ساخته شود. از قرار دادن اضافی ویجت‌ها که نیازی به بازسازی ندارند هنگام تغییر وضعیت اجتناب کنید.

## Barrel

بیایید `lib/counter/view/view.dart` را ایجاد کنیم:

`view.dart` را اضافه کنید تا همهٔ اجزای واسط کاربری مربوط  به نمایش شمارنده قابل دسترس باشد.

[view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/view.dart ':include')


بیایید `lib/counter/counter.dart` را ایجاد کنیم.

`counter.dart` را اضافه کنید تا تمام اجزا و کامپوننت‌های واسط کاربری عمومی مربوط به قابلیت شمارنده در دسترس باشند.

[counter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/counter.dart ':include')

خودشه! ما لایه‌ی نمایش (Presentation) را از لایه‌ی منطق کسب و کار (Business logic layer) جدا کردیم. `CounterView` هیچ اطلاعی از اتفاقی که هنگام فشردن دکمه توسط کاربر رخ می‌دهد ندارد؛ فقط به `CounterCubit` اطلاع می‌دهد. علاوه بر این، `CounterCubit` هیچ اطلاعی از اتفاقاتی که با وضعیت (مقدار شمارنده) رخ می‌دهد ندارد؛ به سادگی وضعیت‌های جدید را در پاسخ به تماس‌هایی که صدا زده می‌شوند بر می‌گرداند.

می‌توانیم اپلیکیشن خود را با استفاده از `flutter run` اجرا کنیم و آن را در دستگاه یا شبیه‌ساز مشاهده کنیم.

همچنین می‌توانید کد منبع کامل (شامل تست‌های واحد و ویجت) این مثال را در [اینجا](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter) پیدا کنید.
