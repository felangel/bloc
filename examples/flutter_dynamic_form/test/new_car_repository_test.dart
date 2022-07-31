import 'package:flutter_dynamic_form/new_car_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewCarRepository', () {
    late NewCarRepository newCarRepository;

    setUp(() {
      newCarRepository = NewCarRepository();
    });

    group('fetchBrands', () {
      test('returns car brands', () async {
        expect(
          newCarRepository.fetchBrands(),
          completion(
            equals(['Chevy', 'Toyota', 'Honda']),
          ),
        );
      });
    });

    group('fetchModels', () {
      test('returns Chevy models', () async {
        expect(
          newCarRepository.fetchModels(brand: 'Chevy'),
          completion(equals(['Malibu', 'Impala'])),
        );
      });
      test('returns Toyota models', () async {
        expect(
          newCarRepository.fetchModels(brand: 'Toyota'),
          completion(equals(['Corolla', 'Supra'])),
        );
      });
      test('returns Honda models', () async {
        expect(
          newCarRepository.fetchModels(brand: 'Honda'),
          completion(equals(['Civic', 'Accord'])),
        );
      });
      test('returns no models', () async {
        expect(
          newCarRepository.fetchModels(brand: 'Fake-Brand'),
          completion(equals(<String>[])),
        );
      });
    });

    group('fetchYears', () {
      group('Chevy brand', () {
        const brand = 'Chevy';
        test('returns years on Malibu model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Malibu'),
            completion(equals(['2019', '2018'])),
          );
        });
        test('returns years on Impala model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Impala'),
            completion(equals(['2017', '2016'])),
          );
        });
        test('returns no years on non-existent model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Fake-Model'),
            completion(equals(<String>[])),
          );
        });
      });

      group('Toyota brand', () {
        const brand = 'Toyota';
        test('returns years on Corolla model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Corolla'),
            completion(equals(['2015', '2014'])),
          );
        });
        test('returns years on Supra model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Supra'),
            completion(equals(['2013', '2012'])),
          );
        });
        test('returns no years on non-existent model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Fake-Model'),
            completion(equals(<String>[])),
          );
        });
      });

      group('Honda brand', () {
        const brand = 'Honda';
        test('returns years on Civic model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Civic'),
            completion(equals(['2011', '2010'])),
          );
        });
        test('returns years on Accord model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Accord'),
            completion(equals(['2009', '2008'])),
          );
        });
        test('returns no years on non-existent model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Fake-Model'),
            completion(equals(<String>[])),
          );
        });
      });
      group('No brand', () {
        const brand = 'Fake-Brand';
        test('returns no years on non-existent model', () {
          expect(
            newCarRepository.fetchYears(brand: brand, model: 'Fake-Model'),
            completion(equals(<String>[])),
          );
        });
      });
    });
  });
}
