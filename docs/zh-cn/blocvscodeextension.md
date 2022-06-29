<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/docs/assets/bloc_logo_full.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://github.com/felangel/bloc/actions"><img src="https://img.shields.io/github/workflow/status/felangel/bloc/build.svg?logo=github" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/version-short/FelixAngelov.bloc.svg" alt="Version"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/installs-short/FelixAngelov.bloc.svg" alt="Installs"></a>
<a href="https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc"><img src="https://vsmarketplacebadge.apphb.com/rating-short/FelixAngelov.bloc.svg" alt="Ratings"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="http://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

## 总览

[VSCode](https://code.visualstudio.com/) 支持 [Bloc Library](https://bloclibrary.dev)，并且为 [Flutter](https://flutter.dev/) 和 [AngularDart](https://angulardart.dev/) 移动端应用程序，提供有效的 [Blocs](https://github.com/felangel/bloc) 和 [Cubits](https://github.com/felangel/cubit) 支持。

## 安装

`bloc`可以从 [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) 或者 [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension) 安装。

## 命令

| 命令                | 描述                  |
| ------------------ | -------------------- |
| `Bloc: New Bloc`   | 创建一个新的    `bloc` |
| `Cubit: New Cubit` | 创建一个新的    `Cubit`|

你可以通过启动命令面板(查看 -> 命令面板)并输入命令名运行来激活这些命令，或者你可以右键单击你想要创建 bloc/cubit 的目录并从上下文菜单中选择该命令。

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## 代码操作

| 操作                            | 描述                               |
| ------------------------------ | -----------------------------------|
| `Wrap with BlocBuilder`        | 将现有插件包装成 `BlocBuilder`        |
| `Wrap with BlocListener`       | 将现有插件包装成 `BlocListener`       |
| `Wrap with BlocConsumer`       | 将现有插件包装成 `BlocConsumer`       |
| `Wrap with BlocProvider`       | 将现有插件包装成 `BlocProvider`       |
| `Wrap with RepositoryProvider` | 将现有插件包装成 `RepositoryProvider` |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## 代码片段

### Bloc

| 捷径                  | 描述                                  |
| ------------------- | --------------------------------------|
| `bloc`              | 创建一个新的`Bloc`类                     |
| `cubit`             | 创建一个新的`Cubit`类                    |
| `blocobserver`      | 创建一个新的`BlocObserver`类             |
| `blocprovider`      | 创建一个新的`BlocProvider`插件            |
| `multiblocprovider` | 创建一个新的`MultiBlocProvider`插件       |
| `repoprovider`      | 创建一个新的`RepositoryProvider`插件      |
| `multirepoprovider` | 创建一个新的`MultiRepositoryProvider`插件 |
| `blocbuilder`       | 创建一个新的`BlocBuilder`插件             |
| `bloclistener`      | 创建一个新的`BlocListener`插件            |
| `multibloclistener` | 创建一个新的`MultiBlocListener`插件       |
| `blocconsumer`      | 创建一个新的`BlocConsumer`插件            |
| `blocof`            | `BlocProvider.of()`的快捷方式            |
| `repoof`            | `RepositoryProvider.of()`的快捷方式          |
| `read`              | `context.read()`的快捷方式                   |
| `watch`             | `context.watch()`的快捷方式         |
| `select`            | `context.select()`的快捷方式       |
| `blocstate`         | 创建一个新的状态类                        |
| `blocevent`         | 创建一个新的事件类                        |

### 冻结 Bloc

| 捷径          | 描述                                            |
| ------------ | ---------------------------------------------- |
| `feventwhen` | `freeze.when`函数用于创建对于状态函数的map事件      |
| `feventmap`  | `freeze.map`函数用于创建对于状态函数的map事件       |
| `fstate`     | 创建一个分类状态                                 |
| `fevent`     | 创建一个分类事件                                 |
