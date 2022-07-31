import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_dynamic_form/new_car/new_car.dart';
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
      setUp: () {
        when(newCarRepository.fetchBrands).thenAnswer((_) async => mockBrands);
      },
      build: () => NewCarBloc(newCarRepository: newCarRepository),
      act: (bloc) => bloc.add(const NewCarFormLoaded()),
      expect: () => [
        const NewCarState.brandsLoadInProgress(),
        const NewCarState.brandsLoadSuccess(brands: mockBrands),
      ],
      verify: (_) => verify(newCarRepository.fetchBrands).called(1),
    );

    blocTest<NewCarBloc, NewCarState>(
      'emits models loading in progress and models load success',
      setUp: () {
        when(
          () => newCarRepository.fetchModels(brand: mockBrand),
        ).thenAnswer((_) async => mockModels);
      },
      build: () => NewCarBloc(newCarRepository: newCarRepository),
      act: (bloc) => bloc.add(NewCarBrandChanged(brand: mockBrand)),
      expect: () => [
        NewCarState.modelsLoadInProgress(brands: const [], brand: mockBrand),
        NewCarState.modelsLoadSuccess(
          brands: const [],
          brand: mockBrand,
          models: mockModels,
        ),
      ],
      verify: (_) {
        verify(() => newCarRepository.fetchModels(brand: mockBrand)).called(1);
      },
    );

    blocTest<NewCarBloc, NewCarState>(
      'emits years loading in progress and year load success',
      setUp: () {
        when(
          () => newCarRepository.fetchYears(model: mockModel),
        ).thenAnswer((_) async => mockYears);
      },
      build: () => NewCarBloc(newCarRepository: newCarRepository),
      act: (bloc) => bloc.add(NewCarModelChanged(model: mockModel)),
      expect: () => [
        NewCarState.yearsLoadInProgress(
          brands: const [],
          brand: null,
          models: const [],
          model: mockModel,
        ),
        NewCarState.yearsLoadSuccess(
          brands: const [],
          brand: null,
          models: const [],
          model: mockModel,
          years: mockYears,
        ),
      ],
      verify: (_) {
        verify(
          () => newCarRepository.fetchYears(model: mockModel),
        ).called(1);
      },
    );

    blocTest<NewCarBloc, NewCarState>(
      'changes year when NewCarYearChanged is added',
      build: () => NewCarBloc(newCarRepository: newCarRepository),
      act: (bloc) => bloc.add(NewCarYearChanged(year: mockYear)),
      expect: () => [const NewCarState.initial().copyWith(year: mockYear)],
    );

    blocTest<NewCarBloc, NewCarState>(
      'emits correct states when complete flow is executed',
      setUp: () {
        when(
          newCarRepository.fetchBrands,
        ).thenAnswer((_) => Future.value(mockBrands));
        when(
          () => newCarRepository.fetchModels(brand: mockBrand),
        ).thenAnswer((_) => Future.value(mockModels));
        when(
          () => newCarRepository.fetchYears(brand: mockBrand, model: mockModel),
        ).thenAnswer((_) => Future.value(mockYears));
      },
      build: () => NewCarBloc(newCarRepository: newCarRepository),
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
        NewCarState.yearsLoadSuccess(
          brands: mockBrands,
          brand: mockBrand,
          models: mockModels,
          model: mockModel,
          years: mockYears,
        ).copyWith(year: mockYear)
      ],
      verify: (_) => verifyInOrder([
        newCarRepository.fetchBrands,
        () => newCarRepository.fetchModels(brand: mockBrand),
        () => newCarRepository.fetchYears(brand: mockBrand, model: mockModel),
      ]),
    );
  });
}
