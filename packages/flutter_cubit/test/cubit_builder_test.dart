import 'package:cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class MyThemeApp extends StatefulWidget {
  MyThemeApp({
    Key key,
    @required Cubit<ThemeData> themeCubit,
    @required Function onBuild,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild,
        super(key: key);

  final Cubit<ThemeData> _themeCubit;
  final Function _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState(
        themeCubit: _themeCubit,
        onBuild: _onBuild,
      );
}

class MyThemeAppState extends State<MyThemeApp> {
  MyThemeAppState({
    @required Cubit<ThemeData> themeCubit,
    @required Function onBuild,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild;

  Cubit<ThemeData> _themeCubit;
  final Function _onBuild;

  @override
  Widget build(BuildContext context) {
    return CubitBuilder<Cubit<ThemeData>, ThemeData>(
      cubit: _themeCubit,
      builder: ((context, theme) {
        _onBuild();
        return MaterialApp(
          key: const Key('material_app'),
          theme: theme,
          home: Column(
            children: [
              RaisedButton(
                key: const Key('raised_button_1'),
                onPressed: () {
                  setState(() => _themeCubit = DarkThemeCubit());
                },
              ),
              RaisedButton(
                key: const Key('raised_button_2'),
                onPressed: () {
                  setState(() => _themeCubit = _themeCubit);
                },
              ),
            ],
          ),
        );
      }),
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
            CubitBuilder<CounterCubit, int>(
              cubit: _cubit,
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
            CubitBuilder<CounterCubit, int>(
              cubit: _cubit,
              builder: (context, count) {
                return Text(
                  '$count',
                  key: const Key('myCounterAppText'),
                );
              },
            ),
            RaisedButton(
              key: const Key('myCounterAppIncrementButton'),
              onPressed: _cubit.increment,
            )
          ],
        ),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

void main() {
  group('CubitBuilder', () {
    testWidgets('throws if initialized with null cubit and builder',
        (tester) async {
      try {
        await tester.pumpWidget(
          CubitBuilder<ThemeCubit, ThemeData>(
            cubit: null,
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with null builder', (tester) async {
      try {
        await tester.pumpWidget(
          CubitBuilder<ThemeCubit, ThemeData>(
            cubit: ThemeCubit(),
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

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
        CubitProvider.value(
          value: themeCubit,
          child: CubitBuilder<ThemeCubit, ThemeData>(
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

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit and'
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
      await tester.pumpWidget(MyCounterApp());
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
  });
}
