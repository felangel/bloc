import 'dart:async';

import 'package:replay_bloc/replay_bloc.dart';
import 'package:test/test.dart';

import 'blocs/counter_bloc.dart';

void main() {
  group('ReplayBloc', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterBloc().state, 0);
      });
    });

    group('canUndo', () {
      test('is false when no state changes have occurred', () async {
        final bloc = CounterBloc();
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });

      test('is true when a single state change has occurred', () async {
        final bloc = CounterBloc()..add(Increment());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.canUndo, isTrue);
        await bloc.close();
      });

      test('is false when undos have been exhausted', () async {
        final bloc = CounterBloc()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });
    });

    group('canRedo', () {
      test('is false when no state changes have occurred', () async {
        final bloc = CounterBloc();
        expect(bloc.canRedo, isFalse);
        await bloc.close();
      });

      test('is true when a single undo has occurred', () async {
        final bloc = CounterBloc()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        expect(bloc.canRedo, isTrue);
        await bloc.close();
      });

      test('is false when redos have been exhausted', () async {
        final bloc = CounterBloc()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        await Future<void>.delayed(Duration.zero, bloc.redo);
        expect(bloc.canRedo, isFalse);
        await bloc.close();
      });
    });

    group('clearHistory', () {
      test('clears history and redos on new bloc', () async {
        final bloc = CounterBloc()..clearHistory();
        expect(bloc.canRedo, isFalse);
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });
    });

    group('undo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final bloc = CounterBloc(limit: 0);
        final subscription = bloc.stream.listen(states.add);
        bloc.add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1]);
      });

      test('skips states filtered out by shouldReplay at undo time', () async {
        final states = <int>[];
        final bloc = CounterBloc(shouldReplayCallback: (i) => !i.isEven);
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..undo()
          ..undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1]);
      });

      test(
          'doesn\'t skip states that would be filtered out by shouldReplay '
          'at transition time but not at undo time', () async {
        var replayEvens = false;
        final states = <int>[];
        final bloc = CounterBloc(
          shouldReplayCallback: (i) => !i.isEven || replayEvens,
        );
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        replayEvens = true;
        bloc
          ..undo()
          ..undo()
          ..undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 2, 1, 0]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final bloc = CounterBloc(limit: 1);
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc.add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });

      test('triggers onEvent', () async {
        final onEventCalls = <ReplayEvent>[];
        final bloc = CounterBloc(onEventCallback: onEventCalls.add)
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        expect(onEventCalls.length, 2);
        expect(onEventCalls.last.toString(), 'Undo');
      });

      test('triggers onTransition', () async {
        final onTransitionCalls = <Transition<ReplayEvent, int>>[];
        final bloc = CounterBloc(onTransitionCallback: onTransitionCalls.add)
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        expect(onTransitionCalls.length, 2);
        expect(
          onTransitionCalls.last.toString(),
          'Transition { currentState: 1, event: Undo, nextState: 0 }',
        );
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test('triggers onEvent', () async {
        final onEventCalls = <ReplayEvent>[];
        final bloc = CounterBloc(onEventCallback: onEventCalls.add)
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo();
        await bloc.close();
        expect(onEventCalls.length, 3);
        expect(onEventCalls.last.toString(), 'Redo');
      });

      test('triggers onTransition', () async {
        final onTransitionCalls = <Transition<ReplayEvent, int>>[];
        final bloc = CounterBloc(onTransitionCallback: onTransitionCalls.add)
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo();
        await bloc.close();
        expect(onTransitionCalls.length, 3);
        expect(
          onTransitionCalls.last.toString(),
          'Transition { currentState: 0, event: Redo, nextState: 1 }',
        );
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final bloc = CounterBloc();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..add(Decrement());
        await Future<void>.delayed(Duration.zero);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 0]);
      });

      test(
          'redo does not redo states which were'
          ' filtered out by shouldReplay at undo time', () async {
        final states = <int>[];
        final bloc = CounterBloc(shouldReplayCallback: (i) => !i.isEven);
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..undo()
          ..undo()
          ..redo()
          ..redo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1, 3]);
      });

      test(
          'redo does not redo states which were'
          ' filtered out by shouldReplay at transition time', () async {
        var replayEvens = false;
        final states = <int>[];
        final bloc = CounterBloc(
          shouldReplayCallback: (i) => !i.isEven || replayEvens,
        );
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..undo()
          ..undo();
        replayEvens = true;
        bloc
          ..redo()
          ..redo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 3, 1, 2, 3]);
      });
    });
  });

  group('ReplayBlocMixin', () {
    group('initial state', () {
      test('is correct', () {
        expect(CounterBlocMixin().state, 0);
      });
    });

    group('canUndo', () {
      test('is false when no state changes have occurred', () async {
        final bloc = CounterBlocMixin();
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });

      test('is true when a single state change has occurred', () async {
        final bloc = CounterBlocMixin()..add(Increment());
        await Future<void>.delayed(Duration.zero);
        expect(bloc.canUndo, isTrue);
        await bloc.close();
      });

      test('is false when undos have been exhausted', () async {
        final bloc = CounterBlocMixin()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });
    });

    group('canRedo', () {
      test('is false when no state changes have occurred', () async {
        final bloc = CounterBlocMixin();
        expect(bloc.canRedo, isFalse);
        await bloc.close();
      });

      test('is true when a single undo has occurred', () async {
        final bloc = CounterBlocMixin()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        expect(bloc.canRedo, isTrue);
        await bloc.close();
      });

      test('is false when redos have been exhausted', () async {
        final bloc = CounterBlocMixin()..add(Increment());
        await Future<void>.delayed(Duration.zero, bloc.undo);
        await Future<void>.delayed(Duration.zero, bloc.redo);
        expect(bloc.canRedo, isFalse);
        await bloc.close();
      });
    });

    group('clearHistory', () {
      test('clears history and redos on new bloc', () async {
        final bloc = CounterBlocMixin()..clearHistory();
        expect(bloc.canRedo, isFalse);
        expect(bloc.canUndo, isFalse);
        await bloc.close();
      });
    });

    group('undo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when limit is 0', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin(limit: 0);
        final subscription = bloc.stream.listen(states.add);
        bloc.add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1]);
      });

      test('loses history outside of limit', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin(limit: 1);
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });

      test('reverts to initial state', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc.add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 0]);
      });

      test('reverts to previous state with multiple state changes ', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.undo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1]);
      });
    });

    group('redo', () {
      test('does nothing when no state changes have occurred', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, isEmpty);
      });

      test('does nothing when no undos have occurred', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2]);
      });

      test('works when one undo has occurred', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test('does nothing when undos have been exhausted', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..redo()
          ..redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 2]);
      });

      test(
          'does nothing when undos has occurred '
          'followed by a new state change', () async {
        final states = <int>[];
        final bloc = CounterBlocMixin();
        final subscription = bloc.stream.listen(states.add);
        bloc
          ..add(Increment())
          ..add(Increment());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..undo()
          ..add(Decrement());
        await Future<void>.delayed(Duration.zero);
        bloc.redo();
        await bloc.close();
        await subscription.cancel();
        expect(states, const <int>[1, 2, 1, 0]);
      });
    });
  });
}
