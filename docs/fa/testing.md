# آزمایش کردن (Testing)

> Bloc به گونه ای طراحی شده است که آزمایش آن بسیار آسان باشد.

به خاطر سادگی، بیایید تست ها را برای `CounterBloc` که در [مفاهیم اصلی](coreconcepts.md) ایجاد کردیم بنویسیم.

برای مرور مجدد، پیاده سازی `CounterBloc` به شکل زیر است:

[counter_bloc.dart](_snippets/testing/counter_bloc.dart.md ':include')

قبل از اینکه شروع کنیم به نوشتن تست ها، باید یک فریمورک آزمایشی را به وابستگی هایمان اضافه کنیم.

ما باید [test](https://pub.dev/packages/test) و [bloc_test](https://pub.dev/packages/bloc_test) را به `pubspec.yaml` خود اضافه کنیم.

[pubspec.yaml](_snippets/testing/pubspec.yaml.md ':include')

بیایید با ایجاد فایل برای تست `CounterBloc` شروع کنیم، `counter_bloc_test.dart` را ایجاد کنید و بسته تست را وارد کنید.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_imports.dart.md ':include')

بعداز آن، باید `main` و گروه تست خود را ایجاد کنیم.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_main.dart.md ':include')

?> **توجه**: گروه‌ها برای سازماندهی تست‌های فردی (Individual) و همچنین برای ایجاد یک محیط (Context) که در آن می‌توانید یک `setUp` و `tearDown` مشترک را در تمام تست‌های فردی به اشتراک بگذارید، استفاده می‌شوند.

بیایید با ایجاد نمونه‌ای از `CounterBloc` خود که در تمامی تست‌هایمان استفاده خواهد شد، شروع کنیم.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_setup.dart.md ':include')

حالا می‌توانیم شروع به نوشتن تست‌های فردی خود کنیم.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_initial_state.dart.md ':include')

?> **توجه**: می‌توانیم تمامی تست‌های خود را با استفاده از دستور `pub run test` اجرا کنیم.

در این نقطه باید تست اولیه ما را پاس کرده باشیم! حالا بیایید یک تست پیچیده‌تر را با استفاده از بسته [bloc_test](https://pub.dev/packages/bloc_test) بنویسیم.

[counter_bloc_test.dart](_snippets/testing/counter_bloc_test_bloc_test.dart.md ':include')

باید بتوانیم تست‌ها را اجرا کنیم و ببینیم که همه آنها پاس می‌شوند.

این تمام چیزی است که در آن وجود دارد، آزمایش باید سریع باشد و ما باید هنگام ایجاد تغییرات و بازسازی کد خود احساس اطمینان کنیم.

شما می‌توانید به برنامه [Weather App](https://github.com/felangel/bloc/tree/master/examples/flutter_weather) مراجعه کنید تا یک مثال از یک برنامه کاملاً تست شده را ببینید.
