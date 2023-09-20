# آموزش شمارنده انگولار دارت

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

> در آموزش زیر قصد داریم با استفاده از کتابخانه Bloc یک Counter در انگولار دارت بسازیم.

![demo](./assets/gifs/angular_counter.gif)

## راه اندازی

ما با ایجاد یک پروژه جدید انگولار دارت با [stagehand](https://github.com/dart-lang/stagehand) شروع خواهیم کرد.

[script](_snippets/angular_counter_tutorial/stagehand.sh.md ':include')

!> برای فعال‌سازی ابزار stagehand دستور `dart pub global activate stagehand` را اجرا کنید.

سپس می توانیم  محتوای `pubspec.yaml` را با موارد زیر جایگزین کنیم:

[pubspec.yaml](_snippets/angular_counter_tutorial/pubspec.yaml.md ':include')

و در ادامه وابستگی های را نصب کنید

[script](_snippets/angular_counter_tutorial/install.sh.md ':include')

برنامه شمارنده ما فقط دو دکمه برای افزایش/کاهش مقدار شمارنده و یک عنصر برای نمایش مقدار فعلی دارد. بیایید طراحی `CounterEvents` را شروع کنیم.

## رویدادهای شمارنده

[counter_event.dart](_snippets/angular_counter_tutorial/counter_event.dart.md ':include')

## وضعیت‌های شمارنده

از آنجایی که وضعیت شمارنده ما می تواند با یک عدد صحیح نمایش داده شود، نیازی به ایجاد یک کلاس سفارشی نداریم!

## کلاس Bloc شمارنده

[counter_bloc.dart](_snippets/angular_counter_tutorial/counter_bloc.dart.md ':include')

?> **نکته**: فقط از تعریف کلاس می توانیم بگوییم که `CounterBloc` ما، `CounterEvents` را به عنوان ورودی و خروجی اعداد صحیح می گیرد.

## اپلیکیشن شمارنده

اکنون که `CounterBloc` خود را به طور کامل پیاده‌سازی کرده‌ایم، می‌توانیم ایجاد کامپوننت برنامه انگولار دارت خود را شروع کنیم.

 فایل `app.component.dart` ما باید به شکل زیر باشد:

[app.component.dart](_snippets/angular_counter_tutorial/app_component.dart.md ':include')

 و فایل `app.component.html` باید به شکل زیر باشد:

[app.component.html](_snippets/angular_counter_tutorial/app_component.html.md ':include')

## صفحه‌ی شمارنده

در نهایت، تنها چیزی که باقی می ماند ساختن کامپوننت صفحه شمارنده است.

 فایل `counter_page_component.dart` ما باید به شکل زیر باشد:

[counter_page_component.dart](_snippets/angular_counter_tutorial/counter_page_component.dart.md ':include')

?> **نکته**: ما می توانیم با استفاده از سیستم تزریق وابستگی انگولار دارت به نمونه `CounterBloc` دسترسی پیدا کنیم. از آنجایی که ما آن را به عنوان یک `Provider` ثبت کرده ایم، انگولار دارت می تواند `CounterBloc` را به درستی حل کند.

?> **نکته**: ما `CounterBloc` را در `ngOnDestroy` می بندیم.

?> **نکته**: ما `BlocPipe` را وارد می کنیم تا بتوانیم از آن در قالب خود استفاده کنیم.

در نهایت، `counter_page_component.html` ما باید به شکل زیر باشد:

[counter_page_component.html](_snippets/angular_counter_tutorial/counter_page_component.html.md ':include')

?> **نکته**: ما از `BlocPipe` استفاده می‌کنیم تا بتوانیم حالت `CounterBloc` خود را هنگام به‌روزرسانی نمایش دهیم.

خودشه! ما لایه ارائه خود را از لایه لاجیک (منطق تجاری) خود، جدا کرده ایم. `CounterPageComponent` ما نمی‌داند وقتی کاربر یک دکمه را فشار می‌دهد چه اتفاقی می‌افتد; فقط یک رویداد اضافه می کند تا به `CounterBloc` اطلاع دهد. به‌علاوه، `CounterBloc` ما هیچ اطلاعاتی از اینکه وضعیت چگونه است (مقدار شمارنده) ندارد؛ فقط `CounterEvents` را به اعداد صحیح تبدیل می‌کند.

ما می توانیم برنامه خود را با `webdev serve` اجرا و آن را [به صورت محلی](http://localhost:8080) مشاهده کنیم.

منبع کامل این مثال را می توانید در [اینجا](https://github.com/felangel/Bloc/tree/master/examples/angular_counter) بیابید.
