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
<a href="https://discord.gg/Hc5KD3g"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
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

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-1.gif)

Ou você pode clicar com o botão direito do mouse no diretório em que deseja criar o bloc/cubit e selecionar o comando no menu de contexto.

![demo](https://raw.githubusercontent.com/felangel/bloc/master/extensions/vscode/assets/new-bloc-usage-2.gif)

## Snippets de Uso

### Bloc

| Shortcut                  | Description                                          |
| ------------------------- | ---------------------------------------------------- |
| `bloc`                    | Creates a Bloc Class                                 |
| `blocbuilder`             | Creates a BlocBuilder Widget                         |
| `bloclistener`            | Creates a BlocListener Widget                        |
| `multibloclistener`       | Creates a MultiBlocListener Widget                   |
| `blocconsumer`            | Creates a BlocConsumer Widget                        |
| `blocprovider`            | Creates a BlocProvider Widget                        |
| `multiblocprovider`       | Creates a MultiBlocProvider Widget                   |
| `repositoryprovider`      | Creates a RepositoryProvider Widget                  |
| `multirepositoryprovider` | Creates a MultiRepositoryProvider Widget             |
| `blocobserver`            | Creates a BlocObserver Class                         |
| `contextbloc`             | Shortcut for `context.bloc<MyBloc>()`                |
| `blocof`                  | Shortcut for `BlocProvider.of<MyBloc>()`             |
| `contextrepository`       | Shortcut for `context.repository<MyRepository>()`    |
| `repositoryof`            | Shortcut for `RepositoryProvider.of<MyRepository>()` |

### Cubit

| Shortcut             | Description                                |
| -------------------- | ------------------------------------------ |
| `cubit`              | Creates a Cubit Class                      |
| `cubitbuilder`       | Creates a CubitBuilder Widget              |
| `cubitlistener`      | Creates a CubitListener Widget             |
| `multicubitlistener` | Creates a MultiCubitListener Widget        |
| `cubitconsumer`      | Creates a CubitConsumer Widget             |
| `cubitprovider`      | Creates a CubitProvider Widget             |
| `multicubitprovider` | Creates a MultiCubitProvider Widget        |
| `contextcubit`       | Shortcut for `context.cubit<MyCubit>()`    |
| `cubitof`            | Shortcut for `CubitProvider.of<MyCubit>()` |
