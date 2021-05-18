import 'package:flutter_dynamic_form/bloc/new_car_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewCarEvent', () {
    group('NewCarFormLoaded', () {
      test('supports value comparison', () {
        expect(const NewCarFormLoaded(), const NewCarFormLoaded());
      });
    });

    group('NewCarBrandChanged', () {
      final mockCarBrand = 'Chevy';
      test('supports value comparison', () {
        expect(const NewCarBrandChanged(), const NewCarBrandChanged());
        expect(
          NewCarBrandChanged(brand: mockCarBrand),
          NewCarBrandChanged(brand: mockCarBrand),
        );
      });
    });

    group('NewCarModelChanged', () {
      final mockCarModel = 'Malibu';
      test('supports value comparison', () {
        expect(const NewCarModelChanged(), const NewCarModelChanged());
        expect(
          NewCarModelChanged(model: mockCarModel),
          NewCarModelChanged(model: mockCarModel),
        );
      });
    });

    group('NewCarModelChanged', () {
      final mockYear = '2021';
      test('supports value comparison', () {
        expect(const NewCarYearChanged(), const NewCarYearChanged());
        expect(
          NewCarYearChanged(year: mockYear),
          NewCarYearChanged(year: mockYear),
        );
      });
    });
  });
}