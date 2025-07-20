<p align="center">
<img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/logos/bloc_lint.png" height="100" alt="Bloc" />
</p>

<p align="center">
<a href="https://pub.dev/packages/bloc_lint"><img src="https://img.shields.io/pub/v/bloc_lint.svg" alt="Pub"></a>
<a href="https://github.com/felangel/bloc/actions"><img src="https://github.com/felangel/bloc/actions/workflows/main.yaml/badge.svg" alt="build"></a>
<a href="https://codecov.io/gh/felangel/bloc"><img src="https://codecov.io/gh/felangel/Bloc/branch/master/graph/badge.svg" alt="codecov"></a>
<a href="https://github.com/felangel/bloc"><img src="https://img.shields.io/github/stars/felangel/bloc.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev/docs/development/data-and-backend/state-mgmt/options#bloc--rx"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://github.com/Solido/awesome-flutter#standard"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://fluttersamples.com"><img src="https://img.shields.io/badge/flutter-samples-teal.svg?longCache=true" alt="Flutter Samples"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://discord.gg/bloc"><img src="https://img.shields.io/discord/649708778631200778.svg?logo=discord&color=blue" alt="Discord"></a>
<a href="https://github.com/felangel/bloc"><img src="https://tinyurl.com/bloc-library" alt="Bloc Library"></a>
</p>

---

Official lint rules for development when using the bloc state management library.

**Learn more at [bloclibrary.dev](https://bloclibrary.dev)!**

This package is built to work with:

- [bloc](https://pub.dev/packages/bloc)
- [bloc_tools](https://pub.dev/packages/bloc_tools)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [angular_bloc](https://pub.dev/packages/angular_bloc)
- [bloc_concurrency](https://pub.dev/packages/bloc_concurrency)
- [bloc_test](https://pub.dev/packages/bloc_test)
- [hydrated_bloc](https://pub.dev/packages/hydrated_bloc)
- [replay_bloc](https://pub.dev/packages/replay_bloc)

---

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/felangel)]

<table style="background-color: white; border: 1px solid black">
    <tbody>
        <tr>
            <td align="center" style="border: 1px solid black">
                <a href="https://shorebird.dev"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/shorebird.png" width="225"/></a>
            </td>            
            <td align="center" style="border: 1px solid black">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=Github&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=Github_Jan2022_FlutterChat&utm_term=bloc"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/stream.png" width="225"/></a>
            </td>
            <td align="center" style="border: 1px solid black">
                <a href="https://rettelgame.com/"><img src="https://raw.githubusercontent.com/felangel/bloc/master/assets/sponsors/rettel.png" width="225"/></a>
            </td>
        </tr>
    </tbody>
</table>

---

## Quick Start

1. Install the [bloc command-line tools](https://pub.dev/packages/bloc_tools)

   ```sh
   dart pub global activate bloc_tools
   ```

2. Install the [bloc_lint](https://pub.dev/packages/bloc_lint) package

   ```sh
   dart pub add --dev bloc_lint
   ```

3. Add an `analysis_options.yaml` to the root of your project with the
   recommended rules

   ```yaml
   include: package:bloc_lint/recommended.yaml
   ```

4. Run the linter

   ```sh
   bloc lint .
   ```

For more information, check out the [official documentation](https://bloclibrary.dev/lint)

## Recommended Lint Rules

- [avoid_flutter_imports](https://bloclibrary.dev/lint-rules/avoid_flutter_imports)
- [avoid_public_bloc_methods](https://bloclibrary.dev/lint-rules/avoid_public_bloc_methods)
- [avoid_public_fields](https://bloclibrary.dev/lint-rules/avoid_public_fields)
- [prefer_file_naming_conventions](https://bloclibrary.dev/lint-rules/prefer_file_naming_conventions)
- [prefer_void_public_cubit_methods](https://bloclibrary.dev/lint-rules/prefer_void_public_cubit_methods)

## All Lint Rules

- [avoid_flutter_imports](https://bloclibrary.dev/lint-rules/avoid_flutter_imports)
- [avoid_public_bloc_methods](https://bloclibrary.dev/lint-rules/avoid_public_bloc_methods)
- [avoid_public_fields](https://bloclibrary.dev/lint-rules/avoid_public_fields)
- [prefer_bloc](https://bloclibrary.dev/lint-rules/prefer_bloc)
- [prefer_cubit](https://bloclibrary.dev/lint-rules/prefer_cubit)
- [prefer_file_naming_conventions](https://bloclibrary.dev/lint-rules/prefer_file_naming_conventions)
- [prefer_void_public_cubit_methods](https://bloclibrary.dev/lint-rules/prefer_void_public_cubit_methods)

## Dart Versions

- Dart 3: >= 3.7.0

## Maintainers

- [Felix Angelov](https://github.com/felangel)
