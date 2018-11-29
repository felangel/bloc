abstract class PostEvent {}

class Fetch extends PostEvent {
  @override
  String toString() => 'Fetch';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fetch && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
