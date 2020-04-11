# Başlanğıc

?> Bloc-dan istifadə etməyə başlamaq üçün  sizin cihazınızda [Dart SDK](https://dart.dev/get-dart) yüklənməlidir.

## Icmal

Bloc bir neçə pub paketlərindən ibarətdir:

- [bloc](https://pub.dev/packages/bloc) - Əsas bloc kitabxanası
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Bloc ilə işləyərək, sürətli və reaktiv mobil tətbiqlərin yaradılması üçün güclü Flutter Widget-ləri
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Bloc ilə işləyərək, sürətli və reaktiv veb tətbiqlərin yaradılması üçün güclü Angular Komponentləri

## Quraşdırma

İlk olaraq, biz bloc paketini bizim `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

[Flutter](https://flutter.dev/) tətbiqi üçün, biz həmçinin flutter_bloc paketini `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

[AngularDart](https://angulardart.dev/) tətbiqi üçün, biz həmçinin angular_bloc paketini `pubspec.yaml`-a dependency olaraq əlavə etməliyik.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Daha sonra bloc-u quraşdırmağa ehtiyacımız var.

!> Əmin olun ki, aşağıdakı əmri `pubspec.yaml` faylı ilə eyni qovluqda icra edirsiniz.

- Dart və ya AngularDart üçün `pub get` əmrini icra edin

- Flutter üçün `flutter packages get` əmrini icra edin

## Import

Artıq biz bloc-u uğurla quraşdırdıq, `main.dart`-ı yarada və bloc-u import edə bilərik..

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Flutter tətbiqi üçün biz həmçinin flutter_bloc-u import edə bilərik.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

AngularDart tətbiqi üçün biz həmçinin angular_bloc-u import edə bilərik.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
