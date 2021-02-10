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

## Introdução

Plugin Bloc para [IntelliJ](https://www.jetbrains.com/idea/) e [Android Studio](https://developer.android.com/studio/) com suporte para o [Bloc](https://bloclibrary.dev) e provê ferramentas para criar [Blocs](https://github.com/felangel/bloc) e [Cubits](https://github.com/felangel/cubit) eficientemente para apps [Flutter](https://flutter.dev/) e [AngularDart](https://angulardart.dev/).

## Instalação

Bloc pode ser instalado a partir de [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [searching within VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Comandos

| Comando            | Description   |
| ------------------ | ------------- |
| `Bloc: New Bloc`   | Criar o Bloc  |
| `Cubit: New Cubit` | Criar o Cubit |

Você pode ativar o comando iniciando a paleta de comandos (Exibir -> Paleta de Comandos) e executando o comando.
Ou você pode clicar com o botão direito do mouse no diretório em que deseja criar o bloc/cubit e selecionar o comando no menu de contexto.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## Code Actions

| Action                         | Description                                    |
| ------------------------------ | ---------------------------------------------- |
| `Wrap with BlocBuilder`        | Wraps current widget in a `BlocBuilder`        |
| `Wrap with BlocListener`       | Wraps current widget in a `BlocListener`       |
| `Wrap with BlocConsumer`       | Wraps current widget in a `BlocConsumer`       |
| `Wrap with BlocProvider`       | Wraps current widget in a `BlocProvider`       |
| `Wrap with RepositoryProvider` | Wraps current widget in a `RepositoryProvider` |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## Snippets

### Bloc

| Shortcut            | Description                                |
| ------------------- | ------------------------------------------ |
| `bloc`              | Creates a `Bloc` class                     |
| `cubit`             | Creates a `Cubit` class                    |
| `blocobserver`      | Creates a `BlocObserver` class             |
| `blocprovider`      | Creates a `BlocProvider` widget            |
| `multiblocprovider` | Creates a `MultiBlocProvider` widget       |
| `repoprovider`      | Creates a `RepositoryProvider` widget      |
| `multirepoprovider` | Creates a `MultiRepositoryProvider` widget |
| `blocbuilder`       | Creates a `BlocBuilder` widget             |
| `bloclistener`      | Creates a `BlocListener` widget            |
| `multibloclistener` | Creates a `MultiBlocListener` widget       |
| `blocconsumer`      | Creates a `BlocConsumer` widget            |
| `blocof`            | Shortcut for `BlocProvider.of()`           |
| `repoof`            | Shortcut for `RepositoryProvider.of()`     |
| `read`              | Shortcut for `context.read()`              |
| `watch`             | Shortcut for `context.watch()`             |
| `select`            | Shortcut for `context.select()`            |
| `blocstate`         | Creates a state class                      |
| `blocevent`         | Creates an event class                     |

### Freezed Bloc

| Shortcut     | Description                                                     |
| ------------ | --------------------------------------------------------------- |
| `feventwhen` | Creates a map event to state function with freeze.when function |
| `feventmap`  | Creates a map event to state function with freeze.map function  |
| `fstate`     | Creates a sub state                                             |
| `fevent`     | Creates a sub event                                             |
