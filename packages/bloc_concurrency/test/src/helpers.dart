// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
import 'package:bloc/bloc.dart';

abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  bool operator ==(Object value) {
    if (identical(this, value)) return true;
    return value is Increment;
  }

  @override
  int get hashCode => 0;
}

const delay = Duration(milliseconds: 30);

Future<void> wait() => Future.delayed(delay);
Future<void> tick() => Future.delayed(Duration.zero);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventTransformer<Increment> transformer) : super(0) {
    on<Increment>(
      (event, emit) {
        onCalls.add(event);
        return Future<void>.delayed(delay, () {
          if (emit.isDone) return;
          onEmitCalls.add(event);
          emit(state + 1);
        });
      },
      transformer: transformer,
    );
  }

  final onCalls = <CounterEvent>[];
  final onEmitCalls = <CounterEvent>[];
}
