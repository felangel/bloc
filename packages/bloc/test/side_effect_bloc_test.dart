import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBlocObserver extends Mock implements BlocObserver {}

Future<void> tick() => Future<void>.delayed(Duration.zero);

class TestSideEffectBloc extends SideEffectBloc<String, String, String> {
  TestSideEffectBloc() : super('initial_state') {
    on<String>((event, emit) {
      emit('new_state');
      emitEffect('new_effect');
    });
  }
}

void main() {
  group('SideEffectBloc', () {
    late TestSideEffectBloc bloc;

    setUp(() {
      bloc = TestSideEffectBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test('emits initial state', () {
      expect(bloc.state, 'initial_state');
    });

    test('emits state and effect on event', () async {
      unawaited(expectLater(bloc.stream, emitsInOrder(['new_state'])));
      unawaited(expectLater(bloc.effectsStream, emitsInOrder(['new_effect'])));

      bloc.add('event');
      await tick();
      expect(bloc.state, 'new_state');
    });

    test('throws StateError for effect after close', () async {
      await bloc.close();
      expect(() => bloc.emitEffect('effect'), throwsA(isA<StateError>()));
    });

    test('closes streams properly', () async {
      unawaited(expectLater(bloc.stream, emitsDone));
      unawaited(expectLater(bloc.effectsStream, emitsDone));
      await bloc.close();
    });
  });
}

void unawaited(Future<void> future) {}
