import 'dart:async';

import 'package:cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAppWithNavigation extends MaterialApp {
  MyAppWithNavigation({Key key, Widget child})
      : super(key: key, home: Scaffold(body: child));
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key key,
    this.onCounterCubitClosed,
    this.onThemeCubitClosed,
    this.counterCubitValue,
    this.themeCubitValue,
  }) : super(key: key);

  final VoidCallback onCounterCubitClosed;
  final VoidCallback onThemeCubitClosed;
  final CounterCubit counterCubitValue;
  final ThemeCubit themeCubitValue;

  @override
  Widget build(BuildContext context) {
    getProviders() {
      final providers = <CubitProvider>[];
      if (counterCubitValue != null) {
        providers.add(
          CubitProvider<CounterCubit>.value(
            value: counterCubitValue,
          ),
        );
      } else {
        providers.add(
          CubitProvider<CounterCubit>(
            create: (_) => CounterCubit(onClose: onCounterCubitClosed),
          ),
        );
      }

      if (themeCubitValue != null) {
        providers.add(
          CubitProvider<ThemeCubit>.value(
            value: themeCubitValue,
          ),
        );
      } else {
        providers.add(
          CubitProvider<ThemeCubit>(
            create: (_) => ThemeCubit(onClose: onThemeCubitClosed),
          ),
        );
      }
      return providers;
    }

    return MultiCubitProvider(
      providers: getProviders(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              RaisedButton(
                key: const Key('pop_button'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const SizedBox()),
                  );
                },
              ),
              RaisedButton(
                key: const Key('increment_button'),
                onPressed: () =>
                    CubitProvider.of<CounterCubit>(context).increment(),
              ),
              RaisedButton(
                key: const Key('toggle_theme_button'),
                onPressed: () => CubitProvider.of<ThemeCubit>(context).toggle(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CubitBuilder<ThemeCubit, ThemeData>(
      cubit: CubitProvider.of<ThemeCubit>(context),
      builder: (_, theme) {
        return MaterialApp(home: CounterPage(), theme: theme);
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counterCubit = CubitProvider.of<CounterCubit>(context);

    return Scaffold(
      body: CubitBuilder<CounterCubit, int>(
        cubit: counterCubit,
        builder: (context, count) {
          return Center(
            child: Text('$count', key: const Key('counter_text')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('pop_button'),
        onPressed: Navigator.of(context).pop,
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onClose}) : super(0);

  final VoidCallback onClose;

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit({this.onClose}) : super(ThemeData.light());

  final VoidCallback onClose;

  void toggle() {
    emit(state == ThemeData.dark() ? ThemeData.light() : ThemeData.dark());
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

void main() {
  group('MultiCubitProvider', () {
    testWidgets('throws if initialized with no providers', (tester) async {
      try {
        await tester.pumpWidget(
          MultiCubitProvider(providers: null, child: const SizedBox()),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child', (tester) async {
      try {
        await tester.pumpWidget(
          MultiCubitProvider(providers: [], child: null),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('passes cubits to children', (tester) async {
      await tester.pumpWidget(
        MultiCubitProvider(
          providers: [
            CubitProvider<CounterCubit>(create: (_) => CounterCubit()),
            CubitProvider<ThemeCubit>(create: (_) => ThemeCubit())
          ],
          child: MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey((const Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('passes cubits to children without explicit states',
        (tester) async {
      await tester.pumpWidget(
        MultiCubitProvider(
          providers: [
            CubitProvider(create: (_) => CounterCubit()),
            CubitProvider(create: (_) => ThemeCubit())
          ],
          child: MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey((const Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('adds event to each cubit', (tester) async {
      await tester.pumpWidget(
        MultiCubitProvider(
          providers: [
            CubitProvider<CounterCubit>(
              create: (_) => CounterCubit()..decrement(),
            ),
            CubitProvider<ThemeCubit>(
              create: (_) => ThemeCubit()..toggle(),
            ),
          ],
          child: MyApp(),
        ),
      );

      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.dark());

      final counterFinder = find.byKey((const Key('counter_text')));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '-1');
    });

    testWidgets('close on counter cubit which was loaded (lazily)',
        (tester) async {
      var counterCubitClosed = false;
      var themeCubitClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterCubitClosed: () => counterCubitClosed = true,
            onThemeCubitClosed: () => themeCubitClosed = true,
          ),
        ),
      );

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);

      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterCubitClosed, true);
      expect(themeCubitClosed, false);
    });

    testWidgets('close on theme cubit which was loaded (lazily)',
        (tester) async {
      var counterCubitClosed = false;
      var themeCubitClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterCubitClosed: () => counterCubitClosed = true,
            onThemeCubitClosed: () => themeCubitClosed = true,
          ),
        ),
      );

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);

      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, true);
    });

    testWidgets('close on all cubits which were loaded (lazily)',
        (tester) async {
      var counterCubitClosed = false;
      var themeCubitClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterCubitClosed: () => counterCubitClosed = true,
            onThemeCubitClosed: () => themeCubitClosed = true,
          ),
        ),
      );

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);
      await tester.tap(find.byKey(const Key('increment_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('toggle_theme_button')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterCubitClosed, true);
      expect(themeCubitClosed, true);
    });

    testWidgets(
        'does not call close on cubits if they were not loaded (lazily)',
        (tester) async {
      var counterCubitClosed = false;
      var themeCubitClosed = false;

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            onCounterCubitClosed: () => counterCubitClosed = true,
            onThemeCubitClosed: () => themeCubitClosed = true,
          ),
        ),
      );

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);
    });

    testWidgets('does not close when created using value', (tester) async {
      var counterCubitClosed = false;
      var themeCubitClosed = false;

      final counterCubit = CounterCubit(
        onClose: () => counterCubitClosed = true,
      );
      final themeCubit = ThemeCubit(
        onClose: () => themeCubitClosed = true,
      );

      await tester.pumpWidget(
        MyAppWithNavigation(
          child: HomePage(
            counterCubitValue: counterCubit,
            themeCubitValue: themeCubit,
          ),
        ),
      );

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);

      await tester.tap(find.byKey(const Key('pop_button')));
      await tester.pumpAndSettle();

      expect(counterCubitClosed, false);
      expect(themeCubitClosed, false);
    });
  });
}
