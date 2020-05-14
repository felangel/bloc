# 准备开始

?> 为了使用`bloc`你须要安装[Dart SDK](https://dart.dev/get-dart)

## 总览

Bloc是由以下包所组成:

- [bloc](https://pub.dev/packages/bloc) - bloc的核心库
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - 强大的Flutter Widgets可与`bloc`配合使用，以构建快速，反应灵活的移动端应用程序。
- [angular_bloc](https://pub.dev/packages/angular_bloc) - 强大的Angular组件可与`bloc`配合使用，以构建快速的反应式Web应用程序。

## 安装

我们要做的第一件事是将`bloc`的包作为依赖项（dependencies) 添加到我们的`pubspec.yaml`中。

[pubspec.yaml](../_snippets/getting_started/bloc_pubspec.yaml.md ':include')

对于[Flutter]https://flutter.dev/ 的应用程序，我们还需要将`flutter_bloc`包作为依赖项添加到我们的`pubspec.yaml`中 

[pubspec.yaml](../_snippets/getting_started/flutter_bloc_pubspec.yaml.md ':include')

对于[AngularDart]https://angulardart.dev/ 的应用程序，我们还需要将angular_bloc包作为依赖项添加到我们的`pubspec.yaml`中。

[pubspec.yaml](../_snippets/getting_started/angular_bloc_pubspec.yaml.md ':include')

接下来，我们要安装`bloc`.

!> 确保从与`pubspec.yaml`文件相同的目录下运行以下命令。

- 如果是 Dart 或者 AngularDart 的话，运行 `pub get`

- 如果是 Flutter 的话，运行 `flutter packages get`

## 引入（Import)

现在我们已经成功安装了bloc，接下来我们可以创建我们的`main.dart`并导入bloc。

[main.dart](../_snippets/getting_started/bloc_main.dart.md ':include')

对于Flutter应用程序，我们还要导入flutter_bloc。

[main.dart](../_snippets/getting_started/flutter_bloc_main.dart.md ':include')

对于AngularDart应用程序，我们还要导入angular_bloc。

[main.dart](../_snippets/getting_started/angular_bloc_main.dart.md ':include')
