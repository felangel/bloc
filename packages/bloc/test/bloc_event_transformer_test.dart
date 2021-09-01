import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

const delay = Duration(milliseconds: 30);

Future<void> wait() => Future.delayed(delay);
Future<void> tick() => Future.delayed(Duration.zero);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventTransformer<CounterEvent> transformer) : super(0) {
    on<CounterEvent>(
      (event, emit) {
        onCalls.add(event);
        return Future<void>.delayed(delay, () {
          if (emit.isCanceled) return;
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
  group('concurrent', () {
    test('processes events concurrently', () async {
      final states = <int>[];
      final bloc = CounterBloc(concurrent())
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
  });

  group('enqueue', () {
    test('processes events one at a time', () async {
      final states = <int>[];
      final bloc = CounterBloc(enqueue())
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
  });

  group('drop', () {
    test('processes only the current event and ignores remaining', () async {
      final states = <int>[];
      final bloc = CounterBloc(drop())
        ..stream.listen(states.add)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await tick();

      expect(bloc.onCalls, equals([CounterEvent.increment]));

      await wait();

      expect(bloc.onEmitCalls, equals([CounterEvent.increment]));
      expect(states, equals([1]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

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

      bloc
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
  });

  group('restartable', () {
    test('processes only the latest event and cancels remaining', () async {
      final states = <int>[];
      final bloc = CounterBloc(restartable())..stream.listen(states.add);
      Future<void> addEvents() async {
        const spacer = Duration(milliseconds: 10);
        await Future<void>.delayed(spacer);
        bloc.add(CounterEvent.increment);
        await Future<void>.delayed(spacer);
        bloc.add(CounterEvent.increment);
        await Future<void>.delayed(spacer);
        bloc.add(CounterEvent.increment);
        await Future<void>.delayed(spacer);
      }

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment
        ]),
      );

      await wait();

      expect(bloc.onEmitCalls, equals([CounterEvent.increment]));
      expect(states, equals([1]));

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment
        ]),
      );

      await wait();

      expect(
        bloc.onEmitCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );

      expect(states, equals([1, 2]));

      await tick();
      await addEvents();

      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment
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
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
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
  });
}
