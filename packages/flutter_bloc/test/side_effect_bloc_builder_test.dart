import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSideEffectBloc extends Bloc<dynamic, String> implements SideEffectBloc<dynamic, String, int> {
  FakeSideEffectBloc() : super('initial_state');

  @override
  final StreamController<int> _effectController = StreamController<int>.broadcast();

  @override
  Stream<int> get effectsStream => _effectController.stream;

  void emitEffect(int effect) => _effectController.add(effect);

  @override
  Future<void> close() {
    _effectController.close();
    return super.close();
  }

  @override
  void onEffect(int effect) {}
}

void main() {
  late FakeSideEffectBloc fakeBloc;
  const testState = 'initial_state';
  const testEffect = 42;

  setUp(() {
    fakeBloc = FakeSideEffectBloc();
  });

  tearDown(() {
    fakeBloc.close();
  });

  testWidgets('builds with provided bloc and calls builder with state', (tester) async {
    const expectedWidget = Text('Built');
    var builderCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
          bloc: fakeBloc,
          builder: (context, state) {
            builderCalled = true;
            expect(state, testState);
            return expectedWidget;
          },
          effectHandler: (state, effect) {},
        ),
      ),
    );

    expect(builderCalled, isTrue);
    expect(find.byWidget(expectedWidget), findsOneWidget);
  });

  testWidgets('reads bloc from context if not provided', (tester) async {
    const expectedWidget = Text('Built');
    var builderCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: fakeBloc,
          child: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
            builder: (context, state) {
              builderCalled = true;
              expect(state, testState);
              return expectedWidget;
            },
            effectHandler: (state, effect) {},
          ),
        ),
      ),
    );

    expect(builderCalled, isTrue);
    expect(find.byWidget(expectedWidget), findsOneWidget);
  });

  testWidgets('handles effects via effectHandler', (tester) async {
    var effectHandled = false;
    const expectedWidget = Text('Built');

    await tester.pumpWidget(
      MaterialApp(
        home: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
          bloc: fakeBloc,
          builder: (context, state) => expectedWidget,
          effectHandler: (state, effect) {
            effectHandled = true;
            expect(state, testState);
            expect(effect, testEffect);
          },
        ),
      ),
    );

    fakeBloc.emitEffect(testEffect);
    await tester.pump();

    expect(effectHandled, isTrue);
  });

  testWidgets('respects buildWhen condition', (tester) async {
    var buildCount = 0;
    const expectedWidget = Text('Built');

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: fakeBloc,
          child: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
            buildWhen: (previous, current) => false,
            builder: (context, state) {
              buildCount++;
              return expectedWidget;
            },
            effectHandler: (state, effect) {},
          ),
        ),
      ),
    );

    fakeBloc.emit('new_state');
    await tester.pump();

    expect(buildCount, 1); // Should not rebuild due to buildWhen returning false
  });

  testWidgets('cancels effect stream subscription on dispose', (tester) async {
    const expectedWidget = Text('Built');

    await tester.pumpWidget(
      MaterialApp(
        home: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
          bloc: fakeBloc,
          builder: (context, state) => expectedWidget,
          effectHandler: (state, effect) {},
        ),
      ),
    );

    expect(fakeBloc._effectController.hasListener, isTrue);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));

    expect(fakeBloc._effectController.hasListener, isFalse);
  });

  testWidgets('handles effectHandler errors without crashing', (tester) async {
    const expectedWidget = Text('Built');

    await tester.pumpWidget(
      MaterialApp(
        home: SideEffectBlocBuilder<FakeSideEffectBloc, String, int>(
          bloc: fakeBloc,
          builder: (context, state) => expectedWidget,
          effectHandler: (state, effect) => throw Exception('Test error'),
        ),
      ),
    );

    fakeBloc.emitEffect(testEffect);
    await tester.pump();

    expect(find.byWidget(expectedWidget), findsOneWidget); // Widget still builds
  });
}