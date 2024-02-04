# دستورالعمل ها: ناوبری (Navigation)

> در این دستورالعمل، قصد داریم نحوه استفاده از `BlocBuilder` و یا `BlocListener` برای انجام ناوبری را بررسی کنیم. سه رویکرد را بررسی خواهیم کرد: ناوبری مستقیم (Direct Navigation)، ناوبری با استفاده از روت (Route Navigation) و ناوبری اعلامی (Declarative Navigation) با استفاده از Navigator 2.0.

## ناوبری مستقیم (Direct Navigation)

> در این مثال، قصد داریم نحوه استفاده از `BlocBuilder` را برای نمایش یک صفحه (ویجت) خاص در پاسخ به تغییر وضعیتی در بلاک بدون استفاده از یک مسیر (Route) را بررسی کنیم.

![demo](./assets/gifs/recipes_flutter_navigation_direct.gif)

### Bloc

بیایید `MyBloc` را ایجاد کنیم که `MyEvents` را دریافت می‌کند و آنها را به `MyStates` تبدیل می‌کند.

#### MyEvent

به منظور سادگی، `MyBloc` ما تنها به دو `MyEvents`، یعنی `EventA` و `EventB`، پاسخ می‌دهد.

[my_event.dart](_snippets/recipes_flutter_navigation/my_event.dart.md ':include')

#### MyState

`MyBloc` ما می‌تواند یکی از دو `DataStates` مختلف را داشته باشد:

- `StateA` - وضعیت بلاک هنگامی که `PageA` باید رندر شود.
- `StateB` - وضعیت بلاک هنگامی که `PageB` باید رندر شود.

[my_state.dart](_snippets/recipes_flutter_navigation/my_state.dart.md ':include')

#### MyBloc

`MyBloc` ما باید به شکلی شبیه به این باشد:

[my_bloc.dart](_snippets/recipes_flutter_navigation/my_bloc.dart.md ':include')

### لایه رابط کاربری (UI)

حالا بیایید نگاهی به این بیندازیم که چطور `MyBloc` را به یک ویجت متصل کنیم و بر اساس وضعیت بلاک، یک صفحه متفاوت نمایش دهیم.

[main.dart](_snippets/recipes_flutter_navigation/direct_navigation/main.dart.md ':include')

?> ما می‌توانیم از ویجت `BlocBuilder` برای رندر کردن ویجت مناسب در پاسخ به تغییرات وضعیت در `MyBloc` استفاده کنیم.

?> ما از ویجت `BlocProvider` استفاده می‌کنیم تا نمونه `MyBloc` را در دسترس کل درخت ویجت (Widget tree) قرار دهیم.

می‌توانید کد کامل این دستورالعمل را در [اینجا](https://gist.github.com/felangel/386c840aad41c7675ab8695f15c4cb09) پیدا کنید.

## Route Navigation

> در این مثال، قصد داریم بررسی کنیم که چگونه از `BlocListener` برای هدایت به یک صفحه مشخص (ویجت) در پاسخ به تغییر وضعیت در یک بلاک با استفاده از یک مسیر استفاده کنیم.

![demo](./assets/gifs/recipes_flutter_navigation_routes.gif)

### Bloc

ما قصد داریم از همان `MyBloc` در مثال قبلی, استفاده مجدد کنیم.

### لایه رابط کاربری (UI)

بیایید نگاهی به نحوه مسیریابی به صفحه دیگر بر اساس وضعیت `MyBloc` بیندازیم.

[main.dart](_snippets/recipes_flutter_navigation/route_navigation/main.dart.md ':include')

?> ما از ویجت `BlocListener` استفاده می‌کنیم تا در پاسخ به تغییرات وضعیت در `MyBloc`، یک مسیر جدید را ایجاد کنیم.

!> به خاطر این منظور، ما یک رویداد را فقط برای مسیریابی اضافه می‌کنیم. در یک برنامه واقعی، شما باید رویدادهای مسیریابی صریح را ایجاد نکنید. اگر برای ایجاد مسیریابی نیاز به "منطق کسب‌وکار (Business logic)" نباشد، همیشه باید مستقیماً در پاسخ به ورودی کاربر (در تابع `onPressed` و غیره) مسیریابی کنید. تنها در پاسخ به تغییرات وضعیت، اگر برای تعیین مقصد مسیریابی نیاز به "منطق کسب‌وکار" وجود داشته باشد، مسیریابی کنید.

منبع کامل این روش را می‌توانید در [اینجا](https://gist.github.com/felangel/6bcd4be10c046ceb33eecfeb380135dd) پیدا کنید.

## Navigation 2.0

> در این مثال، نگاهی به نحوه استفاده از صفحات API Navigator 2.0 برای مدیریت مسیریابی در پاسخ به تغییرات وضعیت در یک بلاک خواهیم داشت.

?> توجه: ما قصد داریم از [پکیج: flow_builder](https://pub.dev/packages/flow_builder) استفاده کنیم تا کار با رابط برنامه‌نویسی Navigator 2.0 را آسان‌تر کنیم.

### Bloc

با هدف نشان دادن مزایای مسیریاب ها (Navigator's)، ما یک مثال کمی پیچیده‌تر را ایجاد خواهیم کرد.
بیایید `BookBloc` را بسازیم که `BookEvents` را دریافت کرده و آن‌ها را به `BookStates` تبدیل می‌کند.

#### BookEvent

`BookEvent` به دو رویداد پاسخ خواهد داد: انتخاب یک کتاب و عدم انتخاب یک کتاب.

[book_event.dart](_snippets/recipes_flutter_navigation/navigation2/book_event.dart.md ':include')

#### BookState

در وضعیت `BookState`، اگر کاربر بر روی یک کتاب کلیک کند، `BookState` شامل لیستی از کتاب‌ها و یک کتاب انتخاب شده (اختیاری) خواهد بود.

[book_state.dart](_snippets/recipes_flutter_navigation/navigation2/book_state.dart.md ':include')

#### BookBloc

`BookBloc` به هر `BookEvent` پاسخ داده و در پاسخ، وضعیت `BookState` مناسب را ارسال (`emit`) خواهد کرد.

[book_bloc.dart](_snippets/recipes_flutter_navigation/navigation2/book_bloc.dart.md ':include')

### لایه رابط کاربری (UI)

حالا بیایید با استفاده از `FlowBuilder`، بلاک را به رابط کاربری متصل کنیم!

[main.dart](_snippets/recipes_flutter_navigation/navigation2/main.dart.md ':include')

منبع کامل این روش را می‌توانید در [اینجا](https://gist.github.com/felangel/bd3cf504a10c0763a32f7a94e2649369) پیدا کنید.
