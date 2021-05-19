// ignore_for_file: prefer_const_constructors
import 'package:flutter_dynamic_form/new_car/new_car.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewCarEvent', () {
    group('NewCarFormLoaded', () {
      test('supports value comparison', () {
        expect(NewCarFormLoaded(), NewCarFormLoaded());
      });
    });

    group('NewCarBrandChanged', () {
      const mockCarBrand = 'Chevy';
      test('supports value comparison', () {
        expect(NewCarBrandChanged(), NewCarBrandChanged());
        expect(
          NewCarBrandChanged(brand: mockCarBrand),
          NewCarBrandChanged(brand: mockCarBrand),
        );
      });
    });

    group('NewCarModelChanged', () {
      const mockCarModel = 'Malibu';
      test('supports value comparison', () {
        expect(NewCarModelChanged(), NewCarModelChanged());
        expect(
          NewCarModelChanged(model: mockCarModel),
          NewCarModelChanged(model: mockCarModel),
        );
      });
    });

    group('NewCarYearChanged', () {
      const mockYear = '2021';
      test('supports value comparison', () {
        expect(NewCarYearChanged(), NewCarYearChanged());
        expect(
          NewCarYearChanged(year: mockYear),
          NewCarYearChanged(year: mockYear),
        );
      });
    });
  });
}
