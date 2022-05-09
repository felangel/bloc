```dart
class BadBloc extends Bloc {
  final OtherBloc otherBloc;
  late final StreamSubscription otherBlocSubscription;

  MyBloc(this.otherBloc) {
    // No matter how much you are tempted to do this, you should not do this!
    // Keep reading for better alternatives!
    otherBlocSubscription = otherBloc.stream.listen((state) {
      add(MyEvent())
    });
  }

  @override
  Future<void> close() {
    otherBlocSubscription.cancel();
    return super.close();
  }
}
```
