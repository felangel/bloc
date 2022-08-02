// ignore_for_file: prefer_const_constructors
import 'package:flutter_dynamic_form/new_car/new_car.dart';
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
        expect(NewCarState.initial(), NewCarState.initial());
        expect(
          NewCarState.brandsLoadInProgress(),
          NewCarState.brandsLoadInProgress(),
        );
        expect(
          NewCarState.brandsLoadSuccess(brands: mockBrands),
          NewCarState.brandsLoadSuccess(brands: mockBrands),
        );
        expect(
          NewCarState.modelsLoadInProgress(brands: mockBrands),
          NewCarState.modelsLoadInProgress(brands: mockBrands),
        );
        expect(
          NewCarState.modelsLoadSuccess(
            brands: mockBrands,
            brand: mockBrand,
            models: mockModels,
          ),
          NewCarState.modelsLoadSuccess(
            brands: mockBrands,
            brand: mockBrand,
            models: mockModels,
          ),
        );
        expect(
          NewCarState.yearsLoadInProgress(
            brands: mockBrands,
            brand: mockBrand,
            models: mockModels,
            model: mockModel,
          ),
          NewCarState.yearsLoadInProgress(
            brands: mockBrands,
            brand: mockBrand,
            models: mockModels,
            model: mockModel,
          ),
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
