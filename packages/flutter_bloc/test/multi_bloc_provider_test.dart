import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyAppWithNavigation extends MaterialApp {
  MyAppWithNavigation({required Widget child, Key? key})
      : super(key: key, home: Scaffold(body: child));
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    this.onCounterCubitClosed,
    this.onThemeCubitClosed,
    this.counterCubitValue,
    this.themeCubitValue,
  }) : super(key: key);

  final VoidCallback? onCounterCubitClosed;
  final VoidCallback? onThemeCubitClosed;
  final CounterCubit? counterCubitValue;
  final ThemeCubit? themeCubitValue;

  @override
  Widget build(BuildContext context) {
    List<BlocProvider<StateStreamableSource<Object?>>> getProviders() {
      final providers = <BlocProvider>[];
      if (counterCubitValue != null) {
        providers.add(
          BlocProvider<CounterCubit>.value(
            value: counterCubitValue!,
          ),
        );
      } else {
        providers.add(
          BlocProvider<CounterCubit>(
            create: (_) => CounterCubit(onClose: onCounterCubitClosed),
          ),
        );
      }

      if (themeCubitValue != null) {
        providers.add(
          BlocProvider<ThemeCubit>.value(
            value: themeCubitValue!,
          ),
        );
      } else {
        providers.add(
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(onClose: onThemeCubitClosed),
          ),
        );
      }
      return providers;
    }

    return MultiBlocProvider(
      providers: getProviders(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              ElevatedButton(
                key: const Key('pop_button'),
                child: const SizedBox(),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => const SizedBox()),
                  );
                },
              ),
              ElevatedButton(
                key: const Key('increment_button'),
                child: const SizedBox(),
                onPressed: () =>
                    BlocProvider.of<CounterCubit>(context).increment(),
              ),
              ElevatedButton(
                key: const Key('toggle_theme_button'),
                child: const SizedBox(),
                onPressed: () => BlocProvider.of<ThemeCubit>(context).toggle(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      bloc: BlocProvider.of<ThemeCubit>(context),
      builder: (_, theme) {
        return MaterialApp(home: const CounterPage(), theme: theme);
      },
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final counterCubit = BlocProvider.of<CounterCubit>(context);

    return Scaffold(
      body: BlocBuilder<CounterCubit, int>(
        bloc: counterCubit,
        builder: (context, count) {
          return Center(
            child: Text('$count', key: const Key('counter_text')),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('pop_button'),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit({this.onClose}) : super(0);

  final VoidCallback? onClose;

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

  final VoidCallback? onClose;

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
  group('MultiBlocProvider', () {
    testWidgets('passes cubits to children', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CounterCubit>(create: (_) => CounterCubit()),
            BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('passes cubits to children without explicit states',
        (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => CounterCubit()),
            BlocProvider(create: (_) => ThemeCubit()),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.light());

      final counterFinder = find.byKey(const Key('counter_text'));
      expect(counterFinder, findsOneWidget);

      final counterText = tester.widget<Text>(counterFinder);
      expect(counterText.data, '0');
    });

    testWidgets('adds event to each cubit', (tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CounterCubit>(
              create: (_) => CounterCubit()..decrement(),
            ),
            BlocProvider<ThemeCubit>(
              create: (_) => ThemeCubit()..toggle(),
            ),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, ThemeData.dark());

      final counterFinder = find.byKey(const Key('counter_text'));
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
