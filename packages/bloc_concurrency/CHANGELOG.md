# 0.3.0

- chore(deps): upgrade to `package:bloc v9.0.0`
- chore: update sponsors
- chore: add `funding` to `pubspec.yaml`

# 0.2.5

- docs: improve diagrams
- chore: update copyright year
- chore: update sponsors

# 0.2.4

- chore: update sponsors

# 0.2.3

- chore: fix `require_trailing_commas`
- chore(deps): upgrade to `package:mocktail v1.0.0`
- chore: add `topics` to `pubspec.yaml`

# 0.2.2

- docs: upgrade to Dart 3
- refactor: standardize analysis_options

# 0.2.1

- chore: add screenshots to `pubspec.yaml`
- refactor: upgrade to Dart 2.19
  - deps: upgrade to `very_good_analysis 3.1.0`
- docs: update example to follow naming conventions

# 0.2.0

- feat: upgrade to `bloc: ^8.0.0`

# 0.2.0-dev.2

- feat: upgrade to `bloc: ^8.0.0-dev.5`

# 0.2.0-dev.1

- feat: upgrade to `bloc: ^8.0.0-dev.3`

# 0.1.0

- feat: upgrade to `bloc: ^7.2.0`

# 0.1.0-dev.2

- feat: upgrade to `bloc: ^7.2.0-dev.2`

# 0.1.0-dev.1

- feat: initial development release
  - includes `EventTransformer` options:
    - `concurrent`: process events concurrently
    - `sequential`: process events sequentially
    - `droppable`: ignore any events added while an event is processing
    - `restartable`: process only the latest event and cancel previous handlers
