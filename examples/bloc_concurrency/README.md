A Flutter app that uses [BlocConcurrency](https://pub.dev/packages/bloc_concurrency).

## 🔄 Transformers

- **`sequential()`** – Processes one event at a time in the order received; waits for the previous to finish.  

  ![Sequential Demo](output/gifs/sequential.gif)

- **`concurrent()`** – Processes all incoming events simultaneously in parallel.  

  ![Concurrent Demo](output/gifs/concurrent.gif)

- **`droppable()`** – Drops new events if a previous one is still being processed.  

  ![Droppable Demo](output/gifs/droppable.gif)

- **`restartable()`** – Cancels the currently processing event and starts the latest one.

  ![Restartable Demo](output/gifs/restartable.gif)

- **`debounceTime(Duration)`** – Delays event handling until a quiet period passes (e.g. user stops typing).  

  ![Debounce Demo](output/gifs/debounce.gif)

- **`throttleTime(Duration)`** – Limits event processing to one per time window, ignoring rapid bursts.  

  ![Throttle Demo](output/gifs/throttle.gif)
