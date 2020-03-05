# 准备开始

?> 为了使用`bloc`你须要安装[Dart SDK](https://dart.dev/get-dart)

## 总览

Bloc是由以下包所组成:

- [bloc](https://pub.dev/packages/bloc) - bloc的核心库
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - 强大的Flutter Widgets可与`bloc`配合使用，以构建快速，反应灵活的移动端应用程序。
- [angular_bloc](https://pub.dev/packages/angular_bloc) - 强大的Angular组件可与`bloc`配合使用，以构建快速的反应式Web应用程序。

## 安装

我们要做的第一件事是将`bloc`的包作为依赖项（dependencies) 添加到我们的`pubspec.yaml`中。

```yaml
dependencies:
  bloc: ^3.0.0
```

对于[Flutter]https://flutter.dev/ 的应用程序，我们还需要将`flutter_bloc`包作为依赖项添加到我们的`pubspec.yaml`中 

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.2.0
```

对于[AngularDart]https://angulardart.dev/ 的应用程序，我们还需要将angular_bloc包作为依赖项添加到我们的`pubspec.yaml`中。

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

接下来，我们要安装`bloc`.

!> 确保从与`pubspec.yaml`文件相同的目录下运行以下命令。

- 如果是 Dart 或者 AngularDart 的话，运行 `pub get`

- 如果是 Flutter 的话，运行 `flutter packages get`

## 引入（Import)

现在我们已经成功安装了bloc，接下来我们可以创建我们的`main.dart`并导入bloc。

```dart
import 'package:bloc/bloc.dart';
```

对于Flutter应用程序，我们还要导入flutter_bloc。

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

对于AngularDart应用程序，我们还要导入angular_bloc。

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
