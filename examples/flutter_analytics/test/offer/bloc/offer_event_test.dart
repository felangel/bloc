// ignore_for_file: prefer_const_constructors
import 'package:flutter_analytics/offer/offer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_repository/shopping_repository.dart';

void main() {
  const product = Product(
    id: 0,
    name: 'name',
    description: 'description',
  );

  const offer = Offer(
    id: 0,
    product: product,
    title: 'name',
    subtitle: 'subtitle',
    description: 'description',
  );

  group('OfferEvent', () {
    group('OfferStarted', () {
      test('supports value comparison', () {
        expect(
          OfferStarted(),
          OfferStarted(),
        );
      });
    });

    group('OfferSelected', () {
      test('supports value comparison', () {
        expect(
          OfferSelected(offer),
          OfferSelected(offer),
        );
      });

      test('has event name', () {
        expect(
          OfferSelected(offer).eventName,
          isNotEmpty,
        );
      });

      test('has event parameters', () {
        expect(
          OfferSelected(offer).parameters,
          isMap.having(
            (map) => map.isNotEmpty,
            'is not empty',
            true,
          ),
        );
      });
    });
  });
}
