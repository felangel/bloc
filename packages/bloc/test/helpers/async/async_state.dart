part of 'async_bloc.dart';

@immutable
class AsyncState {
  final bool isLoading;
  final bool hasError;
  final bool isSuccess;

  AsyncState({this.isLoading, this.hasError, this.isSuccess});

  factory AsyncState.initial() {
    return AsyncState(isLoading: false, hasError: false, isSuccess: false);
  }

  AsyncState copyWith({bool isLoading, bool hasError, bool isSuccess}) {
    return AsyncState(
        isLoading: isLoading ?? this.isLoading,
        hasError: hasError ?? this.hasError,
        isSuccess: isSuccess ?? this.isSuccess);
  }

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AsyncState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          hasError == other.hasError &&
          isSuccess == other.isSuccess;

  @override
  int get hashCode =>
      isLoading.hashCode ^ hasError.hashCode ^ isSuccess.hashCode;

  @override
  String toString() =>
      'AsyncState { isLoading: $isLoading, hasError: $hasError, '
      'isSuccess: $isSuccess }';
}
