import 'package:flutter_dynamic_form/bloc/new_car_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewCarState', () {
    const mockBrands = ['Chevy', 'Toyota', 'Honda'];
    final mockBrand = mockBrands[0];
    const mockModels = ['Malibu', 'Impala'];
    final mockModel = mockModels[0];
    const mockYears = ['2008', '2020'];

    group('NewCarState', () {
      test('supports value comparison', () {
        // ignore: prefer_const_constructors
        expect(const NewCarState.initial(), NewCarState.initial());
        expect(
          const NewCarState.brandsLoadInProgress(),
          // ignore: prefer_const_constructors
          NewCarState.brandsLoadInProgress(),
        );
        expect(
          const NewCarState.brandsLoadSuccess(brands: mockBrands),
          const NewCarState.brandsLoadSuccess(brands: mockBrands),
        );
        expect(
          const NewCarState.modelsLoadInProgress(brands: mockBrands),
          const NewCarState.modelsLoadInProgress(brands: mockBrands),
        );
        expect(
          NewCarState.modelsLoadSuccess(
              brands: mockBrands, brand: mockBrand, models: mockModels),
          NewCarState.modelsLoadSuccess(
              brands: mockBrands, brand: mockBrand, models: mockModels),
        );
        expect(
          NewCarState.yearsLoadInProgress(
              brands: mockBrands,
              brand: mockBrand,
              models: mockModels,
              model: mockModel),
          NewCarState.yearsLoadInProgress(
              brands: mockBrands,
              brand: mockBrand,
              models: mockModels,
              model: mockModel),
        );
        expect(
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
          ),
        );
      });
    });
  });
}
