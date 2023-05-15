part of 'async_bloc.dart';

@immutable
class AsyncState {
  const AsyncState({
    required this.isLoading,
    required this.hasError,
    required this.isSuccess,
  });

  factory AsyncState.initial() {
    return const AsyncState(
      isLoading: false,
      hasError: false,
      isSuccess: false,
    );
  }

  final bool isLoading;
  final bool hasError;
  final bool isSuccess;

  AsyncState copyWith({bool? isLoading, bool? hasError, bool? isSuccess}) {
    return AsyncState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
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
