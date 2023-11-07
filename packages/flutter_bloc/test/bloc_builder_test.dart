import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class MyThemeApp extends StatefulWidget {
  const MyThemeApp({
    required Cubit<ThemeData> themeCubit,
    required void Function() onBuild,
    Key? key,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild,
        super(key: key);

  final Cubit<ThemeData> _themeCubit;
  final void Function() _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState();
}

class MyThemeAppState extends State<MyThemeApp> {
  MyThemeAppState();

  @override
  void initState() {
    super.initState();
    _themeCubit = widget._themeCubit;
    _onBuild = widget._onBuild;
  }

  late Cubit<ThemeData> _themeCubit;
  late final void Function() _onBuild;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Cubit<ThemeData>, ThemeData>(
      bloc: _themeCubit,
      builder: (context, theme) {
        _onBuild();
        return MaterialApp(
          key: const Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              ElevatedButton(
                key: const Key('raised_button_1'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _themeCubit = DarkThemeCubit());
                },
              ),
              ElevatedButton(
                key: const Key('raised_button_2'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _themeCubit = _themeCubit);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(ThemeData.light());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class DarkThemeCubit extends Cubit<ThemeData> {
  DarkThemeCubit() : super(ThemeData.dark());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class MyCounterApp extends StatefulWidget {
  const MyCounterApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  final CounterCubit _cubit = CounterCubit();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key('myCounterApp'),
        body: Column(
          children: <Widget>[
            BlocBuilder<CounterCubit, int>(
              bloc: _cubit,
              buildWhen: (previousState, state) {
                return (previousState + state) % 3 == 0;
              },
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppTextCondition'),
                );
              },
            ),
            BlocBuilder<CounterCubit, int>(
              bloc: _cubit,
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppText'),
                );
              },
            ),
            ElevatedButton(
              key: const Key('myCounterAppIncrementButton'),
              onPressed: _cubit.increment,
              child: const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

void main() {
  group('BlocBuilder', () {
    testWidgets('passes initial state to widget', (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      themeCubit.setDarkTheme();

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'infers the cubit from the context if the cubit is not provided',
        (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        BlocProvider.value(
          value: themeCubit,
          child: BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, theme) {
              numBuilds++;
              return MaterialApp(
                key: const Key('material_app'),
                theme: theme,
                home: const SizedBox(),
              );
            },
          ),
        ),
      );

      themeCubit.setDarkTheme();

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();

      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('updates cubit and performs new lookup when widget is updated',
        (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => BlocProvider.value(
            value: themeCubit,
            child: BlocBuilder<ThemeCubit, ThemeData>(
              builder: (context, theme) {
                numBuilds++;
                return MaterialApp(
                  key: const Key('material_app'),
                  theme: theme,
                  home: ElevatedButton(
                    child: const SizedBox(),
                    onPressed: () => setState(() {}),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 2);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit and '
        'unsubscribes from old cubit', (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_1')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      final themeCubit = DarkThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_2')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final themeCubit = ThemeCubit()..setDarkTheme();
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('with buildWhen only rebuilds when buildWhen evaluates to true',
        (tester) async {
      await tester.pumpWidget(const MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder =
          find.byKey(const Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final counterText1 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText1.data, '0');

      final conditionalCounterText1 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText2 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText2.data, '1');

      final conditionalCounterText2 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText3 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText3.data, '2');

      final conditionalCounterText3 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText4 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText4.data, '3');

      final conditionalCounterText4 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText4.data, '2');
    });

    testWidgets('calls buildWhen and builder with correct state',
        (tester) async {
      final buildWhenPreviousState = <int>[];
      final buildWhenCurrentState = <int>[];
      final states = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        BlocBuilder<CounterCubit, int>(
          bloc: counterCubit,
          buildWhen: (previous, state) {
            if (state.isEven) {
              buildWhenPreviousState.add(previous);
              buildWhenCurrentState.add(state);
              return true;
            }
            return false;
          },
          builder: (_, state) {
            states.add(state);
            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pumpAndSettle();

      expect(states, [0, 2]);
      expect(buildWhenPreviousState, [1]);
      expect(buildWhenCurrentState, [2]);
    });

    testWidgets(
        'does not rebuild with latest state when '
        'buildWhen is false and widget is updated', (tester) async {
      const key = Key('__target__');
      final states = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) => BlocBuilder<CounterCubit, int>(
              bloc: counterCubit,
              buildWhen: (previous, state) => state.isEven,
              builder: (_, state) {
                states.add(state);
                return ElevatedButton(
                  key: key,
                  child: const SizedBox(),
                  onPressed: () => setState(() {}),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pumpAndSettle();
      expect(states, [0, 2]);

      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
      expect(states, [0, 2, 2]);
    });

    testWidgets('rebuilds when provided bloc is changed', (tester) async {
      final firstCounterCubit = CounterCubit();
      final secondCounterCubit = CounterCubit(seed: 100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: firstCounterCubit,
            child: BlocBuilder<CounterCubit, int>(
              builder: (context, state) => Text('Count $state'),
            ),
          ),
        ),
      );

      expect(find.text('Count 0'), findsOneWidget);

      firstCounterCubit.increment();
      await tester.pumpAndSettle();
      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Count 0'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: secondCounterCubit,
            child: BlocBuilder<CounterCubit, int>(
              builder: (context, state) => Text('Count $state'),
            ),
          ),
        ),
      );

      expect(find.text('Count 100'), findsOneWidget);
      expect(find.text('Count 1'), findsNothing);

      secondCounterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 101'), findsOneWidget);
    });
  });
}
