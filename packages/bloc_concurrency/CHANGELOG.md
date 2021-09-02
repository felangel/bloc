# 0.1.0-dev.1

- feat: initial development release
  - includes `EventTransformer` options:
    - `concurrent`: process events concurrently
    - `sequential`: process events sequentially
    - `droppable`: ignore any events added while an event is processing
    - `restartable`: process only the latest event and cancel previous handlers
