# 0.1.0-dev.8

- feat: add `bloc new <template>` command

  ```sh
  $ bloc new --help
  Generate new bloc components.

  Usage: bloc new <subcommand> [arguments]
  -h, --help    Print this usage information.

  Available subcommands:
    bloc             Generate a new Bloc in Dart. Built for the bloc state management library.
    cubit            Generate a new Cubit in Dart. Built for the bloc state management library.
    hydrated_bloc    Generate a new HydratedBloc in Dart. Built for the bloc state management library.
    hydrated_cubit   Generate a new HydratedCubit in Dart. Built for the bloc state management library.
    replay_bloc      Generate a new ReplayBloc in Dart. Built for the bloc state management library.
    replay_cubit     Generate a new ReplayCubit in Dart. Built for the bloc state management library.

  Run "bloc help" to see global options.
  ```

- chore: bump minimum Dart SDK version to 3.7.0

# 0.1.0-dev.7

- fix: version constant
- chore(deps): upgrade to `pub_updater ^0.5.0`

# 0.1.0-dev.6

- chore: add screenshot to `pubspec.yaml`
- chore(deps): upgrade to `mocktail ^1.0.0`
- chore: add `topics` to `pubspec.yaml`
- chore: update copyright year
- chore: update logos

# 0.1.0-dev.5

- refactor: standardize analysis options
- deps: remove `package:universal_io`
- deps: upgrade to `pub_updater ^0.3.0`
- deps: upgrade to `mason ^0.1.0-dev.33`

# 0.1.0-dev.4

- feat: improve update prompt style

# 0.1.0-dev.3

- fix: upgrade to `pub_updater ^0.2.1`

# 0.1.0-dev.2

- feat: automatic update support
- docs: minor README improvements

# 0.1.0-dev.1

- feat: initial development release
  - includes `help` command for usage
  - includes `--version` flag
