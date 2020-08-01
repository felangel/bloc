import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

void main() {
  group('BlocProvider', () {
    test('is a CubitProvider internally', () {
      expect(
        BlocProvider<CounterBloc>(
          create: (context) => CounterBloc(),
          child: const SizedBox(),
        ),
        isA<CubitProvider<CounterBloc>>(),
      );
    });

    testWidgets('can be provided without an explicit type', (tester) async {
      final key = const Key('__text_count__');
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider(
            create: (_) => CounterBloc(),
            child: Builder(
              builder: (context) => Text(
                '${BlocProvider.of<CounterBloc>(context).state}',
                key: key,
              ),
            ),
          ),
        ),
      );
      final text = tester.widget(find.byKey(key)) as Text;
      expect(text.data, '0');
    });
    testWidgets(
      'can access bloc directly within builder',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider(
                create: (_) => CounterBloc(),
                child: BlocBuilder<CounterBloc, int>(
                  builder: (context, state) => Column(
                    children: [
                      Text('state: $state'),
                      RaisedButton(
                        key: const Key('increment_button'),
                        onPressed: () {
                          context
                              .bloc<CounterBloc>()
                              .add(CounterEvent.increment);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('state: 0'), findsOneWidget);
        await tester.tap(find.byKey(const Key('increment_button')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('state: 1'), findsOneWidget);
      },
    );
    testWidgets(
        'should throw FlutterError if BlocProvider is not found in current '
        'context', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            BlocProvider.of<CounterBloc>(context);
            return const SizedBox();
          },
        ),
      );
      final dynamic exception = tester.takeException();
      final expectedMessage = '''
        BlocProvider.of() called with a context that does not contain a Bloc of type CounterBloc.
        No ancestor could be found starting from the context that was passed to BlocProvider.of<CounterBloc>().

        This can happen if the context you used comes from a widget above the BlocProvider.

        The context used was: Builder(dirty)
''';
      expect(exception is FlutterError, true);
      expect(exception.message, expectedMessage);
    });
    testWidgets(
        'should not wrap into FlutterError if '
        'ProviderNotFoundException with wrong valueType '
        'is thrown', (tester) async {
      await tester.pumpWidget(
        BlocProvider<CounterBloc>(
          create: (context) => CounterBloc(),
          child: Builder(
            builder: (context) {
              Provider.of<int>(context);
              return const SizedBox();
            },
          ),
        ),
      );
      final dynamic exception = tester.takeException();
      expect(exception is ProviderNotFoundException, true);
    });
  });
}
