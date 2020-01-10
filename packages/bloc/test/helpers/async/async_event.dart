import 'package:meta/meta.dart';

@immutable
class AsyncEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AsyncEvent && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AsyncEvent';
}
