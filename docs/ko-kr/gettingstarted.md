# 시작하기

?> bloc을 사용하기 위해서는 [Dart SDK](https://dart.dev/get-dart)가 설치되어야 합니다.

## 개요

Bloc은 몇 가지 pub pachages로 구성되어 있습니다:

- [bloc](https://pub.dev/packages/bloc) - 핵심 bloc 라이브러리
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - bloc을 이용하여 빠른 반응형 모바일 어플리케이션 개발을 돕는 강력한 Flutter Widget
- [angular_bloc](https://pub.dev/packages/angular_bloc) - bloc을 이용하여 빠른 반응형 웹 어플리케이션 개발을 돕는 강력한 Angular Component
  
## 설치

먼저, `pubspec.yaml`의 dependency로 bloc 패키지를 추가해야 합니다.

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

[Flutter](https://flutter.dev/) 어플리케이션의 경우에는, flutter_bloc 패키지도 같이 `pubspec.yaml`의 dependency로 추가합니다.

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

[AngularDart](https://angulardart.dev/) 어플리케이션의 경우에는, angular_bloc 패키지도 같이 `pubspec.yaml`의 dependency로 추가합니다.

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

이제 bloc을 설치해봅시다.

!> `pubspec.yaml` 파일과 같은 directory에서 다음 명령어를 실행합니다.

- Dart와 AngularDart의 경우에는, `pub get` 명령어를 실행합니다.

- Flutter의 경우에는, `flutter packages get` 명령어를 실행합니다.

## Import

bloc이 성공적으로 설치되었다면, `main.dart`를 생성하고 bloc을 import 합니다.

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

Flutter 어플리케이션의 경우, flutter_bloc도 import 할 수 있습니다.

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

AngularDart 어플리케이션의 경우, angular_bloc도 import 할 수 있습니다.

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
