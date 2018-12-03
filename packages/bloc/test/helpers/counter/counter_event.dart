abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is Increment && runtimeType == other.runtimeType;

  @override
  int get hashCode => 7;

  String toString() => 'Increment';
}

class Decrement extends CounterEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is Decrement && runtimeType == other.runtimeType;

  @override
  int get hashCode => 8;

  @override
  String toString() => 'Decrement';
}
