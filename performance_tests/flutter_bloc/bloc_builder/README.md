# BlocBuilder Performance Tests

Integration Tests which test the performance of BlocBuilder variants.

## Running the tests

```
flutter drive --target=test_driver/main.dart --driver=test_driver/driver/bloc_builder_performance_test.dart
```

## Results

|                  | StreamBuilder | BlocStreamBuilder |
| ---------------- | ------------- | ----------------- |
| Avg Frame (ms)   | 1.29          | 1.21              |
| Worst Frame (ms) | 9.1           | 8.88              |

**Average across 10 runs*

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).
