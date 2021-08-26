import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

const delay = Duration(milliseconds: 30);
const offset = Duration(milliseconds: 10);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventTransformer<CounterEvent> modifier) : super(0) {
    on<CounterEvent>(
      (event, emit) {
        return Future<void>.delayed(delay, () {
          onCalls.add(event);
          emit(state + 1);
        });
      },
      modifier,
    );
  }

  final onCalls = <CounterEvent>[];
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

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );
      expect(states, equals([1, 2, 3]));
      await bloc.close();
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

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
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

      await Future<void>.delayed(delay + offset);
      expect(bloc.onCalls, equals([CounterEvent.increment]));
      expect(states, equals([1]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
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
      expect(states, equals([1, 2, 3]));
    });
  });

  group('restartable', () {
    test('processes only the latest event and cancels remaining', () async {
      final states = <int>[];
      final bloc = CounterBloc(restartable())
        ..stream.listen(states.add)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );
      expect(states, equals([1, 2]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay + offset);
      expect(
        bloc.onCalls,
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
      expect(states, equals([1, 2, 3]));
    });
  });
}
