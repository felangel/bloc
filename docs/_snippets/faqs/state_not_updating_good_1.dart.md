```dart
sealed class MyState extends Equatable {
    const MyState();
}

final class StateA extends MyState {
    final String property;

    const StateA(this.property);

    @override
    List<Object> get props => [property]; // pass all properties to props
}
```
