import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

const delay = Duration(milliseconds: 30);

Future<void> wait() => Future.delayed(delay);
Future<void> tick() => Future.delayed(Duration.zero);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc([EventTransformer<CounterEvent>? transformer]) : super(0) {
    on<CounterEvent>(
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

void main() {
  late EventTransformer transformer;

  setUp(() {
    transformer = Bloc.transformer;
  });

  tearDown(() {
    Bloc.transformer = transformer;
  });

  test('processes events concurrently by default', () async {
    final states = <int>[];
    final bloc = CounterBloc()
      ..stream.listen(states.add)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment);

    await tick();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(states, equals([1, 2, 3]));

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(
      bloc.onEmitCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(states, equals([1, 2, 3]));
  });

  test(
      'when processing events concurrently '
      'all subscriptions are canceled on close', () async {
    final states = <int>[];
    final bloc = CounterBloc()
      ..stream.listen(states.add)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment);

    await tick();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(bloc.onEmitCalls, isEmpty);

    expect(states, isEmpty);
  });

  test(
      'processes events sequentially when '
      'Bloc.transformer is overridden.', () async {
    Bloc.transformer = (events, mapper) => events.asyncExpand<dynamic>(mapper);
    final states = <int>[];
    final bloc = CounterBloc()
      ..stream.listen(states.add)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment)
      ..add(CounterEvent.increment);

    await tick();

    expect(
      bloc.onCalls,
      equals([CounterEvent.increment]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([CounterEvent.increment]),
    );
    expect(states, equals([1]));

    await tick();

    expect(
      bloc.onCalls,
      equals([CounterEvent.increment, CounterEvent.increment]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([CounterEvent.increment, CounterEvent.increment]),
    );

    expect(states, equals([1, 2]));

    await tick();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(states, equals([1, 2, 3]));

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(
      bloc.onEmitCalls,
      equals([
        CounterEvent.increment,
        CounterEvent.increment,
        CounterEvent.increment,
      ]),
    );

    expect(states, equals([1, 2, 3]));
  });
}
