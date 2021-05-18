import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dynamic_form/bloc/new_car_bloc.dart';
import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNewCarRepository extends Mock implements NewCarRepository {}

void main() {
  const mockBrands = ['Chevy', 'Toyota', 'Honda'];
  final mockBrand = mockBrands[0];
  const mockModels = ['Malibu', 'Impala'];
  final mockModel = mockModels[0];
  const mockYears = ['2008', '2020'];
  final mockYear = mockYears[0];

  group('NewCarBloc', () {
    late NewCarRepository newCarRepository;

    setUp(() {
      newCarRepository = MockNewCarRepository();
    });

    test('initial state is NewCarState.initial', () {
      expect(
        NewCarBloc(newCarRepository: newCarRepository).state,
        const NewCarState.initial(),
      );
    });

    blocTest<NewCarBloc, NewCarState>(
      'emits brands loading in progress and brands load success',
      build: () {
        when(newCarRepository.fetchBrands).thenAnswer(
          (_) => Future<List<String>>.value(mockBrands)
        );
        return NewCarBloc(newCarRepository: newCarRepository);
      },
      act: (bloc) => bloc.add(const NewCarFormLoaded()),
      expect: () => [
        const NewCarState.brandsLoadInProgress(),
        const NewCarState.brandsLoadSuccess(brands: mockBrands),
      ],
      verify: (_) => verify(newCarRepository.fetchBrands).called(1),
    );

    blocTest<NewCarBloc, NewCarState>(
      'emits models loading in progress and models load success',
      build: () {
        when(() => newCarRepository.fetchModels(brand: mockBrand)).thenAnswer(
          (_) => Future<List<String>>.value(mockModels)
        );
        return NewCarBloc(newCarRepository: newCarRepository);
      },
      act: (bloc) => bloc.add(NewCarBrandChanged(brand: mockBrand)),
      expect: () => [
        NewCarState.modelsLoadInProgress(brands: [], brand: mockBrand),
        NewCarState.modelsLoadSuccess(
          brands: [],
          brand: mockBrand,
          models: mockModels,
        ),
      ],
      verify: (_) => verify(
        () => newCarRepository.fetchModels(brand: mockBrand)
      ).called(1),
    );

    blocTest<NewCarBloc, NewCarState>(
      'emits years loading in progress and year load success',
      build: () {
        when(() => newCarRepository.fetchYears(
          brand: null,
          model: mockModel,
        )).thenAnswer((_) => Future.value(mockYears));
        return NewCarBloc(newCarRepository: newCarRepository);
      },
      act: (bloc) => bloc.add(NewCarModelChanged(model: mockModel)),
      expect: () => [
        NewCarState.yearsLoadInProgress(
          brands: [],
          brand: null,
          models: [],
          model: mockModel,
        ),
        NewCarState.yearsLoadSuccess(
          brands: [],
          brand: null,
          models: [],
          model: mockModel,
          years: mockYears,
        ),
      ],
      verify: (_) => verify(() => newCarRepository.fetchYears(
        brand: null,
        model: mockModel,
      )).called(1),
    );

    blocTest<NewCarBloc, NewCarState>(
      'changes year when NewCarYearChanged is added',
      build: () => NewCarBloc(newCarRepository: newCarRepository),
      act: (bloc) => bloc.add(NewCarYearChanged(year: mockYear)),
      expect: () => [
        const NewCarState.initial().copyWith(year: mockYear)
      ],
    );

    blocTest<NewCarBloc, NewCarState>(
      'full NewCarBloc test',
      build: () {
        when(newCarRepository.fetchBrands).thenAnswer(
          (_) => Future.value(mockBrands)
        );
        when(() => newCarRepository.fetchModels(
          brand: mockBrand,
        )).thenAnswer((_) => Future.value(mockModels));
        when(() => newCarRepository.fetchYears(
          brand: mockBrand,
          model: mockModel,
        )).thenAnswer((_) => Future.value(mockYears));
        return NewCarBloc(newCarRepository: newCarRepository);
      },
      act: (bloc) => bloc
        ..add(const NewCarFormLoaded())
        ..add(NewCarBrandChanged(brand: mockBrand))
        ..add(NewCarModelChanged(model: mockModel))
        ..add(NewCarYearChanged(year: mockYear)),
      expect: () => [
        const NewCarState.brandsLoadInProgress(),
        const NewCarState.brandsLoadSuccess(brands: mockBrands),
        NewCarState.modelsLoadInProgress(brands: mockBrands, brand: mockBrand),
        NewCarState.modelsLoadSuccess(
          brands: mockBrands,
          brand: mockBrand,
          models: mockModels,
        ),
        NewCarState.yearsLoadInProgress(
          brands: mockBrands,
          brand: mockBrand,
          models: mockModels,
          model: mockModel,
        ),
        NewCarState.yearsLoadSuccess(
          brands: mockBrands,
          brand: mockBrand,
          models: mockModels,
          model: mockModel,
          years: mockYears,
        ),
        NewCarState(
          brands: mockBrands,
          brand: mockBrand,
          models: mockModels,
          model: mockModel,
          years: mockYears,
          year: mockYear,
        )
      ],
      verify: (_) => verifyInOrder([
        newCarRepository.fetchBrands,
        () => newCarRepository.fetchModels(brand: mockBrand),
        () => newCarRepository.fetchYears(
          brand: mockBrand,
          model: mockModel,
        ),
      ]),
    );
  });
}