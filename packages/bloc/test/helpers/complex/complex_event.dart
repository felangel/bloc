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
  int get hashCode => runtimeType.hashCode;
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
  int get hashCode => runtimeType.hashCode;
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
  int get hashCode => runtimeType.hashCode;
}
