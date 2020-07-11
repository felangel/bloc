part of 'complex_bloc.dart';

@immutable
abstract class ComplexState {}

class ComplexStateA extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateA && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class ComplexStateB extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateB && runtimeType == other.runtimeType;

  @override
  int get hashCode => 1;
}

class ComplexStateC extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateC && runtimeType == other.runtimeType;

  @override
  int get hashCode => 2;
}

class ComplexStateD extends ComplexState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexStateD && runtimeType == other.runtimeType;

  @override
  int get hashCode => 3;
}
