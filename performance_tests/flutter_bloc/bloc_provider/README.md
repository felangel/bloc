# BlocProvider Performance Tests

Integration Tests which test the performance of BlocProvider variants.

## Running the tests

```
flutter drive --target=test_driver/main.dart --driver=test_driver/driver/bloc_provider_performance_test.dart
```

## Results

**I + A**: `InheritedWidget` + `ancestorWidgetOfExactType`

**S + A**: `StatelessWidget` + `ancestorWidgetOfExactType`

**I + I**: `InheritedWidget` + `inheritFromWidgetOfExactType`

**SF + AI**: `StatefulWidget` + `InheritedWidget` + `ancestorInheritedElementForWidgetOfExactType`

**S + AI**: `StatelessWidget` + `InheritedWidget` + `ancestorInheritedElementForWidgetOfExactType`

**I + AI**: `InheritedWidget` + `ancestorInheritedElementForWidgetOfExactType`

|                  | I + A  | S + A | I + I  | SF + AI | S + AI | I + AI |
| ---------------- | ------ | ----- | ------ | ------- | ------ | ------ |
| Avg Frame (ms)   | 1.363  | 1.159 | 1.446  | 1.145   | 1.249  | 1.100  |
| Worst Frame (ms) | 12.157 | 9.967 | 10.348 | 8.350   | 10.811 | 8.969  |

**Average across 10 runs*

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).
