import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CounterPage(),
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ValueA valueA = ImmutableProvider.of<ValueA>(context);
    final ValueB valueB = ImmutableProvider.of<ValueB>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Column(
        children: [
          Text(
            '${valueA.data}',
            key: Key('valueA_data'),
            style: TextStyle(fontSize: 24.0),
          ),
          Text(
            '${valueB.data}',
            key: Key('valueB_data'),
            style: TextStyle(fontSize: 24.0),
          ),
        ],
      ),
    );
  }
}

class ValueA {
  final int data;

  ValueA(this.data);
}

class ValueB {
  final int data;

  ValueB(this.data);
}

void main() {
  group('ImmutableProviderTree', () {
    testWidgets('throws if initialized with no immutableProviders and no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          ImmutableProviderTree(
            immutableProviders: null,
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no immutableProviders',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          ImmutableProviderTree(
            immutableProviders: null,
            child: Container(),
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          ImmutableProviderTree(
            immutableProviders: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes values to children', (WidgetTester tester) async {
      await tester.pumpWidget(
        ImmutableProviderTree(
          immutableProviders: [
            ImmutableProvider<ValueA>(value: ValueA(0)),
            ImmutableProvider<ValueB>(value: ValueB(1)),
          ],
          child: MyApp(),
        ),
      );

      final Finder valueAFinder = find.byKey((Key('valueA_data')));
      expect(valueAFinder, findsOneWidget);

      final Text valueAText = tester.widget(valueAFinder);
      expect(valueAText.data, '0');

      final Finder valueBFinder = find.byKey((Key('valueB_data')));
      expect(valueBFinder, findsOneWidget);

      final Text valueBText = tester.widget(valueBFinder);
      expect(valueBText.data, '1');
    });
  });
}
