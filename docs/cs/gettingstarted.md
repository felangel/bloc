# Začínáme

?> Abyste mohli začít používat bloc, musíte mít na svém počítači nainstalovaný [Dart SDK](https://dart.dev/get-dart).

## Přehled

Bloc obsahuje několik pub balíčků:

- [bloc](https://pub.dev/packages/bloc) - Základní knihovna bloc.
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - Užitečné Flutter widgety pro práci s blocem, určené k vytváření rychlejších, reaktivních mobilních aplikací.
- [angular_bloc](https://pub.dev/packages/angular_bloc) - Užitečné AngularDart komponenty pro práci s blocem, určené k vytváření rychlejších, reaktivních webových aplikací.

## Instalace

První věci, kterou potřebujeme udělat, je přidat jako závislost do našeho `pubspec.yaml` balíček bloc.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

Pro [Flutter](https://flutter.dev/) aplikaci také potřebujeme přidat jako závislost do našeho `pubspec.yaml` balíček flutter_bloc.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

Pro [AngularDart](https://angulardart.dev/) aplikaci také potřebujeme přidat jako závislost do našeho `pubspec.yaml` balíček angular_bloc.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

Jako další potřebujeme nainstalovat bloc.

!> Ujistěte se, že spustíte následující příkazy ze stejné složky, ve které se nachází váš soubor `pubspec.yaml`.

- Pro Dart nebo AngularDart, spustěte `pub get`

- Pro Flutter spustěte `flutter packages get`

## Importování

Nyní, když jsme úspěšně nainstalovali bloc, můžeme vytvořit náš soubor `main.dart` a importovat bloc.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Pro Flutter aplikaci můžeme také importovat flutter_bloc.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

Pro AngularDart aplikaci můžeme také importovat angular_bloc.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
