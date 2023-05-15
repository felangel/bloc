import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends MaterialApp {
  const MyApp({Key? key}) : super(key: key, home: const CounterPage());
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repositoryA = RepositoryProvider.of<RepositoryA>(context);
    final repositoryB = RepositoryProvider.of<RepositoryB>(context);

    return Scaffold(
      body: Column(
        children: [
          Text(
            '${repositoryA.data}',
            key: const Key('RepositoryA_data'),
          ),
          Text(
            '${repositoryB.data}',
            key: const Key('RepositoryB_data'),
          ),
        ],
      ),
    );
  }
}

class RepositoryA {
  const RepositoryA(this.data);

  final int data;
}

class RepositoryB {
  const RepositoryB(this.data);

  final int data;
}

void main() {
  group('MultiRepositoryProvider', () {
    testWidgets('passes values to children', (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<RepositoryA>(
              create: (_) => const RepositoryA(0),
            ),
            RepositoryProvider<RepositoryB>(
              create: (_) => const RepositoryB(1),
            ),
          ],
          child: const MyApp(),
        ),
      );

      final repositoryAFinder = find.byKey(const Key('RepositoryA_data'));
      expect(repositoryAFinder, findsOneWidget);

      final repositoryAText = tester.widget(repositoryAFinder) as Text;
      expect(repositoryAText.data, '0');

      final repositoryBFinder = find.byKey(const Key('RepositoryB_data'));
      expect(repositoryBFinder, findsOneWidget);

      final repositoryBText = tester.widget(repositoryBFinder) as Text;
      expect(repositoryBText.data, '1');
    });

    testWidgets('passes values to children without explict types',
        (tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider(
              create: (_) => const RepositoryA(0),
            ),
            RepositoryProvider(
              create: (_) => const RepositoryB(1),
            ),
          ],
          child: const MyApp(),
        ),
      );

      final repositoryAFinder = find.byKey(const Key('RepositoryA_data'));
      expect(repositoryAFinder, findsOneWidget);

      final repositoryAText = tester.widget(repositoryAFinder) as Text;
      expect(repositoryAText.data, '0');

      final repositoryBFinder = find.byKey(const Key('RepositoryB_data'));
      expect(repositoryBFinder, findsOneWidget);

      final repositoryBText = tester.widget(repositoryBFinder) as Text;
      expect(repositoryBText.data, '1');
    });
  });
}
