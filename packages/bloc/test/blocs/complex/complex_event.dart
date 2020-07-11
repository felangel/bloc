part of 'complex_bloc.dart';

@immutable
abstract class ComplexEvent {}

class ComplexEventA extends ComplexEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexEventA && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class ComplexEventB extends ComplexEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexEventB && runtimeType == other.runtimeType;

  @override
  int get hashCode => 1;
}

class ComplexEventC extends ComplexEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexEventC && runtimeType == other.runtimeType;

  @override
  int get hashCode => 2;
}

class ComplexEventD extends ComplexEvent {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexEventD && runtimeType == other.runtimeType;

  @override
  int get hashCode => 3;
}
