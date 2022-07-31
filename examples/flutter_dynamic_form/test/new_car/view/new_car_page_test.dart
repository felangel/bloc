import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dynamic_form/new_car/new_car.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNewCarRepository extends Mock implements NewCarRepository {}

class MockNewCarBloc extends MockBloc<NewCarEvent, NewCarState>
    implements NewCarBloc {}

extension on WidgetTester {
  Future<void> pumpNewCarPage(NewCarRepository newCarRepository) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepositoryProvider.value(
            value: newCarRepository,
            child: const NewCarPage(),
          ),
        ),
      ),
    );
  }

  Future<void> pumpNewCarForm(NewCarBloc newCarBloc) {
    return pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: newCarBloc,
            child: const NewCarForm(),
          ),
        ),
      ),
    );
  }
}

void main() {
  const brandDropdownButtonKey = Key('newCarForm_brand_dropdownButton');
  const modelDropdownButtonKey = Key('newCarForm_model_dropdownButton');
  const yearDropdownButtonKey = Key('newCarForm_year_dropdownButton');

  late NewCarRepository newCarRepository;
  late NewCarBloc newCarBloc;

  const mockBrands = ['Chevy', 'Toyota', 'Honda'];
  final mockBrand = mockBrands[0];
  const mockModels = ['Malibu', 'Impala'];
  final mockModel = mockModels[0];
  const mockYears = ['2008', '2020'];
  final mockYear = mockYears[0];

  setUp(() {
    newCarRepository = MockNewCarRepository();
    newCarBloc = MockNewCarBloc();
  });

  tearDown(resetMocktailState);

  group('NewCarPage', () {
    testWidgets('renders NewCarForm', (tester) async {
      when(() => newCarRepository.fetchBrands()).thenAnswer(
        (_) async => ['honda'],
      );
      await tester.pumpNewCarPage(newCarRepository);
      expect(find.byType(NewCarForm), findsOneWidget);
      verify(() => newCarRepository.fetchBrands()).called(1);
    });
  });

  group('NewCarForm', () {
    testWidgets('displays SnackBar after a submission', (tester) async {
      when(() => newCarBloc.state).thenReturn(
        const NewCarState.initial().copyWith(
          brand: mockBrand,
          model: mockModel,
          year: mockYear,
        ),
      );
      await tester.pumpNewCarForm(newCarBloc);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Submitted $mockBrand $mockModel $mockYear'),
        findsOneWidget,
      );
    });

    testWidgets('cannot submit blank form', (tester) async {
      when(() => newCarBloc.state).thenReturn(const NewCarState.initial());
      await tester.pumpNewCarForm(newCarBloc);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('can select a brand via DropdownButton', (tester) async {
      when(() => newCarBloc.state).thenReturn(
        const NewCarState.initial().copyWith(brands: mockBrands),
      );
      await tester.pumpNewCarForm(newCarBloc..add(const NewCarFormLoaded()));
      await tester.tap(find.byKey(brandDropdownButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mockBrand).last);
      verify(
        () => newCarBloc.add(NewCarBrandChanged(brand: mockBrand)),
      ).called(1);
    });

    testWidgets('can select a model via DropdownButton', (tester) async {
      when(() => newCarBloc.state).thenReturn(
        const NewCarState.initial().copyWith(models: mockModels),
      );
      await tester.pumpNewCarForm(newCarBloc);
      await tester.tap(find.byKey(modelDropdownButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mockModel).last);
      verify(
        () => newCarBloc.add(NewCarModelChanged(model: mockModel)),
      ).called(1);
    });

    testWidgets('can select a year via DropdownButton', (tester) async {
      when(() => newCarBloc.state).thenReturn(
        const NewCarState.initial().copyWith(years: mockYears),
      );
      await tester.pumpNewCarForm(newCarBloc);
      await tester.tap(find.byKey(yearDropdownButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(mockYear).last);
      verify(() => newCarBloc.add(NewCarYearChanged(year: mockYear))).called(1);
    });
  });
}
