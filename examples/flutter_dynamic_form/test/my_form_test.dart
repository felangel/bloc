import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_form/bloc/new_car_bloc.dart';
import 'package:flutter_dynamic_form/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockNewCarBloc extends MockBloc<NewCarEvent, NewCarState>
  implements NewCarBloc {}

class FakeNewCarEvent extends Fake implements NewCarEvent {}
class FakeNewCarState extends Fake implements NewCarState {}

extension on WidgetTester {
  Future<void> pumpMyForm(NewCarBloc newCarBloc) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: newCarBloc,
            child: MyForm(),
          )
        ),
      ),
    );
  }
}

const _brandDropdownButtonKey = Key('myForm_onBrandChanged');
const _modelDropdownButtonKey = Key('myForm_onModelChanged');
const _yearDropdownButtonKey = Key('myForm_onYearChanged');

void main() {
  late NewCarBloc newCarBloc;

  const mockBrands = ['Chevy', 'Toyota', 'Honda'];
  final mockBrand = mockBrands[0];
  const mockModels = ['Malibu', 'Impala'];
  final mockModel = mockModels[0];
  const mockYears = ['2008', '2020'];
  final mockYear = mockYears[0];

  setUpAll(() {
    registerFallbackValue<NewCarState>(FakeNewCarState());
    registerFallbackValue<NewCarEvent>(FakeNewCarEvent());
    newCarBloc = MockNewCarBloc();
  });

  group('MyForm', () {
    testWidgets('loads car form', (tester) async {
      when(() => newCarBloc.state).thenReturn(const NewCarState.initial());
      await tester.pumpMyForm(newCarBloc..add(const NewCarFormLoaded()));
      verify(() => newCarBloc.add(const NewCarFormLoaded())).called(1);
    });

    testWidgets('can submit new car form and displays SnackBar',
      (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          brand: mockBrand,
          model: mockModel,
          year: mockYear,
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(
        'Submitted $mockBrand $mockModel $mockYear'),
        findsOneWidget,
      );
    });

    testWidgets('cannot submit new car form', (tester) async {
      when(() => newCarBloc.state).thenReturn(const NewCarState.initial());
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('selects car brand under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(brands: mockBrands));
      await tester.pumpMyForm(newCarBloc..add(const NewCarFormLoaded()));
      await tester.tap(find.byKey(_brandDropdownButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mockBrand).first);
      verify(
        () => newCarBloc.add(NewCarBrandChanged(brand: mockBrand))
      ).called(1);
    });

    testWidgets('selects car model under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          models: mockModels,
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.byKey(_modelDropdownButtonKey));
      await tester.pump(const Duration(seconds: 1));
      print(mockModel);
      await tester.tap(find.text(mockModel).first);
      verify(
        () => newCarBloc.add(NewCarModelChanged(model: mockModel))
      ).called(1);
    });

    testWidgets('selects year under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          years: mockYears,
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.byKey(_yearDropdownButtonKey));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text(mockYear).first);
      verify(
        () => newCarBloc.add(NewCarYearChanged(year: mockYear))
      ).called(1);
    });


    testWidgets('finds no brands under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          brands: [],
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.byKey(_brandDropdownButtonKey));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DropdownMenuItem), findsNothing);
    });

    testWidgets('finds no models under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          models: [],
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.byKey(_modelDropdownButtonKey));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DropdownMenuItem), findsNothing);
    });

    testWidgets('finds no years under DropdownButton', (tester) async {
      when(() => newCarBloc.state)
        .thenReturn(const NewCarState.initial().copyWith(
          years: [],
      ));
      await tester.pumpMyForm(newCarBloc);
      await tester.tap(find.byKey(_yearDropdownButtonKey));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DropdownMenuItem), findsNothing);
    });
  });
}