# شروع به کار (Getting Started)

?> برای استفاده از Bloc باید [Dart SDK](https://dart.dev/get-dart) را در دستگاه خود نصب کنید.

## بررسی کلی

Bloc از چندین بسته pub تشکیل شده است.

- [bloc](https://pub.dev/packages/bloc) - کتابخانه اصلی Bloc
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - ویجت‌های قدرتمند Flutter که برای کار با bloc ساخته شده‌اند تا بتوانید برنامه‌های موبایل پویا و واکنش‌پذیر را ایجاد کنید.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - ویژگی‌های قدرتمند برای Angular که برای کار با Bloc طراحی شده‌اند تا بتوانید برنامه‌های وب پویا و واکنش‌پذیر را ایجاد کنید.
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc) - یک افزونه برای کتابخانه مدیریت وضعیت Bloc که به طور خودکار وضعیت‌های Bloc را ذخیره و بازیابی می‌کند.
- [replay_bloc](https://pub.dev/packages/replay_bloc) - یک افزونه برای کتابخانه مدیریت وضعیت Bloc که قابلیت پشتیبانی از عملیات واگرد (Undo) و اَزنو (Redo) را اضافه می‌کند.

## نصب

برای یک برنامه [Dart](https://dart.dev/)، باید بسته `bloc` را به `pubspec.yaml` به عنوان یک وابستگی اضافه کنیم.

[pubspec.yaml](_snippets/getting_started/bloc_pubspec.yaml.md ':include')

برای یک برنامه [Flutter](https://flutter.dev/)، باید بسته `flutter_bloc` را به `pubspec.yaml` به عنوان یک وابستگی اضافه کنید.

[pubspec.yaml](_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

برای یک برنامه [AngularDart](https://angulardart.dev/)، ما باید بسته `angular_bloc` را به `pubspec.yaml` به عنوان وابستگی اضافه کنیم.

[pubspec.yaml](_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

بعداز این کار باید Bloc را نصب کنیم.

!> از همان مسیر دایرکتوری که فایل `pubspec.yaml` شما قرار دارد، اطمینان حاصل کنید که دستور زیر را اجرا کرده اید.

- برای Dart یا AngularDart دستور `pub get` را اجرا کنید

- برای فلاتر، `flutter packages get` را اجرا کنید

## وارد كردن

حالا که با موفقیت Bloc را نصب کردیم، می‌توانیم `main.dart` خود را ایجاد کنیم و `bloc` را وارد کنیم.

[main.dart](_snippets/getting_started/bloc_main.dart.md ':include')

برای یک برنامه فلاتر، می‌توانیم `flutter_bloc` را وارد کنیم.

[main.dart](_snippets/getting_started/flutter_bloc_main.dart.md ':include')

برای یک برنامه AngularDart، می‌توانیم `angular_bloc` را وارد کنیم.

[main.dart](_snippets/getting_started/angular_bloc_main.dart.md ':include')
