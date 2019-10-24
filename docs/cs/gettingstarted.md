# Začínáme

?> Abyste mohli začít používat bloc, musíte mít na svém počítači nainstalovaný [Dart SDK](https://www.dartlang.org/install).

## Přehled

Bloc obsahuje několik pub balíčků:

- [bloc](https://pub.dev/packages/bloc) - Základní knihovna bloc.
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Výkonné Flutter widgety vytvořené k práci s bloc, určené k vytváření rychlejších, reaktivních mobilních aplikací.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Výkonné AngularDart komponenty vytvořené k práci s bloc, určené k vytváření rychlejších, reaktivních webových aplikací.

## Instalace

První věci, kterou potřebujeme udělat je přidání balíčku bloc do našeho `pubspec.yaml` jako závislost.

```yaml
dependencies:
  bloc: ^1.0.0
```

Pro [Flutter](https://flutter.io) aplikaci také potřebujeme do našeho `pubspec.yaml` přidat balíček flutter_bloc jako závislost.

```yaml
dependencies:
  bloc: ^1.0.0
  flutter_bloc: ^1.0.0
```

Pro [AngularDart](https://webdev.dartlang.org/angular) aplikaci také potřebujeme do našeho `pubspec.yaml` přidat balíček angular_bloc jako závislost.

```yaml
dependencies:
  bloc: ^1.0.0
  angular_bloc: ^1.0.0
```

Jako další potřebujeme nainstalovat bloc.

!> Ujistěte se, že spustíte následující příkazy ze stejné složky, ve které se nachází váš soubor `pubspec.yaml`.

- Pro Dart nebo AngularDart, spustěte `pub get`

- Pro Flutter spustěte `flutter packages get`

## Importování

Nyní, když jsme úspěšně nainstalovali bloc, můžeme vytvořit náš soubor `main.dart` a importovat bloc.

```dart
import 'package:bloc/bloc.dart';
```

Pro Flutter aplikaci můžeme také importovat flutter_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

Pro AngularDart aplikaci můžeme také importovat angular_bloc.

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
