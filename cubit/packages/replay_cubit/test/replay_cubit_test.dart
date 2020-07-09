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
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0]);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final cubit = CounterCubit(limit: 0);
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final cubit = CounterCubit(limit: 1);
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0]);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final cubit = CounterCubit();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.decrement);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 0]);
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
        final cubit = CounterCubitMixin();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        expect(cubit.canUndo, isTrue);
        await cubit.close();
      });

      test('is false when undos have been exhausted', () async {
        final cubit = CounterCubitMixin();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
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
        final cubit = CounterCubitMixin();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        expect(cubit.canRedo, isTrue);
        await cubit.close();
      });

      test('is false when redos have been exhausted', () async {
        final cubit = CounterCubitMixin();
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
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
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0]);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin(limit: 0);
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin(limit: 1);
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0]);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final cubit = CounterCubitMixin();
        final subscription = cubit.listen(states.add);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.increment);
        await Future<void>.delayed(Duration.zero, cubit.undo);
        await Future<void>.delayed(Duration.zero, cubit.decrement);
        await Future<void>.delayed(Duration.zero, cubit.redo);
        await cubit.close();
        await subscription.cancel();
        expect(states, [0, 1, 2, 1, 0]);
      });
    });
  });
}
