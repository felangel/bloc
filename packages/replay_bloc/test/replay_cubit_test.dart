import 'dart:async';

import 'package:test/test.dart';

import 'cubits/counter_cubit.dart';

void main() {
  group('ReplayCubit', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterCubit().state, 0);
      });
    });

    group('canUndo', () {
      test('is false when no state changes have occurred', () async {
        final cubit = CounterCubit();
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });

      test('is true when a single state change has occurred', () async {
        final cubit = CounterCubit();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        expect(cubit.canUndo, isTrue);
        await cubit.close();
      });

      test('is false when undos have been exhausted', () async {
        final cubit = CounterCubit();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });
    });

    group('canRedo', () {
      test('is false when no state changes have occurred', () async {
        final cubit = CounterCubit();
        expect(cubit.canRedo, isFalse);
        await cubit.close();
      });

      test('is true when a single undo has occurred', () async {
        final cubit = CounterCubit();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        expect(cubit.canRedo, isTrue);
        await cubit.close();
      });

      test('is false when redos have been exhausted', () async {
        final cubit = CounterCubit();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        expect(cubit.canRedo, isFalse);
        await cubit.close();
      });
    });

    group('clearHistory', () {
      test('clears history and redos on new cubit', () async {
        final cubit = CounterCubit()..clearHistory();
        expect(cubit.canRedo, isFalse);
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });
    });

    group('undo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit.undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final cubit = CounterCubit(limit: 0);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1]);
      });

      test('skips states filtered out by shouldReplay at undo time', () async {
        final states = <int>[];
        final cubit = CounterCubit(shouldReplayCallback: (i) => !i.isEven);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..increment();
        await Future<void>.delayed(Duration.zero);
        cubit
          ..undo()
          ..undo()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1]);
      });

      test(
          'doesn\'t skip states that would be filtered out by shouldReplay '
          'at transition time but not at undo time', () async {
        var replayEvens = false;
        final states = <int>[];
        final cubit = CounterCubit(
          shouldReplayCallback: (i) => !i.isEven || replayEvens,
        );
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..increment();
        await Future<void>.delayed(Duration.zero);
        replayEvens = true;
        cubit
          ..undo()
          ..undo()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 2, 1, 0]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final cubit = CounterCubit(limit: 1);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit.redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..redo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..decrement()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 0]);
      });

      test(
          'redo does not redo states which were'
          ' filtered out by shouldReplay at undo time', () async {
        final states = <int>[];
        final cubit = CounterCubit(shouldReplayCallback: (i) => !i.isEven);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..increment()
          ..undo()
          ..undo()
          ..undo()
          ..redo()
          ..redo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1, 3]);
      });

      test(
          'redo does not redo states which were'
          ' filtered out by shouldReplay at transition time', () async {
        var replayEvens = false;
        final states = <int>[];
        final cubit = CounterCubit(
          shouldReplayCallback: (i) => !i.isEven || replayEvens,
        );
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..increment()
          ..undo()
          ..undo()
          ..undo();
        replayEvens = true;
        cubit
          ..redo()
          ..redo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1, 2, 3]);
      });
    });
  });

  group('ReplayMixin', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterCubitMixin().state, 0);
      });
    });

    group('canUndo', () {
      test('is false when no state changes have occurred', () async {
        final cubit = CounterCubitMixin();
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });

      test('is true when a single state change has occurred', () async {
        final cubit = CounterCubitMixin()..increment();
        expect(cubit.canUndo, isTrue);
        await cubit.close();
      });

      test('is false when undos have been exhausted', () async {
        final cubit = CounterCubitMixin()
          ..increment()
          ..undo();
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });
    });

    group('canRedo', () {
      test('is false when no state changes have occurred', () async {
        final cubit = CounterCubitMixin();
        expect(cubit.canRedo, isFalse);
        await cubit.close();
      });

      test('is true when a single undo has occurred', () async {
        final cubit = CounterCubitMixin()
          ..increment()
          ..undo();
        expect(cubit.canRedo, isTrue);
        await cubit.close();
      });

      test('is false when redos have been exhausted', () async {
        final cubit = CounterCubitMixin()
          ..increment()
          ..undo()
          ..redo();
        expect(cubit.canRedo, isFalse);
        await cubit.close();
      });
    });

    group('clearHistory', () {
      test('clears history and redos on new cubit', () async {
        final cubit = CounterCubitMixin()..clearHistory();
        expect(cubit.canRedo, isFalse);
        expect(cubit.canUndo, isFalse);
        await cubit.close();
      });
    });

    group('undo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit.undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin(limit: 0);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin(limit: 1);
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..redo()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.stream.listen(states.add);
        cubit
          ..increment()
          ..increment()
          ..undo()
          ..decrement()
          ..redo();
        await cubit.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 0]);
      });
    });
  });
}
