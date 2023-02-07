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
