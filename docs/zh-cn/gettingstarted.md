# 入门

?> 为了开始使用 bloc，您必须在计算机上安装[Dart SDK](https://dart.dev/get-dart)

## 概览

Bloc 由几个 pub 包组成：

- [bloc](https://pub.dev/packages/bloc) - 核心 bloc 库
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - 强大的 Flutter Widget，与 bloc 配合使用，以构建快速、响应式移动应用程序。
- [angular_bloc](https://pub.dev/packages/angular_bloc) - 强大的 Angular 组件，与 bloc 配合使用，以构建快速、响应式 Web 应用程序。

## 安装

我们需要做的第一件事是将 bloc 包为依赖项添加到我们的`pubspec.yaml` 中。

```yaml
dependencies:
  bloc: ^3.0.0
```

对于 [Flutter](https://flutter.dev/) 应用程序, 我们还需要将 flutter_bloc 软件包作为依赖项添加到我们的`pubspec.yaml`中。

```yaml
dependencies:
  bloc: ^3.0.0
  flutter_bloc: ^3.2.0
```

对于 [AngularDart](https://angulardart.dev/) 我们还需要将 angular_bloc 软件包作为依赖项添加到我们的`pubspec.yaml`中。

```yaml
dependencies:
  bloc: ^3.0.0
  angular_bloc: ^3.0.0
```

接下来，我们需要安装 bloc。

!> 确保从与`pubspec.yaml`文件相同的目录中运行以下命令。

- 对于 Dart 或 AngularDart 运行 `pub get`

- 对于 Flutter 运行 `flutter packages get`

## 导入

现在我们已经成功安装了 bloc，我们可以创建我们的`main.dart`并导入 bloc。

```dart
import 'package:bloc/bloc.dart';
```

对于 Flutter 应用程序，我们还可以导入 flutter_bloc。

```dart
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
```

对于 AngularDart 应用程序，我们还可以导入 angular_bloc。

```dart
import 'package:bloc/bloc.dart';
import 'package:angular_bloc/angular_bloc.dart';
```
