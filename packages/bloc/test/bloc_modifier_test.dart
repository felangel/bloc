import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

enum CounterEvent { increment }

const delay = Duration(milliseconds: 30);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventModifier<CounterEvent> modifier) : super(0) {
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

      await Future<void>.delayed(delay);
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

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));

      await Future<void>.delayed(delay);
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

      await Future<void>.delayed(delay);
      expect(bloc.onCalls, equals([CounterEvent.increment]));
      expect(states, equals([1]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
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

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment
        ]),
      );
      expect(states, equals([1]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
          CounterEvent.increment,
        ]),
      );
      expect(states, equals([1, 2]));

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
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
          CounterEvent.increment
        ]),
      );
      expect(states, equals([1, 2, 3]));
    });
  });

  group('keepLatest', () {
    test('drops all intermediate events and enqueues latest event', () async {
      final states = <int>[];
      final bloc = CounterBloc(keepLatest())
        ..stream.listen(states.add)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      await Future<void>.delayed(delay);
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));

      await bloc.close();
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment, CounterEvent.increment]),
      );
      expect(states, equals([1, 2]));
    });
  });

  group('debounceTime', () {
    test('debounces based on provided duration', () async {
      final debounceDuration = const Duration(milliseconds: 300);
      final states = <int>[];
      final bloc = CounterBloc(debounceTime(debounceDuration))
        ..stream.listen(states.add)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
      expect(bloc.onCalls, isEmpty);
      expect(states, isEmpty);

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(delay);
      expect(bloc.onCalls, isEmpty);
      expect(states, isEmpty);

      bloc
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment)
        ..add(CounterEvent.increment);

      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));

      await bloc.close();
      expect(
        bloc.onCalls,
        equals([CounterEvent.increment]),
      );
      expect(states, equals([1]));
    });
  });
}
