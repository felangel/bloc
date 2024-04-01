import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

const _delay = Duration(milliseconds: 100);

class ComplexException implements Exception {
  ComplexException([this.message]);

  final String? message;
}

abstract class ComplexStreamEvent {}

class OnEachWrongErrorTypeOnError extends ComplexStreamEvent {}

class OnEachComplexWithoutOnError extends ComplexStreamEvent {}

class OnEachComplexOnError extends ComplexStreamEvent {}

class ForEachWrongErrorTypeOnError extends ComplexStreamEvent {}

class ForEachComplexWithoutOnError extends ComplexStreamEvent {}

class ForEachComplexOnError extends ComplexStreamEvent {}

class OnComplexFailure extends ComplexStreamEvent {
  OnComplexFailure(this.e);
  final ComplexException e;
}

@immutable
abstract class ComplexStreamState {}

class ComplexDataState extends ComplexStreamState {
  ComplexDataState(this.i);
  final int i;

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexDataState &&
          runtimeType == other.runtimeType &&
          i == other.i;

  @override
  int get hashCode => i;
}

class ComplexFailureState extends ComplexStreamState {
  ComplexFailureState(this.e);
  final ComplexException e;

  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is ComplexFailureState &&
          runtimeType == other.runtimeType &&
          e == other.e;

  @override
  int get hashCode => e.message.hashCode;
}

class ComplexStreamBloc extends Bloc<ComplexStreamEvent, ComplexStreamState> {
  ComplexStreamBloc(Stream<int> stream) : super(ComplexDataState(0)) {
    on<OnEachWrongErrorTypeOnError>(
      (_, emit) async {
        await emit.onEach<int, Error>(
          stream,
          onData: (i) =>
              Future<void>.delayed(_delay, () => emit(ComplexDataState(i))),
          onError: (_, __) => emit(ComplexDataState(-1)),
        );
      },
    );
    on<OnEachComplexWithoutOnError>(
      (_, emit) async {
        await emit.onEach<int, ComplexException>(
          stream,
          onData: (i) =>
              Future<void>.delayed(_delay, () => emit(ComplexDataState(i))),
        );
      },
    );
    on<OnEachComplexOnError>(
      (_, emit) async {
        await emit.onEach<int, ComplexException>(
          stream,
          onData: (i) =>
              Future<void>.delayed(_delay, () => emit(ComplexDataState(i))),
          onError: (e, _) => emit(ComplexFailureState(e)),
        );
      },
    );

    on<ForEachWrongErrorTypeOnError>(
      (_, emit) async {
        await emit.forEach<int, Error>(
          stream,
          onData: (i) => ComplexDataState(i),
          onError: (_, __) => ComplexDataState(-1),
        );
      },
    );
    on<ForEachComplexWithoutOnError>(
      (_, emit) async {
        await emit.onEach<int, ComplexException>(
          stream,
          onData: (i) =>
              Future<void>.delayed(_delay, () => emit(ComplexDataState(i))),
        );
      },
    );
    on<ForEachComplexOnError>(
      (_, emit) async {
        await emit.forEach<int, ComplexException>(
          stream,
          onData: (i) => ComplexDataState(i),
          onError: (e, _) => ComplexFailureState(e),
        );
      },
    );
  }
}
