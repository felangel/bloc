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
    final RepositoryA repositoryA = RepositoryProvider.of<RepositoryA>(context);
    final RepositoryB repositoryB = RepositoryProvider.of<RepositoryB>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Column(
        children: [
          Text(
            '${repositoryA.data}',
            key: Key('RepositoryA_data'),
            style: TextStyle(fontSize: 24.0),
          ),
          Text(
            '${repositoryB.data}',
            key: Key('RepositoryB_data'),
            style: TextStyle(fontSize: 24.0),
          ),
        ],
      ),
    );
  }
}

class RepositoryA {
  final int data;

  RepositoryA(this.data);
}

class RepositoryB {
  final int data;

  RepositoryB(this.data);
}

void main() {
  group('MultiRepositoryProvider', () {
    testWidgets(
        'throws if initialized with no RepositoryProviders and no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: null,
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no RepositoryProviders',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiRepositoryProvider(
            providers: null,
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
          MultiRepositoryProvider(
            providers: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes values to children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<RepositoryA>(
                builder: (context) => RepositoryA(0)),
            RepositoryProvider<RepositoryB>(
                builder: (context) => RepositoryB(1)),
          ],
          child: MyApp(),
        ),
      );

      final Finder repositoryAFinder = find.byKey((Key('RepositoryA_data')));
      expect(repositoryAFinder, findsOneWidget);

      final Text repositoryAText = tester.widget(repositoryAFinder);
      expect(repositoryAText.data, '0');

      final Finder repositoryBFinder = find.byKey((Key('RepositoryB_data')));
      expect(repositoryBFinder, findsOneWidget);

      final Text repositoryBText = tester.widget(repositoryBFinder);
      expect(repositoryBText.data, '1');
    });
  });
}
