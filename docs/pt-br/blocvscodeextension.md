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

Bloc pode ser instalado a partir do [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=FelixAngelov.bloc) ou [pesquisando no VSCode](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Comandos

| Comando            | Descrição           |
| ------------------ | ------------------- |
| `Bloc: New Bloc`   | Criar um novo Bloc  |
| `Cubit: New Cubit` | Criar um novo Cubit |

Você pode ativar o comando iniciando a paleta de comandos (Exibir -> Paleta de Comandos) e executando o comando.
Ou você pode clicar com o botão direito do mouse no diretório em que deseja criar o bloc/cubit e selecionar o comando no menu de contexto.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage.gif)

## Ações de código

| Ação                           | Descrição                                         |
| ------------------------------ | ------------------------------------------------- |
| `Wrap with BlocBuilder`        | Envolve o widget atual em um `BlocBuilder`        |
| `Wrap with BlocListener`       | Envolve o widget atual em um `BlocListener`       |
| `Wrap with BlocConsumer`       | Envolve o widget atual em um `BlocConsumer`       |
| `Wrap with BlocProvider`       | Envolve o widget atual em um `BlocProvider`       |
| `Wrap with RepositoryProvider` | Envolve o widget atual em um `RepositoryProvider` |

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/wrap-with-usage.gif)

## Snippets

### Bloc

| Atalho              | Descrição                                  |
| ------------------- | ------------------------------------------ |
| `bloc`              | Cria uma classe `Bloc`                     |
| `cubit`             | Cria uma classe `Cubit`                    |
| `blocobserver`      | Cria uma classe `BlocObserver`             |
| `blocprovider`      | Cria um widget `BlocProvider`              |
| `multiblocprovider` | Cria um widget `MultiBlocProvider`         |
| `repoprovider`      | Cria um widget `RepositoryProvider`        |
| `multirepoprovider` | Cria um widget `MultiRepositoryProvider`   |
| `blocbuilder`       | Cria um widget `BlocBuilder`               |
| `bloclistener`      | Cria um widget `BlocListener`              |
| `multibloclistener` | Cria um widget `MultiBlocListener`         |
| `blocconsumer`      | Cria um widget `BlocConsumer`              |
| `blocof`            | Atalho para `BlocProvider.of()`            |
| `repoof`            | Atalho para `RepositoryProvider.of()`      |
| `read`              | Atalho para `context.read()`               |
| `watch`             | Atalho para `context.watch()`              |
| `select`            | Atalho para `context.select()`             |
| `blocstate`         | Cria uma classe state                      |
| `blocevent`         | Cria uma classe event                      |

### Freezed Bloc

| Atalho       | Descrição                                                             |
| ------------ | --------------------------------------------------------------------- |
| `feventwhen` | Cria uma função de mapear evento para estado com a função freeze.when |
| `feventmap`  | Cria uma função de mapear evento para estado com a função freeze.map  |
| `fstate`     | Cria um sub state                                                     |
| `fevent`     | Cria um sub event                                                     |
