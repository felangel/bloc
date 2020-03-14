# Başlanğıc

?> Bloc-dan istifadə etməyə başlamaq üçün  sizin cihazınızda [Dart SDK](https://dart.dev/get-dart) yüklənməlidir.

## Icmal

Bloc bir neçə pub paketlərindən ibarətdir:

- [bloc](https://pub.dev/packages/bloc) - Əsas bloc kitabxanası
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Bloc ilə işləyərək, sürətli və reaktiv mobil tətbiqlərin yaradılması üçün güclü Flutter Widget-ləri
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Bloc ilə işləyərək, sürətli və reaktiv veb tətbiqlərin yaradılması üçün gücle Angular Komponentləri

## Quraşdırma

İlk olaraq, biz bloc paketini bizim `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

```yaml
dependencies:
  bloc: ^3.0.0
```

[Flutter](https://flutter.dev/) tətbiqi üçün, biz həmçinin flutter_bloc paketini `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.2.0
```

[AngularDart](https://angulardart.dev/) tətbiqi üçün, biz həmçinin angular_bloc paketini `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

Daha sonra bloc-u quraşdırmağa ehtiyacımız var.

!> Əmin olun ki, aşağıdakı əmri `pubspec.yaml` faylı ilə eyni qovluqda icra edirsiniz.

- Dart və ya AngularDart üçün `pub get` əmrini icra edin

- Flutter üçün `flutter packages get` əmrini icra edin

## Import

Artıq biz bloc-u uğurla quraşdırdıq, `main.dart`-ı yarada və bloc-u import edə bilərik..

```dart
import 'package:bloc/bloc.dart';
```

Flutter tətbiqi üçün biz həmçinin flutter_bloc-u import edə bilərik.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

AngularDart tətbiqi üçün biz həmçinin angular_bloc-u import edə bilərik.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```