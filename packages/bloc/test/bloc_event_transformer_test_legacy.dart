// ignore_for_file: deprecated_member_use_from_same_package

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

@immutable
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
  CounterBloc({EventTransformer<Increment>? incrementTransformer}) : super(0) {
    on<Increment>(
      (event, emit) {
        onCalls.add(event);
        return Future<void>.delayed(delay, () {
          if (emit.isDone) return;
          onEmitCalls.add(event);
          emit(state + 1);
        });
      },
      transformer: incrementTransformer,
    );
  }

  final onCalls = <CounterEvent>[];
  final onEmitCalls = <CounterEvent>[];
}

void main() {
  test('processes events concurrently by default', () async {
    final states = <int>[];
    final bloc = CounterBloc()
      ..stream.listen(states.add)
      ..add(Increment())
      ..add(Increment())
      ..add(Increment());

    await tick();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(states, equals([1, 2, 3]));

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(
      bloc.onEmitCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(states, equals([1, 2, 3]));
  });

  test(
      'when processing events concurrently '
      'all subscriptions are canceled on close', () async {
    final states = <int>[];
    final bloc = CounterBloc()
      ..stream.listen(states.add)
      ..add(Increment())
      ..add(Increment())
      ..add(Increment());

    await tick();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(bloc.onEmitCalls, isEmpty);

    expect(states, isEmpty);
  });

  test(
      'processes events sequentially when '
      'transformer is overridden.', () async {
    EventTransformer<Increment> incrementTransformer() {
      return (events, mapper) => events.asyncExpand(mapper);
    }

    final states = <int>[];
    final bloc = CounterBloc(incrementTransformer: incrementTransformer())
      ..stream.listen(states.add)
      ..add(Increment())
      ..add(Increment())
      ..add(Increment());

    await tick();

    expect(
      bloc.onCalls,
      equals([Increment()]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([Increment()]),
    );
    expect(states, equals([1]));

    await tick();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment()]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([Increment(), Increment()]),
    );

    expect(states, equals([1, 2]));

    await tick();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    await wait();

    expect(
      bloc.onEmitCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(states, equals([1, 2, 3]));

    await bloc.close();

    expect(
      bloc.onCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(
      bloc.onEmitCalls,
      equals([Increment(), Increment(), Increment()]),
    );

    expect(states, equals([1, 2, 3]));
  });

  test(
      'processes events sequentially when '
      'Bloc.transformer is overridden.', () async {
    await BlocOverrides.runZoned(
      () async {
        final states = <int>[];
        final bloc = CounterBloc()
          ..stream.listen(states.add)
          ..add(Increment())
          ..add(Increment())
          ..add(Increment());

        await tick();

        expect(
          bloc.onCalls,
          equals([Increment()]),
        );

        await wait();

        expect(
          bloc.onEmitCalls,
          equals([Increment()]),
        );
        expect(states, equals([1]));

        await tick();

        expect(
          bloc.onCalls,
          equals([Increment(), Increment()]),
        );

        await wait();

        expect(
          bloc.onEmitCalls,
          equals([Increment(), Increment()]),
        );

        expect(states, equals([1, 2]));

        await tick();

        expect(
          bloc.onCalls,
          equals([
            Increment(),
            Increment(),
            Increment(),
          ]),
        );

        await wait();

        expect(
          bloc.onEmitCalls,
          equals([Increment(), Increment(), Increment()]),
        );

        expect(states, equals([1, 2, 3]));

        await bloc.close();

        expect(
          bloc.onCalls,
          equals([Increment(), Increment(), Increment()]),
        );

        expect(
          bloc.onEmitCalls,
          equals([Increment(), Increment(), Increment()]),
        );

        expect(states, equals([1, 2, 3]));
      },
      eventTransformer: (events, mapper) => events.asyncExpand<dynamic>(mapper),
    );
  });
}
