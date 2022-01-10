# Flutter 计数器教程

![beginner](https://img.shields.io/badge/level-beginner-green.svg)

>  在下面的教程中，我们会使用Flutter和Bloc库来开发一个计数器应用。

![demo](../assets/gifs/flutter_counter.gif)

## 核心要点

- [BlocObserver](/coreconcepts?id=blocobserver)：用于观察Bloc内状态变化的Widget。
- [BlocProvider](/flutterbloccoreconcepts?id=blocprovider)：为它的children提供Bloc的Widget。
- [BlocBuilder](/flutterbloccoreconcepts?id=blocbuilder)：根据新的state来绘制对应Widget的Widget。
- 用Cubit替代Bloc。[两者有何不同?](/coreconcepts?id=cubit-vs-bloc)
- 通过 [context.read](/migration?id=❗contextbloc-and-contextrepository-are-deprecated-in-favor-of-contextread-and-contextwatch) 来触发Event⚡。

## 新建项目和配置文件yaml

我们先新建一个全新的flutter应用

```sh
flutter create flutter_counter
```

将下面代码复制粘贴到 `pubspec.yaml` 文件中

[pubspec.yaml](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/pubspec.yaml ':include')

安装依赖包package

```sh
flutter packages get
```

## 项目架构

```
├── lib
│   ├── app.dart
│   ├── counter
│   │   ├── counter.dart
│   │   ├── cubit
│   │   │   └── counter_cubit.dart
│   │   └── view
│   │       ├── counter_page.dart
│   │       └── counter_view.dart
│   ├── counter_observer.dart
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
```

这个应用中我们使用的是功能驱动（feature-driven）的项目结构。这种项目结构可以让我们通过一个个独立的功能来扩展项目。在当前项目中，我们只需要做一个功能（也就是计数器），但是在将来我们可以通过加入更多功能来实现一个复杂的应用。

## BlocObserver

首先，我们需要了解如何创建一个`BlocObserver` ， 它将帮助我们观察应用中所有的状态变化.

创建文件 `lib/counter_observer.dart`:

[counter_observer.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter_observer.dart ':include')

在这个文件中，我们只重写了 `onChange`，用来查看所有产生的状态（state）变化

?> **注意**: `onChange` 在 `Bloc` 和 `Cubit` 中发挥的作用是相同的。

## main.dart

接下来，用下面的代码替换`main.dart` 里面的内容:

[main.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/main.dart ':include')

在上面的代码中，我们初始化了之前创建的 `CounterObserver` 并且通过 `runApp`调用我们即将创建的`CounterApp`。

## Counter App

创建 `lib/app.dart`:

`CounterApp` 是一个`home`是`CounterPage`的`MaterialApp`。

[app.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/app.dart ':include')

?> **注意**: `CounterApp` 扩展（extends)自`MaterialApp`，所以在这里它是一个`MaterialApp`。 在大多数的情况下，我们会创建一个`StatelessWidget` 或者 `StatefulWidget` 实例，并且通过`build`来绘制 Widget。但是现在我们并不需要绘制任何Widget，所以我们直接从`MaterialApp`进行扩展（extends)，这样更简单。

接下来，让我们来看下 `CounterPage`!

## Counter Page 

创建 `lib/counter/view/counter_page.dart`:

`CounterPage` 是用来创建一个 `CounterCubit` 实例(也就是接下来我们要创建的类的实例) 并把它提供给 `CounterView`使用。

[counter_page.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_page.dart ':include')

?> **注意**: 分离（或者解耦）`Cubit` 创建部分的代码和 `Cubit` 使用部分的代码是非常重要的。这样使得代码更容易被测试或者被重复使用。

## Counter Cubit

创建 `lib/counter/cubit/counter_cubit.dart`:

`CounterCubit` 类将提供两种方法:

- `increment`: 给当前状态（state）加1
- `decrement`: 给当前状态（state）减1

设置 `CounterCubit`状态的数据类型为 `int`， 初始值是 `0`。

[counter_cubit.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/cubit/counter_cubit.dart ':include')

?> **小贴士**: 可以使用 [VSCode Extension](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) 或者 [IntelliJ Plugin](https://plugins.jetbrains.com/plugin/12129-bloc) 自动创建新的Cubit。

接下来我们来写`CounterView`，它将使用state并且和`CounterCubit`交互。

## Counter View

创建 `lib/counter/view/counter_view.dart`:

`CounterView` 是用来绘制计数器上的数字以及两个用于增加和减少数字的FloatingActionButtons。

[counter_view.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/view/counter_view.dart ':include')

用`BlocBuilder` 把 `Text` 包起来，这样每一次`CounterCubit`状态变化的时候里面的文字就会更新。 另外，使用`context.read<CounterCubit>()`来接入`CounterCubit`实例。

?> **注意**: 只有 `Text` 需要被 `BlocBuilder`包起来，因为这是唯一一个会随着 `CounterCubit` 状态（state)变化而变化的组件。请不要包裹任何不随状态（state)改变而改变的Widget， 从而避免绘制不必要的组件。

## Barrel 

创建 `lib/counter/counter.dart`:

加入 `counter.dart` 用来导出所有有关计数器的公共接口。

[counter.dart](https://raw.githubusercontent.com/felangel/bloc/master/examples/flutter_counter/lib/counter/counter.dart ':include')

大功告成! 我们已经将表现层（presentation layer）从数据逻辑层（business logic layer）中分离出来。`CounterView`不会知道用户点击按钮的时候发生了什么，它只是通知了 `CounterCubit`。 而且， `CounterCubit` 不会知道状态（也就是计数器的值）是什么， 它只是根据被调用的方法来发出新的状态。

最后，通过执行 `flutter run` 让我们在真实设备或者模拟器上运行它。

本教程的完整代码 (包括单元测试和Widget测试) 请查看 [这里](https://github.com/felangel/Bloc/tree/master/examples/flutter_counter)。
