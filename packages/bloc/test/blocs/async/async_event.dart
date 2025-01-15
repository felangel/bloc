part of 'async_bloc.dart';

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
  int get hashCode => Object.hashAll([runtimeType]);

  @override
  String toString() => 'AsyncEvent';
}
